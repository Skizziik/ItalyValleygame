extends Node
## Global game state machine. Autoloaded as "GameManager".
## Controls game state transitions and tree pause behavior.

var current_state: Enums.GameState = Enums.GameState.MAIN_MENU
var _previous_state: Enums.GameState = Enums.GameState.MAIN_MENU
var _playtime_seconds: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if current_state == Enums.GameState.PLAYING:
		_playtime_seconds += delta


## Change the game state. Handles tree pause and emits signals.
func change_state(new_state: Enums.GameState) -> void:
	if new_state == current_state:
		return

	var old_state := current_state
	_previous_state = current_state
	current_state = new_state

	_apply_state_behavior(new_state)
	SignalBus.game_state_changed.emit(old_state, new_state)

	match new_state:
		Enums.GameState.PAUSED:
			SignalBus.game_paused.emit()
		Enums.GameState.PLAYING:
			if old_state == Enums.GameState.PAUSED:
				SignalBus.game_resumed.emit()


## Return to the previous state (useful for closing menus)
func return_to_previous_state() -> void:
	change_state(_previous_state)


## True only when the player is actively playing (not in menus/dialogue/etc.)
func is_gameplay_active() -> bool:
	return current_state == Enums.GameState.PLAYING


## True when player input should be blocked (dialogue, cutscene, loading)
func is_input_blocked() -> bool:
	return current_state in [
		Enums.GameState.DIALOGUE,
		Enums.GameState.CUTSCENE,
		Enums.GameState.LOADING,
		Enums.GameState.MAIN_MENU,
	]


## True when the game world should be paused (menus, inventory, etc.)
func is_world_paused() -> bool:
	return current_state in [
		Enums.GameState.PAUSED,
		Enums.GameState.INVENTORY,
		Enums.GameState.CRAFTING,
		Enums.GameState.SHOPPING,
		Enums.GameState.DIALOGUE,
		Enums.GameState.CUTSCENE,
		Enums.GameState.MAIN_MENU,
		Enums.GameState.LOADING,
	]


## Start a new game: reset everything and load the starting scene
func new_game() -> void:
	_playtime_seconds = 0.0
	change_state(Enums.GameState.LOADING)
	SignalBus.game_started.emit()


## Quit the game cleanly
func quit_game() -> void:
	get_tree().quit()


## Total playtime in seconds (for save file)
func get_playtime_seconds() -> float:
	return _playtime_seconds


## Set playtime (used when loading a save)
func set_playtime_seconds(seconds: float) -> void:
	_playtime_seconds = seconds


## Serialize game manager state for saving
func serialize() -> Dictionary:
	return {
		"playtime_seconds": _playtime_seconds,
	}


## Deserialize game manager state from save data
func deserialize(data: Dictionary) -> void:
	_playtime_seconds = data.get("playtime_seconds", 0.0)


## Apply pause/unpause behavior based on the new state
func _apply_state_behavior(state: Enums.GameState) -> void:
	match state:
		Enums.GameState.PLAYING:
			get_tree().paused = false
		Enums.GameState.PAUSED, \
		Enums.GameState.INVENTORY, \
		Enums.GameState.CRAFTING, \
		Enums.GameState.SHOPPING:
			get_tree().paused = true
		Enums.GameState.DIALOGUE, \
		Enums.GameState.CUTSCENE:
			get_tree().paused = true
		Enums.GameState.FISHING, \
		Enums.GameState.COMBAT:
			get_tree().paused = false
		Enums.GameState.LOADING:
			get_tree().paused = true
		Enums.GameState.MAIN_MENU:
			get_tree().paused = false
