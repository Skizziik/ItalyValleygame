# Italy Valley -- Development Roadmap

> Stardew Valley-like pixel art game set in Italy, built with Godot 4.6 and GDScript.

---

## MVP Scope

Phases marked with **[MVP]** are required for the minimum viable product.

---

## Phase 0 -- Project Setup [MVP]

- Godot 4.6 project initialization
- Folder structure (`scenes/`, `scripts/`, `assets/`, `data/`, `ui/`, `docs/`)
- Version control (.gitignore, initial commit)
- CLAUDE.md, README.md, docs scaffolding
- Base project settings (resolution, pixel-perfect rendering, input map)

## Phase 1 -- Core Systems and Managers [MVP]

- GameManager autoload (global state, scene transitions)
- EventBus autoload (signal-based decoupling)
- Constants/Enums definitions
- Scene transition system
- Debug overlay / console

## Phase 2 -- Player [MVP]

- Player scene (AnimatedSprite2D, CollisionShape2D)
- 4-directional movement (WASD)
- Idle and walk animations
- Camera follow with smoothing
- Player state machine (idle, walking, using tool, interacting)
- Interaction system (E key, Area2D detection)

## Phase 3 -- World [MVP]

- TileMapLayer setup (ground, paths, water, obstacles)
- Farm map (home area)
- Town map (piazza, shops, harbour)
- Map transitions (doors, paths between areas)
- Collision layers and masks
- Z-sorting for depth

## Phase 4 -- Time System [MVP]

- In-game clock (configurable day length)
- Day/night cycle (CanvasModulate or shader)
- Day counter and season tracking (Primavera, Estate, Autunno, Inverno)
- Year counter
- TimeManager autoload with signals (hour_changed, day_changed, season_changed)
- HUD clock display

## Phase 5 -- Inventory System [MVP]

- Inventory data model (slots, stacking, max stack size)
- InventoryManager autoload
- Hotbar UI (bottom of screen, 1-9 or scroll to select)
- Full inventory grid UI (I key)
- Item database (JSON or Resource-based)
- Pick up / drop items
- Item tooltips

## Phase 6 -- Storage [MVP]

- Chest object (placeable, interactable)
- Chest UI (grid, drag-and-drop between chest and inventory)
- Fridge variant (for kitchen ingredients)
- Shipping bin (sell items, revenue calculated at end of day)

## Phase 7 -- Farming [MVP]

- Tillable soil tiles (hoe interaction)
- Seed planting
- Crop growth stages (per-crop timers, sprite swaps)
- Watering mechanic (watering can interaction)
- Harvesting
- Crop data definitions (name, seasons, growth days, sell price)
- Seasonal crop restrictions
- Withered/dead crops on season change
- Scarecrow (crow protection radius)

## Phase 8 -- Tools [MVP]

- Tool system (equip from hotbar, LMB to use)
- Hoe (till soil)
- Watering Can (water crops, refill at water source)
- Axe (chop trees, stumps)
- Pickaxe (break rocks, ore nodes)
- Scythe (cut grass/weeds, harvest certain crops)
- Tool upgrade tiers (base, copper, iron, gold, iridium equivalent)
- Stamina/energy cost per tool use
- Energy bar UI

## Phase 9 -- Crafting [MVP]

- Crafting recipes data (input items, output item, unlock conditions)
- Crafting UI (C key)
- Workbench object (required for advanced recipes)
- Unlockable recipes (leveling, story, purchase)

## Phase 10 -- Economy [MVP]

- Currency system (Euro or fictional equivalent)
- Shop UI (buy/sell interface)
- NPC shopkeepers (basic, no dialogue tree yet)
- Dynamic or static pricing
- Shipping bin revenue (end-of-day summary screen)
- Player wallet HUD

## Phase 11 -- NPCs

- NPC scene (sprite, collision, schedule data)
- NPC pathfinding (Navigation2D or simple waypoint system)
- Daily schedules (location per hour/day/season)
- Gift system (like/dislike/love/hate per NPC)
- Friendship levels (hearts)
- Friendship UI (social tab)
- Key NPCs: farmer neighbor, shop owner, fisherman, mayor, chef, etc.

## Phase 12 -- Dialogue and Localization

- Dialogue system (JSON or Resource-based dialogue trees)
- Dialogue UI (portrait, name, text box, choices)
- Branching dialogue (conditions: friendship, quest state, season)
- Localization framework (Italian primary, English secondary)
- Translation file structure (CSV or PO)

## Phase 13 -- Quests

- Quest data model (objectives, rewards, prerequisites)
- QuestManager autoload
- Quest log UI (J key)
- Main story quests
- Side quests (NPC-driven, seasonal events)
- Bulletin board (daily/weekly random quests)
- Quest notification and completion popups

## Phase 14 -- Fishing

- Fishing rod tool
- Fishing minigame (timing or bar-based)
- Fish database (species, locations, seasons, times, rarity)
- Bait and tackle items
- Fish pond (place on farm)

## Phase 15 -- Combat and Dungeons

- Simple combat system (melee swing, hitbox)
- Enemy AI (basic patrol, chase, attack)
- Health system (player and enemies)
- Dungeon/cave tilemap (procedural or hand-crafted floors)
- Loot drops (ore, gems, monster materials)
- Sword and weapon variants
- Boss encounters (optional)

## Phase 16 -- Animals

- Barn and coop buildings (purchasable/upgradeable)
- Animal types (chickens, cows, goats, sheep)
- Feeding mechanic
- Produce collection (eggs, milk, wool)
- Animal happiness/friendship
- Animal purchase from NPC

## Phase 17 -- Cooking

- Cooking station (kitchen in farmhouse)
- Recipe data (ingredients, output, unlock conditions)
- Cooking UI
- Buff system (temporary stat boosts from food)
- Italian-themed recipes (pasta, risotto, pizza, gelato, etc.)

## Phase 18 -- Jobs and Skills

- Skill categories (Farming, Fishing, Mining, Foraging, Combat, Cooking)
- XP gain per action
- Skill levels with unlocks (recipes, abilities, tool efficiency)
- Skill UI (tab in menu)

## Phase 19 -- Decoration and Building

- Furniture placement system (grid-snapped, rotate)
- Farmhouse interior customization
- Outdoor decoration (fences, paths, lighting)
- Farm building placement (barn, coop, shed, well)
- Building purchase/upgrade through NPC carpenter

## Phase 20 -- Collections

- Museum / collection log
- Item encyclopedia (tracks discovered items)
- Fish collection, crop collection, mineral collection
- Completion rewards

## Phase 21 -- Achievements

- Achievement data model (conditions, rewards)
- Achievement notification popup
- Achievement gallery UI
- Milestones (first harvest, first fish, first friend, etc.)

## Phase 22 -- Save and Load System [MVP]

- Save game data structure (player, inventory, world state, time, relationships)
- Serialization (JSON or Godot Resource)
- Save to user:// directory
- Load from file
- Multiple save slots (3-5)
- Autosave (end of day)

## Phase 23 -- Main Menu and Game Flow [MVP]

- Main menu scene (New Game, Continue, Settings, Quit)
- Settings menu (volume, controls, display)
- Character creation (name, appearance options)
- Intro sequence (arrival in Italy, farm inheritance story hook)
- Pause menu (Esc key)
- End-of-day sequence (earnings summary, save prompt)

## Phase 24 -- Audio

- Background music (per-location, per-season)
- Ambient sounds (birds, waves, wind, rain)
- SFX (tools, footsteps, UI clicks, item pickup)
- Volume controls (master, music, SFX, ambient)
- Audio crossfading between areas

## Phase 25 -- Story and Events

- Main storyline (restoring the farm, community center equivalent)
- Seasonal festivals (Vendemmia, Carnevale, Ferragosto, Natale)
- Cutscenes (simple: camera pan, dialogue, sprite animation)
- Marriage/romance system (optional, late scope)
- Year-end evaluation

## Phase 26 -- Polish

- Screen transitions (fade, wipe)
- Particle effects (rain, snow, leaves, sparkles)
- Juice (screen shake, squash-and-stretch, item pop)
- Loading screens
- Error handling and edge case hardening
- Performance profiling and optimization

## Phase 27 -- Art and Assets

- Tileset creation/refinement (Italian countryside aesthetic)
- Character sprites (player, NPCs)
- Crop and item sprites
- UI theme (rustic Italian style)
- Portraits for dialogue
- Seasonal tileset variants

## Phase 28 -- QA and Release

- Playtesting passes
- Bug triage and fixing
- Balance tuning (economy, crop timings, energy)
- Accessibility review
- Build export (Windows, Linux, macOS)
- Itch.io or Steam page setup
- Launch checklist

---

## Phase Dependency Overview

```
Phase 0  --> Phase 1 --> Phase 2 --> Phase 3
                |            |          |
                v            v          v
             Phase 4     Phase 5    Phase 7
                |            |          |
                v            v          v
             Phase 10    Phase 6    Phase 8
                             |
                             v
                          Phase 9
```

Post-MVP phases (11-21, 24-28) can be developed in flexible order once the MVP core is stable. Phases 22-23 should be integrated early despite being listed later, as save/load and menus are essential for testing.

---

## Status Key

- [ ] Not started
- [~] In progress
- [x] Complete

| Phase | Name                    | Status |
|-------|-------------------------|--------|
| 0     | Project Setup           | [ ]    |
| 1     | Core/Managers           | [ ]    |
| 2     | Player                  | [ ]    |
| 3     | World                   | [ ]    |
| 4     | Time System             | [ ]    |
| 5     | Inventory               | [ ]    |
| 6     | Storage                 | [ ]    |
| 7     | Farming                 | [ ]    |
| 8     | Tools                   | [ ]    |
| 9     | Crafting                | [ ]    |
| 10    | Economy                 | [ ]    |
| 11    | NPCs                    | [ ]    |
| 12    | Dialogue/i18n           | [ ]    |
| 13    | Quests                  | [ ]    |
| 14    | Fishing                 | [ ]    |
| 15    | Combat/Dungeons         | [ ]    |
| 16    | Animals                 | [ ]    |
| 17    | Cooking                 | [ ]    |
| 18    | Jobs/Skills             | [ ]    |
| 19    | Decoration/Building     | [ ]    |
| 20    | Collections             | [ ]    |
| 21    | Achievements            | [ ]    |
| 22    | Save/Load               | [ ]    |
| 23    | Main Menu/Game Flow     | [ ]    |
| 24    | Audio                   | [ ]    |
| 25    | Story/Events            | [ ]    |
| 26    | Polish                  | [ ]    |
| 27    | Art/Assets              | [ ]    |
| 28    | QA/Release              | [ ]    |
