extends Node
## Global game enumerations. Autoloaded as "Enums".

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DIALOGUE,
	CUTSCENE,
	INVENTORY,
	CRAFTING,
	SHOPPING,
	FISHING,
	COMBAT,
	LOADING,
}

enum Season {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER,
}

enum Weather {
	CLEAR,
	CLOUDY,
	RAIN,
	STORM,
}

enum Quality {
	NORMAL,
	SILVER,
	GOLD,
}

enum ItemCategory {
	MATERIAL,
	TOOL,
	SEED,
	CROP,
	FISH,
	CRAFTED,
	FOOD,
	FURNITURE,
	QUEST,
	ARTIFACT,
}

enum ToolType {
	AXE,
	PICKAXE,
	HOE,
	WATERING_CAN,
	FISHING_ROD,
	SCYTHE,
	KNIFE,
}

enum ToolTier {
	BASIC,
	COPPER,
	IRON,
	GOLD,
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

enum TimeOfDay {
	DAWN,
	MORNING,
	AFTERNOON,
	EVENING,
	NIGHT,
}

enum RelationshipLevel {
	STRANGER,
	ACQUAINTANCE,
	FRIEND,
	CLOSE_FRIEND,
	BEST_FRIEND,
}


## Helper: Season name as localization key
func season_name(season: Season) -> String:
	match season:
		Season.SPRING: return "SEASON_SPRING"
		Season.SUMMER: return "SEASON_SUMMER"
		Season.AUTUMN: return "SEASON_AUTUMN"
		Season.WINTER: return "SEASON_WINTER"
	return "SEASON_UNKNOWN"


## Helper: Weather name as localization key
func weather_name(weather: Weather) -> String:
	match weather:
		Weather.CLEAR: return "WEATHER_CLEAR"
		Weather.CLOUDY: return "WEATHER_CLOUDY"
		Weather.RAIN: return "WEATHER_RAIN"
		Weather.STORM: return "WEATHER_STORM"
	return "WEATHER_UNKNOWN"


## Helper: Quality name as localization key
func quality_name(quality: Quality) -> String:
	match quality:
		Quality.NORMAL: return "QUALITY_NORMAL"
		Quality.SILVER: return "QUALITY_SILVER"
		Quality.GOLD: return "QUALITY_GOLD"
	return "QUALITY_UNKNOWN"


## Helper: Quality price multiplier
func quality_price_multiplier(quality: Quality) -> float:
	match quality:
		Quality.NORMAL: return 1.0
		Quality.SILVER: return 1.25
		Quality.GOLD: return 1.5
	return 1.0


## Helper: Time of day from hour
func time_of_day_from_hour(hour: int) -> TimeOfDay:
	if hour >= 5 and hour < 8:
		return TimeOfDay.DAWN
	elif hour >= 8 and hour < 12:
		return TimeOfDay.MORNING
	elif hour >= 12 and hour < 17:
		return TimeOfDay.AFTERNOON
	elif hour >= 17 and hour < 21:
		return TimeOfDay.EVENING
	else:
		return TimeOfDay.NIGHT


## Helper: Hearts required for relationship level
func hearts_for_level(level: RelationshipLevel) -> int:
	match level:
		RelationshipLevel.STRANGER: return 0
		RelationshipLevel.ACQUAINTANCE: return 2
		RelationshipLevel.FRIEND: return 4
		RelationshipLevel.CLOSE_FRIEND: return 7
		RelationshipLevel.BEST_FRIEND: return 10
	return 0


## Helper: Relationship level from hearts count
func level_from_hearts(hearts: int) -> RelationshipLevel:
	if hearts >= 10:
		return RelationshipLevel.BEST_FRIEND
	elif hearts >= 7:
		return RelationshipLevel.CLOSE_FRIEND
	elif hearts >= 4:
		return RelationshipLevel.FRIEND
	elif hearts >= 2:
		return RelationshipLevel.ACQUAINTANCE
	else:
		return RelationshipLevel.STRANGER
