extends Control
## Always-visible hotbar at the bottom of the screen. Shows 10 item slots
## with key binding labels and highlights the currently selected slot.

var _slots: Array[ItemSlot] = []
var _container: HBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_ui()
	_connect_signals()
	_refresh_all_slots()


func _build_ui() -> void:
	# Anchor to bottom-center
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	anchor_top = 1.0
	anchor_bottom = 1.0
	anchor_left = 0.5
	anchor_right = 0.5

	# Background panel
	var bg := PanelContainer.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	bg_style.set_corner_radius_all(2)
	bg_style.set_content_margin_all(2.0)
	bg.add_theme_stylebox_override("panel", bg_style)
	add_child(bg)

	# HBox for slots
	_container = HBoxContainer.new()
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_theme_constant_override("separation", 2)
	bg.add_child(_container)

	# Create 10 slots
	var slot_scene := preload("res://scenes/ui/ItemSlot.tscn")
	for i in range(Constants.HOTBAR_SLOTS):
		var slot: ItemSlot = slot_scene.instantiate() as ItemSlot
		slot.slot_index = i
		# Key label: 1-9 then 0
		var key_text := str((i + 1) % 10)
		slot.set_key_label(key_text)
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_shift_clicked.connect(_on_slot_shift_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_exited.connect(_on_slot_exited)
		_container.add_child(slot)
		_slots.append(slot)

	# Position: compute total width and offset
	var total_width := Constants.HOTBAR_SLOTS * 18 + (Constants.HOTBAR_SLOTS - 1) * 2 + 4
	var total_height := 18 + 4
	bg.position = Vector2(-total_width / 2.0, -total_height - 4)
	bg.size = Vector2(total_width, total_height)

	# Set initial selection highlight
	_update_selection(InventoryManager.selected_hotbar_slot)


func _connect_signals() -> void:
	# Listen for hotbar data changes
	InventoryManager.hotbar.slot_changed.connect(_on_hotbar_slot_changed)
	SignalBus.hotbar_slot_changed.connect(_on_selected_slot_changed)


func _on_hotbar_slot_changed(index: int) -> void:
	if index >= 0 and index < _slots.size():
		_slots[index].set_item_data(InventoryManager.hotbar.get_slot(index))


func _on_selected_slot_changed(slot_index: int) -> void:
	_update_selection(slot_index)


func _update_selection(selected: int) -> void:
	for i in range(_slots.size()):
		_slots[i].set_selected(i == selected)


func _refresh_all_slots() -> void:
	for i in range(_slots.size()):
		_slots[i].set_item_data(InventoryManager.hotbar.get_slot(i))
	_update_selection(InventoryManager.selected_hotbar_slot)


# ── Slot Interactions ──────────────────────────────────────────────────────

func _on_slot_clicked(index: int, _button: int) -> void:
	# During INVENTORY state: click to interact with held item
	if GameManager.current_state != Enums.GameState.INVENTORY:
		return

	var hb := InventoryManager.hotbar

	if InventoryManager.has_held_item():
		var held := InventoryManager.get_held_item()
		if hb.is_slot_empty(index):
			hb.set_slot(index, held["item_id"], int(held["quantity"]), int(held["quality"]))
			InventoryManager.clear_held_item()
		else:
			var slot_data := hb.get_slot(index)
			if slot_data["item_id"] == held["item_id"] and int(slot_data["quality"]) == int(held["quality"]):
				var stack_max: int = ItemDatabase.get_stack_max(held["item_id"])
				var space: int = stack_max - int(slot_data["quantity"])
				if space > 0:
					var to_add := mini(int(held["quantity"]), space)
					hb.set_slot(index, slot_data["item_id"],
						int(slot_data["quantity"]) + to_add, int(slot_data["quality"]))
					var leftover: int = int(held["quantity"]) - to_add
					if leftover > 0:
						InventoryManager.set_held_item(held["item_id"], leftover, int(held["quality"]))
					else:
						InventoryManager.clear_held_item()
				else:
					# Swap
					hb.set_slot(index, held["item_id"], int(held["quantity"]), int(held["quality"]))
					InventoryManager.set_held_item(slot_data["item_id"], int(slot_data["quantity"]), int(slot_data["quality"]))
			else:
				# Different item — swap
				hb.set_slot(index, held["item_id"], int(held["quantity"]), int(held["quality"]))
				InventoryManager.set_held_item(slot_data["item_id"], int(slot_data["quantity"]), int(slot_data["quality"]))
	else:
		if not hb.is_slot_empty(index):
			var slot_data := hb.get_slot(index)
			InventoryManager.set_held_item(
				slot_data["item_id"], int(slot_data["quantity"]), int(slot_data["quality"]))
			hb.clear_slot(index)


func _on_slot_shift_clicked(index: int) -> void:
	# Shift-click: transfer from hotbar to main inventory
	if GameManager.current_state != Enums.GameState.INVENTORY:
		return

	var hb := InventoryManager.hotbar
	if hb.is_slot_empty(index):
		return

	var slot_data := hb.get_slot(index)
	var overflow := InventoryManager.main_inventory.add_item(
		slot_data["item_id"],
		int(slot_data["quantity"]),
		int(slot_data["quality"])
	)

	if overflow < int(slot_data["quantity"]):
		if overflow > 0:
			hb.set_slot(index, slot_data["item_id"], overflow, int(slot_data["quality"]))
		else:
			hb.clear_slot(index)


func _on_slot_hovered(index: int) -> void:
	var hb := InventoryManager.hotbar
	if not hb.is_slot_empty(index):
		var slot_data := hb.get_slot(index)
		var mouse_pos := get_global_mouse_position()
		SignalBus.tooltip_requested.emit(slot_data["item_id"], mouse_pos)


func _on_slot_exited(_index: int) -> void:
	SignalBus.tooltip_hidden.emit()
