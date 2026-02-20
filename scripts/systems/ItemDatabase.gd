extends Node
## Loads and indexes item definitions from data/items.json.
## Autoloaded as "ItemDatabase".

var _items: Dictionary = {}
var _loaded: bool = false


func _ready() -> void:
	_load_items()


## Check if an item ID exists in the database.
func has_item(item_id: String) -> bool:
	return _items.has(item_id)


## Get the full data dictionary for an item. Returns empty dict if not found.
func get_item(item_id: String) -> Dictionary:
	return _items.get(item_id, {})


## Get the stack_max for an item. Returns STACK_MAX_DEFAULT if item not found.
func get_stack_max(item_id: String) -> int:
	var item := get_item(item_id)
	if item.is_empty():
		return Constants.STACK_MAX_DEFAULT
	return int(item.get("stack_max", Constants.STACK_MAX_DEFAULT))


## Get all items matching a specific category (e.g. "CROP", "TOOL").
func get_items_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in _items.values():
		if item.get("category", "") == category:
			result.append(item)
	return result


## Get all items that have a specific tag (e.g. "sellable", "cookable").
func get_items_by_tag(tag: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in _items.values():
		var tags: Array = item.get("tags", [])
		if tags.has(tag):
			result.append(item)
	return result


## Get all items available in a specific season (e.g. "SUMMER").
## Items with an empty seasons array are available in all seasons.
func get_items_by_season(season: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in _items.values():
		var seasons: Array = item.get("seasons", [])
		if seasons.is_empty() or seasons.has(season):
			result.append(item)
	return result


## Get a display name for an item (uses name_key for now, localization later).
func get_item_display_name(item_id: String) -> String:
	var item := get_item(item_id)
	if item.is_empty():
		return item_id
	# For now, convert name_key to readable form: ITEM_TOMATO -> Tomato
	var name_key: String = item.get("name_key", item_id)
	var display := name_key.replace("ITEM_", "").replace("_", " ").to_pascal_case()
	return display


## Get a description for an item.
func get_item_description(item_id: String) -> String:
	var item := get_item(item_id)
	if item.is_empty():
		return ""
	var desc_key: String = item.get("description_key", "")
	# Placeholder descriptions until localization system exists
	return desc_key.replace("ITEM_", "").replace("_DESC", "").replace("_", " ").to_lower()


## Get total number of loaded items.
func get_item_count() -> int:
	return _items.size()


# ── Loading ────────────────────────────────────────────────────────────────

func _load_items() -> void:
	var file := FileAccess.open("res://data/items.json", FileAccess.READ)
	if file == null:
		push_error("ItemDatabase: cannot open items.json (error %d)" % FileAccess.get_open_error())
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("ItemDatabase: JSON parse error at line %d: %s" % [
			json.get_error_line(), json.get_error_message()
		])
		return

	var data = json.data
	if not data is Dictionary:
		push_error("ItemDatabase: root element must be a Dictionary")
		return

	var items_array: Array = (data as Dictionary).get("items", [])
	var valid_count := 0

	for item_data in items_array:
		if not item_data is Dictionary:
			push_warning("ItemDatabase: skipping non-dict entry")
			continue

		var item_dict: Dictionary = item_data as Dictionary
		if not _validate_item(item_dict):
			continue

		_items[item_dict["id"]] = item_dict
		valid_count += 1

	_loaded = true
	DebugManager.dlog("inventory", "ItemDatabase: loaded %d items" % valid_count)


func _validate_item(item: Dictionary) -> bool:
	# Required string fields
	for field in ["id", "name_key", "description_key", "category"]:
		if not item.has(field) or not item[field] is String or (item[field] as String).is_empty():
			push_warning("ItemDatabase: item missing or empty required field '%s'" % field)
			return false

	# Required numeric fields
	for field in ["stack_max", "base_price"]:
		if not item.has(field):
			push_warning("ItemDatabase: item '%s' missing field '%s'" % [item.get("id", "?"), field])
			return false

	# Validate category is a known enum value
	var category: String = item["category"]
	var valid_categories := [
		"MATERIAL", "TOOL", "SEED", "CROP", "FISH",
		"CRAFTED", "FOOD", "FURNITURE", "QUEST", "ARTIFACT",
	]
	if category not in valid_categories:
		push_warning("ItemDatabase: item '%s' has unknown category '%s'" % [item["id"], category])
		return false

	# Ensure tags is an array
	if item.has("tags") and not item["tags"] is Array:
		push_warning("ItemDatabase: item '%s' tags must be an Array" % item["id"])
		return false

	# Ensure seasons is an array
	if item.has("seasons") and not item["seasons"] is Array:
		push_warning("ItemDatabase: item '%s' seasons must be an Array" % item["id"])
		return false

	return true
