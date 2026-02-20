# Italy Valley — Master Task List

> **Last updated:** 2026-02-20
> **Legend:** `- [x]` = done | `- [ ]` = pending
> Phases are roughly sequential, but some can overlap.

---

## Phase 0: Project Setup

- [x] Create Godot 4.6 project
- [x] Configure for 2D pixel art (GL Compatibility renderer)
- [x] Set viewport to 640x360, window override 1280x720
- [x] Set stretch mode "viewport", aspect "keep"
- [x] Set default texture filter to Nearest (pixel-perfect rendering)
- [x] Set up folder structure: `scenes/`, `scripts/`, `data/`, `assets/`, `docs/`, `tests/`
- [x] Configure input map: move_up (W / Up), move_down (S / Down), move_left (A / Left), move_right (D / Right)
- [x] Configure input map: interact (E), use_tool (LMB), inventory (I), journal (J), map (M), quests (Q), craft (C), pause (Esc)
- [x] Create `docs/GDD.md` (Game Design Document)
- [x] Create `docs/TASKS.md` (this file)
- [ ] Create `docs/ROADMAP.md` (milestone timeline with target dates)
- [ ] Create `docs/ASSETS_LICENSES.md` (source, license, attribution for every asset)
- [ ] Create `README.md` (how to run, controls, project structure)
- [ ] Initialize git repository
- [ ] Set up `.gitignore` for Godot (exclude `.godot/`, `*.import` cached files)
- [ ] Push initial commit to GitHub (`ItalyValleygame` repo)
- [ ] Configure internationalization settings for RU/EN

---

## Phase 1: Core Engine & Manager Autoloads

### 1.1 GameManager (Autoload)
- [ ] Create `GameManager.gd` autoload script
- [ ] Define game states enum: MAIN_MENU, PLAYING, PAUSED, DIALOGUE, CUTSCENE, INVENTORY, CRAFTING, SHOPPING, FISHING, COMBAT, LOADING
- [ ] Implement state machine with `change_state()` and state transition validation
- [ ] Implement `is_gameplay_active()` helper (blocks input during menus/dialogue)
- [ ] Add global pause toggle (set `get_tree().paused`)
- [ ] Register GameManager as autoload in project.godot

### 1.2 SignalBus (Autoload)
- [ ] Create `SignalBus.gd` global signal bus autoload
- [ ] Define core signals: `day_started`, `day_ended`, `season_changed`, `weather_changed`
- [ ] Define player signals: `player_energy_changed`, `player_health_changed`, `player_money_changed`
- [ ] Define inventory signals: `item_added`, `item_removed`, `item_used`, `hotbar_changed`
- [ ] Define NPC signals: `friendship_changed`, `gift_given`, `dialogue_started`, `dialogue_ended`
- [ ] Define quest signals: `quest_started`, `quest_completed`, `quest_failed`, `quest_objective_updated`
- [ ] Define economy signals: `item_sold`, `item_bought`, `shop_opened`, `shop_closed`
- [ ] Define world signals: `crop_planted`, `crop_harvested`, `tree_chopped`, `rock_mined`
- [ ] Define combat signals: `enemy_hit`, `enemy_defeated`, `player_hit`, `boss_phase_changed`

### 1.3 SceneLoader (Autoload)
- [ ] Create `SceneLoader.gd` autoload for scene transitions
- [ ] Implement `change_scene(path, transition_type)` method
- [ ] Implement fade-to-black transition (ColorRect + AnimationPlayer)
- [ ] Implement fade-to-white transition (for special events)
- [ ] Add loading screen support for larger scenes
- [ ] Handle spawn point data between scenes (entry position + direction)
- [ ] Prevent double-loading / input during transition

### 1.4 AudioManager (Autoload)
- [ ] Create `AudioManager.gd` autoload
- [ ] Implement BGM (background music) player with crossfade
- [ ] Implement ambient sound layer (separate from BGM)
- [ ] Implement SFX player (pooled AudioStreamPlayers for concurrent sounds)
- [ ] Implement UI sound player (clicks, hovers, open/close)
- [ ] Add volume controls: master, music, ambient, SFX, UI
- [ ] Add music transition system (fade out old, fade in new)
- [ ] Implement `play_bgm()`, `play_sfx()`, `play_ambient()`, `play_ui_sound()` methods
- [ ] Mute / unmute support

### 1.5 Debug System
- [ ] Create `DebugManager.gd` autoload
- [ ] Implement DEBUG flag toggle (F3 or config)
- [ ] Create on-screen debug overlay (FPS, game state, time, position, season, weather)
- [ ] Implement debug console / command input (toggle with tilde ~)
- [ ] Add debug commands: `set_time`, `set_season`, `give_item`, `set_money`, `teleport`, `set_friendship`
- [ ] Add debug commands: `spawn_enemy`, `godmode`, `skip_day`, `set_weather`
- [ ] Log system with severity levels (INFO, WARN, ERROR) and file output
- [ ] Ensure all debug features are disabled in release builds

### 1.6 Constants & Enums
- [ ] Create `Constants.gd` with game-wide constants (tile size, max stack, etc.)
- [ ] Create `Enums.gd` with shared enums (ItemCategory, Season, Weather, Quality, ToolTier, etc.)
- [ ] Define item categories: RESOURCE, MATERIAL, SEED, CROP, FISH, FOOD, TOOL, WEAPON, FURNITURE, QUEST, ARTIFACT, CRAFTED_GOOD, ANIMAL_PRODUCT
- [ ] Define quality levels: NORMAL, SILVER, GOLD, IRIDIUM
- [ ] Define seasons: SPRING, SUMMER, AUTUMN, WINTER
- [ ] Define weather types: CLEAR, CLOUDY, RAIN, STORM
- [ ] Define tool tiers: BASIC, COPPER, IRON, GOLD

---

## Phase 2: Player Character

### 2.1 Player Scene & Movement
- [ ] Create `Player.tscn` scene (CharacterBody2D)
- [ ] Add Sprite2D (placeholder rectangle or simple sprite)
- [ ] Add CollisionShape2D (appropriate hitbox)
- [ ] Create `Player.gd` script extending CharacterBody2D
- [ ] Implement 8-directional movement (WASD / Arrow keys)
- [ ] Implement walk speed (base ~80 px/s)
- [ ] Implement run speed (hold Shift, ~130 px/s)
- [ ] Track facing direction (last non-zero input vector)
- [ ] Prevent movement during dialogue/menus/cutscenes (check GameManager state)
- [ ] Add smooth acceleration / deceleration for cozy feel

### 2.2 Player Animation
- [ ] Create AnimationPlayer or AnimatedSprite2D node
- [ ] Define animation states: idle_down, idle_up, idle_left, idle_right
- [ ] Define animation states: walk_down, walk_up, walk_left, walk_right
- [ ] Define animation states: run_down, run_up, run_left, run_right
- [ ] Define animation states: use_tool_down, use_tool_up, use_tool_left, use_tool_right
- [ ] Create AnimationTree with state machine for smooth transitions
- [ ] Implement animation direction sync with movement direction
- [ ] Add placeholder sprite frames (colored rectangles per direction)

### 2.3 Camera
- [ ] Add Camera2D as child of Player
- [ ] Enable position smoothing for smooth follow
- [ ] Set camera zoom appropriate for 640x360 viewport
- [ ] Implement camera limits (clamp to map bounds)
- [ ] Add camera shake method (for tool impacts, combat hits)

### 2.4 Energy / Stamina System
- [ ] Add `max_energy` and `current_energy` to Player
- [ ] Default max energy: 100 (upgradeable later)
- [ ] Implement `use_energy(amount)` method with validation
- [ ] Implement energy depletion effects: speed reduction at <20%, block heavy actions at 0
- [ ] Implement energy restoration: sleep (full restore), food (partial restore)
- [ ] Emit `player_energy_changed` signal on change
- [ ] Add energy bar UI element (see Phase 23)

### 2.5 Health System
- [ ] Add `max_health` and `current_health` to Player
- [ ] Default max health: 100
- [ ] Implement `take_damage(amount)` method with invincibility frames
- [ ] Implement `heal(amount)` method
- [ ] Implement death/knockout: teleport home, lose some energy, lose small amount of money
- [ ] Implement invincibility frames after taking damage (flashing sprite)
- [ ] Emit `player_health_changed` signal on change
- [ ] Add health bar UI element (see Phase 23)

### 2.6 Player Interaction
- [ ] Add Area2D for interaction detection (in front of player, based on facing direction)
- [ ] Implement interaction raycast or overlap check
- [ ] Show contextual prompt ("Press E to ...") when near interactable
- [ ] Handle interaction input (E key) to trigger nearest interactable
- [ ] Create `Interactable` base class / interface for objects
- [ ] Prioritize closest interactable when multiple overlap

---

## Phase 3: World & TileMap

### 3.1 TileMap Setup
- [ ] Create base TileMap node in world scene
- [ ] Configure tile size (16x16 pixels)
- [ ] Set up terrain layers: ground (grass, dirt, sand, stone, water)
- [ ] Set up terrain layer: paths (cobblestone, gravel, wooden planks)
- [ ] Set up terrain layer: farmland (soil states)
- [ ] Set up decoration layer (flowers, pebbles, grass tufts)
- [ ] Set up collision layer on TileMap (walls, water, cliffs)
- [ ] Configure physics layers: WORLD, PLAYER, NPC, ENEMY, INTERACTABLE, PROJECTILE
- [ ] Add navigation layer for NPC pathfinding

### 3.2 First Test Map — Farm
- [ ] Design farm layout (house, garden plots, shed area, path to village)
- [ ] Paint ground tiles (grass, dirt, farmland plots)
- [ ] Add collision boundaries (fences, edges)
- [ ] Place player spawn point marker
- [ ] Place house entrance door (scene transition trigger)
- [ ] Place mailbox interactable
- [ ] Place shipping box interactable
- [ ] Add farm boundary markers / fences

### 3.3 Village Map
- [ ] Design village layout (piazza, cafe, market, dock, residential)
- [ ] Paint village tiles (cobblestone, buildings, plazas)
- [ ] Place building entrances (cafe, shop, mayor's office, etc.)
- [ ] Add NPC spawn/path points
- [ ] Add bulletin board on piazza
- [ ] Place benches, lampposts, decorative elements

### 3.4 Beach / Coast Map
- [ ] Design beach layout (shoreline, dock, fishing spots)
- [ ] Paint beach tiles (sand, water edge, rocks, pier)
- [ ] Place fishing interaction points
- [ ] Add beach loot spawn points (shells, glass, bottles)
- [ ] Add transition to village and cliffside

### 3.5 Forest / Olive Groves Map
- [ ] Design forest area (trees, clearings, olive groves, herb patches)
- [ ] Paint forest tiles (dense grass, tree bases, paths)
- [ ] Place choppable trees
- [ ] Place foraging spots (herbs, mushrooms)
- [ ] Add transition to ruins entrance

### 3.6 Vineyard / Hills Map
- [ ] Design vineyard hillside area
- [ ] Paint vineyard tiles (grape rows, hillside paths)
- [ ] Place grape harvest interaction points
- [ ] Add overlook / vista point

### 3.7 Ruins Entrance (Overworld)
- [ ] Design ruins exterior area
- [ ] Paint ancient stone tiles, crumbled walls
- [ ] Place dungeon entrance (scene transition to dungeon)
- [ ] Add atmospheric elements (moss, cracks, fallen pillars)

### 3.8 Interior Maps
- [ ] Player house interior (bedroom, kitchen, living area)
- [ ] Cafe interior
- [ ] Shop interior
- [ ] Mayor's office interior
- [ ] Archaeologist's study interior

### 3.9 Scene Transitions
- [ ] Create `SceneTransitionArea.tscn` (Area2D trigger)
- [ ] Implement `target_scene` and `spawn_point` export variables
- [ ] Trigger SceneLoader fade transition on player overlap
- [ ] Pass spawn position and facing direction to new scene
- [ ] Test all transitions between maps

### 3.10 Day/Night Lighting
- [ ] Add CanvasModulate node for global tint
- [ ] Define color curves for time-of-day: dawn (6:00), morning, noon, afternoon, dusk, evening, night
- [ ] Implement smooth color interpolation based on TimeManager
- [ ] Add interior lighting override (constant inside buildings)
- [ ] Add point lights for lamps, windows at night
- [ ] Add streetlamp auto-on at dusk

### 3.11 Weather System (Visual)
- [ ] Create rain particle effect (GPUParticles2D)
- [ ] Create storm particle effect (heavy rain + lightning flashes)
- [ ] Create cloudy overlay (subtle darkening)
- [ ] Implement clear weather (no overlay, bright sun tint)
- [ ] Sync weather visuals with TimeManager weather state
- [ ] Add puddle sprites that appear during rain (optional)

### 3.12 Seasonal Tile Swaps
- [ ] Create spring tile variants (green grass, flowers, blossoms)
- [ ] Create summer tile variants (lush green, dry patches, bright)
- [ ] Create autumn tile variants (orange/brown leaves, harvest colors)
- [ ] Create winter tile variants (snow, bare trees, frost)
- [ ] Implement automatic tile swap on season change
- [ ] Swap tree sprites per season
- [ ] Swap foliage/flower decorations per season

---

## Phase 4: Time & Calendar System

### 4.1 TimeManager (Autoload)
- [ ] Create `TimeManager.gd` autoload
- [ ] Define in-game time variables: `current_hour`, `current_minute`
- [ ] Define time range: 6:00 AM to 2:00 AM (next day)
- [ ] Configure real-seconds-per-game-minute ratio (e.g., 0.7s = 1 game minute => ~14 min real = 1 game day)
- [ ] Implement `advance_time(minutes)` method
- [ ] Implement `is_daytime()`, `is_nighttime()`, `is_morning()`, `is_evening()` helpers
- [ ] Pause time progression during menus, dialogue, cutscenes
- [ ] Emit `time_changed` signal every game minute
- [ ] Emit `hour_changed` signal every game hour

### 4.2 Calendar
- [ ] Define calendar structure: 4 seasons x 28 days = 112 days per year
- [ ] Track `current_day` (1-28), `current_season` (SPRING/SUMMER/AUTUMN/WINTER), `current_year`
- [ ] Track day of week (Monday-Sunday, 7-day weeks, 4 weeks per season)
- [ ] Implement `advance_day()` (called on sleep)
- [ ] Implement season transition logic (day 28 -> day 1 of next season)
- [ ] Emit `day_started` signal with day/season/weather info
- [ ] Emit `season_changed` signal with new season

### 4.3 Weather Generation
- [ ] Define weather probabilities per season (spring: more rain, summer: mostly clear, autumn: cloudy/rain, winter: cold/overcast)
- [ ] Generate next-day weather on sleep (or at day start)
- [ ] Allow weather to change mid-day (rare, e.g., sudden storm)
- [ ] Store `current_weather` and `tomorrow_weather`
- [ ] Emit `weather_changed` signal
- [ ] TV/radio weather forecast for tomorrow (interaction with home object)

### 4.4 Season Change Events
- [ ] Trigger visual tile swap on season change
- [ ] Update crop validity (seasonal crops die if out-of-season)
- [ ] Update NPC dialogues for new season
- [ ] Update shop inventories for season
- [ ] Trigger season-start notification to player

### 4.5 Time/Date UI
- [ ] Create HUD clock display (current time, 12h or 24h format)
- [ ] Create HUD date display (day number, season name, day of week)
- [ ] Create HUD weather icon (sun, cloud, rain, storm)
- [ ] Update UI elements in real-time from TimeManager
- [ ] Position clock/date in top-right corner of screen
- [ ] Style UI with pixel art theme

---

## Phase 5: Inventory System

### 5.1 Item Data Structure
- [ ] Create `data/items.json` with item definitions
- [ ] Define item schema: `id`, `name_key` (for localization), `description_key`, `category`, `stack_max`, `base_price`, `rarity`, `seasons`, `quality_rules`, `icon_path`, `sprite_path`, `tags`
- [ ] Populate initial items: basic tools (axe, pickaxe, hoe, watering_can, fishing_rod)
- [ ] Populate initial items: materials (wood, stone, copper_ore, iron_ore, coal, fiber, clay)
- [ ] Populate initial items: seeds (tomato_seeds, basil_seeds, grape_seeds, olive_seeds, lemon_seeds, wheat_seeds, garlic_seeds, onion_seeds, eggplant_seeds, zucchini_seeds, pepper_seeds, rosemary_seeds, oregano_seeds, thyme_seeds)
- [ ] Populate initial items: crops/produce (tomato, basil, grape, olive, lemon, wheat, garlic, onion, eggplant, zucchini, pepper, rosemary, oregano, thyme)
- [ ] Populate initial items: fish (sardine, anchovy, dorado, sea_bass, trout, carp, squid, octopus, shrimp, swordfish)
- [ ] Populate initial items: foraging (wild_mushroom, wild_berries, pine_cone, seashell, sea_glass, message_in_bottle)
- [ ] Populate initial items: animal products (egg, milk, goat_cheese, wool, honey)
- [ ] Populate initial items: crafted goods (olive_oil, wine, dried_herbs, flour, tomato_sauce)
- [ ] Populate initial items: food (espresso, cappuccino, cornetto, pasta_pomodoro, focaccia, panini, minestrone, bruschetta)
- [ ] Populate initial items: artifacts (ancient_coin, mosaic_fragment, amphora_shard, roman_ring, etruscan_figurine)
- [ ] Populate initial items: furniture (wooden_table, wooden_chair, bookshelf, flower_pot, rug, painting, lamp)

### 5.2 ItemDatabase Loader
- [ ] Create `ItemDatabase.gd` singleton/autoload
- [ ] Load and parse `items.json` on game start
- [ ] Validate all required fields exist for each item
- [ ] Validate icon_path references exist
- [ ] Log clear error messages for invalid/missing data
- [ ] Provide `get_item(id)` method returning item data dictionary
- [ ] Provide `get_items_by_category(category)` method
- [ ] Provide `get_items_by_tag(tag)` method
- [ ] Provide `get_items_by_season(season)` method

### 5.3 Inventory Data Model
- [ ] Create `Inventory.gd` class (not autoload — reusable for player + chests)
- [ ] Define slot structure: `{ item_id, quantity, quality }`
- [ ] Implement `add_item(item_id, quantity, quality)` with stacking logic
- [ ] Implement `remove_item(item_id, quantity)` with stack decrement
- [ ] Implement `has_item(item_id, quantity)` check
- [ ] Implement `get_item_count(item_id)` across all slots
- [ ] Implement `swap_slots(from_index, to_index)`
- [ ] Implement `split_stack(slot_index, amount)` — split into cursor
- [ ] Implement `merge_stacks(from_index, to_index)` — combine same items
- [ ] Implement `sort_inventory(sort_mode)` — by type, price, name, rarity
- [ ] Implement `find_first_empty_slot()` method
- [ ] Implement `is_full()` check
- [ ] Emit signals: `slot_changed(index)`, `inventory_sorted`
- [ ] Enforce `stack_max` from ItemDatabase

### 5.4 Player Inventory (InventoryManager Autoload)
- [ ] Create `InventoryManager.gd` autoload
- [ ] Initialize player inventory with 36 slots (6x6 grid)
- [ ] Initialize hotbar with 10 slots
- [ ] Track `selected_hotbar_slot` (0-9)
- [ ] Implement `get_selected_item()` from hotbar
- [ ] Handle number key input (1-0) for hotbar selection
- [ ] Handle mouse scroll for hotbar cycling
- [ ] Link hotbar and inventory (hotbar = first 10 slots, or separate)

### 5.5 Inventory UI
- [ ] Create `InventoryUI.tscn` Control scene
- [ ] Create inventory grid (6 columns x 6 rows of slot panels)
- [ ] Create individual `InventorySlot.tscn` (TextureRect + Label for count + quality indicator)
- [ ] Implement slot rendering: show item icon, quantity, quality star
- [ ] Implement click-to-pick-up item (attach to cursor)
- [ ] Implement click-to-place item (from cursor to slot)
- [ ] Implement right-click to split stack in half
- [ ] Implement shift-click for quick transfer (to/from hotbar or chest)
- [ ] Implement drag and drop between slots
- [ ] Implement cursor-held item display (item follows mouse)
- [ ] Add item tooltip on hover: name, category, description, price, quality, effects
- [ ] Add category filter tabs: All, Resources, Seeds, Crops, Fish, Food, Tools, Quest
- [ ] Implement sorting buttons (by type, by price, by name)
- [ ] Add close button and Esc/I key to close
- [ ] Handle edge cases: dropping item on occupied slot (swap), dropping on same type (merge)

### 5.6 Hotbar UI
- [ ] Create `HotbarUI.tscn` Control scene
- [ ] Display 10 slots horizontally at bottom of screen
- [ ] Highlight selected slot
- [ ] Show item icon and quantity in each slot
- [ ] Update on inventory change
- [ ] Show key bindings (1-0) on each slot

---

## Phase 6: Storage (Chests)

### 6.1 Chest Base Class
- [ ] Create `ChestBase.gd` extending StaticBody2D / Area2D
- [ ] Add Inventory instance with configurable slot count
- [ ] Implement open/close interaction (E key)
- [ ] Play open/close animation
- [ ] Implement save/load chest contents

### 6.2 Chest Types
- [ ] Create `WoodenChest.tscn` — 20 slots
- [ ] Create `LargeChest.tscn` — 36 slots
- [ ] Create `Fridge.tscn` — 24 slots (food/ingredients only, filtered)
- [ ] Create `Barn Storage` — 48 slots (future)

### 6.3 Chest UI
- [ ] Create `ChestUI.tscn` Control scene (similar to InventoryUI)
- [ ] Display chest slots in grid
- [ ] Open chest UI alongside player inventory (side by side)
- [ ] Implement drag and drop between chest and inventory
- [ ] Add "Quick Transfer All" button: move matching items to chest
- [ ] Add "Quick Transfer Resources" button
- [ ] Add "Quick Transfer Ingredients" button
- [ ] Add search/filter input field within chest UI
- [ ] Add sort button within chest
- [ ] Close both UIs when done

---

## Phase 7: Farming

### 7.1 Soil System
- [ ] Create `FarmTile.gd` managing individual farm tile state
- [ ] Define soil states: EMPTY, TILLED, WATERED, PLANTED, GROWING, HARVESTABLE
- [ ] Implement tile sprite changes per state (dry dirt, tilled lines, dark watered soil)
- [ ] Tilled soil reverts to dirt after a few days without planting
- [ ] Watered soil dries out at start of next day
- [ ] Rain auto-waters all tilled/planted tiles
- [ ] Track per-tile data: soil_state, crop_id, growth_stage, days_growing, fertilizer, watered_today

### 7.2 Farming Tools Integration
- [ ] Hoe: changes EMPTY tile to TILLED
- [ ] Watering Can: changes TILLED/PLANTED tile to WATERED state
- [ ] Seed use: on TILLED tile, changes to PLANTED with crop_id
- [ ] Scythe/hand: on HARVESTABLE tile, triggers harvest
- [ ] Validate tool usage (can't hoe water, can't plant on non-tilled, etc.)
- [ ] Subtract player energy on tool use

### 7.3 Crop Data
- [ ] Create `data/crops.json` with crop definitions
- [ ] Define crop schema: `id`, `seed_item_id`, `harvest_item_id`, `seasons`, `growth_days`, `growth_stages`, `regrows` (boolean), `regrow_days`, `water_needed` (per stage), `sell_price_by_quality`
- [ ] Populate crops: tomato (8 days, summer), basil (5 days, spring/summer), grape (10 days, autumn, regrows), olive (12 days, autumn), lemon (14 days, summer, coastal only)
- [ ] Populate crops: wheat (7 days, summer/autumn), garlic (6 days, spring), onion (5 days, spring/summer), eggplant (9 days, summer), zucchini (6 days, summer)
- [ ] Populate crops: pepper (8 days, summer), rosemary (7 days, spring/summer), oregano (5 days, spring/summer), thyme (5 days, spring/summer)
- [ ] Add growth stage sprite paths per crop (4-5 stages each)

### 7.4 Crop Growth Logic
- [ ] Advance crop growth stage daily (on `day_started`)
- [ ] Only advance if watered (or rained)
- [ ] Check season validity — crops planted in wrong season wilt/die
- [ ] Handle multi-stage growth (seed -> sprout -> growing -> mature -> harvestable)
- [ ] Handle regrowable crops (grape, etc.): reset to mid-stage after harvest
- [ ] Update tile sprite when growth stage changes

### 7.5 Harvest & Quality
- [ ] Implement harvest interaction on HARVESTABLE tiles
- [ ] Determine quality based on: base chance + fertilizer bonus + (random)
- [ ] Quality distribution: ~60% Normal, ~25% Silver, ~12% Gold, ~3% Iridium (with good fertilizer)
- [ ] Add harvested item to player inventory with quality tag
- [ ] Play harvest animation and sound
- [ ] Reset tile state (to TILLED for regrowable, EMPTY otherwise)

### 7.6 Fertilizer
- [ ] Create fertilizer item types: basic_fertilizer, quality_fertilizer, speed_fertilizer
- [ ] Implement fertilizer application to TILLED soil
- [ ] Basic fertilizer: slight quality boost
- [ ] Quality fertilizer: significant quality boost
- [ ] Speed fertilizer: reduces growth time by 1-2 days
- [ ] Track fertilizer on per-tile basis
- [ ] Fertilizer persists until crop harvested (then consumed)

### 7.7 Sprinkler System (Later Phase)
- [ ] Create sprinkler item and placeable object
- [ ] Basic sprinkler: waters 4 adjacent tiles
- [ ] Quality sprinkler: waters 8 surrounding tiles
- [ ] Auto-water at start of each day
- [ ] Sprinkler placement validation (on farm tiles only)

---

## Phase 8: Tools System

### 8.1 Tool Base Class
- [ ] Create `Tool.gd` base Resource or class
- [ ] Define tool properties: `tool_type`, `tier`, `energy_cost`, `power`, `animation_name`
- [ ] Define tool types enum: AXE, PICKAXE, HOE, WATERING_CAN, FISHING_ROD, SCYTHE
- [ ] Define tool tiers: BASIC, COPPER, IRON, GOLD
- [ ] Implement base `use(player, target_position)` virtual method

### 8.2 Axe
- [ ] Implement axe usage: chop trees, stumps, branches
- [ ] Basic axe: 3 hits to fell small tree, 6 hits for large
- [ ] Each tier reduces hits needed by 1
- [ ] Energy cost: 4 (basic), 3 (copper), 2 (iron), 1 (gold)
- [ ] Drop resources: wood, hardwood, sap, tree seeds
- [ ] Play chopping animation per direction

### 8.3 Pickaxe
- [ ] Implement pickaxe usage: break rocks, mine ore nodes
- [ ] Basic pickaxe: 3 hits for small rock, 6 for large, can't break boulders
- [ ] Each tier allows breaking harder rocks and reduces hits
- [ ] Gold pickaxe can break boulders
- [ ] Energy cost: 4 (basic), 3 (copper), 2 (iron), 1 (gold)
- [ ] Drop resources: stone, copper_ore, iron_ore, coal, geode (rare)
- [ ] Play mining animation per direction

### 8.4 Hoe
- [ ] Implement hoe usage: till soil on farm tiles
- [ ] Basic hoe: tills 1 tile
- [ ] Copper: tills 1 tile faster (less energy)
- [ ] Iron: tills 2 tiles in a line
- [ ] Gold: tills 3 tiles in a line
- [ ] Energy cost: 3 (basic), 2 (copper), 2 (iron), 1 (gold)
- [ ] Occasionally dig up artifacts/clay
- [ ] Play tilling animation per direction

### 8.5 Watering Can
- [ ] Implement watering can usage: water tilled/planted tiles
- [ ] Track water level (capacity): 20 (basic), 30 (copper), 40 (iron), 55 (gold)
- [ ] Refill at water source (well, pond, river)
- [ ] Basic: waters 1 tile
- [ ] Copper: waters 1 tile, larger capacity
- [ ] Iron: waters 3 tiles in a line
- [ ] Gold: waters 5 tiles in a line
- [ ] Energy cost: 2 (basic), 2 (copper), 1 (iron), 1 (gold)
- [ ] Play watering animation per direction
- [ ] Show fill level indicator

### 8.6 Fishing Rod
- [ ] Implement fishing rod usage: cast line at water tiles
- [ ] Initiate fishing minigame on cast (see Phase 14)
- [ ] Upgrade tiers improve catch difficulty reduction and rare fish chance
- [ ] Energy cost: 3 per cast

### 8.7 Tool Upgrades
- [ ] Create upgrade recipes: tool + bars + money at forge
- [ ] Copper upgrade: 5 copper bars + 2000 Euro
- [ ] Iron upgrade: 5 iron bars + 5000 Euro
- [ ] Gold upgrade: 5 gold bars + 10000 Euro
- [ ] Upgrade takes 2 in-game days (tool unavailable during upgrade)
- [ ] NPC blacksmith/craftsman handles upgrades (dialogue interaction)
- [ ] Upgraded tool replaces old tool in inventory

### 8.8 Tool Animations
- [ ] Create tool swing animation set (per direction, per tool type)
- [ ] Sync tool animation with player use_tool animation
- [ ] Add impact effects (particles: dirt, stone chips, water splash, wood chips)
- [ ] Add screen shake on heavy impacts (pickaxe on rock)
- [ ] Add sound effects per tool hit

---

## Phase 9: Crafting System

### 9.1 Recipe Data
- [ ] Create `data/recipes.json` with all crafting recipes
- [ ] Define recipe schema: `id`, `name_key`, `result_item_id`, `result_quantity`, `ingredients` (array of {item_id, quantity}), `workbench_type`, `craft_time_seconds`, `unlocked_by` (default/quest/skill/purchase)
- [ ] Populate general recipes: torch, rope, chest, basic_fertilizer, quality_fertilizer, speed_fertilizer
- [ ] Populate cooking recipes (see Phase 17)
- [ ] Populate forge recipes: copper_bar, iron_bar, gold_bar, tool upgrades
- [ ] Populate carpenter recipes: furniture items, fences, sprinklers
- [ ] Populate olive press recipes: olive_oil
- [ ] Populate winery recipes: wine (grape -> barrel -> wine over days)
- [ ] Populate herb dryer recipes: dried_herbs (various)
- [ ] Populate beehive output: honey (passive production, season-dependent)
- [ ] Populate composter recipes: fertilizer from organic waste
- [ ] Populate alchemist recipes: health_potion, energy_tonic, luck_potion, fishing_potion

### 9.2 CraftingManager (Autoload)
- [ ] Create `CraftingManager.gd` autoload
- [ ] Load and validate `recipes.json` on start
- [ ] Implement `get_available_recipes(workbench_type)` — filter by workbench
- [ ] Implement `can_craft(recipe_id)` — check player has ingredients
- [ ] Implement `craft(recipe_id)` — consume ingredients, produce result, add to inventory
- [ ] Track discovered/unlocked recipes per player save
- [ ] Implement recipe discovery: unlock on quest completion, NPC gift, found in ruins
- [ ] Emit signals: `recipe_unlocked`, `item_crafted`

### 9.3 Crafting UI
- [ ] Create `CraftingUI.tscn` Control scene
- [ ] Display list of available recipes (filtered by current workbench)
- [ ] Show recipe details panel: result item icon, name, description, required ingredients with have/need counts
- [ ] Grey out recipes where ingredients are missing
- [ ] Highlight craftable recipes
- [ ] "Craft" button (enabled only when `can_craft` is true)
- [ ] Add search bar for recipe lookup
- [ ] Add category filter tabs per workbench type
- [ ] Show "New!" badge on recently unlocked recipes
- [ ] Play craft success animation and sound
- [ ] Close with Esc / C key

### 9.4 Workbench Objects
- [ ] Create `Workbench.gd` base class (interactable, opens crafting UI with filter)
- [ ] Create `BasicWorkbench.tscn` — general crafting
- [ ] Create `KitchenStove.tscn` — cooking recipes
- [ ] Create `CarpenterTable.tscn` — furniture/wood recipes
- [ ] Create `Forge.tscn` — metal smelting, tool upgrades
- [ ] Create `OlivePress.tscn` — olive oil production
- [ ] Create `WineryBarrel.tscn` — wine fermentation (time-based)
- [ ] Create `HerbDryer.tscn` — herb drying (time-based)
- [ ] Create `Beehive.tscn` — passive honey production
- [ ] Create `Composter.tscn` — fertilizer from organic waste (time-based)
- [ ] Create `AlchemistTable.tscn` — potions/tonics
- [ ] Create `LoomStation.tscn` — cloth/fabric crafting
- [ ] Implement time-based crafting for barrels/dryer/composter (start process, collect after X days)

---

## Phase 10: Economy & Shops

### 10.1 EconomyManager (Autoload)
- [ ] Create `EconomyManager.gd` autoload
- [ ] Track player money (`current_euros`)
- [ ] Implement `add_money(amount)` and `spend_money(amount)` with validation
- [ ] Implement `can_afford(amount)` check
- [ ] Emit `player_money_changed` signal
- [ ] Calculate sell price: `base_price * quality_multiplier * rarity_multiplier`
- [ ] Quality multipliers: Normal 1.0x, Silver 1.25x, Gold 1.5x, Iridium 2.0x
- [ ] Market day bonus: Saturday sells at 1.2x multiplier

### 10.2 Shipping Box
- [ ] Create `ShippingBox.tscn` interactable on farm
- [ ] Open shipping UI: drag items from inventory to shipping slots
- [ ] Items are "sold" at end of day (on sleep) — show earnings summary
- [ ] Calculate total earnings with quality and market day bonuses
- [ ] Add sold items to daily earnings report
- [ ] Play ka-ching sound on placing items

### 10.3 Shop System
- [ ] Create `Shop.gd` base class for NPC shops
- [ ] Define shop inventory data: `data/shops.json` per shop
- [ ] Shop schema: `shop_id`, `items` (array of {item_id, stock, price_override, season_only})
- [ ] Implement buy/sell UI with item list, prices, player money display
- [ ] Implement buy: deduct money, add item to inventory
- [ ] Implement sell (at shop): add money, remove item from inventory
- [ ] Prices vary by shop (general store vs. specialty)
- [ ] Some shops have seasonal or rotating stock

### 10.4 Shop Inventories
- [ ] Seed Shop (Mercato): all seasonal seeds, fertilizers, basic tools
- [ ] General Store: miscellaneous items, furniture basics, cooking ingredients
- [ ] Fisherman's Supply: bait, rod upgrades, tackle
- [ ] Kitchen Supply: cooking ingredients not farmable (flour, sugar, butter, salt)
- [ ] Carpenter Shop: furniture, building materials (later)
- [ ] Blacksmith: tool upgrades, metal bars (buy/sell)

### 10.5 Shop UI
- [ ] Create `ShopUI.tscn` Control scene
- [ ] Display shop name and keeper NPC portrait
- [ ] Show buyable items in scrollable list with icons, names, prices
- [ ] Show player's money in corner
- [ ] Buy button per item (or click to buy)
- [ ] Sell tab: show player inventory, click to sell
- [ ] Quantity selector for bulk buy/sell
- [ ] Confirm purchase popup for expensive items
- [ ] Close with Esc key

---

## Phase 11: NPC System

### 11.1 NPC Base Class
- [ ] Create `NPC.gd` extending CharacterBody2D
- [ ] Add Sprite2D / AnimatedSprite2D for NPC appearance
- [ ] Add CollisionShape2D
- [ ] Add interaction Area2D (triggers dialogue when player presses E)
- [ ] Add name label above head (visible when nearby)
- [ ] Implement facing-player logic when interacting

### 11.2 NPC Data
- [ ] Create `data/npcs.json` with NPC definitions
- [ ] NPC schema: `id`, `name_key`, `role`, `personality`, `location_default`, `portrait_path`, `sprite_path`, `schedule`, `gift_preferences` (loved, liked, neutral, disliked, hated), `heart_events`
- [ ] Define NPC roster:
  - [ ] Marco — Barista at piazza cafe, cheerful, loves coffee culture
  - [ ] Luigi — Old fisherman at the port, gruff but kind
  - [ ] Sofia — Market owner / general store, practical, warm
  - [ ] Elena — Herbalist / apothecary, mystical, knowledgeable
  - [ ] Signor Rossi — Mayor, traditionalist, skeptical of outsiders
  - [ ] Professore Bianchi — Archaeologist, eccentric, obsessed with ruins
  - [ ] Alessandra — Young musician, free-spirited, street performer
  - [ ] Giovanni — Master craftsman / carpenter, quiet, skilled
  - [ ] Isabella — Artist / painter, dreamy, paints landscapes
  - [ ] Nonna Maria — Village elder, everyone's grandma, best cook
  - [ ] Tommaso — Young vineyard worker, ambitious, hardworking
  - [ ] Chiara — Beekeeper, gentle, nature-lover

### 11.3 NPC Schedules & Pathfinding
- [ ] Define schedule format: array of `{ time_start, time_end, location, position, activity }`
- [ ] Implement schedule-driven NPC movement (walk to location at scheduled time)
- [ ] Implement basic A* pathfinding on navigation grid
- [ ] Handle schedule variations: weekday vs. weekend, season, weather (e.g., NPCs stay inside during rain)
- [ ] NPCs idle at destination (play idle animation, face random direction)
- [ ] NPCs walk between scheduled points at realistic speed
- [ ] Handle NPC-NPC and NPC-obstacle collision avoidance

### 11.4 Friendship System
- [ ] Track friendship per NPC: 0-10 hearts, each heart = 250 points (0-2500 total)
- [ ] Implement `change_friendship(npc_id, amount)` method
- [ ] Daily talk bonus: +20 points first conversation per day
- [ ] Gift bonus: varies by preference category (loved: +80, liked: +45, neutral: +20, disliked: -20, hated: -40)
- [ ] Birthday gift bonus: 8x multiplier
- [ ] Track gifts given today (limit: 1 gift per NPC per day)
- [ ] Emit `friendship_changed` signal with NPC id and new value
- [ ] Unlock new dialogue at heart milestones (2, 4, 6, 8, 10)
- [ ] Unlock heart events at specific heart levels

### 11.5 Gift System
- [ ] Implement gift-giving interaction (hold item, press E on NPC)
- [ ] Check NPC gift preference for held item
- [ ] Play NPC reaction animation (happy, pleased, neutral, unhappy, disgusted)
- [ ] Show NPC response dialogue (loved/liked/neutral/disliked/hated reaction)
- [ ] Remove gifted item from player inventory
- [ ] Apply friendship change
- [ ] Track "already gifted today" flag per NPC

### 11.6 Heart Events (Cutscenes)
- [ ] Create `HeartEvent.gd` system for triggering scripted scenes
- [ ] Define trigger conditions: NPC heart level, time of day, location, season, quest state
- [ ] Implement cutscene mode: lock player, show dialogue, move NPCs, camera pan
- [ ] Create at least 1-2 heart events per NPC for MVP (total ~12-24 events)
- [ ] Heart events reveal NPC backstory and deepen relationships
- [ ] Some heart events give unique items or unlock recipes

---

## Phase 12: Dialogue & Localization

### 12.1 DialogueManager (Autoload)
- [ ] Create `DialogueManager.gd` autoload
- [ ] Implement `start_dialogue(npc_id, context)` method
- [ ] Select appropriate dialogue based on: NPC, friendship level, time, weather, season, active quests
- [ ] Handle dialogue progression (advance with E or click)
- [ ] Handle branching choices (player selects from 2-4 options)
- [ ] Handle dialogue outcomes (friendship change, quest start, item give, shop open)
- [ ] Emit `dialogue_started` and `dialogue_ended` signals
- [ ] Set GameManager state to DIALOGUE during conversation

### 12.2 Dialogue Data
- [ ] Create `data/dialogues/` folder structure (per NPC or per category)
- [ ] Define dialogue JSON schema: `id`, `npc_id`, `conditions` (friendship_min, season, weather, time_range, quest_state), `priority`, `lines` (array of {speaker, text_key, choices})
- [ ] Write default greeting dialogues for each NPC (all friendship levels)
- [ ] Write weather-specific dialogues ("Beautiful day!" vs. "This rain...")
- [ ] Write season-specific dialogues (harvest talk in autumn, etc.)
- [ ] Write friendship-milestone dialogues (new lines at 2, 4, 6, 8, 10 hearts)
- [ ] Write quest-related dialogues
- [ ] Write heart event dialogue scripts

### 12.3 Dialogue UI
- [ ] Create `DialogueBox.tscn` Control scene (bottom of screen panel)
- [ ] Display NPC portrait (left side)
- [ ] Display NPC name label
- [ ] Display dialogue text with typewriter effect (character by character)
- [ ] Skip typewriter on click/E (show full text instantly)
- [ ] Advance to next line on click/E
- [ ] Display choice buttons when branching dialogue
- [ ] Auto-close after final line
- [ ] Cozy UI styling (warm colors, rounded corners, pixel font)

### 12.4 Localization
- [ ] Set up Godot's built-in localization system (Translation resources)
- [ ] Create `data/locale/en.csv` (English strings)
- [ ] Create `data/locale/ru.csv` (Russian strings)
- [ ] Map all item names, descriptions, dialogue text, UI labels to translation keys
- [ ] Implement locale switching in settings menu
- [ ] Test all UI elements with both languages (check text overflow)
- [ ] Localize: item names, item descriptions, NPC dialogue, UI labels, quest text, achievement names, season/weather names, tutorial text, menu options

---

## Phase 13: Quest System

### 13.1 QuestManager (Autoload)
- [ ] Create `QuestManager.gd` autoload
- [ ] Load quest data from `data/quests.json`
- [ ] Track active quests, completed quests, failed quests
- [ ] Implement `start_quest(quest_id)` method
- [ ] Implement `update_objective(quest_id, objective_id, progress)` method
- [ ] Implement `complete_quest(quest_id)` — give rewards
- [ ] Implement `fail_quest(quest_id)` if applicable
- [ ] Check quest auto-completion conditions each day
- [ ] Emit signals: `quest_started`, `quest_objective_updated`, `quest_completed`, `quest_failed`

### 13.2 Quest Data
- [ ] Create `data/quests.json` with quest definitions
- [ ] Quest schema: `id`, `name_key`, `description_key`, `type` (main/side/bulletin), `giver_npc_id`, `objectives` (array), `rewards` (money, items, friendship, recipe_unlock), `prerequisites` (quests, friendship, season), `time_limit` (for bulletin quests)
- [ ] Objective schema: `id`, `type` (collect, deliver, talk, catch_fish, harvest, craft, kill, explore), `target_id`, `target_quantity`, `current_progress`

### 13.3 Main Story Quests
- [ ] Quest: "Welcome to the Village" — talk to Mayor, explore piazza, visit cafe
- [ ] Quest: "The Old Farm" — clean up farm, till first plot, plant first seed
- [ ] Quest: "Meeting the Neighbors" — introduce yourself to 5 NPCs
- [ ] Quest: "First Harvest" — grow and harvest your first crop
- [ ] Quest: "The Market Stall" — sell items worth 500 Euro total
- [ ] Quest: "The Fisherman's Tale" — learn fishing from Luigi, catch first fish
- [ ] Quest: "Ruin Rumors" — talk to Professore Bianchi about the ruins
- [ ] Quest: "Into the Ruins" — enter the dungeon for the first time
- [ ] Quest: "Ancient Secrets" — find 3 artifacts in the ruins
- [ ] Quest: "The Village Festival" — participate in first seasonal festival
- [ ] Quest: "Restoring the Piazza" — contribute materials to village restoration
- [ ] Quest: "The Guardian's Challenge" — defeat the Ruin Guardian mini-boss
- [ ] Quest: "The Truth Revealed" — discover the family secret in the ruins
- [ ] Quest: "Village Reborn" — village reaches prosperity milestone (endgame)

### 13.4 Side Quests (Examples)
- [ ] Quest: "Marco's Special Blend" — bring Marco rare herbs for a new coffee recipe
- [ ] Quest: "Luigi's Lost Lure" — find Luigi's lucky fishing lure in the beach loot
- [ ] Quest: "Sofia's Supply Run" — deliver goods to 3 NPCs for Sofia
- [ ] Quest: "Elena's Remedy" — gather medicinal herbs for Elena's potion
- [ ] Quest: "Nonna's Recipe Book" — find Nonna Maria's lost recipe pages (3 locations)
- [ ] Quest: "Giovanni's Masterpiece" — bring Giovanni rare wood for a special furniture piece
- [ ] Quest: "Isabella's Inspiration" — show Isabella a Gold-quality crop, fish, or artifact
- [ ] Quest: "Alessandra's Concert" — help set up instruments for a piazza performance

### 13.5 Bulletin Board Quests
- [ ] Create bulletin board interactable in piazza
- [ ] Generate daily requests: "Deliver 5 tomatoes", "Catch 3 sardines", "Bring 10 wood"
- [ ] Generate weekly requests: larger amounts, better rewards
- [ ] Random selection from pool of fetch/deliver templates
- [ ] Rewards: money + friendship with requesting NPC
- [ ] Expire at end of day (daily) or end of week (weekly)

### 13.6 Quest Journal UI
- [ ] Create `QuestJournalUI.tscn` Control scene
- [ ] Display active quests list (left panel)
- [ ] Display selected quest details (right panel): name, description, objectives with progress bars, rewards preview
- [ ] Tab for completed quests (greyed out)
- [ ] Highlight new/updated quests
- [ ] Show quest giver NPC name and portrait
- [ ] Open with J key, close with Esc/J

---

## Phase 14: Fishing

### 14.1 Fishing Minigame
- [ ] Create `FishingMinigame.tscn` scene/overlay
- [ ] Implement cast mechanic: power bar for distance (click to cast)
- [ ] Implement wait phase: bobber in water, random wait time (2-8 seconds)
- [ ] Implement bite indicator: bobber splashes, exclamation mark, sound cue
- [ ] Implement catch phase: vertical bar with moving fish zone + player indicator
- [ ] Player holds button to move indicator up, releases to let it fall
- [ ] Keep indicator within fish zone to fill catch meter
- [ ] Fish zone moves erratically (difficulty varies by fish rarity)
- [ ] Successful catch: catch meter fills to 100%
- [ ] Failed catch: catch meter depletes to 0% (fish escapes)
- [ ] Show caught fish result screen (name, size, rarity)
- [ ] Add to inventory on success

### 14.2 Fish Data
- [ ] Create `data/fish.json` with fish definitions
- [ ] Fish schema: `id`, `name_key`, `description_key`, `category` (sea/river/lake), `rarity` (common/uncommon/rare/legendary), `seasons`, `time_range` (some fish only at night), `weather_condition`, `difficulty` (minigame speed/erraticness), `base_price`, `min_size`, `max_size`
- [ ] Populate sea fish: sardine, anchovy, dorado, sea_bass, swordfish, red_mullet, sea_bream
- [ ] Populate river fish: trout, carp, perch, catfish, eel
- [ ] Populate lake fish: pike, tench, freshwater_shrimp
- [ ] Populate rare/legendary: giant_octopus, golden_dorado, ancient_coelacanth
- [ ] Populate squid/octopus (night fishing, sea only)

### 14.3 Fishing Locations
- [ ] Tag water tiles by type: sea, river, lake
- [ ] Different fishing spots yield different fish pools
- [ ] Beach/dock: sea fish
- [ ] River crossing near forest: river fish
- [ ] Mountain pond (later area): lake fish
- [ ] Rare fish spots (hidden, discoverable)

### 14.4 Bait System
- [ ] Create bait items: basic_bait, quality_bait, specialty_bait
- [ ] Basic bait: slightly faster bite time
- [ ] Quality bait: faster bite + slightly better rarity odds
- [ ] Specialty bait: target specific fish categories
- [ ] Bait consumed on each cast
- [ ] Equip bait to fishing rod via inventory interaction

### 14.5 Rod Upgrades
- [ ] Basic rod: standard difficulty, basic fish only
- [ ] Copper rod: reduced difficulty, can use bait
- [ ] Iron rod: further reduced difficulty, access to uncommon fish
- [ ] Gold rod: lowest difficulty, access to rare fish, can use tackle

### 14.6 Beach Loot
- [ ] Create beach forageable spawns (daily refresh)
- [ ] Spawn items: seashell, conch_shell, sea_glass, driftwood, coral_fragment
- [ ] Rare spawn: message_in_bottle (contains lore text, recipe, or treasure map)
- [ ] Seasonal beach loot variations
- [ ] Player picks up with E interaction

---

## Phase 15: Combat & Ruins/Dungeons

### 15.1 Weapon System
- [ ] Create `Weapon.gd` base class
- [ ] Define weapon properties: `damage`, `attack_speed`, `range`, `knockback`
- [ ] Create weapon types: stick (2 dmg), dagger (5 dmg), short_sword (8 dmg), sword (12 dmg)
- [ ] Implement weapon equip from hotbar
- [ ] Weapon swing on LMB (use_tool action when weapon equipped)
- [ ] Create hitbox Area2D that activates during swing animation
- [ ] Damage enemies in hitbox
- [ ] Handle attack cooldown based on weapon speed

### 15.2 Combat Mechanics
- [ ] Implement player attack animation (swing per direction)
- [ ] Implement hit detection (weapon hitbox vs. enemy hurtbox)
- [ ] Implement knockback on hit (push enemy away)
- [ ] Implement player dodge/dash (Shift + direction, short invincibility frames)
- [ ] Implement dodge cooldown (1-2 seconds)
- [ ] Implement food healing during combat (eat from hotbar)
- [ ] Death/knockout: teleport to dungeon entrance, lose some items from inventory

### 15.3 Enemy Base Class
- [ ] Create `Enemy.gd` extending CharacterBody2D
- [ ] Add health, damage, speed, detection_range, attack_range properties
- [ ] Implement state machine: IDLE, PATROL, CHASE, ATTACK, HURT, DEAD
- [ ] Implement player detection (Area2D or raycast)
- [ ] Implement basic AI: patrol randomly, chase player when detected, attack when in range
- [ ] Implement taking damage, hurt animation, death animation
- [ ] Implement loot drop on death
- [ ] Implement despawn/fade after death

### 15.4 Enemy Types
- [ ] Create `Bat.tscn` — flying enemy, fast, low HP, erratic movement
  - [ ] HP: 15, Damage: 5, Speed: fast, drops: bat_wing, guano
- [ ] Create `StoneGolem.tscn` — slow, tanky, melee punch attack
  - [ ] HP: 40, Damage: 10, Speed: slow, drops: stone, copper_ore, iron_ore
- [ ] Create `RuinGhost.tscn` — phases through walls, ranged projectile attack
  - [ ] HP: 25, Damage: 8, Speed: medium, drops: ectoplasm, ancient_coin

### 15.5 Dungeon Rooms (Fixed Layout MVP)
- [ ] Create `DungeonRoom.gd` base scene for dungeon rooms
- [ ] Design 5-8 fixed dungeon rooms with varying layouts
- [ ] Room types: combat room (enemies), treasure room (chest), puzzle room (simple), corridor
- [ ] Place ore nodes in dungeon walls (copper, iron, gold)
- [ ] Place artifact spawn points in dungeon
- [ ] Implement room transitions (doors/stairs between rooms)
- [ ] Track which rooms have been cleared
- [ ] Implement dungeon entrance/exit (return to overworld)

### 15.6 Loot Drops
- [ ] Create `LootDrop.tscn` (item pickup on ground)
- [ ] Define loot tables per enemy in JSON
- [ ] Implement random loot roll on enemy death
- [ ] Dropped items have pick-up Area2D (auto-collect on player overlap)
- [ ] Dropped items have slight bounce animation on spawn
- [ ] Items despawn after 5 minutes if not collected

### 15.7 Mini-Boss: Ruin Guardian
- [ ] Create `RuinGuardian.tscn` extending Enemy
- [ ] HP: 150 (Phase 1) + 100 (Phase 2) = 250 total
- [ ] Phase 1: melee slam attacks (telegraphed with charge-up animation), summon small stone golems
- [ ] Phase 2: faster, adds ranged shockwave attack, glowing weak spots
- [ ] Transition: stagger at Phase 1 HP depletion, brief cutscene, transform
- [ ] Telegraphed attacks: show red zone 0.5s before impact
- [ ] Drop: unique artifact, rare ore, recipe unlock
- [ ] Boss room with locked doors (open on defeat)
- [ ] Victory cutscene and lore reveal

---

## Phase 16: Animals

### 16.1 Animal Base Class
- [ ] Create `Animal.gd` extending CharacterBody2D
- [ ] Properties: `animal_type`, `name`, `happiness`, `hunger`, `health`, `age_days`
- [ ] Implement basic wandering AI within pen/coop area
- [ ] Implement eating animation and idle animation
- [ ] Implement petting interaction (player presses E)
- [ ] Track daily care: fed, watered, petted

### 16.2 Chicken
- [ ] Create `Chicken.tscn` scene
- [ ] Implement chicken coop building
- [ ] Daily produce: egg (if happy and fed)
- [ ] Quality of egg depends on happiness
- [ ] Happiness increases with daily petting and feeding
- [ ] Happiness decreases if not fed or left in rain

### 16.3 Goat
- [ ] Create `Goat.tscn` scene
- [ ] Implement barn/pen area
- [ ] Daily produce: goat_milk (if happy and fed)
- [ ] Goat milk can be crafted into goat_cheese (at kitchen or dairy station)
- [ ] Same happiness/care mechanics as chicken

### 16.4 Sheep
- [ ] Create `Sheep.tscn` scene
- [ ] Shearing produce: wool (every 3 days if happy)
- [ ] Implement shearing interaction (special tool or E interaction)
- [ ] Wool used in crafting (loom -> fabric)

### 16.5 Bees
- [ ] Create `Beehive.tscn` as placeable farm object
- [ ] Passive honey production: 1 honey every 4 days (spring/summer/autumn only)
- [ ] Honey type varies by nearby flowers (generic honey MVP)
- [ ] No direct animal sprite needed — hive object with buzzing particles
- [ ] Harvest honey with E interaction

### 16.6 Animal Care System
- [ ] Implement feeding: place feed in trough / use hay from inventory
- [ ] Implement watering: fill water trough
- [ ] Track mood: happy, content, sad, sick
- [ ] Sick animals: don't produce, need medicine (craft or buy from Elena)
- [ ] Animals can die if neglected for many days (or just stop producing — more cozy)
- [ ] Buying animals from NPC (farmer/market)
- [ ] Animal purchase prices and availability

---

## Phase 17: Cooking

### 17.1 Cooking Recipe Data
- [ ] Add cooking recipes to `data/recipes.json` (workbench_type: "kitchen")
- [ ] Recipe: Espresso — coffee_beans (buy) + water -> espresso (energy +30)
- [ ] Recipe: Cappuccino — coffee_beans + milk -> cappuccino (energy +40)
- [ ] Recipe: Cornetto — flour + butter + sugar -> cornetto (energy +25)
- [ ] Recipe: Pasta Pomodoro — flour + tomato + basil + olive_oil -> pasta_pomodoro (energy +60, speed buff)
- [ ] Recipe: Focaccia — flour + olive_oil + rosemary + salt -> focaccia (energy +45)
- [ ] Recipe: Panini — bread + cheese + tomato -> panini (energy +50)
- [ ] Recipe: Minestrone — tomato + zucchini + onion + garlic + basil -> minestrone (energy +70, health +20)
- [ ] Recipe: Bruschetta — bread + tomato + basil + olive_oil -> bruschetta (energy +35)
- [ ] Recipe: Pesto Pasta — flour + basil + garlic + olive_oil + pine_nut -> pesto_pasta (energy +65, luck buff)
- [ ] Recipe: Caprese Salad — tomato + mozzarella + basil + olive_oil -> caprese (energy +40)
- [ ] Recipe: Grilled Fish — any_fish + lemon + olive_oil -> grilled_fish (energy +55)
- [ ] Recipe: Herb Frittata — egg + mixed_herbs + cheese -> herb_frittata (energy +50)
- [ ] Recipe: Tiramisu — espresso + mascarpone + egg + sugar + cocoa -> tiramisu (energy +100, all buffs) (late-game recipe)

### 17.2 Kitchen UI
- [ ] Reuse CraftingUI with kitchen-specific filter
- [ ] Show cooking animation when crafting food
- [ ] Display food effects in recipe preview (energy, buffs)

### 17.3 Food Effects System
- [ ] Implement food consumption from inventory/hotbar (right-click or E)
- [ ] Apply energy restoration on eat
- [ ] Apply temporary buffs: speed_boost (move faster), luck_boost (better drops), fishing_boost (easier minigame), combat_boost (more damage)
- [ ] Buff duration: 3-8 in-game hours depending on food quality
- [ ] Show active buff icons on HUD
- [ ] Higher quality food = stronger/longer buffs
- [ ] Can't eat when full (energy at max) — or just waste it (no punishment, cozy)

---

## Phase 18: Jobs / Minigames

### 18.1 Job System Framework
- [ ] Create `JobManager.gd` or per-job scripts
- [ ] Track available jobs per day (based on NPC schedules and day of week)
- [ ] Track job cooldowns (1 job per type per day)
- [ ] Job rewards: fixed Euro payment + friendship with NPC + sometimes unique items

### 18.2 Barista Shift Minigame
- [ ] Create `BaristaMinigame.tscn` scene
- [ ] Customers arrive with orders (espresso, cappuccino, cornetto) — shown as icons
- [ ] Player must select correct items in order before timer runs out
- [ ] Difficulty increases: more customers, shorter timer, more complex orders
- [ ] Score based on speed and accuracy
- [ ] Reward: 50-200 Euro + friendship with Marco
- [ ] Available during cafe hours (8:00-14:00)

### 18.3 Fisherman Help Minigame
- [ ] Create `FishingHelpMinigame.tscn` scene
- [ ] Unload crates from boat: timing-based button press
- [ ] Sort fish by type into correct bins
- [ ] Score based on speed and accuracy
- [ ] Reward: 80-150 Euro + friendship with Luigi + sometimes free fish
- [ ] Available at port in morning (6:00-10:00)

### 18.4 Mail Delivery Job
- [ ] Create `MailDelivery.gd` quest-like job
- [ ] Player receives 3-5 letters to deliver to specific NPCs
- [ ] Navigate village, find NPCs at their scheduled locations
- [ ] Deliver each letter (interact with NPC)
- [ ] Complete when all delivered
- [ ] Reward: 100 Euro + small friendship boost with all recipients
- [ ] Available from post box / mayor's office

### 18.5 Olive Picking Job
- [ ] Create `OlivePicking.tscn` scene
- [ ] Rapid-tap or timed-click to shake olives from trees
- [ ] Sort olives by quality (quick sorting UI)
- [ ] Seasonal: only in autumn
- [ ] Reward: 120 Euro + olives (keep some) + friendship with orchard owner

### 18.6 Grape Harvest (Vendemmia)
- [ ] Create `VendemmiaEvent.tscn` scene
- [ ] Seasonal event: autumn, lasts 3 days
- [ ] Pick grapes from vineyard (similar to olive picking but larger scale)
- [ ] Community event: NPCs participate, special dialogue
- [ ] Reward: large Euro payment + grapes + reputation boost + unique recipe

---

## Phase 19: Decor & House

### 19.1 Furniture Data
- [ ] Create `data/furniture.json` with furniture definitions
- [ ] Furniture schema: `id`, `name_key`, `category` (table, chair, lamp, rug, wall_art, plant, storage), `size` (tiles), `placement_rules` (floor/wall/table), `comfort_bonus`, `icon_path`, `sprite_path`
- [ ] Populate furniture: wooden_table, wooden_chair, cushioned_chair, bookshelf, small_lamp, floor_lamp, woven_rug, landscape_painting, flower_pot, herb_planter, wall_clock, mirror, curtains, bed_upgrade

### 19.2 Furniture Placement System
- [ ] Create `FurniturePlacement.gd` system
- [ ] Enter placement mode (from inventory, select furniture item)
- [ ] Show ghost preview of furniture at cursor position (green = valid, red = invalid)
- [ ] Snap to grid (tile-based placement)
- [ ] Validate placement: not overlapping other furniture, within room bounds, correct surface type
- [ ] Place with click, cancel with Esc
- [ ] Pick up placed furniture (interact + hold, returns to inventory)
- [ ] Rotate furniture (R key while in placement mode)

### 19.3 House Interior
- [ ] Create player house interior scene with room boundaries
- [ ] Default room: bedroom (bed, small table, lamp)
- [ ] Upgradeable rooms: kitchen (unlock stove/cooking), living room, workshop
- [ ] Room expansions purchased from Giovanni (carpenter NPC)
- [ ] Each expansion costs materials + money + time (2-3 days)

### 19.4 Atmospheric Interactions
- [ ] Sit on benches in village (press E, player sits, camera stays, relaxing idle)
- [ ] Sit at cafe table (triggers Marco dialogue option)
- [ ] Look through telescope at overlook point (shows panoramic view)
- [ ] Listen to Alessandra's music at piazza (play music, slight energy restore)
- [ ] Pet village cat/dog (random wandering animals, purely cosmetic)

---

## Phase 20: Collections & Museum

### 20.1 Collection System
- [ ] Create `CollectionManager.gd` autoload
- [ ] Track discovered/donated items per category
- [ ] Categories: Fish, Artifacts, Herbs, Minerals, Crops (optional)
- [ ] Persist collection data in save file
- [ ] Emit `item_donated`, `collection_completed` signals

### 20.2 Fish Collection
- [ ] Track all unique fish species caught
- [ ] Fish collection UI: grid showing all fish (silhouette if not caught, colored if caught)
- [ ] Show catch details: name, description, largest size caught, season/location hint
- [ ] Reward at milestones: 25% caught (bait recipe), 50% (better rod), 75% (rare fishing spot access), 100% (golden fishing trophy)

### 20.3 Artifact Collection
- [ ] Track all unique artifacts found in ruins
- [ ] Artifact list: ancient_coin, mosaic_fragment, amphora_shard, roman_ring, etruscan_figurine, bronze_lamp, marble_bust, inscribed_tablet, golden_chalice, faded_fresco_piece
- [ ] Each artifact has a lore description (ties into main story)
- [ ] Donation to Professore Bianchi's museum/study

### 20.4 Herb Collection
- [ ] Track all herbs found/grown
- [ ] Herb list: rosemary, oregano, thyme, basil, sage, lavender, mint, chamomile
- [ ] Donate to Elena (herbalist)
- [ ] Rewards: potion recipes, herb garden seeds

### 20.5 Museum / Archaeology Corner
- [ ] Create museum interior scene (part of Professore Bianchi's study or town hall)
- [ ] Display cases for donated artifacts (visual placement)
- [ ] Donate items via interaction (select from inventory)
- [ ] Each donation gives: money reward + friendship with Professore + lore text unlock
- [ ] Completing full collection: major story unlock + unique item
- [ ] Visual progression: empty museum -> increasingly filled displays

### 20.6 Lore Unlocks
- [ ] Create lore entry system (collectible text entries)
- [ ] Lore entries unlocked via: artifact donations, heart events, exploration, quest completions
- [ ] Lore viewer UI: scrollable journal of discovered lore entries
- [ ] Lore tells the backstory of the village, ruins, family history

---

## Phase 21: Achievements

### 21.1 Achievement System
- [ ] Create `AchievementManager.gd` autoload
- [ ] Track achievement unlock conditions
- [ ] Persist achievement state in save file
- [ ] Emit `achievement_unlocked` signal
- [ ] Show notification popup when achievement unlocks (toast notification)

### 21.2 Achievement Definitions
- [ ] Achievement: "Primo Raccolto" (First Harvest) — harvest your first crop
- [ ] Achievement: "Primo Pesce" (First Catch) — catch your first fish
- [ ] Achievement: "Primo Crafting" (First Craft) — craft your first item
- [ ] Achievement: "Amico del Villaggio" (Village Friend) — reach 5 hearts with any NPC
- [ ] Achievement: "Segreto delle Rovine" (Ruin Secret) — defeat the Ruin Guardian
- [ ] Achievement: "Colazione Italiana" (Italian Breakfast) — make espresso + cornetto in the same morning
- [ ] Achievement: "Maestro Cuoco" (Master Chef) — cook 10 different recipes
- [ ] Achievement: "Pescatore Provetto" (Expert Angler) — catch 20 different fish species
- [ ] Achievement: "Collezionista" (Collector) — donate 10 artifacts to the museum
- [ ] Achievement: "Benvenuto a Casa" (Welcome Home) — fully furnish your house
- [ ] Achievement: "Imprenditore" (Entrepreneur) — earn a total of 50,000 Euro
- [ ] Achievement: "Amico di Tutti" (Everyone's Friend) — reach 5 hearts with all NPCs
- [ ] Achievement: "Vendemmia!" — participate in the grape harvest festival
- [ ] Achievement: "Rinascita" (Rebirth) — complete the main storyline

### 21.3 Achievement UI
- [ ] Create `AchievementUI.tscn` panel
- [ ] Display all achievements in grid/list (locked = greyed out, unlocked = full color)
- [ ] Show achievement name, description, icon, unlock date
- [ ] Progress bar for partially-completable achievements
- [ ] Access from pause menu or dedicated key

---

## Phase 22: Save/Load System

### 22.1 SaveManager (Autoload)
- [ ] Create `SaveManager.gd` autoload
- [ ] Define save file format: JSON
- [ ] Define save file location: `user://saves/`
- [ ] Support 3 save slots
- [ ] Implement `save_game(slot_index)` method
- [ ] Implement `load_game(slot_index)` method
- [ ] Implement `delete_save(slot_index)` method
- [ ] Implement `has_save(slot_index)` check
- [ ] Add save version number for migration support

### 22.2 Save Data Structure
- [ ] Save player data: position, facing_direction, current_scene, max_energy, current_energy, max_health, current_health
- [ ] Save time data: current_hour, current_minute, current_day, current_season, current_year, current_weather
- [ ] Save inventory data: all 36 inventory slots + 10 hotbar slots (item_id, quantity, quality per slot)
- [ ] Save chest data: all placed chests (position, scene, contents)
- [ ] Save money: current_euros, total_earned
- [ ] Save relationships: friendship points per NPC, gifts_given_today per NPC
- [ ] Save quest data: active quests (with progress), completed quest IDs, failed quest IDs
- [ ] Save world state: farm tile states (soil, crop, growth_stage, watered, fertilizer per tile), chopped trees (regrow timer), mined rocks (respawn timer)
- [ ] Save crop data: all planted crops with growth stage, watered status, fertilizer
- [ ] Save animal data: owned animals (type, name, happiness, health, daily_care)
- [ ] Save collection data: caught fish, donated artifacts, found herbs
- [ ] Save achievement data: unlocked achievement IDs, progress counters
- [ ] Save crafting data: unlocked recipe IDs
- [ ] Save furniture data: placed furniture (item_id, position, rotation per piece)
- [ ] Save settings: volume levels, language, window mode (or keep settings separate)
- [ ] Save dungeon progress: cleared rooms, boss defeated flag

### 22.3 Autosave
- [ ] Implement autosave on sleep (end of day)
- [ ] Implement autosave on scene transition (optional, could be costly)
- [ ] Autosave to dedicated autosave slot (separate from manual saves)
- [ ] Show subtle "Saving..." indicator during autosave

### 22.4 Save Versioning & Migration
- [ ] Include `save_version` field in save file
- [ ] Implement migration function: if save_version < current_version, apply transformations
- [ ] Handle missing fields gracefully (use defaults for new features)
- [ ] Log warnings for any migration issues

### 22.5 Save/Load Error Handling
- [ ] Handle corrupted save files (catch JSON parse errors)
- [ ] Handle missing save files
- [ ] Show user-friendly error messages
- [ ] Backup previous save before overwriting

---

## Phase 23: Main Menu & Settings

### 23.1 Main Menu Scene
- [ ] Create `MainMenu.tscn` scene
- [ ] Design pixel art title screen with Italy Valley logo
- [ ] Background: animated Italian village scene or static art
- [ ] Menu buttons: New Game, Continue, Load Game, Settings, Credits, Quit
- [ ] Play title screen background music
- [ ] Animate menu elements (subtle movement, particles)

### 23.2 New Game Flow
- [ ] "New Game" button opens character name input
- [ ] Optional: farm name input
- [ ] Select save slot (if starting new game in occupied slot, confirm overwrite)
- [ ] Play intro sequence (see Phase 25)
- [ ] Load farm scene with fresh save data

### 23.3 Load Game Screen
- [ ] Display 3 save slots with preview info
- [ ] Show per slot: player name, farm name, day/season/year, play time, money, last played date
- [ ] Load selected save
- [ ] Delete save option with confirmation

### 23.4 Settings Menu
- [ ] Create `SettingsUI.tscn` scene/panel
- [ ] Audio settings: Master volume, Music volume, SFX volume, Ambient volume (sliders)
- [ ] Language setting: English / Russian (dropdown or toggle)
- [ ] Display settings: Window mode (Windowed / Fullscreen / Borderless), VSync toggle
- [ ] Controls display: show current keybindings (rebinding is stretch goal)
- [ ] Apply button + Cancel button
- [ ] Persist settings to `user://settings.cfg`

### 23.5 Pause Menu
- [ ] Create `PauseMenu.tscn` overlay
- [ ] Trigger with Esc key
- [ ] Buttons: Resume, Save Game, Settings, Main Menu, Quit
- [ ] Set `get_tree().paused = true` when open
- [ ] Dim/blur background

### 23.6 Credits Screen
- [ ] Create `Credits.tscn` scene
- [ ] Scrolling credits text: developer, artist, music, tools, licenses
- [ ] Return to main menu button

### 23.7 HUD (Heads-Up Display)
- [ ] Create `HUD.tscn` persistent UI layer
- [ ] Energy bar (top-left)
- [ ] Health bar (below energy, only show in combat/dungeon)
- [ ] Money display (top-left, below bars)
- [ ] Clock & date display (top-right)
- [ ] Weather icon (top-right, next to clock)
- [ ] Hotbar (bottom-center)
- [ ] Active buff icons (below clock)
- [ ] Quest tracker (right side, shows current quest objective)
- [ ] Notification area (center-top, for popups: items gained, quest updates)

---

## Phase 24: Audio

### 24.1 Background Music
- [ ] Compose or source: main menu theme (warm, inviting Italian feel)
- [ ] Compose or source: farm theme (peaceful, pastoral)
- [ ] Compose or source: village theme (lively, accordion/guitar)
- [ ] Compose or source: beach theme (relaxed, waves, light melody)
- [ ] Compose or source: forest theme (mysterious, nature sounds blend)
- [ ] Compose or source: ruins/dungeon theme (tense, ancient, echoey)
- [ ] Compose or source: boss battle theme (dramatic, urgent)
- [ ] Compose or source: night theme (calm, crickets, gentle)
- [ ] Compose or source: rain ambient overlay
- [ ] Compose or source: festival/event theme (festive, upbeat)
- [ ] Seasonal variations (spring = lighter, winter = more muted)

### 24.2 Ambient Sounds
- [ ] Farm ambient: birds, wind, distant church bells
- [ ] Village ambient: chatter, footsteps, distant music
- [ ] Beach ambient: waves, seagulls, wind
- [ ] Forest ambient: rustling leaves, bird calls, insects
- [ ] Ruins ambient: dripping water, echoes, distant rumbles
- [ ] Night ambient: crickets, owls, wind
- [ ] Rain ambient: rain on roof (interior), rain on ground (exterior)
- [ ] Interior ambient: clock ticking, fire crackling (if fireplace)

### 24.3 Sound Effects
- [ ] Tool SFX: axe_chop, pickaxe_hit, hoe_till, watering_pour, fishing_cast, fishing_reel
- [ ] Farming SFX: seed_plant, crop_harvest, crop_rustle
- [ ] Combat SFX: sword_swing, hit_enemy, player_hurt, enemy_death, dodge_whoosh
- [ ] UI SFX: menu_open, menu_close, button_click, button_hover, item_pickup, item_drop, item_equip, coin_collect, notification_pop
- [ ] Interaction SFX: door_open, door_close, chest_open, chest_close, npc_talk_blip
- [ ] World SFX: footstep_grass, footstep_stone, footstep_sand, footstep_wood, water_splash
- [ ] Cooking SFX: sizzle, chopping, bubbling, ding (done)
- [ ] Achievement SFX: fanfare_short
- [ ] Save SFX: save_complete chime

### 24.4 Music Transitions
- [ ] Crossfade between area BGM on scene change
- [ ] Smooth transition to combat music when entering dungeon
- [ ] Fade out music during cutscenes (or play cutscene-specific music)
- [ ] Weather overlay mixing (add rain layer over current BGM)

---

## Phase 25: Story Content

### 25.1 Intro Sequence
- [ ] Create intro cutscene: player arrives at village by bus/train
- [ ] Show village establishing shots (pixel art stills or simple animation)
- [ ] Mayor greets player at entrance, gives key to old house
- [ ] Player walks to farm, sees run-down state
- [ ] Intro text: explain premise (inherited property, fresh start)
- [ ] Transition to first day gameplay

### 25.2 Main Storyline Beats
- [ ] Act 1 — Settling In: fix up farm, meet villagers, learn basic mechanics
- [ ] Act 2 — Village Revival: open market stall, restore piazza, attract visitors
- [ ] Act 3 — The Ruins Mystery: explore ruins, find family artifacts, learn truth
- [ ] Act 4 — Resolution: defeat Ruin Guardian, village celebrates, family secret resolved
- [ ] Track story progress via main quest chain completion

### 25.3 NPC Heart Event Scenes
- [ ] Marco 2-heart event: teaches you to make espresso, unlocks recipe
- [ ] Marco 6-heart event: shares dream of expanding cafe, player helps
- [ ] Luigi 2-heart event: tells fishing stories at the dock
- [ ] Luigi 6-heart event: reveals he used to be a famous chef, gives recipe
- [ ] Sofia 2-heart event: market day chaos, player helps manage shop
- [ ] Sofia 6-heart event: Sofia confides about keeping the market alive
- [ ] Elena 2-heart event: herb gathering walk in forest, teaches player about herbs
- [ ] Elena 6-heart event: mysterious potion brewing, reveals connection to ruins
- [ ] Professore Bianchi 4-heart event: shows hidden room in ruins, major lore dump
- [ ] Nonna Maria 2-heart event: cooking lesson, unlocks Nonna's special recipe
- [ ] Giovanni 4-heart event: shows carpentry workshop, unlocks furniture crafting
- [ ] Alessandra 4-heart event: sunset concert on hilltop, unlocks music box item

### 25.4 Festival Events (1 per Season MVP)
- [ ] Spring Festival: "Festa della Primavera" — flower decorating contest, seed giveaway, NPC dancing
- [ ] Summer Festival: "Festa del Mare" — fishing tournament, beach party, fireworks
- [ ] Autumn Festival: "Vendemmia" — grape harvest, wine tasting, community feast
- [ ] Winter Festival: "Natale in Piazza" — gift exchange, caroling, special market stalls
- [ ] Each festival: unique scene, dialogue, activities, exclusive items/recipes
- [ ] Festival announcement a few days before (NPC mentions, bulletin board)

---

## Phase 26: Polish & Juice

### 26.1 Screen Effects
- [ ] Screen shake on tool impact (configurable intensity)
- [ ] Screen shake on player damage
- [ ] Screen flash on critical hit or boss phase change
- [ ] Vignette effect at low health

### 26.2 Particle Effects
- [ ] Dirt particles on hoe till
- [ ] Wood chips on axe chop
- [ ] Stone chips on pickaxe hit
- [ ] Water droplets on watering
- [ ] Sparkle on item pickup
- [ ] Hearts on NPC gift (loved)
- [ ] Crop growth sparkle
- [ ] Enemy death poof
- [ ] Cooking steam
- [ ] Firefly particles at night (farm/forest)
- [ ] Falling leaves (autumn)
- [ ] Snow particles (winter)

### 26.3 UI Animations
- [ ] Inventory open/close slide animation
- [ ] Item pickup floating text (+1 Wood)
- [ ] Money change animation (+50 Euro floating text)
- [ ] Health/energy bar smooth interpolation (not instant snap)
- [ ] Quest complete banner slide-in
- [ ] Achievement unlock toast notification (slide from top)
- [ ] Tooltip fade in/out
- [ ] Dialogue text typewriter effect
- [ ] Menu button hover scaling

### 26.4 Transition Effects
- [ ] Fade to black on scene change (already in Phase 1 — polish timing)
- [ ] Wipe transitions for special events
- [ ] Sleep transition (fade to black, show "Day X" text, fade in)
- [ ] Season change splash screen ("Summer has arrived!")

### 26.5 Cozy Polish
- [ ] Footstep sound variation (slightly randomized pitch)
- [ ] Tool sound variation (randomized pitch)
- [ ] NPC talk blip variation per NPC (higher/lower pitch = voice character)
- [ ] Ambient wind affecting grass/trees (shader or animation)
- [ ] Water edge animation (tile animation)
- [ ] Smoke from chimneys
- [ ] Laundry hanging on lines (sways in wind)
- [ ] Cat/dog wandering in village (cosmetic)

---

## Phase 27: Art Assets

### 27.1 Player Sprites
- [ ] Player idle sprites (4 directions)
- [ ] Player walk cycle sprites (4 directions, 4-6 frames each)
- [ ] Player run cycle sprites (4 directions, 4-6 frames each)
- [ ] Player tool use sprites (axe, pickaxe, hoe, watering can — 4 directions each)
- [ ] Player fishing cast sprite (1 direction or 4)
- [ ] Player combat swing sprites (4 directions)
- [ ] Player dodge/dash sprite
- [ ] Player eating/drinking sprite
- [ ] Player sleeping sprite
- [ ] Player carrying item sprite (optional)

### 27.2 NPC Sprites
- [ ] Create sprite sheets for each of the 12 NPCs
- [ ] NPC idle sprites (4 directions each)
- [ ] NPC walk cycle sprites (4 directions, 4 frames each)
- [ ] NPC special activity sprites (Marco pouring coffee, Luigi fishing, etc.)
- [ ] NPC portrait art for dialogue box (happy, neutral, sad, surprised expressions per NPC)

### 27.3 Crop Sprites
- [ ] Create growth stage sprites per crop (seed, sprout, growing, mature, harvestable — 5 stages)
- [ ] Crops to sprite: tomato, basil, grape, olive, lemon, wheat, garlic, onion, eggplant, zucchini, pepper, rosemary, oregano, thyme
- [ ] Withered crop sprite (for out-of-season death)
- [ ] Watered soil overlay sprite

### 27.4 Tile Sets
- [ ] Village tileset: cobblestone, buildings, roofs, doors, windows, walls, stairs
- [ ] Farm tileset: grass, dirt, tilled soil, watered soil, fences, paths
- [ ] Beach tileset: sand, water edge, rocks, pier/dock, shells
- [ ] Forest tileset: trees (seasonal variants), bushes, paths, clearings, mushroom logs
- [ ] Ruins tileset: ancient stone, crumbled walls, columns, moss, torches, floor patterns
- [ ] Interior tileset: wooden floor, stone floor, walls, furniture bases
- [ ] Mountain/hill tileset: rocky terrain, cliffs, overlook areas

### 27.5 Item Icons
- [ ] Tool icons (axe, pickaxe, hoe, watering can, fishing rod — per tier)
- [ ] Weapon icons (stick, dagger, short_sword, sword)
- [ ] Seed icons (all seed types)
- [ ] Crop/produce icons (all harvested items)
- [ ] Fish icons (all fish types)
- [ ] Food/cooking icons (all cooked dishes)
- [ ] Material icons (wood, stone, ores, bars, fiber, clay, cloth)
- [ ] Crafted good icons (olive oil, wine, dried herbs, cheese, flour)
- [ ] Artifact icons (all artifact types)
- [ ] Furniture icons (all placeable furniture)
- [ ] Foraging icons (mushrooms, berries, shells, sea glass)
- [ ] Animal product icons (egg, milk, wool, honey)
- [ ] Potion/tonic icons
- [ ] Bait icons
- [ ] Quest item icons

### 27.6 UI Sprites
- [ ] Inventory background panel
- [ ] Inventory slot frame (normal, selected, empty)
- [ ] Hotbar background
- [ ] Dialogue box frame
- [ ] Button sprites (normal, hover, pressed)
- [ ] Heart icons (empty, half, full) for friendship
- [ ] Quality star icons (normal, silver, gold, iridium)
- [ ] Weather icons (sun, cloud, rain, storm)
- [ ] Season icons (flower, sun, leaf, snowflake)
- [ ] Currency icon (Euro)
- [ ] Energy bar frame and fill
- [ ] Health bar frame and fill
- [ ] Clock frame
- [ ] Tooltip background
- [ ] Tab sprites for UI panels
- [ ] Scroll bar sprites
- [ ] Checkbox/radio button sprites

### 27.7 Animal Sprites
- [ ] Chicken sprite sheet (idle, walk, eat, 2-3 directions)
- [ ] Goat sprite sheet (idle, walk, eat, 2-3 directions)
- [ ] Sheep sprite sheet (idle, walk, sheared variant, 2-3 directions)
- [ ] Cat sprite (village wandering, idle, sit)
- [ ] Dog sprite (village wandering, idle, sit)

### 27.8 Enemy Sprites
- [ ] Bat sprite sheet (fly, attack, hurt, death — 4 frames each)
- [ ] Stone Golem sprite sheet (idle, walk, attack, hurt, death — 4 directions)
- [ ] Ruin Ghost sprite sheet (float, attack, hurt, death — translucent)
- [ ] Ruin Guardian sprite sheet (idle, slam, shockwave, hurt, Phase 1, Phase 2, death)

### 27.9 World Object Sprites
- [ ] Trees (small, large — 4 seasons each)
- [ ] Rocks (small, medium, large, boulder)
- [ ] Bushes (seasonal variants)
- [ ] Chests (wooden, large, fridge — open/closed)
- [ ] Workbench sprites (all crafting stations)
- [ ] Shipping box sprite
- [ ] Mailbox sprite
- [ ] Bulletin board sprite
- [ ] Lamp posts (on/off)
- [ ] Benches
- [ ] Market stalls
- [ ] Fishing bobber sprite
- [ ] Beehive sprite
- [ ] Animal feeders/troughs
- [ ] Signs and notice boards
- [ ] Flowers (seasonal, multiple types)
- [ ] Dungeon props (torches, crumbled pillars, treasure chests, ore nodes)

---

## Phase 28: Testing & QA

### 28.1 Playthrough Testing
- [ ] Complete full game loop test: wake -> farm -> sell -> explore -> sleep
- [ ] Test all 4 seasons cycle (play through full year)
- [ ] Test all main story quests start to finish
- [ ] Test all side quests
- [ ] Test all NPC friendship progression (0 to 10 hearts)
- [ ] Test all heart events trigger correctly
- [ ] Test all festival events
- [ ] Test dungeon full clear including boss fight
- [ ] Test all crafting recipes produce correct results
- [ ] Test all cooking recipes and food effects

### 28.2 System-Specific Testing
- [ ] Test inventory: add, remove, stack, split, swap, sort, overflow, full inventory
- [ ] Test chest: open, close, transfer, quick-transfer, all chest types
- [ ] Test farming: till, water, plant, grow (all crops), harvest, quality, fertilizer, season death
- [ ] Test tools: all tools, all tiers, energy costs, upgrade process
- [ ] Test fishing: all fish, all locations, all bait types, rod upgrades, rarity rates
- [ ] Test combat: all weapons, all enemies, dodge, death/knockout, loot drops
- [ ] Test animals: buy, feed, water, pet, produce, sickness
- [ ] Test economy: buy, sell, shipping box, market day bonus, price by quality
- [ ] Test quests: start, track, complete, fail, bulletin board generation
- [ ] Test dialogue: all NPC contexts (time, weather, season, friendship), branching choices
- [ ] Test crafting: all workbenches, recipe discovery, time-based crafting
- [ ] Test collections: fish, artifacts, herbs, museum donations, rewards
- [ ] Test achievements: all 14 achievements trigger correctly

### 28.3 Save/Load Testing
- [ ] Save and load each data category (verify all data persists)
- [ ] Save in every scene, load from every scene
- [ ] Test save slot management (create, overwrite, delete)
- [ ] Test autosave on sleep
- [ ] Test save version migration (simulate old save format)
- [ ] Test corrupted save handling (manually break save file)
- [ ] Test save with max inventory, many chests, all NPCs befriended

### 28.4 Edge Case Testing
- [ ] Inventory full: try to pick up item (should show notification)
- [ ] Money at 0: try to buy item
- [ ] Energy at 0: try to use tool
- [ ] Health at 0: death sequence and recovery
- [ ] Plant crop at season end: handle season transition correctly
- [ ] Use tool on invalid tile (water, wall, etc.)
- [ ] Gift NPC twice in one day
- [ ] Try to fish on land
- [ ] Enter dungeon at night with no weapon
- [ ] Open multiple UIs simultaneously (should not be possible)
- [ ] Rapid input during scene transitions
- [ ] Save during dialogue / cutscene (should block or defer)

### 28.5 Performance Testing
- [ ] Profile FPS in largest scene (village with many NPCs)
- [ ] Profile memory usage with full inventory + many chests
- [ ] Test NPC pathfinding with many NPCs simultaneously
- [ ] Test particle effect performance (rain + many crop particles)
- [ ] Check for memory leaks (play for extended session)
- [ ] Test TileMap rendering performance with large maps
- [ ] Profile save/load times with large save files

### 28.6 Localization Testing
- [ ] All UI labels display correctly in English
- [ ] All UI labels display correctly in Russian
- [ ] No text overflow/truncation in either language
- [ ] All item names/descriptions localized
- [ ] All NPC dialogue localized
- [ ] All quest text localized
- [ ] All achievement text localized
- [ ] Language switch works mid-game without restart

### 28.7 Bug Fix Pass
- [ ] Fix all critical bugs (crashes, data loss, softlocks)
- [ ] Fix all major bugs (broken mechanics, incorrect behavior)
- [ ] Fix all minor bugs (visual glitches, text errors, minor UX issues)
- [ ] Final regression test after bug fixes

---

## Summary Counters

> Update these manually as you progress.

| Phase | Description                | Total Tasks | Completed |
|-------|---------------------------|-------------|-----------|
| 0     | Project Setup             | 16          | 10        |
| 1     | Core Engine & Managers    | ~50         | 0         |
| 2     | Player Character          | ~35         | 0         |
| 3     | World & TileMap           | ~60         | 0         |
| 4     | Time & Calendar           | ~25         | 0         |
| 5     | Inventory System          | ~55         | 0         |
| 6     | Storage (Chests)          | ~15         | 0         |
| 7     | Farming                   | ~35         | 0         |
| 8     | Tools System              | ~35         | 0         |
| 9     | Crafting System           | ~30         | 0         |
| 10    | Economy & Shops           | ~25         | 0         |
| 11    | NPC System                | ~40         | 0         |
| 12    | Dialogue & Localization   | ~25         | 0         |
| 13    | Quest System              | ~35         | 0         |
| 14    | Fishing                   | ~25         | 0         |
| 15    | Combat & Ruins            | ~35         | 0         |
| 16    | Animals                   | ~25         | 0         |
| 17    | Cooking                   | ~20         | 0         |
| 18    | Jobs / Minigames          | ~20         | 0         |
| 19    | Decor & House             | ~15         | 0         |
| 20    | Collections & Museum      | ~20         | 0         |
| 21    | Achievements              | ~20         | 0         |
| 22    | Save/Load System          | ~25         | 0         |
| 23    | Main Menu & Settings      | ~30         | 0         |
| 24    | Audio                     | ~30         | 0         |
| 25    | Story Content             | ~25         | 0         |
| 26    | Polish & Juice            | ~30         | 0         |
| 27    | Art Assets                | ~60         | 0         |
| 28    | Testing & QA              | ~40         | 0         |
| **TOTAL** |                       | **~900+**   | **10**    |
