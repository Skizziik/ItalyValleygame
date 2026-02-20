extends CharacterBody2D
## Main player character. Controls movement, stats, interaction, and tool use.
## Must be in the "player" group for SceneLoader and DebugManager integration.

# ── Stats ───────────────────────────────────────────────────────────────────
var energy: int = Constants.MAX_ENERGY
var max_energy: int = Constants.MAX_ENERGY
var health: int = Constants.MAX_HEALTH
var max_health: int = Constants.MAX_HEALTH
var money: int = Constants.STARTING_MONEY

# ── Movement ────────────────────────────────────────────────────────────────
var facing: Enums.Direction = Enums.Direction.DOWN
var is_running: bool = false
var _move_input: Vector2 = Vector2.ZERO

# ── Combat ──────────────────────────────────────────────────────────────────
var is_invincible: bool = false

# ── Interaction ─────────────────────────────────────────────────────────────
var can_interact: bool = false
var _nearest_interactable: Node2D = null
var _interactables_in_range: Array[Node2D] = []

# ── Tool Use ────────────────────────────────────────────────────────────────
var _is_using_tool: bool = false

# ── Node References ─────────────────────────────────────────────────────────
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _camera: Camera2D = $Camera2D
@onready var _interaction_area: Area2D = $InteractionArea
@onready var _tool_hitbox: Area2D = $ToolHitbox
@onready var _tool_hitbox_shape: CollisionShape2D = $ToolHitbox/CollisionShape2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _invincibility_timer: Timer = $InvincibilityTimer


func _ready() -> void:
	add_to_group("player")
	_tool_hitbox.monitoring = false
	_tool_hitbox_shape.disabled = true

	_interaction_area.body_entered.connect(_on_interaction_body_entered)
	_interaction_area.body_exited.connect(_on_interaction_body_exited)
	_interaction_area.area_entered.connect(_on_interaction_area_entered)
	_interaction_area.area_exited.connect(_on_interaction_area_exited)
	_invincibility_timer.timeout.connect(_on_invincibility_timeout)

	SignalBus.day_ended.connect(_on_day_ended)
	SignalBus.day_started.connect(_on_day_started)

	# Emit initial stats
	SignalBus.player_energy_changed.emit(energy, max_energy)
	SignalBus.player_health_changed.emit(health, max_health)


func _physics_process(_delta: float) -> void:
	if not GameManager.is_gameplay_active():
		velocity = Vector2.ZERO
		return

	_read_movement_input()
	_apply_movement()
	_update_facing()
	_update_tool_hitbox_position()
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.is_input_blocked():
		return

	if not event.is_pressed() or event.is_echo():
		return

	# Menu shortcuts
	if event.is_action("pause"):
		if GameManager.current_state == Enums.GameState.PLAYING:
			GameManager.change_state(Enums.GameState.PAUSED)
		elif GameManager.current_state == Enums.GameState.PAUSED:
			GameManager.change_state(Enums.GameState.PLAYING)
		get_viewport().set_input_as_handled()
		return

	if not GameManager.is_gameplay_active():
		return

	if event.is_action("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()
	elif event.is_action("use_tool"):
		_try_use_tool()
		get_viewport().set_input_as_handled()
	elif event.is_action("inventory"):
		GameManager.change_state(Enums.GameState.INVENTORY)
		get_viewport().set_input_as_handled()
	elif event.is_action("craft"):
		GameManager.change_state(Enums.GameState.CRAFTING)
		get_viewport().set_input_as_handled()


# ── Movement ────────────────────────────────────────────────────────────────

func _read_movement_input() -> void:
	_move_input = Vector2.ZERO
	_move_input.x = Input.get_axis("move_left", "move_right")
	_move_input.y = Input.get_axis("move_up", "move_down")

	if _move_input.length() > 1.0:
		_move_input = _move_input.normalized()


func _apply_movement() -> void:
	var speed := Constants.PLAYER_SPEED

	if is_running:
		speed *= Constants.PLAYER_RUN_MULTIPLIER

	if energy <= 0:
		speed *= Constants.EXHAUSTION_SPEED_PENALTY

	velocity = _move_input * speed


func _update_facing() -> void:
	if _move_input == Vector2.ZERO:
		return

	# Prioritize vertical when moving diagonally but mostly vertical
	if absf(_move_input.y) > absf(_move_input.x):
		if _move_input.y < 0:
			facing = Enums.Direction.UP
		else:
			facing = Enums.Direction.DOWN
	else:
		if _move_input.x < 0:
			facing = Enums.Direction.LEFT
		else:
			facing = Enums.Direction.RIGHT


# ── Energy System ───────────────────────────────────────────────────────────

## Attempt to use energy. Returns false if not enough (action should be blocked).
func use_energy(amount: int) -> bool:
	if energy <= 0:
		SignalBus.player_exhausted.emit()
		return false

	energy = maxi(energy - amount, 0)
	SignalBus.player_energy_changed.emit(energy, max_energy)

	if energy <= 0:
		SignalBus.player_exhausted.emit()
		DebugManager.dlog("player", "Player exhausted — energy depleted")

	return true


## Restore energy by a fixed amount (from food, etc.)
func restore_energy(amount: int) -> void:
	energy = mini(energy + amount, max_energy)
	SignalBus.player_energy_changed.emit(energy, max_energy)


## Fully restore energy (after sleeping)
func restore_all_energy() -> void:
	energy = max_energy
	SignalBus.player_energy_changed.emit(energy, max_energy)


# ── Health System ───────────────────────────────────────────────────────────

## Take damage. Triggers invincibility frames.
func take_damage(amount: int) -> void:
	if is_invincible or amount <= 0:
		return

	health = maxi(health - amount, 0)
	SignalBus.player_health_changed.emit(health, max_health)
	SignalBus.player_hit.emit(amount)
	DebugManager.dlog("player", "Took %d damage, health: %d/%d" % [amount, health, max_health])

	if health <= 0:
		_die()
		return

	# Start invincibility
	is_invincible = true
	_invincibility_timer.start(Constants.INVINCIBILITY_DURATION)
	_start_damage_flash()


## Heal by a fixed amount (from food, potions, etc.)
func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	SignalBus.player_health_changed.emit(health, max_health)


## Fully restore health
func restore_all_health() -> void:
	health = max_health
	SignalBus.player_health_changed.emit(health, max_health)


func _die() -> void:
	DebugManager.dlog("player", "Player died")
	SignalBus.player_died.emit()
	# Death handling (respawn, penalty) will be added in later phases


func _on_invincibility_timeout() -> void:
	is_invincible = false
	_sprite.modulate.a = 1.0


func _start_damage_flash() -> void:
	if _animation_player.has_animation("damage_flash"):
		_animation_player.play("damage_flash")
	else:
		# Fallback: simple blink via tween
		var tween := create_tween()
		tween.set_loops(4)
		tween.tween_property(_sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(_sprite, "modulate:a", 1.0, 0.1)


# ── Interaction System ──────────────────────────────────────────────────────

func _try_interact() -> void:
	_update_nearest_interactable()
	if _nearest_interactable and _nearest_interactable.has_method("interact"):
		_nearest_interactable.interact(self)
		DebugManager.dlog("player", "Interacted with: %s" % _nearest_interactable.name)


func _update_nearest_interactable() -> void:
	if _interactables_in_range.is_empty():
		_nearest_interactable = null
		can_interact = false
		return

	# Remove any freed nodes
	_interactables_in_range = _interactables_in_range.filter(
		func(n: Node2D) -> bool: return is_instance_valid(n)
	)

	if _interactables_in_range.is_empty():
		_nearest_interactable = null
		can_interact = false
		return

	# Find closest
	var closest: Node2D = null
	var closest_dist := INF
	for obj in _interactables_in_range:
		var dist := global_position.distance_squared_to(obj.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = obj

	_nearest_interactable = closest
	can_interact = closest != null


func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and body != self:
		_interactables_in_range.append(body)
		_update_nearest_interactable()


func _on_interaction_body_exited(body: Node2D) -> void:
	_interactables_in_range.erase(body)
	_update_nearest_interactable()


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		var parent := area.get_parent()
		if parent is Node2D and parent != self:
			_interactables_in_range.append(parent)
			_update_nearest_interactable()


func _on_interaction_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Node2D:
		_interactables_in_range.erase(parent)
		_update_nearest_interactable()


# ── Tool System ─────────────────────────────────────────────────────────────

func _try_use_tool() -> void:
	if _is_using_tool:
		return

	# Energy cost will depend on equipped tool (placeholder: generic cost)
	# For now, just activate the hitbox briefly
	_is_using_tool = true
	_tool_hitbox.monitoring = true
	_tool_hitbox_shape.disabled = false

	DebugManager.dlog("player", "Tool used, facing: %s" % Enums.Direction.keys()[facing])

	# Deactivate after a short delay
	await get_tree().create_timer(0.2).timeout

	_tool_hitbox.monitoring = false
	_tool_hitbox_shape.disabled = true
	_is_using_tool = false


func _update_tool_hitbox_position() -> void:
	var offset := Vector2.ZERO
	match facing:
		Enums.Direction.UP:    offset = Vector2(0, -16)
		Enums.Direction.DOWN:  offset = Vector2(0, 16)
		Enums.Direction.LEFT:  offset = Vector2(-16, 0)
		Enums.Direction.RIGHT: offset = Vector2(16, 0)

	_tool_hitbox.position = offset


# ── Time Events ─────────────────────────────────────────────────────────────

func _on_day_ended() -> void:
	DebugManager.dlog("player", "Day ended — sleeping")
	SignalBus.player_slept.emit()
	restore_all_energy()
	restore_all_health()


func _on_day_started(_day: int) -> void:
	SignalBus.player_woke_up.emit()


# ── Save/Load ───────────────────────────────────────────────────────────────

func serialize() -> Dictionary:
	return {
		"position_x": global_position.x,
		"position_y": global_position.y,
		"energy": energy,
		"health": health,
		"money": money,
		"facing": facing,
	}


func deserialize(data: Dictionary) -> void:
	global_position = Vector2(
		data.get("position_x", 0.0),
		data.get("position_y", 0.0),
	)
	energy = data.get("energy", max_energy)
	health = data.get("health", max_health)
	money = data.get("money", Constants.STARTING_MONEY)
	facing = data.get("facing", Enums.Direction.DOWN) as Enums.Direction

	SignalBus.player_energy_changed.emit(energy, max_energy)
	SignalBus.player_health_changed.emit(health, max_health)
	SignalBus.money_changed.emit(money)
