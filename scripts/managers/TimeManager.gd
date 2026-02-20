extends Node
## In-game clock, calendar, and weather system. Autoloaded as "TimeManager".
## Uses delta accumulation — game time is independent of real time.

var current_hour: int = 6
var current_minute: int = 0
var current_day: int = 1
var current_season: Enums.Season = Enums.Season.SPRING
var current_year: int = 1
var current_weather: Enums.Weather = Enums.Weather.CLEAR
var tomorrow_weather: Enums.Weather = Enums.Weather.CLEAR

var time_scale: float = 1.0
var _accumulated_seconds: float = 0.0
var _day_names: PackedStringArray = [
	"MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"
]

## Weather probability tables per season [CLEAR, CLOUDY, RAIN, STORM]
var _weather_chances: Dictionary = {
	Enums.Season.SPRING: [0.40, 0.25, 0.30, 0.05],
	Enums.Season.SUMMER: [0.55, 0.25, 0.15, 0.05],
	Enums.Season.AUTUMN: [0.30, 0.30, 0.30, 0.10],
	Enums.Season.WINTER: [0.35, 0.35, 0.25, 0.05],
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_roll_tomorrow_weather()


func _process(delta: float) -> void:
	if not GameManager.is_gameplay_active():
		return

	_accumulated_seconds += delta * time_scale
	var minutes_to_add := int(_accumulated_seconds * Constants.GAME_MINUTES_PER_REAL_SECOND)

	if minutes_to_add > 0:
		_accumulated_seconds -= float(minutes_to_add) / Constants.GAME_MINUTES_PER_REAL_SECOND
		_advance_minutes(minutes_to_add)


## Advance the clock by a number of minutes, triggering signals as needed
func _advance_minutes(minutes: int) -> void:
	for _i in range(minutes):
		var old_hour := current_hour
		current_minute += 1

		if current_minute >= 60:
			current_minute = 0
			current_hour += 1
			SignalBus.hour_changed.emit(current_hour)

			if current_hour >= Constants.DAY_END_HOUR:
				_end_day()
				return

		if current_hour != old_hour or current_minute % 10 == 0:
			SignalBus.minute_changed.emit(current_hour, current_minute)


## Force advance to the next day (used for sleeping)
func advance_day() -> void:
	_end_day()


## Set time directly (debug / quest use)
func set_time(hour: int, minute: int) -> void:
	current_hour = clampi(hour, 0, 25)
	current_minute = clampi(minute, 0, 59)
	SignalBus.hour_changed.emit(current_hour)
	SignalBus.minute_changed.emit(current_hour, current_minute)


## Force weather change (debug / quest use)
func set_weather(weather: Enums.Weather) -> void:
	current_weather = weather
	SignalBus.weather_changed.emit(current_weather)


## Formatted time string: "14:30"
func get_time_string() -> String:
	var display_hour := current_hour % 24
	return "%02d:%02d" % [display_hour, current_minute]


## Formatted date string: "Day 15, Summer, Year 1"
func get_date_string() -> String:
	var season_name := _season_display_name()
	return "Day %d, %s, Year %d" % [current_day, season_name, current_year]


## Day of the week name (MON-SUN based on day number)
func get_day_name() -> String:
	var day_index := (current_day - 1) % 7
	return _day_names[day_index]


## True if it's a market day (every 7th day = Saturday)
func is_market_day() -> bool:
	return current_day % 7 == 6  # Saturday = day 6, 13, 20, 27


## True when it's nighttime (hour >= 20 or < 6)
func is_night() -> bool:
	var h := current_hour % 24
	return h >= 20 or h < 6


## Current time of day enum
func get_time_of_day() -> Enums.TimeOfDay:
	return Enums.time_of_day_from_hour(current_hour % 24)


## Total days elapsed since game start (for crop calculations, etc.)
func get_total_days() -> int:
	return (current_year - 1) * Constants.DAYS_PER_YEAR \
		+ current_season * Constants.DAYS_PER_SEASON \
		+ current_day


## Serialize for save system
func serialize() -> Dictionary:
	return {
		"hour": current_hour,
		"minute": current_minute,
		"day": current_day,
		"season": current_season,
		"year": current_year,
		"weather": current_weather,
		"tomorrow_weather": tomorrow_weather,
	}


## Deserialize from save data
func deserialize(data: Dictionary) -> void:
	current_hour = data.get("hour", 6)
	current_minute = data.get("minute", 0)
	current_day = data.get("day", 1)
	current_season = data.get("season", Enums.Season.SPRING) as Enums.Season
	current_year = data.get("year", 1)
	current_weather = data.get("weather", Enums.Weather.CLEAR) as Enums.Weather
	tomorrow_weather = data.get("tomorrow_weather", Enums.Weather.CLEAR) as Enums.Weather


## Reset to day 1 spring year 1 (new game)
func reset() -> void:
	current_hour = Constants.DAY_START_HOUR
	current_minute = 0
	current_day = 1
	current_season = Enums.Season.SPRING
	current_year = 1
	current_weather = Enums.Weather.CLEAR
	_accumulated_seconds = 0.0
	_roll_tomorrow_weather()


## End the current day and advance to the next
func _end_day() -> void:
	SignalBus.day_ended.emit()

	current_hour = Constants.DAY_START_HOUR
	current_minute = 0
	current_day += 1
	_accumulated_seconds = 0.0

	if current_day > Constants.DAYS_PER_SEASON:
		current_day = 1
		_advance_season()

	# Apply tomorrow's weather forecast
	current_weather = tomorrow_weather
	_roll_tomorrow_weather()
	SignalBus.weather_changed.emit(current_weather)
	SignalBus.weather_forecast_ready.emit(tomorrow_weather)
	SignalBus.day_started.emit(current_day)
	SignalBus.hour_changed.emit(current_hour)
	SignalBus.minute_changed.emit(current_hour, current_minute)


## Advance to the next season, possibly next year
func _advance_season() -> void:
	var next_season := (current_season + 1) as Enums.Season
	if next_season > Enums.Season.WINTER:
		next_season = Enums.Season.SPRING
		current_year += 1
		SignalBus.year_changed.emit(current_year)

	current_season = next_season
	SignalBus.season_changed.emit(current_season)


## Roll tomorrow's weather based on seasonal probability table
func _roll_tomorrow_weather() -> void:
	var chances: Array = _weather_chances.get(current_season, [0.5, 0.25, 0.2, 0.05])
	var roll := randf()
	var cumulative := 0.0

	for i in range(chances.size()):
		cumulative += chances[i]
		if roll <= cumulative:
			tomorrow_weather = i as Enums.Weather
			return

	tomorrow_weather = Enums.Weather.CLEAR


## Season display name for UI (uses localization key via Enums helper)
func _season_display_name() -> String:
	var key := Enums.season_name(current_season)
	var translated := tr(key)
	# If translation not found, return English fallback
	if translated == key:
		match current_season:
			Enums.Season.SPRING: return "Spring"
			Enums.Season.SUMMER: return "Summer"
			Enums.Season.AUTUMN: return "Autumn"
			Enums.Season.WINTER: return "Winter"
	return translated
