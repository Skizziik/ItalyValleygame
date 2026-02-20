extends Node
## Global game constants. Autoloaded as "Constants".

# --- Rendering ---
const TILE_SIZE: int = 16
const VIEWPORT_WIDTH: int = 640
const VIEWPORT_HEIGHT: int = 360

# --- Player Movement ---
const PLAYER_SPEED: float = 80.0
const PLAYER_RUN_MULTIPLIER: float = 1.5
const PLAYER_DASH_SPEED: float = 200.0
const PLAYER_DASH_DURATION: float = 0.15

# --- Player Stats ---
const MAX_ENERGY: int = 100
const MAX_HEALTH: int = 100
const ENERGY_REGEN_ON_SLEEP: float = 1.0  # multiplier: 1.0 = full restore
const EXHAUSTION_SPEED_PENALTY: float = 0.5  # speed multiplier at 0 energy

# --- Energy Costs ---
const ENERGY_COST_CHOP: int = 5
const ENERGY_COST_MINE: int = 6
const ENERGY_COST_HOE: int = 4
const ENERGY_COST_WATER: int = 3
const ENERGY_COST_FISH_CAST: int = 2
const ENERGY_COST_COMBAT_SWING: int = 3

# --- Inventory ---
const INVENTORY_ROWS: int = 6
const INVENTORY_COLS: int = 6
const INVENTORY_SIZE: int = INVENTORY_ROWS * INVENTORY_COLS  # 36
const HOTBAR_SLOTS: int = 10
const STACK_MAX_DEFAULT: int = 999
const STACK_MAX_TOOL: int = 1
const STACK_MAX_FOOD: int = 50
const STACK_MAX_SEED: int = 999
const STACK_MAX_FURNITURE: int = 99

# --- Storage ---
const CHEST_SLOTS_SMALL: int = 18
const CHEST_SLOTS_LARGE: int = 36
const FRIDGE_SLOTS: int = 24

# --- Time & Calendar ---
const DAYS_PER_SEASON: int = 28
const SEASONS_PER_YEAR: int = 4
const DAYS_PER_YEAR: int = DAYS_PER_SEASON * SEASONS_PER_YEAR  # 112
const DAY_START_HOUR: int = 6
const DAY_END_HOUR: int = 26  # 2:00 AM next day (represented as 26 for math)
const GAME_MINUTES_PER_REAL_SECOND: float = 0.7  # tunable: how fast time passes
const PASS_OUT_HOUR: int = 26  # forced sleep

# --- Economy ---
const STARTING_MONEY: int = 500  # €500
const MARKET_DAY: int = 7  # every 7th day = Saturday market
const MARKET_PRICE_BONUS: float = 1.25  # 25% price boost on market days
const SELL_PRICE_MULTIPLIER: float = 0.5  # items sell for 50% of base price

# --- NPC / Relationships ---
const MAX_HEARTS: int = 10
const HEART_POINTS_PER_HEART: int = 250
const MAX_FRIENDSHIP_POINTS: int = MAX_HEARTS * HEART_POINTS_PER_HEART  # 2500
const GIFT_POINTS_LOVED: int = 80
const GIFT_POINTS_LIKED: int = 45
const GIFT_POINTS_NEUTRAL: int = 20
const GIFT_POINTS_DISLIKED: int = -20
const GIFT_POINTS_HATED: int = -40
const GIFTS_PER_DAY: int = 1
const TALK_POINTS: int = 10  # points for daily conversation

# --- Farming ---
const CROP_QUALITY_CHANCE_SILVER: float = 0.15  # 15% base chance for silver
const CROP_QUALITY_CHANCE_GOLD: float = 0.05  # 5% base chance for gold
const FERTILIZER_QUALITY_BONUS: float = 0.15  # +15% to quality chances
const WATERED_GROWTH_SPEED: float = 1.0  # normal growth when watered
const UNWATERED_GROWTH_SPEED: float = 0.0  # no growth when not watered

# --- Fishing ---
const FISH_MINIGAME_DURATION: float = 15.0  # seconds for fishing minigame
const FISH_BAR_SPEED: float = 300.0
const FISH_CATCH_ZONE_SIZE: float = 0.2  # fraction of bar (20%)

# --- Combat ---
const INVINCIBILITY_DURATION: float = 0.8  # seconds after taking damage
const KNOCKBACK_FORCE: float = 150.0
const LOOT_MAGNET_RADIUS: float = 48.0  # pixels

# --- Scene Transitions ---
const FADE_DURATION: float = 0.4  # seconds for fade in/out
const SCENE_LOAD_MIN_DISPLAY: float = 0.3  # minimum time to show loading

# --- Save System ---
const AUTOSAVE_INTERVAL: float = 300.0  # 5 minutes
const AUTOSAVE_SLOT: int = 999
const MAX_SAVE_SLOTS: int = 5
const SAVE_VERSION: int = 1

# --- Audio ---
const BGM_CROSSFADE_DURATION: float = 1.0  # seconds
const AMBIENT_CROSSFADE_DURATION: float = 2.0
const DEFAULT_SFX_VOLUME_DB: float = 0.0
const DEFAULT_BGM_VOLUME_DB: float = -6.0
const DEFAULT_AMBIENT_VOLUME_DB: float = -10.0
const DEFAULT_UI_VOLUME_DB: float = -3.0

# --- Maps ---
const FARM_MAP_WIDTH: int = 40   # tiles
const FARM_MAP_HEIGHT: int = 30  # tiles
const FARMHOUSE_MAP_WIDTH: int = 12  # tiles
const FARMHOUSE_MAP_HEIGHT: int = 10  # tiles

# --- Physics Layers (bit indices, not values) ---
const PHYSICS_LAYER_WORLD: int = 1
const PHYSICS_LAYER_PLAYER: int = 2
const PHYSICS_LAYER_NPC: int = 3
const PHYSICS_LAYER_INTERACTABLE: int = 4
const PHYSICS_LAYER_TOOL_TARGET: int = 5
const PHYSICS_LAYER_ENEMY: int = 6

# --- Debug ---
const DEBUG_OVERLAY_UPDATE_INTERVAL: float = 0.25  # update overlay 4x per second
