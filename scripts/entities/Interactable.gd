extends Node2D
class_name Interactable
## Base class for all interactable objects in the world.
## Automatically creates a detection Area2D on physics layer INTERACTABLE (bit 4).
## Subclasses must override interact() and optionally get_interaction_prompt().

## Size of the detection area. Override in subclass or set before _ready().
@export var detection_size: Vector2 = Vector2(32, 32)


func _ready() -> void:
	_create_detection_area()


## Called when the player presses the interact key while in range.
func interact(_player: Node2D) -> void:
	push_warning("Interactable.interact() not overridden on: %s" % name)


## Returns the text shown to the player (e.g., "Talk", "Pick up", "Open").
func get_interaction_prompt() -> String:
	return "Interact"


## Creates a child Area2D that the player's InteractionArea can detect.
func _create_detection_area() -> void:
	var area := Area2D.new()
	area.name = "DetectionArea"
	area.collision_layer = 8  # bit 4 = INTERACTABLE
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	area.add_to_group("interactable")

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = detection_size
	shape.shape = rect
	area.add_child(shape)
	add_child(area)
