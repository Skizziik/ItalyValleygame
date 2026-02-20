extends Control
## Full inventory panel. Shows 6x6 grid with filter tabs, sort buttons,
## click/right-click/shift-click interactions, and cursor-held item.

const GRID_COLS := 6

var _slots: Array[ItemSlot] = []
var _grid: GridContainer
var _cursor_item_display: ColorRect
var _cursor_label: Label
var _active_filter: String = ""  # "" = show all

# Filter tab buttons
var _filter_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP

	_build_ui()
	_connect_signals()
	_refresh_all_slots()

	visibility_changed.connect(_on_visibility_changed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Close inventory with I or Escape
	if event.is_pressed() and not event.is_echo():
		if event.is_action("inventory") or event.is_action("pause"):
			_close_inventory()
			get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not visible:
		return
	# Keep cursor display in sync with InventoryManager held item state
	_update_cursor_display()
	# Update cursor-held item position
	if _cursor_item_display and _cursor_item_display.visible:
		_cursor_item_display.global_position = get_global_mouse_position() + Vector2(2, 2)


func _close_inventory() -> void:
	GameManager.return_to_previous_state()


# ── UI Construction ────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Full screen overlay to catch clicks outside the panel
	var click_catcher := ColorRect.new()
	click_catcher.color = Color(0, 0, 0, 0.4)
	click_catcher.anchors_preset = Control.PRESET_FULL_RECT
	click_catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	click_catcher.gui_input.connect(_on_background_click)
	add_child(click_catcher)

	# Main panel (centered via direct position, no anchors)
	var panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	panel_style.set_corner_radius_all(3)
	panel_style.set_content_margin_all(4.0)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color(0.4, 0.4, 0.4)
	panel.add_theme_stylebox_override("panel", panel_style)

	var panel_width := GRID_COLS * 18 + (GRID_COLS - 1) * 2 + 8
	var panel_height := 180
	panel.position = Vector2(
		(Constants.VIEWPORT_WIDTH - panel_width) / 2.0,
		(Constants.VIEWPORT_HEIGHT - panel_height) / 2.0
	)
	panel.size = Vector2(panel_width, panel_height)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Inventory"
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 7)
	close_btn.custom_minimum_size = Vector2(12, 12)
	close_btn.pressed.connect(_close_inventory)
	header.add_child(close_btn)

	# Filter tabs
	var filter_bar := HBoxContainer.new()
	filter_bar.add_theme_constant_override("separation", 1)
	vbox.add_child(filter_bar)

	var filters := ["All", "Tool", "Mat.", "Seed", "Crop", "Fish", "Food"]
	var filter_categories := ["", "TOOL", "MATERIAL", "SEED", "CROP", "FISH", "FOOD"]

	for i in range(filters.size()):
		var btn := Button.new()
		btn.text = filters[i]
		btn.add_theme_font_size_override("font_size", 6)
		btn.custom_minimum_size = Vector2(0, 10)
		btn.toggle_mode = true
		btn.button_pressed = (i == 0)
		var cat: String = filter_categories[i]
		btn.pressed.connect(_on_filter_pressed.bind(cat, btn))
		filter_bar.add_child(btn)
		_filter_buttons[cat] = btn

	# Inventory grid
	_grid = GridContainer.new()
	_grid.columns = GRID_COLS
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	vbox.add_child(_grid)

	var slot_scene := preload("res://scenes/ui/ItemSlot.tscn")
	for i in range(Constants.INVENTORY_SIZE):
		var slot: ItemSlot = slot_scene.instantiate() as ItemSlot
		slot.slot_index = i
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_right_clicked.connect(_on_slot_right_clicked)
		slot.slot_shift_clicked.connect(_on_slot_shift_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_exited.connect(_on_slot_exited)
		_grid.add_child(slot)
		_slots.append(slot)

	# Sort bar
	var sort_bar := HBoxContainer.new()
	sort_bar.add_theme_constant_override("separation", 2)
	vbox.add_child(sort_bar)

	var sort_cat_btn := Button.new()
	sort_cat_btn.text = "Sort: Category"
	sort_cat_btn.add_theme_font_size_override("font_size", 6)
	sort_cat_btn.custom_minimum_size = Vector2(0, 10)
	sort_cat_btn.pressed.connect(_on_sort_category)
	sort_bar.add_child(sort_cat_btn)

	var sort_name_btn := Button.new()
	sort_name_btn.text = "Sort: Name"
	sort_name_btn.add_theme_font_size_override("font_size", 6)
	sort_name_btn.custom_minimum_size = Vector2(0, 10)
	sort_name_btn.pressed.connect(_on_sort_name)
	sort_bar.add_child(sort_name_btn)

	# Cursor-held item display
	_cursor_item_display = ColorRect.new()
	_cursor_item_display.custom_minimum_size = Vector2(14, 14)
	_cursor_item_display.size = Vector2(14, 14)
	_cursor_item_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cursor_item_display.visible = false
	_cursor_item_display.modulate.a = 0.8
	add_child(_cursor_item_display)

	_cursor_label = Label.new()
	_cursor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cursor_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cursor_label.size = Vector2(14, 14)
	_cursor_label.add_theme_font_size_override("font_size", 7)
	_cursor_label.add_theme_color_override("font_color", Color.WHITE)
	_cursor_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cursor_item_display.add_child(_cursor_label)


func _connect_signals() -> void:
	InventoryManager.main_inventory.slot_changed.connect(_on_inventory_slot_changed)


# ── Slot Interactions ──────────────────────────────────────────────────────

func _on_slot_clicked(index: int, _button: int) -> void:
	var inv := InventoryManager.main_inventory

	if InventoryManager.has_held_item():
		# Place held item
		var held := InventoryManager.get_held_item()

		if inv.is_slot_empty(index):
			# Place into empty slot
			inv.set_slot(index, held["item_id"], int(held["quantity"]), int(held["quality"]))
			InventoryManager.clear_held_item()
		else:
			var slot_data := inv.get_slot(index)
			if slot_data["item_id"] == held["item_id"] and int(slot_data["quality"]) == int(held["quality"]):
				# Merge with existing stack
				var stack_max: int = ItemDatabase.get_stack_max(held["item_id"])
				var space: int = stack_max - int(slot_data["quantity"])
				if space > 0:
					var to_add := mini(int(held["quantity"]), space)
					inv.set_slot(index, slot_data["item_id"],
						int(slot_data["quantity"]) + to_add, int(slot_data["quality"]))
					var leftover: int = int(held["quantity"]) - to_add
					if leftover > 0:
						InventoryManager.set_held_item(held["item_id"], leftover, int(held["quality"]))
					else:
						InventoryManager.clear_held_item()
				else:
					# Stack full — swap
					_swap_with_held(index)
			else:
				# Different item — swap
				_swap_with_held(index)
	else:
		# Pick up item from slot
		if not inv.is_slot_empty(index):
			var slot_data := inv.get_slot(index)
			InventoryManager.set_held_item(
				slot_data["item_id"],
				int(slot_data["quantity"]),
				int(slot_data["quality"])
			)
			inv.clear_slot(index)

	_update_cursor_display()


func _on_slot_right_clicked(index: int) -> void:
	var inv := InventoryManager.main_inventory

	if InventoryManager.has_held_item():
		# Place one item from held stack
		var held := InventoryManager.get_held_item()
		if inv.is_slot_empty(index):
			inv.set_slot(index, held["item_id"], 1, int(held["quality"]))
			var remaining: int = int(held["quantity"]) - 1
			if remaining > 0:
				InventoryManager.set_held_item(held["item_id"], remaining, int(held["quality"]))
			else:
				InventoryManager.clear_held_item()
		elif inv.get_slot(index)["item_id"] == held["item_id"] and int(inv.get_slot(index)["quality"]) == int(held["quality"]):
			var slot_data := inv.get_slot(index)
			var stack_max: int = ItemDatabase.get_stack_max(held["item_id"])
			if int(slot_data["quantity"]) < stack_max:
				inv.set_slot(index, slot_data["item_id"],
					int(slot_data["quantity"]) + 1, int(slot_data["quality"]))
				var remaining: int = int(held["quantity"]) - 1
				if remaining > 0:
					InventoryManager.set_held_item(held["item_id"], remaining, int(held["quality"]))
				else:
					InventoryManager.clear_held_item()
	else:
		# Split stack in half (pick up half)
		if not inv.is_slot_empty(index):
			var slot_data := inv.get_slot(index)
			var total: int = int(slot_data["quantity"])
			if total > 1:
				var take: int = ceili(total / 2.0)
				inv.set_slot(index, slot_data["item_id"], total - take, int(slot_data["quality"]))
				InventoryManager.set_held_item(slot_data["item_id"], take, int(slot_data["quality"]))
			else:
				# Single item — just pick it up
				InventoryManager.set_held_item(
					slot_data["item_id"],
					int(slot_data["quantity"]),
					int(slot_data["quality"])
				)
				inv.clear_slot(index)

	_update_cursor_display()


func _on_slot_shift_clicked(index: int) -> void:
	# Quick transfer: main inventory <-> hotbar
	var inv := InventoryManager.main_inventory
	if inv.is_slot_empty(index):
		return

	var slot_data := inv.get_slot(index)
	var overflow := InventoryManager.hotbar.add_item(
		slot_data["item_id"],
		int(slot_data["quantity"]),
		int(slot_data["quality"])
	)

	if overflow < int(slot_data["quantity"]):
		# Some or all transferred
		if overflow > 0:
			inv.set_slot(index, slot_data["item_id"], overflow, int(slot_data["quality"]))
		else:
			inv.clear_slot(index)


func _on_slot_hovered(index: int) -> void:
	var inv := InventoryManager.main_inventory
	if not inv.is_slot_empty(index):
		var slot_data := inv.get_slot(index)
		var mouse_pos := get_global_mouse_position()
		SignalBus.tooltip_requested.emit(slot_data["item_id"], mouse_pos)


func _on_slot_exited(_index: int) -> void:
	SignalBus.tooltip_hidden.emit()


func _swap_with_held(index: int) -> void:
	var inv := InventoryManager.main_inventory
	var slot_data := inv.get_slot(index)
	var held := InventoryManager.get_held_item()

	inv.set_slot(index, held["item_id"], int(held["quantity"]), int(held["quality"]))
	InventoryManager.set_held_item(slot_data["item_id"], int(slot_data["quantity"]), int(slot_data["quality"]))


func _on_background_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			# Click outside inventory — close if no held item
			if not InventoryManager.has_held_item():
				_close_inventory()


# ── Display Updates ────────────────────────────────────────────────────────

func _on_inventory_slot_changed(index: int) -> void:
	if index >= 0 and index < _slots.size():
		_update_slot_display(index)


func _update_slot_display(index: int) -> void:
	var slot_data := InventoryManager.main_inventory.get_slot(index)

	# Apply filter
	if _active_filter != "" and slot_data["item_id"] != "":
		var item_info := ItemDatabase.get_item(slot_data["item_id"])
		if item_info.get("category", "") != _active_filter:
			_slots[index].set_item_data(Inventory._empty_slot())
			_slots[index].modulate.a = 0.3
			return

	_slots[index].modulate.a = 1.0
	_slots[index].set_item_data(slot_data)


func _refresh_all_slots() -> void:
	for i in range(_slots.size()):
		_update_slot_display(i)


func _update_cursor_display() -> void:
	if not _cursor_item_display:
		return

	if InventoryManager.has_held_item():
		var held := InventoryManager.get_held_item()
		var item_info := ItemDatabase.get_item(held["item_id"])
		_cursor_item_display.color = ItemSlot.CATEGORY_COLORS.get(
			item_info.get("category", ""), Color.WHITE)
		_cursor_label.text = (held["item_id"] as String).left(2).to_upper()
		_cursor_item_display.visible = true
	else:
		_cursor_item_display.visible = false


# ── Filter & Sort ──────────────────────────────────────────────────────────

func _on_filter_pressed(category: String, pressed_btn: Button) -> void:
	_active_filter = category

	# Update toggle states
	for cat: String in _filter_buttons:
		var btn: Button = _filter_buttons[cat]
		btn.button_pressed = (btn == pressed_btn)

	_refresh_all_slots()


func _on_sort_category() -> void:
	InventoryManager.main_inventory.sort_by_category()
	_refresh_all_slots()


func _on_sort_name() -> void:
	InventoryManager.main_inventory.sort_by_name()
	_refresh_all_slots()


func _on_visibility_changed() -> void:
	if visible:
		_refresh_all_slots()
		_update_cursor_display()
