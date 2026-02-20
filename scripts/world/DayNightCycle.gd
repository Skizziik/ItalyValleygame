extends CanvasModulate
## Day/night color tinting driven by TimeManager. Attach to a CanvasModulate node.
## Smoothly interpolates between color keyframes based on in-game time.

## When true, locks color to white (used for interiors).
var _override_active: bool = false
var _override_color: Color = Color.WHITE

## Color keyframes: hour → tint color. Interpolated linearly between entries.
var _keyframes: Array[Dictionary] = [
	{"hour": 3.0, "color": Color(0.15, 0.15, 0.30)},   # deep night
	{"hour": 5.0, "color": Color(0.75, 0.65, 0.55)},   # dawn
	{"hour": 7.0, "color": Color(0.95, 0.90, 0.85)},   # sunrise
	{"hour": 9.0, "color": Color(1.0, 1.0, 1.0)},      # full daylight
	{"hour": 14.0, "color": Color(1.0, 0.98, 0.95)},   # warm afternoon
	{"hour": 18.0, "color": Color(0.90, 0.75, 0.60)},  # golden hour
	{"hour": 20.0, "color": Color(0.50, 0.40, 0.55)},  # dusk
	{"hour": 22.0, "color": Color(0.20, 0.20, 0.35)},  # night
	{"hour": 27.0, "color": Color(0.15, 0.15, 0.30)},  # deep night (wraps)
]


func _ready() -> void:
	SignalBus.minute_changed.connect(_on_minute_changed)
	# Set initial color
	_update_color()


## Lock the tint to a fixed color (for interiors).
func set_override(override_color: Color) -> void:
	_override_active = true
	_override_color = override_color
	color = override_color


## Remove the override and return to time-based tinting.
func clear_override() -> void:
	_override_active = false
	_update_color()


func _on_minute_changed(_hour: int, _minute: int) -> void:
	if not _override_active:
		_update_color()


func _update_color() -> void:
	if _override_active:
		color = _override_color
		return

	var hour_f := float(TimeManager.current_hour) + float(TimeManager.current_minute) / 60.0
	color = _sample_color(hour_f)


## Interpolate the color for a given fractional hour.
func _sample_color(hour: float) -> Color:
	# Clamp / wrap hour for the keyframe range
	if hour < float(_keyframes[0]["hour"]):
		return _keyframes[0]["color"] as Color

	for i in range(_keyframes.size() - 1):
		var kf_a: Dictionary = _keyframes[i]
		var kf_b: Dictionary = _keyframes[i + 1]

		if hour >= float(kf_a["hour"]) and hour < float(kf_b["hour"]):
			var t: float = (hour - float(kf_a["hour"])) / (float(kf_b["hour"]) - float(kf_a["hour"]))
			return (kf_a["color"] as Color).lerp(kf_b["color"] as Color, t)

	# Past the last keyframe
	return _keyframes[_keyframes.size() - 1]["color"] as Color
