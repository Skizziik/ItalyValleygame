extends RefCounted
class_name Inventory
## Reusable inventory container. Used for player backpack, hotbar, chests, etc.
## Each slot is a Dictionary: { "item_id": String, "quantity": int, "quality": int }.
## Empty slot: { "item_id": "", "quantity": 0, "quality": 0 }.

signal slot_changed(index: int)
signal inventory_sorted

var _slots: Array[Dictionary] = []
var _size: int = 0


func _init(size: int) -> void:
	_size = size
	_slots.resize(size)
	for i in range(size):
		_slots[i] = _empty_slot()


## Returns the total number of slots.
func get_size() -> int:
	return _size


## Returns a copy of the slot data at the given index.
func get_slot(index: int) -> Dictionary:
	if index < 0 or index >= _size:
		return _empty_slot()
	return _slots[index].duplicate()


## Returns true if the slot at the given index is empty.
func is_slot_empty(index: int) -> bool:
	if index < 0 or index >= _size:
		return true
	return _slots[index]["item_id"] == ""


# ── Core Operations ────────────────────────────────────────────────────────

## Add items to the inventory. Tries to merge into existing stacks first,
## then fills empty slots. Returns the number of items that could NOT be added.
func add_item(item_id: String, quantity: int = 1, quality: int = 0) -> int:
	if quantity <= 0 or item_id == "":
		return 0

	var stack_max: int = ItemDatabase.get_stack_max(item_id)
	var remaining := quantity

	# First pass: merge into existing stacks of same item + quality
	for i in range(_size):
		if remaining <= 0:
			break
		if _slots[i]["item_id"] == item_id and int(_slots[i]["quality"]) == quality:
			var space: int = stack_max - int(_slots[i]["quantity"])
			if space > 0:
				var to_add := mini(remaining, space)
				_slots[i]["quantity"] = int(_slots[i]["quantity"]) + to_add
				remaining -= to_add
				slot_changed.emit(i)

	# Second pass: fill empty slots
	for i in range(_size):
		if remaining <= 0:
			break
		if _slots[i]["item_id"] == "":
			var to_add := mini(remaining, stack_max)
			_slots[i] = {"item_id": item_id, "quantity": to_add, "quality": quality}
			remaining -= to_add
			slot_changed.emit(i)

	return remaining


## Remove a quantity of an item (any quality). Searches all slots.
## Returns the number of items actually removed.
func remove_item(item_id: String, quantity: int = 1) -> int:
	if quantity <= 0 or item_id == "":
		return 0

	var remaining := quantity

	for i in range(_size):
		if remaining <= 0:
			break
		if _slots[i]["item_id"] == item_id:
			var in_slot: int = int(_slots[i]["quantity"])
			var to_remove := mini(remaining, in_slot)
			_slots[i]["quantity"] = in_slot - to_remove
			remaining -= to_remove
			if int(_slots[i]["quantity"]) <= 0:
				_slots[i] = _empty_slot()
			slot_changed.emit(i)

	return quantity - remaining


## Remove a specific quantity from a specific slot.
## Returns a Dictionary with the removed item data { item_id, quantity, quality }.
func remove_item_at(index: int, quantity: int = 1) -> Dictionary:
	if index < 0 or index >= _size or is_slot_empty(index):
		return _empty_slot()

	var slot := _slots[index]
	var in_slot: int = int(slot["quantity"])
	var to_remove := mini(quantity, in_slot)

	var removed := {
		"item_id": slot["item_id"],
		"quantity": to_remove,
		"quality": int(slot["quality"]),
	}

	slot["quantity"] = in_slot - to_remove
	if int(slot["quantity"]) <= 0:
		_slots[index] = _empty_slot()

	slot_changed.emit(index)
	return removed


## Set a slot directly (used by drag-drop and deserialization).
func set_slot(index: int, item_id: String, quantity: int, quality: int) -> void:
	if index < 0 or index >= _size:
		return

	if item_id == "" or quantity <= 0:
		_slots[index] = _empty_slot()
	else:
		_slots[index] = {"item_id": item_id, "quantity": quantity, "quality": quality}

	slot_changed.emit(index)


## Clear a specific slot.
func clear_slot(index: int) -> void:
	if index < 0 or index >= _size:
		return
	_slots[index] = _empty_slot()
	slot_changed.emit(index)


# ── Queries ────────────────────────────────────────────────────────────────

## Check if the inventory contains at least `quantity` of `item_id` (any quality).
func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_count(item_id) >= quantity


## Get the total count of an item across all slots (any quality).
func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in _slots:
		if slot["item_id"] == item_id:
			total += int(slot["quantity"])
	return total


## Find the first empty slot index. Returns -1 if full.
func find_first_empty_slot() -> int:
	for i in range(_size):
		if _slots[i]["item_id"] == "":
			return i
	return -1


## Returns true if there are no empty slots.
func is_full() -> bool:
	return find_first_empty_slot() == -1


## Count the number of occupied slots.
func get_occupied_slot_count() -> int:
	var count := 0
	for slot in _slots:
		if slot["item_id"] != "":
			count += 1
	return count


# ── Slot Manipulation ─────────────────────────────────────────────────────

## Swap the contents of two slots.
func swap_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= _size or to_index < 0 or to_index >= _size:
		return
	if from_index == to_index:
		return

	var temp := _slots[from_index]
	_slots[from_index] = _slots[to_index]
	_slots[to_index] = temp

	slot_changed.emit(from_index)
	slot_changed.emit(to_index)


## Split a stack: removes `amount` from the slot and returns it.
## Returns { item_id, quantity, quality } of the split portion.
func split_stack(index: int, amount: int) -> Dictionary:
	if index < 0 or index >= _size or is_slot_empty(index):
		return _empty_slot()

	var slot := _slots[index]
	var in_slot: int = int(slot["quantity"])

	if amount <= 0 or amount >= in_slot:
		# Take everything
		var result := slot.duplicate()
		_slots[index] = _empty_slot()
		slot_changed.emit(index)
		return result

	var split := {
		"item_id": slot["item_id"],
		"quantity": amount,
		"quality": int(slot["quality"]),
	}
	slot["quantity"] = in_slot - amount
	slot_changed.emit(index)
	return split


## Merge from_index stack into to_index (must be same item_id + quality).
## Returns leftover quantity that didn't fit in to_index.
func merge_stacks(from_index: int, to_index: int) -> int:
	if from_index < 0 or from_index >= _size or to_index < 0 or to_index >= _size:
		return 0
	if from_index == to_index:
		return 0

	var from_slot := _slots[from_index]
	var to_slot := _slots[to_index]

	# Can only merge same item + quality
	if from_slot["item_id"] != to_slot["item_id"]:
		return int(from_slot["quantity"])
	if int(from_slot["quality"]) != int(to_slot["quality"]):
		return int(from_slot["quantity"])

	var stack_max: int = ItemDatabase.get_stack_max(to_slot["item_id"])
	var space: int = stack_max - int(to_slot["quantity"])

	if space <= 0:
		return int(from_slot["quantity"])

	var to_move := mini(int(from_slot["quantity"]), space)
	to_slot["quantity"] = int(to_slot["quantity"]) + to_move
	from_slot["quantity"] = int(from_slot["quantity"]) - to_move

	if int(from_slot["quantity"]) <= 0:
		_slots[from_index] = _empty_slot()

	slot_changed.emit(from_index)
	slot_changed.emit(to_index)

	return int(_slots[from_index].get("quantity", 0))


# ── Sorting ────────────────────────────────────────────────────────────────

## Sort by category order (tools first, then materials, seeds, etc.), then by name.
func sort_by_category() -> void:
	var category_order := {
		"TOOL": 0, "MATERIAL": 1, "SEED": 2, "CROP": 3, "FISH": 4,
		"FOOD": 5, "CRAFTED": 6, "FURNITURE": 7, "QUEST": 8, "ARTIFACT": 9,
	}

	# Collect non-empty slots
	var items: Array[Dictionary] = []
	for slot in _slots:
		if slot["item_id"] != "":
			items.append(slot.duplicate())

	# Sort
	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var item_a := ItemDatabase.get_item(a["item_id"])
		var item_b := ItemDatabase.get_item(b["item_id"])
		var cat_a: int = category_order.get(item_a.get("category", ""), 99)
		var cat_b: int = category_order.get(item_b.get("category", ""), 99)
		if cat_a != cat_b:
			return cat_a < cat_b
		return a["item_id"] < b["item_id"]
	)

	# Rebuild slots
	for i in range(_size):
		if i < items.size():
			_slots[i] = items[i]
		else:
			_slots[i] = _empty_slot()
		slot_changed.emit(i)

	inventory_sorted.emit()


## Sort alphabetically by item_id.
func sort_by_name() -> void:
	var items: Array[Dictionary] = []
	for slot in _slots:
		if slot["item_id"] != "":
			items.append(slot.duplicate())

	items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["item_id"] < b["item_id"]
	)

	for i in range(_size):
		if i < items.size():
			_slots[i] = items[i]
		else:
			_slots[i] = _empty_slot()
		slot_changed.emit(i)

	inventory_sorted.emit()


# ── Serialization ──────────────────────────────────────────────────────────

## Serialize to an array of slot dictionaries.
func serialize() -> Array:
	var data: Array = []
	for slot in _slots:
		data.append(slot.duplicate())
	return data


## Deserialize from an array of slot dictionaries.
func deserialize(data: Array) -> void:
	for i in range(_size):
		if i < data.size() and data[i] is Dictionary:
			var slot_data: Dictionary = data[i] as Dictionary
			var item_id: String = slot_data.get("item_id", "")
			if item_id != "" and ItemDatabase.has_item(item_id):
				_slots[i] = {
					"item_id": item_id,
					"quantity": int(slot_data.get("quantity", 0)),
					"quality": int(slot_data.get("quality", 0)),
				}
			elif item_id != "":
				push_warning("Inventory: unknown item_id '%s' in save data, clearing slot" % item_id)
				_slots[i] = _empty_slot()
			else:
				_slots[i] = _empty_slot()
		else:
			_slots[i] = _empty_slot()
		slot_changed.emit(i)


## Clear all slots.
func clear_all() -> void:
	for i in range(_size):
		_slots[i] = _empty_slot()
		slot_changed.emit(i)


# ── Helpers ────────────────────────────────────────────────────────────────

static func _empty_slot() -> Dictionary:
	return {"item_id": "", "quantity": 0, "quality": 0}
