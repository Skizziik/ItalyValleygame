extends Node
## Audio manager handling BGM, SFX, ambient, and UI sounds.
## Autoloaded as "AudioManager". Uses Godot audio bus layout.

const BUS_MASTER := &"Master"
const BUS_BGM := &"BGM"
const BUS_SFX := &"SFX"
const BUS_AMBIENT := &"Ambient"
const BUS_UI := &"UI"

const SETTINGS_PATH := "user://audio_settings.cfg"
const MAX_CONCURRENT_SFX: int = 16

var _bgm_player: AudioStreamPlayer
var _bgm_player_fade: AudioStreamPlayer  # second player for crossfading
var _ambient_player: AudioStreamPlayer
var _ambient_player_fade: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _current_bgm_path: String = ""
var _current_ambient_path: String = ""
var _bgm_tween: Tween
var _ambient_tween: Tween
var _settings: ConfigFile


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_players()
	_load_settings()


## Play background music with optional crossfade
func play_bgm(stream: AudioStream, fade_duration: float = -1.0) -> void:
	if stream == null:
		stop_bgm(fade_duration)
		return

	if fade_duration < 0.0:
		fade_duration = Constants.BGM_CROSSFADE_DURATION

	# Skip if same track is already playing
	if _bgm_player.stream == stream and _bgm_player.playing:
		return

	if _bgm_tween:
		_bgm_tween.kill()

	if _bgm_player.playing and fade_duration > 0.0:
		# Crossfade: swap players
		var temp := _bgm_player
		_bgm_player = _bgm_player_fade
		_bgm_player_fade = temp

		# Fade out old player
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(_bgm_player_fade, "volume_db", -80.0, fade_duration)
		_bgm_tween.tween_callback(_bgm_player_fade.stop)

		# Start new track at low volume and fade in
		_bgm_player.stream = stream
		_bgm_player.volume_db = -80.0
		_bgm_player.play()
		_bgm_tween.parallel().tween_property(
			_bgm_player, "volume_db",
			_get_bus_volume_db(BUS_BGM), fade_duration
		)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = _get_bus_volume_db(BUS_BGM)
		_bgm_player.play()

	SignalBus.bgm_changed.emit(stream.resource_path if stream else "")


## Stop background music
func stop_bgm(fade_duration: float = -1.0) -> void:
	if fade_duration < 0.0:
		fade_duration = Constants.BGM_CROSSFADE_DURATION

	if _bgm_tween:
		_bgm_tween.kill()

	if fade_duration > 0.0 and _bgm_player.playing:
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(_bgm_player, "volume_db", -80.0, fade_duration)
		_bgm_tween.tween_callback(_bgm_player.stop)
	else:
		_bgm_player.stop()


## Play a one-shot sound effect
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_variance: float = 0.0) -> void:
	if stream == null:
		return

	var player := _get_sfx_player()
	if player == null:
		return

	player.stream = stream
	player.bus = BUS_SFX
	player.volume_db = volume_db
	if pitch_variance > 0.0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	else:
		player.pitch_scale = 1.0
	player.play()


## Play a UI sound effect (separate bus for independent volume)
func play_ui_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	var player := _get_sfx_player()
	if player == null:
		return

	player.stream = stream
	player.bus = BUS_UI
	player.volume_db = volume_db
	player.pitch_scale = 1.0
	player.play()


## Play ambient sound with crossfade
func play_ambient(stream: AudioStream, fade_duration: float = -1.0) -> void:
	if stream == null:
		stop_ambient(fade_duration)
		return

	if fade_duration < 0.0:
		fade_duration = Constants.AMBIENT_CROSSFADE_DURATION

	if _ambient_player.stream == stream and _ambient_player.playing:
		return

	if _ambient_tween:
		_ambient_tween.kill()

	if _ambient_player.playing and fade_duration > 0.0:
		var temp := _ambient_player
		_ambient_player = _ambient_player_fade
		_ambient_player_fade = temp

		_ambient_tween = create_tween()
		_ambient_tween.tween_property(_ambient_player_fade, "volume_db", -80.0, fade_duration)
		_ambient_tween.tween_callback(_ambient_player_fade.stop)

		_ambient_player.stream = stream
		_ambient_player.volume_db = -80.0
		_ambient_player.play()
		_ambient_tween.parallel().tween_property(
			_ambient_player, "volume_db",
			_get_bus_volume_db(BUS_AMBIENT), fade_duration
		)
	else:
		_ambient_player.stream = stream
		_ambient_player.volume_db = _get_bus_volume_db(BUS_AMBIENT)
		_ambient_player.play()


## Stop ambient sound
func stop_ambient(fade_duration: float = -1.0) -> void:
	if fade_duration < 0.0:
		fade_duration = Constants.AMBIENT_CROSSFADE_DURATION

	if _ambient_tween:
		_ambient_tween.kill()

	if fade_duration > 0.0 and _ambient_player.playing:
		_ambient_tween = create_tween()
		_ambient_tween.tween_property(_ambient_player, "volume_db", -80.0, fade_duration)
		_ambient_tween.tween_callback(_ambient_player.stop)
	else:
		_ambient_player.stop()


## Set volume for a bus (0.0 to 1.0 linear scale)
func set_volume(bus_name: StringName, linear: float) -> void:
	linear = clampf(linear, 0.0, 1.0)
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_error("AudioManager: bus '%s' not found" % bus_name)
		return

	var db := linear_to_db(linear) if linear > 0.0 else -80.0
	AudioServer.set_bus_volume_db(bus_index, db)
	AudioServer.set_bus_mute(bus_index, linear <= 0.0)

	_save_settings()
	SignalBus.volume_changed.emit(bus_name, linear)


## Get volume for a bus (returns 0.0 to 1.0 linear)
func get_volume(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 0.0
	if AudioServer.is_bus_mute(bus_index):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))


## Set master volume
func set_master_volume(linear: float) -> void:
	set_volume(BUS_MASTER, linear)


## Get master volume
func get_master_volume() -> float:
	return get_volume(BUS_MASTER)


## Create audio players and SFX pool
func _setup_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_BGM
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)

	_bgm_player_fade = AudioStreamPlayer.new()
	_bgm_player_fade.bus = BUS_BGM
	_bgm_player_fade.name = "BGMPlayerFade"
	add_child(_bgm_player_fade)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = BUS_AMBIENT
	_ambient_player.name = "AmbientPlayer"
	add_child(_ambient_player)

	_ambient_player_fade = AudioStreamPlayer.new()
	_ambient_player_fade.bus = BUS_AMBIENT
	_ambient_player_fade.name = "AmbientPlayerFade"
	add_child(_ambient_player_fade)

	# Pre-create SFX player pool
	for i in range(MAX_CONCURRENT_SFX):
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_sfx_pool.append(player)


## Get an available SFX player from the pool
func _get_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	# All players busy — steal the oldest one
	return _sfx_pool[0]


## Get current volume_db for a bus (from AudioServer)
func _get_bus_volume_db(bus_name: StringName) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return 0.0
	return AudioServer.get_bus_volume_db(bus_index)


## Load volume settings from config file
func _load_settings() -> void:
	_settings = ConfigFile.new()
	var err := _settings.load(SETTINGS_PATH)
	if err != OK:
		return  # No settings file yet, use defaults

	for bus_name: StringName in [BUS_MASTER, BUS_BGM, BUS_SFX, BUS_AMBIENT, BUS_UI]:
		var key := String(bus_name).to_lower()
		if _settings.has_section_key("audio", key):
			var linear: float = _settings.get_value("audio", key, 1.0)
			set_volume(bus_name, linear)


## Save volume settings to config file
func _save_settings() -> void:
	if _settings == null:
		_settings = ConfigFile.new()

	for bus_name: StringName in [BUS_MASTER, BUS_BGM, BUS_SFX, BUS_AMBIENT, BUS_UI]:
		var key := String(bus_name).to_lower()
		_settings.set_value("audio", key, get_volume(bus_name))

	_settings.save(SETTINGS_PATH)
