extends Node
## Debug overlay and logging system. Autoloaded as "DebugManager".
## Only active in debug builds. Toggle overlay with F3.

var _is_active: bool = false
var _overlay_visible: bool = false
var _canvas_layer: CanvasLayer
var _overlay_label: Label
var _update_timer: float = 0.0
var _fps_history: PackedFloat32Array = []

## Per-category logging filters (set to true to enable logging for a category)
var log_filters: Dictionary = {
	"game": true,
	"time": true,
	"player": true,
	"inventory": false,
	"farming": false,
	"npc": false,
	"quest": false,
	"combat": false,
	"audio": false,
	"save": true,
	"scene": true,
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not OS.is_debug_build():
		set_process(false)
		set_process_input(false)
		return

	_is_active = true
	_create_overlay()
	dlog("game", "DebugManager initialized")


func _process(delta: float) -> void:
	if not _is_active:
		return

	# Track FPS
	_fps_history.append(Engine.get_frames_per_second())
	if _fps_history.size() > 120:
		_fps_history.remove_at(0)

	if not _overlay_visible:
		return

	_update_timer += delta
	if _update_timer >= Constants.DEBUG_OVERLAY_UPDATE_INTERVAL:
		_update_timer = 0.0
		_update_overlay()


func _input(event: InputEvent) -> void:
	if not _is_active:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			toggle_overlay()
			get_viewport().set_input_as_handled()


## Toggle the debug overlay on/off
func toggle_overlay() -> void:
	_overlay_visible = not _overlay_visible
	_canvas_layer.visible = _overlay_visible
	if _overlay_visible:
		_update_overlay()


## Conditional log output. Only prints if the category filter is enabled.
func dlog(category: String, message: String) -> void:
	if not _is_active:
		return
	if not log_filters.get(category, false):
		return

	var timestamp := "%.2f" % (Time.get_ticks_msec() / 1000.0)
	print("[%s] [%s] %s" % [timestamp, category.to_upper(), message])


## Enable or disable logging for a specific category
func set_log_filter(category: String, enabled: bool) -> void:
	log_filters[category] = enabled


## Get average FPS over the history window
func get_avg_fps() -> float:
	if _fps_history.is_empty():
		return 0.0

	var total := 0.0
	for fps in _fps_history:
		total += fps
	return total / _fps_history.size()


## Create the overlay UI
func _create_overlay() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 99
	_canvas_layer.name = "DebugOverlay"
	_canvas_layer.visible = false
	add_child(_canvas_layer)

	# Background panel for readability
	var panel := PanelContainer.new()
	panel.name = "DebugPanel"
	panel.anchors_preset = Control.PRESET_TOP_LEFT
	panel.offset_right = 280.0
	panel.offset_bottom = 200.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.7)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8.0)
	panel.add_theme_stylebox_override("panel", style)
	_canvas_layer.add_child(panel)

	# Label for debug text
	_overlay_label = Label.new()
	_overlay_label.name = "DebugLabel"
	_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_overlay_label.add_theme_font_size_override("font_size", 12)
	_overlay_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0))
	_overlay_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_overlay_label)


## Refresh the overlay content
func _update_overlay() -> void:
	var lines: PackedStringArray = []

	# FPS
	lines.append("FPS: %d (avg: %.0f)" % [
		Engine.get_frames_per_second(), get_avg_fps()
	])

	# Memory
	var mem_mb := OS.get_static_memory_usage() / (1024.0 * 1024.0)
	lines.append("Memory: %.1f MB" % mem_mb)

	# Game state
	var state_name := _game_state_name(GameManager.current_state)
	lines.append("State: %s" % state_name)

	# Time
	lines.append("Time: %s" % TimeManager.get_time_string())
	lines.append("Date: %s %s" % [TimeManager.get_day_name(), TimeManager.get_date_string()])
	lines.append("Weather: %s" % Enums.weather_name(TimeManager.current_weather))

	# Player info (if player exists)
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player: Node2D = players[0] as Node2D
		if player:
			lines.append("Pos: (%.0f, %.0f)" % [player.position.x, player.position.y])
			if "energy" in player:
				lines.append("Energy: %d/%d" % [player.energy, player.max_energy])
			if "health" in player:
				lines.append("Health: %d/%d" % [player.health, player.max_health])

	# Playtime
	var pt := GameManager.get_playtime_seconds()
	var hours := int(pt) / 3600
	var mins := (int(pt) % 3600) / 60
	lines.append("Playtime: %02d:%02d" % [hours, mins])

	# Scene
	lines.append("Scene: %s" % SceneLoader.get_current_scene_path().get_file())

	# Node count
	lines.append("Nodes: %d" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT))

	_overlay_label.text = "\n".join(lines)


## Convert GameState enum to readable string
func _game_state_name(state: Enums.GameState) -> String:
	match state:
		Enums.GameState.MAIN_MENU: return "MAIN_MENU"
		Enums.GameState.PLAYING: return "PLAYING"
		Enums.GameState.PAUSED: return "PAUSED"
		Enums.GameState.DIALOGUE: return "DIALOGUE"
		Enums.GameState.CUTSCENE: return "CUTSCENE"
		Enums.GameState.INVENTORY: return "INVENTORY"
		Enums.GameState.CRAFTING: return "CRAFTING"
		Enums.GameState.SHOPPING: return "SHOPPING"
		Enums.GameState.FISHING: return "FISHING"
		Enums.GameState.COMBAT: return "COMBAT"
		Enums.GameState.LOADING: return "LOADING"
	return "UNKNOWN"
