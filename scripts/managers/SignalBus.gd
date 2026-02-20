extends Node
## Centralized event bus for decoupled communication between systems.
## Autoloaded as "SignalBus". All game events go through here.

# ── Game State ──────────────────────────────────────────────────────────────
signal game_started
signal game_paused
signal game_resumed
signal game_state_changed(old_state: int, new_state: int)

# ── Time & Calendar ─────────────────────────────────────────────────────────
signal minute_changed(hour: int, minute: int)
signal hour_changed(hour: int)
signal day_started(day: int)
signal day_ended
signal season_changed(season: int)
signal year_changed(year: int)

# ── Weather ─────────────────────────────────────────────────────────────────
signal weather_changed(weather: int)
signal weather_forecast_ready(tomorrow_weather: int)

# ── Player ──────────────────────────────────────────────────────────────────
signal player_energy_changed(current: int, maximum: int)
signal player_health_changed(current: int, maximum: int)
signal player_died
signal player_slept
signal player_woke_up
signal player_exhausted
signal player_position_changed(position: Vector2)

# ── Inventory ───────────────────────────────────────────────────────────────
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_used(item_id: String)
signal hotbar_slot_changed(slot_index: int)
signal inventory_full
signal inventory_opened
signal inventory_closed

# ── Farming ─────────────────────────────────────────────────────────────────
signal crop_planted(crop_id: String, tile_position: Vector2i)
signal crop_watered(tile_position: Vector2i)
signal crop_harvested(crop_id: String, quality: int, tile_position: Vector2i)
signal crop_withered(crop_id: String, tile_position: Vector2i)
signal soil_tilled(tile_position: Vector2i)

# ── Animals ─────────────────────────────────────────────────────────────────
signal animal_fed(animal_id: String)
signal animal_product_ready(animal_id: String, product_id: String)
signal animal_mood_changed(animal_id: String, mood: int)

# ── Economy ─────────────────────────────────────────────────────────────────
signal money_changed(new_amount: int)
signal item_sold(item_id: String, quantity: int, total_price: int)
signal item_bought(item_id: String, quantity: int, total_price: int)
signal shop_opened(shop_id: String)
signal shop_closed

# ── NPC & Relationships ────────────────────────────────────────────────────
signal npc_friendship_changed(npc_id: String, new_points: int, hearts: int)
signal npc_gift_given(npc_id: String, item_id: String, reaction: int)
signal npc_talked_to(npc_id: String)
signal heart_event_triggered(npc_id: String, event_id: String)
signal npc_schedule_changed(npc_id: String, location: String)

# ── Dialogue ────────────────────────────────────────────────────────────────
signal dialogue_started(npc_id: String)
signal dialogue_ended(npc_id: String)
signal dialogue_choice_made(npc_id: String, choice_index: int)

# ── Quests ──────────────────────────────────────────────────────────────────
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, objective_index: int)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal quest_reward_given(quest_id: String, rewards: Dictionary)
signal bulletin_board_refreshed

# ── Crafting ────────────────────────────────────────────────────────────────
signal recipe_unlocked(recipe_id: String)
signal item_crafted(recipe_id: String, result_item_id: String, quality: int)
signal crafting_started(recipe_id: String, station_type: String)
signal crafting_finished(recipe_id: String, station_type: String)

# ── Fishing ─────────────────────────────────────────────────────────────────
signal fishing_started
signal fishing_bite
signal fish_caught(fish_id: String, quality: int)
signal fish_escaped
signal fishing_ended
signal beach_loot_found(item_id: String)

# ── Combat & Dungeons ───────────────────────────────────────────────────────
signal enemy_hit(enemy_id: String, damage: int)
signal enemy_defeated(enemy_id: String)
signal player_hit(damage: int)
signal loot_dropped(item_id: String, position: Vector2)
signal dungeon_entered(floor_number: int)
signal dungeon_exited
signal boss_defeated(boss_id: String)

# ── Scene Management ────────────────────────────────────────────────────────
signal scene_changing(target_scene: String)
signal scene_changed(scene_name: String)
signal scene_transition_midpoint

# ── Jobs / Minigames ───────────────────────────────────────────────────────
signal job_started(job_id: String)
signal job_completed(job_id: String, score: int, reward_money: int)
signal job_failed(job_id: String)

# ── Collections & Museum ───────────────────────────────────────────────────
signal collection_item_discovered(collection_id: String, item_id: String)
signal museum_item_donated(item_id: String)
signal collection_completed(collection_id: String)

# ── Achievements ────────────────────────────────────────────────────────────
signal achievement_unlocked(achievement_id: String)
signal achievement_progress(achievement_id: String, current: int, target: int)

# ── Save System ─────────────────────────────────────────────────────────────
signal game_saved(slot: int)
signal game_loaded(slot: int)
signal save_failed(slot: int, error: String)

# ── Audio ───────────────────────────────────────────────────────────────────
signal bgm_changed(track_name: String)
signal volume_changed(bus_name: String, volume: float)

# ── UI ──────────────────────────────────────────────────────────────────────
signal notification_requested(text: String, duration: float)
signal tooltip_requested(item_id: String, position: Vector2)
signal tooltip_hidden
