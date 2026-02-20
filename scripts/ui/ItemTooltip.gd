extends PanelContainer
## Item tooltip that appears on hover. Shows name, category, description,
## price, and quality information. Follows mouse position.

var _name_label: Label
var _category_label: Label
var _desc_label: Label
var _price_label: Label
var _current_item_id: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	_build_ui()
	SignalBus.tooltip_requested.connect(_on_tooltip_requested)
	SignalBus.tooltip_hidden.connect(_on_tooltip_hidden)


func _process(_delta: float) -> void:
	if visible:
		_follow_mouse()


func _build_ui() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.95)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(3.0)
	style.set_border_width_all(1)
	style.border_color = Color(0.5, 0.5, 0.5)
	add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)

	# Item name
	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 7)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_name_label)

	# Category
	_category_label = Label.new()
	_category_label.add_theme_font_size_override("font_size", 6)
	_category_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_category_label)

	# Separator
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(sep)

	# Description
	_desc_label = Label.new()
	_desc_label.add_theme_font_size_override("font_size", 6)
	_desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_desc_label.custom_minimum_size.x = 100
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_desc_label)

	# Price
	_price_label = Label.new()
	_price_label.add_theme_font_size_override("font_size", 6)
	_price_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	_price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_price_label)


func _on_tooltip_requested(item_id: String, _mouse_pos: Vector2) -> void:
	if item_id == "" or not ItemDatabase.has_item(item_id):
		visible = false
		return

	_current_item_id = item_id
	var item := ItemDatabase.get_item(item_id)

	_name_label.text = ItemDatabase.get_item_display_name(item_id)

	var category: String = item.get("category", "")
	_category_label.text = category
	_category_label.add_theme_color_override("font_color",
		ItemSlot.CATEGORY_COLORS.get(category, Color(0.7, 0.7, 0.7)))

	_desc_label.text = ItemDatabase.get_item_description(item_id)

	var price: int = int(item.get("base_price", 0))
	if price > 0:
		_price_label.text = "Sell: %d" % price
		_price_label.visible = true
	else:
		_price_label.visible = false

	visible = true
	_follow_mouse()


func _on_tooltip_hidden() -> void:
	visible = false
	_current_item_id = ""


func _follow_mouse() -> void:
	var mouse_pos := get_global_mouse_position()
	var viewport_size := Vector2(Constants.VIEWPORT_WIDTH, Constants.VIEWPORT_HEIGHT)

	# Offset from mouse
	var pos := mouse_pos + Vector2(8, -4)

	# Clamp to viewport bounds
	if pos.x + size.x > viewport_size.x:
		pos.x = mouse_pos.x - size.x - 4
	if pos.y + size.y > viewport_size.y:
		pos.y = viewport_size.y - size.y
	if pos.y < 0:
		pos.y = 0

	global_position = pos
