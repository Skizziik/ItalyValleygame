extends Node2D
class_name BaseMap
## Base class for all map scenes. Provides day/night cycle integration,
## weather effects hookup, camera limiting, and map metadata.

## If true, day/night tinting is disabled (constant white light).
@export var is_interior: bool = false

## Display name for debug overlay and save data.
@export var map_name: String = ""

## Map bounds in pixels. Used by camera limiting. (0,0) = top-left of map.
## Set these to match your tile grid size: width_tiles * 16, height_tiles * 16.
@export var map_width_px: int = 640
@export var map_height_px: int = 480

var _day_night: CanvasModulate
var _weather_effects: Node2D


func _ready() -> void:
	# Auto-find standard children
	_day_night = get_node_or_null("DayNightCycle") as CanvasModulate
	_weather_effects = get_node_or_null("WeatherEffects")

	if is_interior:
		if _day_night:
			_day_night.set_override(Color.WHITE)
		if _weather_effects:
			_weather_effects.visible = false
			_weather_effects.set_process(false)

	# Start gameplay when map loads
	if GameManager.current_state != Enums.GameState.PLAYING:
		GameManager.change_state(Enums.GameState.PLAYING)

	# Apply camera limits to the player's camera
	_apply_camera_limits()

	DebugManager.dlog("scene", "Map loaded: %s (%s)" % [
		map_name if map_name != "" else name,
		"interior" if is_interior else "exterior"
	])


## Returns the map bounds as a Rect2 in pixels.
func get_map_bounds() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(map_width_px, map_height_px))


## Find the player's Camera2D and set its limits to the map bounds.
func _apply_camera_limits() -> void:
	# Wait one frame so the player instance is fully ready
	await get_tree().process_frame

	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player: Node2D = players[0]
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return

	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_width_px
	camera.limit_bottom = map_height_px
