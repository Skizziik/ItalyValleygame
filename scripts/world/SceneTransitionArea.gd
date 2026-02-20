extends Area2D
class_name SceneTransitionArea
## Reusable trigger area for scene transitions (doors, exits, paths).
## Place as a child of any map. When the player enters, triggers SceneLoader
## with a fade transition to the target scene.

## Path to the target scene file (e.g., "res://scenes/world/FarmHouse.tscn").
@export var target_scene: String = ""

## Name of the Marker2D spawn point in the target scene.
@export var spawn_point: String = "default"


func _ready() -> void:
	# Detect the player body (layer bit 2 = PLAYER)
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if target_scene.is_empty():
		push_warning("SceneTransitionArea '%s': no target_scene set" % name)
		return

	if SceneLoader.is_transitioning():
		return

	DebugManager.dlog("scene", "Transition triggered: %s → %s (spawn: %s)" % [
		name, target_scene, spawn_point
	])

	SceneLoader.change_scene(target_scene, spawn_point)
