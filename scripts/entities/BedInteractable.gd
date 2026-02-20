extends Interactable
## Bed that the player can interact with to sleep and advance to the next day.
## Restores energy and health via Player's _on_day_ended listener.


func interact(_player: Node2D) -> void:
	DebugManager.dlog("player", "Player going to sleep")
	TimeManager.advance_day()


func get_interaction_prompt() -> String:
	return "Sleep"
