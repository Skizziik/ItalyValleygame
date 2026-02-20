extends Node2D
## Base class for all interactable objects in the world.
## Subclasses must override interact() and get_interaction_prompt().
## Add the node to the "interactable" group for detection.

## Called when the player presses the interact key while in range.
func interact(_player: Node2D) -> void:
	push_warning("Interactable.interact() not overridden on: %s" % name)


## Returns the text shown to the player (e.g., "Talk", "Pick up", "Open").
func get_interaction_prompt() -> String:
	return "Interact"
