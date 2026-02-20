extends Control
class_name ItemSlot
## Individual inventory slot UI. Displays an item icon (placeholder color),
## quantity label, quality indicator, and optional key label.
## Used by both HotbarUI and InventoryUI.

signal slot_clicked(index: int, button: int)
signal slot_right_clicked(index: int)
signal slot_shift_clicked(index: int)
signal slot_hovered(index: int)
signal slot_exited(index: int)

const SLOT_SIZE := Vector2(18, 18)

const CATEGORY_COLORS: Dictionary = {
	"TOOL": Color(0.5, 0.5, 0.5),
	"MATERIAL": Color(0.55, 0.41, 0.08),
	"SEED": Color(0.18, 0.55, 0.34),
	"CROP": Color(1.0, 0.55, 0.0),
	"FISH": Color(0.27, 0.51, 0.71),
	"FOOD": Color(0.8, 0.36, 0.36),
	"CRAFTED": Color(0.58, 0.44, 0.86),
	"FURNITURE": Color(0.82, 0.71, 0.55),
	"QUEST": Color(1.0, 0.84, 0.0),
	"ARTIFACT": Color(0.85, 0.65, 0.13),
}

const EMPTY_SLOT_COLOR := Color(0.15, 0.15, 0.15, 0.8)
const SLOT_BG_COLOR := Color(0.2, 0.2, 0.2, 0.9)
const SELECTION_COLOR := Color(1.0, 0.9, 0.2, 0.8)
const BORDER_COLOR := Color(0.3, 0.3, 0.3)

var slot_index: int = -1
var _item_data: Dictionary = Inventory._empty_slot()
var _is_selected: bool = false
var _show_key_label: bool = false
var _pending_key_text: String = ""

var _icon_rect: ColorRect
var _letter_label: Label
var _quantity_label: Label
var _quality_indicator: ColorRect
var _key_label: Label
var _selection_highlight: ColorRect
var _bg_color: Color = EMPTY_SLOT_COLOR


func _ready() -> void:
	custom_minimum_size = SLOT_SIZE
	size = SLOT_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	_build_ui()

	# Apply pending key label if set_key_label was called before _ready
	if _pending_key_text != "":
		_key_label.text = _pending_key_text
		_key_label.visible = true

	_update_display()


func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, SLOT_SIZE), _bg_color)
	# Border
	draw_rect(Rect2(Vector2.ZERO, SLOT_SIZE), BORDER_COLOR, false, 1.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_key_pressed(KEY_SHIFT):
				slot_shift_clicked.emit(slot_index)
			else:
				slot_clicked.emit(slot_index, MOUSE_BUTTON_LEFT)
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(slot_index)
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		slot_hovered.emit(slot_index)
	elif what == NOTIFICATION_MOUSE_EXIT:
		slot_exited.emit(slot_index)


## Set the item data to display in this slot.
func set_item_data(data: Dictionary) -> void:
	_item_data = data
	_update_display()


## Set whether this slot shows a key binding label (for hotbar).
func set_key_label(text: String) -> void:
	_show_key_label = true
	if _key_label:
		_key_label.text = text
		_key_label.visible = true
	else:
		_pending_key_text = text


## Set whether this slot is highlighted as selected.
func set_selected(selected: bool) -> void:
	_is_selected = selected
	if _selection_highlight:
		_selection_highlight.visible = selected


## Returns true if this slot has an item.
func has_item() -> bool:
	return _item_data["item_id"] != ""


## Returns the item data for this slot.
func get_item_data() -> Dictionary:
	return _item_data.duplicate()


# ── Drag and Drop ──────────────────────────────────────────────────────────

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not has_item():
		return null

	var preview := _create_drag_preview()
	set_drag_preview(preview)
	return {"source_index": slot_index, "item_data": _item_data.duplicate()}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and (data as Dictionary).has("source_index")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is Dictionary:
		slot_clicked.emit(slot_index, MOUSE_BUTTON_LEFT)


func _create_drag_preview() -> Control:
	var preview := ColorRect.new()
	preview.custom_minimum_size = SLOT_SIZE
	preview.size = SLOT_SIZE
	var item_info := ItemDatabase.get_item(_item_data["item_id"])
	preview.color = CATEGORY_COLORS.get(item_info.get("category", ""), Color.WHITE)
	preview.modulate.a = 0.7
	return preview


# ── Internal ───────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Icon rectangle (colored placeholder)
	_icon_rect = ColorRect.new()
	_icon_rect.size = Vector2(14, 14)
	_icon_rect.position = Vector2(2, 2)
	_icon_rect.color = Color.TRANSPARENT
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon_rect)

	# Letter label (centered on icon)
	_letter_label = Label.new()
	_letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_letter_label.size = Vector2(14, 14)
	_letter_label.position = Vector2(2, 1)
	_letter_label.add_theme_font_size_override("font_size", 7)
	_letter_label.add_theme_color_override("font_color", Color.WHITE)
	_letter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_letter_label)

	# Quantity label (bottom-right)
	_quantity_label = Label.new()
	_quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_quantity_label.size = Vector2(16, 8)
	_quantity_label.position = Vector2(1, 10)
	_quantity_label.add_theme_font_size_override("font_size", 6)
	_quantity_label.add_theme_color_override("font_color", Color.WHITE)
	_quantity_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_quantity_label.add_theme_constant_override("shadow_offset_x", 1)
	_quantity_label.add_theme_constant_override("shadow_offset_y", 1)
	_quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quantity_label.visible = false
	add_child(_quantity_label)

	# Quality indicator (top-right, 3x3 colored dot)
	_quality_indicator = ColorRect.new()
	_quality_indicator.size = Vector2(3, 3)
	_quality_indicator.position = Vector2(14, 1)
	_quality_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quality_indicator.visible = false
	add_child(_quality_indicator)

	# Key label (top-left, for hotbar)
	_key_label = Label.new()
	_key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_key_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_key_label.size = Vector2(8, 8)
	_key_label.position = Vector2(1, 0)
	_key_label.add_theme_font_size_override("font_size", 5)
	_key_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_key_label.visible = false
	add_child(_key_label)

	# Selection highlight (border overlay)
	_selection_highlight = ColorRect.new()
	_selection_highlight.size = SLOT_SIZE
	_selection_highlight.position = Vector2.ZERO
	_selection_highlight.color = SELECTION_COLOR
	_selection_highlight.modulate.a = 0.3
	_selection_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_highlight.visible = false
	add_child(_selection_highlight)


func _update_display() -> void:
	if not is_inside_tree():
		return

	if _item_data["item_id"] == "":
		_bg_color = EMPTY_SLOT_COLOR
		_icon_rect.color = Color.TRANSPARENT
		_letter_label.text = ""
		_quantity_label.visible = false
		_quality_indicator.visible = false
		queue_redraw()
		return

	var item_info := ItemDatabase.get_item(_item_data["item_id"])
	if item_info.is_empty():
		return

	_bg_color = SLOT_BG_COLOR

	# Placeholder icon: colored rect by category
	var category: String = item_info.get("category", "")
	_icon_rect.color = CATEGORY_COLORS.get(category, Color.WHITE)

	# Show first 2 characters of item id
	var item_id: String = _item_data["item_id"]
	_letter_label.text = item_id.left(2).to_upper()

	# Quantity label
	var qty: int = int(_item_data["quantity"])
	_quantity_label.visible = qty > 1
	_quantity_label.text = str(qty)

	# Quality indicator
	var quality: int = int(_item_data["quality"])
	_quality_indicator.visible = quality > 0
	match quality:
		Enums.Quality.SILVER:
			_quality_indicator.color = Color(0.75, 0.75, 0.75)
		Enums.Quality.GOLD:
			_quality_indicator.color = Color(1.0, 0.84, 0.0)
		_:
			_quality_indicator.visible = false

	queue_redraw()
