extends Node
## Scene transition manager with fade overlay. Autoloaded as "SceneLoader".
## Handles smooth scene changes with black fade and spawn point placement.

var _overlay: ColorRect
var _canvas_layer: CanvasLayer
var _tween: Tween
var _is_transitioning: bool = false
var _pending_spawn_point: String = ""
var _current_scene_path: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_overlay()


## Change scene with a fade-to-black transition.
## spawn_point: name of a Marker2D in the target scene to place the player.
func change_scene(scene_path: String, spawn_point: String = "") -> void:
	if _is_transitioning:
		push_warning("SceneLoader: transition already in progress, ignoring request")
		return

	_is_transitioning = true
	_pending_spawn_point = spawn_point

	SignalBus.scene_changing.emit(scene_path)

	# Fade to black
	await _fade_out()

	# Midpoint signal — systems can prepare for the new scene
	SignalBus.scene_transition_midpoint.emit()

	# Actually change the scene
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneLoader: failed to load scene '%s' (error %d)" % [scene_path, err])
		await _fade_in()
		_is_transitioning = false
		return

	# Wait for the new scene to be ready
	await get_tree().process_frame
	await get_tree().process_frame

	# Place player at spawn point if specified
	if _pending_spawn_point != "":
		_place_player_at_spawn(_pending_spawn_point)

	_current_scene_path = scene_path
	SignalBus.scene_changed.emit(_get_scene_name(scene_path))

	# Fade from black
	await _fade_in()

	_is_transitioning = false


## Quick scene change without transition (for initial load, etc.)
func change_scene_instant(scene_path: String, spawn_point: String = "") -> void:
	_pending_spawn_point = spawn_point
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneLoader: failed to load scene '%s' (error %d)" % [scene_path, err])
		return

	await get_tree().process_frame

	if _pending_spawn_point != "":
		_place_player_at_spawn(_pending_spawn_point)

	_current_scene_path = scene_path
	SignalBus.scene_changed.emit(_get_scene_name(scene_path))


## Whether a scene transition is currently in progress
func is_transitioning() -> bool:
	return _is_transitioning


## Get the current scene's file path
func get_current_scene_path() -> String:
	return _current_scene_path


## Create the overlay CanvasLayer + ColorRect programmatically
func _create_overlay() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	_canvas_layer.name = "SceneTransitionLayer"
	add_child(_canvas_layer)

	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_overlay.modulate.a = 0.0
	_overlay.name = "FadeOverlay"
	_canvas_layer.add_child(_overlay)


## Fade the overlay to opaque (black)
func _fade_out() -> void:
	if _tween:
		_tween.kill()

	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # block input during fade
	_tween = create_tween()
	_tween.tween_property(_overlay, "modulate:a", 1.0, Constants.FADE_DURATION)
	await _tween.finished


## Fade the overlay to transparent
func _fade_in() -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(_overlay, "modulate:a", 0.0, Constants.FADE_DURATION)
	await _tween.finished
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # unblock input


## Find a Marker2D with the given name and move the player there
func _place_player_at_spawn(spawn_name: String) -> void:
	var root := get_tree().current_scene
	if root == null:
		return

	# Look for spawn point Marker2D
	var spawn_marker: Marker2D = _find_spawn_point(root, spawn_name)
	if spawn_marker == null:
		push_warning("SceneLoader: spawn point '%s' not found in scene" % spawn_name)
		return

	# Find the player node
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_warning("SceneLoader: no node in 'player' group found")
		return

	var player: Node2D = players[0] as Node2D
	if player:
		player.global_position = spawn_marker.global_position


## Recursively search for a Marker2D with the given name
func _find_spawn_point(node: Node, spawn_name: String) -> Marker2D:
	if node is Marker2D and node.name == spawn_name:
		return node as Marker2D

	for child in node.get_children():
		var found := _find_spawn_point(child, spawn_name)
		if found:
			return found

	return null


## Extract scene name from path (e.g., "res://scenes/world/farm.tscn" -> "farm")
func _get_scene_name(path: String) -> String:
	return path.get_file().get_basename()
