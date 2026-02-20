extends Node2D
## Temporary test world scene. Sets game state to PLAYING on start.


func _ready() -> void:
	GameManager.change_state(Enums.GameState.PLAYING)
	DebugManager.dlog("scene", "TestWorld loaded — game state set to PLAYING")
