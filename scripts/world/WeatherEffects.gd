extends Node2D
## Weather visual effects: rain, storm (with lightning), cloudy overlay.
## Listens to SignalBus.weather_changed and updates particle effects.
## Particles follow the camera so they're always visible on screen.

var _rain_particles: GPUParticles2D
var _lightning_timer: Timer
var _lightning_flash: CanvasModulate
var _is_storming: bool = false
var _camera: Camera2D


func _ready() -> void:
	SignalBus.weather_changed.connect(_on_weather_changed)
	_create_rain_particles()
	_create_lightning_system()
	# Apply current weather immediately
	_apply_weather(TimeManager.current_weather)


func _process(_delta: float) -> void:
	# Follow camera position so particles stay on screen
	if _camera == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			_camera = players[0].get_node_or_null("Camera2D") as Camera2D

	if _camera:
		global_position = _camera.global_position


func _on_weather_changed(weather: int) -> void:
	_apply_weather(weather as Enums.Weather)


func _apply_weather(weather: Enums.Weather) -> void:
	match weather:
		Enums.Weather.CLEAR:
			_rain_particles.emitting = false
			_stop_lightning()
		Enums.Weather.CLOUDY:
			_rain_particles.emitting = false
			_stop_lightning()
		Enums.Weather.RAIN:
			_rain_particles.amount = 200
			_rain_particles.emitting = true
			_stop_lightning()
		Enums.Weather.STORM:
			_rain_particles.amount = 400
			_rain_particles.emitting = true
			_start_lightning()

	DebugManager.dlog("scene", "Weather visuals: %s" % Enums.weather_name(weather))


## Create the rain particle emitter (programmatic — no texture needed).
func _create_rain_particles() -> void:
	_rain_particles = GPUParticles2D.new()
	_rain_particles.name = "RainParticles"
	_rain_particles.emitting = false
	_rain_particles.amount = 200
	_rain_particles.lifetime = 0.6
	_rain_particles.visibility_rect = Rect2(-400, -300, 800, 600)

	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0.1, 1.0, 0.0)
	material.spread = 5.0
	material.initial_velocity_min = 400.0
	material.initial_velocity_max = 500.0
	material.gravity = Vector3(0.0, 200.0, 0.0)
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(400.0, 10.0, 0.0)
	material.scale_min = 0.5
	material.scale_max = 1.0
	material.color = Color(0.6, 0.7, 0.85, 0.5)

	_rain_particles.process_material = material

	# Simple 2x8 white rectangle as rain drop
	_rain_particles.texture = _create_raindrop_texture()

	add_child(_rain_particles)


## Create a tiny white texture for raindrop particles.
func _create_raindrop_texture() -> ImageTexture:
	var img := Image.create(2, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.85, 0.95, 0.7))
	return ImageTexture.create_from_image(img)


## Create the lightning flash system (screen flash + timer).
func _create_lightning_system() -> void:
	_lightning_timer = Timer.new()
	_lightning_timer.name = "LightningTimer"
	_lightning_timer.one_shot = true
	_lightning_timer.timeout.connect(_on_lightning_timer_timeout)
	add_child(_lightning_timer)


## Start random lightning flashes during storms.
func _start_lightning() -> void:
	_is_storming = true
	_schedule_next_lightning()


## Stop lightning effects.
func _stop_lightning() -> void:
	_is_storming = false
	_lightning_timer.stop()


func _schedule_next_lightning() -> void:
	if not _is_storming:
		return
	# Random interval between flashes: 3-10 seconds
	_lightning_timer.start(randf_range(3.0, 10.0))


func _on_lightning_timer_timeout() -> void:
	if not _is_storming:
		return

	# Flash effect: briefly brighten the screen
	_do_lightning_flash()
	_schedule_next_lightning()


func _do_lightning_flash() -> void:
	# Find the DayNightCycle CanvasModulate in our parent map
	var day_night := get_parent().get_node_or_null("DayNightCycle") as CanvasModulate
	if day_night == null:
		return

	var original_color := day_night.color
	var flash_color := Color(1.2, 1.2, 1.3)  # bright white flash

	var tween := create_tween()
	tween.tween_property(day_night, "color", flash_color, 0.05)
	tween.tween_property(day_night, "color", original_color, 0.15)
	# Second quick flash
	tween.tween_interval(0.1)
	tween.tween_property(day_night, "color", flash_color, 0.03)
	tween.tween_property(day_night, "color", original_color, 0.2)
