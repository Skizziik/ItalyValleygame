extends Node
## Save/load system with JSON serialization, versioning, and autosave.
## Autoloaded as "SaveManager".

const SAVE_DIR := "user://saves/"
const SAVE_FILE_PREFIX := "save_slot_"
const SAVE_EXTENSION := ".json"
const TEMP_EXTENSION := ".tmp"

var _autosave_timer: float = 0.0
var _is_saving: bool = false
var _is_loading: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_save_directory()


func _process(delta: float) -> void:
	if not GameManager.is_gameplay_active():
		return

	_autosave_timer += delta
	if _autosave_timer >= Constants.AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		autosave()


## Save the entire game state to a slot
func save_game(slot: int) -> bool:
	if _is_saving:
		push_warning("SaveManager: save already in progress")
		return false

	_is_saving = true

	var save_data := _build_save_data()
	var json_string := JSON.stringify(save_data, "\t")

	var path := _get_save_path(slot)
	var temp_path := path + TEMP_EXTENSION

	# Write to temp file first (atomic save)
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("SaveManager: failed to open temp file '%s' (error %d)" % [temp_path, err])
		_is_saving = false
		SignalBus.save_failed.emit(slot, "Failed to open file")
		return false

	file.store_string(json_string)
	file.close()

	# Rename temp to final (atomic replace)
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		push_error("SaveManager: cannot access save directory")
		_is_saving = false
		SignalBus.save_failed.emit(slot, "Cannot access save directory")
		return false

	# Remove old save if it exists
	if dir.file_exists(path.get_file()):
		dir.remove(path.get_file())

	var err := dir.rename(temp_path.get_file(), path.get_file())
	if err != OK:
		push_error("SaveManager: failed to rename temp to final (error %d)" % err)
		_is_saving = false
		SignalBus.save_failed.emit(slot, "Failed to finalize save")
		return false

	_is_saving = false
	SignalBus.game_saved.emit(slot)
	return true


## Load game state from a slot
func load_game(slot: int) -> bool:
	if _is_loading:
		push_warning("SaveManager: load already in progress")
		return false

	var path := _get_save_path(slot)
	if not FileAccess.file_exists(path):
		push_error("SaveManager: save file not found '%s'" % path)
		return false

	_is_loading = true

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open save file '%s'" % path)
		_is_loading = false
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_err := json.parse(json_string)
	if parse_err != OK:
		push_error("SaveManager: invalid JSON in '%s' at line %d" % [path, json.get_error_line()])
		_is_loading = false
		return false

	var save_data: Dictionary = json.data
	if not save_data is Dictionary:
		push_error("SaveManager: save data root is not a Dictionary")
		_is_loading = false
		return false

	# Version check and migration
	var version: int = save_data.get("version", 0)
	if version < Constants.SAVE_VERSION:
		save_data = _migrate_save(save_data, version)
		if save_data.is_empty():
			push_error("SaveManager: migration failed from version %d" % version)
			_is_loading = false
			return false
	elif version > Constants.SAVE_VERSION:
		push_error("SaveManager: save version %d is newer than game version %d" % [
			version, Constants.SAVE_VERSION
		])
		_is_loading = false
		return false

	# Deserialize all systems
	_apply_save_data(save_data)

	_is_loading = false
	_autosave_timer = 0.0
	SignalBus.game_loaded.emit(slot)
	return true


## Delete a save slot
func delete_save(slot: int) -> bool:
	var path := _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return false

	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return false

	return dir.remove(path.get_file()) == OK


## Check if a save slot exists
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))


## Get metadata for all save slots (for the load screen UI)
func get_save_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []

	for i in range(Constants.MAX_SAVE_SLOTS):
		if has_save(i):
			var data := _read_save_metadata(i)
			data["slot"] = i
			data["is_autosave"] = false
			slots.append(data)

	# Check autosave slot too
	if has_save(Constants.AUTOSAVE_SLOT):
		var data := _read_save_metadata(Constants.AUTOSAVE_SLOT)
		data["slot"] = Constants.AUTOSAVE_SLOT
		data["is_autosave"] = true
		slots.append(data)

	return slots


## Trigger autosave
func autosave() -> void:
	save_game(Constants.AUTOSAVE_SLOT)


## Build the complete save data dictionary
func _build_save_data() -> Dictionary:
	return {
		"version": Constants.SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(true),
		"playtime_seconds": GameManager.get_playtime_seconds(),
		"game_manager": GameManager.serialize(),
		"time": TimeManager.serialize(),
		"inventory": InventoryManager.serialize(),
		# Future systems add their serialize() here:
		# "economy": EconomyManager.serialize(),
		# "quests": QuestManager.serialize(),
		# "relationships": NPCManager.serialize(),
		# "world": WorldManager.serialize(),
	}


## Apply loaded data to all systems
func _apply_save_data(data: Dictionary) -> void:
	GameManager.deserialize(data.get("game_manager", {}))
	TimeManager.deserialize(data.get("time", {}))
	InventoryManager.deserialize(data.get("inventory", {}))
	# Future systems add their deserialize() here:
	# EconomyManager.deserialize(data.get("economy", {}))
	# QuestManager.deserialize(data.get("quests", {}))
	# NPCManager.deserialize(data.get("relationships", {}))
	# WorldManager.deserialize(data.get("world", {}))


## Read only the metadata from a save (without full deserialization)
func _read_save_metadata(slot: int) -> Dictionary:
	var path := _get_save_path(slot)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		return {}

	var data: Dictionary = json.data
	if not data is Dictionary:
		return {}

	return {
		"timestamp": data.get("timestamp", ""),
		"playtime_seconds": data.get("playtime_seconds", 0.0),
		"version": data.get("version", 0),
		"time": data.get("time", {}),
	}


## Migrate save data from older versions
func _migrate_save(data: Dictionary, from_version: int) -> Dictionary:
	var current := data.duplicate(true)

	# Add migration steps as the game evolves:
	# if from_version < 2:
	#     current["new_field"] = default_value
	#     current["version"] = 2

	current["version"] = Constants.SAVE_VERSION
	return current


## Ensure the saves directory exists
func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


## Get the full path for a save slot
func _get_save_path(slot: int) -> String:
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_EXTENSION
