extends Node
## Player inventory manager. Autoloaded as "InventoryManager".
## Wraps a 36-slot main inventory and 10-slot hotbar.
## Creates and owns the HotbarUI + InventoryUI via a CanvasLayer.

var main_inventory: Inventory
var hotbar: Inventory
var selected_hotbar_slot: int = 0

## Item currently held on the cursor (during drag / click-pick)
var _held_item: Dictionary = Inventory._empty_slot()

## UI references
var _canvas_layer: CanvasLayer
var _hotbar_ui: Control
var _inventory_ui: Control
var _tooltip: Control
var _cursor_icon: Control

var _is_new_game: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	main_inventory = Inventory.new(Constants.INVENTORY_SIZE)
	hotbar = Inventory.new(Constants.HOTBAR_SLOTS)

	_register_hotbar_inputs()
	_create_ui()

	SignalBus.game_state_changed.connect(_on_game_state_changed)
	SignalBus.game_started.connect(_on_game_started)

	# Give starting tools on first load (after a frame so ItemDatabase is ready)
	await get_tree().process_frame
	if _is_new_game:
		_give_starting_items()
		_is_new_game = false


func _unhandled_input(event: InputEvent) -> void:
	# Hotbar slot selection via number keys
	for i in range(10):
		var action_name := "hotbar_%d" % ((i + 1) % 10)
		if event.is_action_pressed(action_name):
			select_hotbar_slot(i)
			get_viewport().set_input_as_handled()
			return

	# Mouse scroll for hotbar cycling
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_hotbar_slot((selected_hotbar_slot - 1 + Constants.HOTBAR_SLOTS) % Constants.HOTBAR_SLOTS)
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_hotbar_slot((selected_hotbar_slot + 1) % Constants.HOTBAR_SLOTS)
			get_viewport().set_input_as_handled()


# ── Public API ─────────────────────────────────────────────────────────────

## Add an item. Tries hotbar first, then main inventory.
## Returns the number of items that could NOT be added (overflow).
func add_item(item_id: String, quantity: int = 1, quality: int = 0) -> int:
	var remaining := hotbar.add_item(item_id, quantity, quality)
	if remaining > 0:
		remaining = main_inventory.add_item(item_id, remaining, quality)

	var added := quantity - remaining
	if added > 0:
		SignalBus.item_added.emit(item_id, added)
		DebugManager.dlog("inventory", "Added %dx %s (overflow: %d)" % [added, item_id, remaining])

	if remaining > 0:
		SignalBus.inventory_full.emit()
		SignalBus.notification_requested.emit("Inventory full!", 2.0)

	return remaining


## Remove an item from both inventories. Returns the amount actually removed.
func remove_item(item_id: String, quantity: int = 1) -> int:
	var removed := hotbar.remove_item(item_id, quantity)
	if removed < quantity:
		removed += main_inventory.remove_item(item_id, quantity - removed)

	if removed > 0:
		SignalBus.item_removed.emit(item_id, removed)
		DebugManager.dlog("inventory", "Removed %dx %s" % [removed, item_id])

	return removed


## Check if the player has at least `quantity` of an item across both inventories.
func has_item(item_id: String, quantity: int = 1) -> bool:
	var total := hotbar.get_item_count(item_id) + main_inventory.get_item_count(item_id)
	return total >= quantity


## Get the total count of an item across both inventories.
func get_item_count(item_id: String) -> int:
	return hotbar.get_item_count(item_id) + main_inventory.get_item_count(item_id)


## Get the item data in the currently selected hotbar slot.
func get_selected_item() -> Dictionary:
	return hotbar.get_slot(selected_hotbar_slot)


## Select a hotbar slot (clamped 0-9).
func select_hotbar_slot(index: int) -> void:
	var clamped := clampi(index, 0, Constants.HOTBAR_SLOTS - 1)
	if clamped == selected_hotbar_slot:
		return
	selected_hotbar_slot = clamped
	SignalBus.hotbar_slot_changed.emit(selected_hotbar_slot)
	DebugManager.dlog("inventory", "Hotbar slot: %d" % selected_hotbar_slot)


# ── Held Item (Cursor) ────────────────────────────────────────────────────

func get_held_item() -> Dictionary:
	return _held_item.duplicate()


func set_held_item(item_id: String, quantity: int, quality: int) -> void:
	_held_item = {"item_id": item_id, "quantity": quantity, "quality": quality}


func clear_held_item() -> void:
	_held_item = Inventory._empty_slot()


func has_held_item() -> bool:
	return _held_item["item_id"] != ""


## Return held item to inventory (called when closing inventory with cursor item).
func return_held_item() -> void:
	if not has_held_item():
		return
	var overflow := add_item(_held_item["item_id"], int(_held_item["quantity"]), int(_held_item["quality"]))
	if overflow > 0:
		push_warning("InventoryManager: could not return %d items to inventory" % overflow)
	clear_held_item()


# ── Serialization ──────────────────────────────────────────────────────────

func serialize() -> Dictionary:
	return {
		"main": main_inventory.serialize(),
		"hotbar": hotbar.serialize(),
		"selected_slot": selected_hotbar_slot,
	}


func deserialize(data: Dictionary) -> void:
	_is_new_game = false
	if data.has("main"):
		main_inventory.deserialize(data["main"] as Array)
	if data.has("hotbar"):
		hotbar.deserialize(data["hotbar"] as Array)
	selected_hotbar_slot = int(data.get("selected_slot", 0))
	SignalBus.hotbar_slot_changed.emit(selected_hotbar_slot)


# ── Input Registration ────────────────────────────────────────────────────

func _register_hotbar_inputs() -> void:
	for i in range(10):
		var action_name := "hotbar_%d" % ((i + 1) % 10)
		if InputMap.has_action(action_name):
			continue
		InputMap.add_action(action_name)
		var event := InputEventKey.new()
		if i < 9:
			event.physical_keycode = KEY_1 + i
		else:
			event.physical_keycode = KEY_0
		InputMap.action_add_event(action_name, event)


# ── UI Creation ───────────────────────────────────────────────────────────

func _create_ui() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 50
	_canvas_layer.name = "InventoryLayer"
	add_child(_canvas_layer)

	# UI scenes are loaded after they are created (in later implementation steps).
	# For now, we attempt to load them if they exist.
	_load_ui_scenes()


func _load_ui_scenes() -> void:
	# HotbarUI
	var hotbar_scene := load("res://scenes/ui/HotbarUI.tscn") as PackedScene
	if hotbar_scene:
		_hotbar_ui = hotbar_scene.instantiate() as Control
		_canvas_layer.add_child(_hotbar_ui)

	# InventoryUI
	var inv_scene := load("res://scenes/ui/InventoryUI.tscn") as PackedScene
	if inv_scene:
		_inventory_ui = inv_scene.instantiate() as Control
		_inventory_ui.visible = false
		_canvas_layer.add_child(_inventory_ui)

	# Tooltip
	var tooltip_scene := load("res://scenes/ui/ItemTooltip.tscn") as PackedScene
	if tooltip_scene:
		_tooltip = tooltip_scene.instantiate() as Control
		_tooltip.visible = false
		_canvas_layer.add_child(_tooltip)


# ── State Management ──────────────────────────────────────────────────────

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	var is_playing := new_state == Enums.GameState.PLAYING
	var is_inventory := new_state == Enums.GameState.INVENTORY
	var show_hotbar := new_state in [
		Enums.GameState.PLAYING,
		Enums.GameState.FISHING,
		Enums.GameState.COMBAT,
		Enums.GameState.INVENTORY,
	]

	# Hotbar visibility (also visible during inventory for shift-click transfers)
	if _hotbar_ui:
		_hotbar_ui.visible = show_hotbar

	# Inventory panel visibility
	if _inventory_ui:
		if is_inventory:
			_inventory_ui.visible = true
			SignalBus.inventory_opened.emit()
		elif _inventory_ui.visible:
			# Closing inventory — return held item
			return_held_item()
			_inventory_ui.visible = false
			SignalBus.inventory_closed.emit()

	# Hide tooltip when leaving inventory
	if _tooltip and not is_inventory:
		_tooltip.visible = false


func _on_game_started() -> void:
	_is_new_game = true
	main_inventory.clear_all()
	hotbar.clear_all()
	selected_hotbar_slot = 0
	clear_held_item()
	_give_starting_items()
	_is_new_game = false


# ── Starting Items ─────────────────────────────────────────────────────────

func _give_starting_items() -> void:
	var starting_tools := ["axe", "pickaxe", "hoe", "watering_can", "fishing_rod"]
	for i in range(starting_tools.size()):
		if ItemDatabase.has_item(starting_tools[i]):
			hotbar.set_slot(i, starting_tools[i], 1, Enums.Quality.NORMAL)

	DebugManager.dlog("inventory", "Starting items given: %d tools in hotbar" % starting_tools.size())
