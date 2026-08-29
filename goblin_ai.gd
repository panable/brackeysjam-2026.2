extends CharacterBody3D


@onready var atk_zone: atk_zone = $AtkZone
@onready var enemy_health: EnemyHealth = $EnemyHealth
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D


@export_category("Movement")
@export var movement_speed := 11.0 ## Normal movement speed.
@export var detection_range := 25.0 ## Maximum distance at which the enemy notices the player.
@export var orbit_distance := 6.0 ## Distance from the player while circling them.


@export_category("Attack")
@export var attack_range := 6.0 ## Distance at which the enemy can start attacking.
@export var attack_cooldown := 3.0 ## Time between attacks.
@export var lunge_speed := 45.0 ## Speed of the attack lunge.
@export var lunge_duration := 0.20 ## How long the lunge lasts.
@export var attack_telegraph := 0.12 ## Short delay before the lunge begins.
@export var hit_radius := 1.5 ## Distance required to hit the player.


@export_category("Behaviour")
@export var orbit_direction_change_time := Vector2(
	0.8,
	1.8
)


var is_attacking := false
var attack_timer := 0.0

var orbit_direction := 1.0
var orbit_timer := 0.0

var just_loaded := true


func _ready() -> void:
	enemy_health.died.connect(_on_enemy_died)


func _physics_process(delta: float) -> void:
	if just_loaded:
		await get_tree().create_timer(1.0).timeout
		just_loaded = false

	if enemy_health.is_dead():
		return

	apply_gravity(delta)

	# EnemyHealth calculates and stores the knockback.
	# GoblinAI remains responsible for actually moving.
	if enemy_health.is_knocked_back():
		apply_knockback()
		move_and_slide()
		return

	if is_attacking:
		return

	update_attack_timer(delta)

	if not is_instance_valid(player):
		stop_moving()
		move_and_slide()
		return

	var direction_to_player := player.global_position - global_position
	direction_to_player.y = 0.0

	var distance_to_player := direction_to_player.length()

	if distance_to_player > detection_range:
		stop_moving()
		move_and_slide()
		return

	update_orbit(delta)

	if distance_to_player <= attack_range and attack_timer <= 0.0:
		start_attack()
		return

	var movement_direction := get_movement_direction(
		direction_to_player,
		distance_to_player
	)

	move_towards_player(movement_direction, delta)

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -2.0


func apply_knockback() -> void:
	velocity.x = enemy_health.knockback_velocity.x
	velocity.z = enemy_health.knockback_velocity.z


func update_attack_timer(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta


func update_orbit(delta: float) -> void:
	orbit_timer -= delta

	if orbit_timer > 0.0:
		return

	orbit_timer = randf_range(
		orbit_direction_change_time.x,
		orbit_direction_change_time.y
	)

	orbit_direction *= -1.0


func get_movement_direction(
	direction_to_player: Vector3,
	distance_to_player: float
) -> Vector3:
	if distance_to_player > orbit_distance:
		navigation_agent.target_position = player.global_position

		var next_position := navigation_agent.get_next_path_position()

		var direction := next_position - global_position
		direction.y = 0.0

		if direction.length_squared() > 0.01:
			return direction.normalized()

		return Vector3.ZERO

	var forward := direction_to_player.normalized()

	return Vector3(
		-forward.z,
		0.0,
		forward.x
	) * orbit_direction


func move_towards_player(
	direction: Vector3,
	delta: float
) -> void:
	var target_velocity := direction * movement_speed

	velocity.x = move_toward(
		velocity.x,
		target_velocity.x,
		30.0 * delta
	)

	velocity.z = move_toward(
		velocity.z,
		target_velocity.z,
		30.0 * delta
	)


func stop_moving() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


func start_attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown

	stop_moving()

	await get_tree().create_timer(
		attack_telegraph
	).timeout

	if not is_instance_valid(player):
		finish_attack()
		return

	if enemy_health.is_dead():
		return

	lunge()


func lunge() -> void:
	var target_position := player.global_position

	target_position.y = global_position.y

	var lunge_direction := target_position - global_position

	lunge_direction.y = 0.0

	if lunge_direction.length_squared() < 0.01:
		finish_attack()
		return

	lunge_direction = lunge_direction.normalized()

	var elapsed := 0.0

	while elapsed < lunge_duration:
		if enemy_health.is_dead():
			return

		if enemy_health.is_knocked_back():
			return

		var delta := get_physics_process_delta_time()

		velocity.x = lunge_direction.x * lunge_speed
		velocity.z = lunge_direction.z * lunge_speed

		move_and_slide()

		elapsed += delta

		await get_tree().physics_frame

	stop_moving()

	if is_instance_valid(player):
		var distance_to_player := global_position.distance_to(
			player.global_position
		)

		if distance_to_player <= hit_radius:
			damage_player()

	await get_tree().create_timer(0.15).timeout

	finish_attack()


func damage_player() -> void:
	atk_zone.reset_damage_cooldown()


func finish_attack() -> void:
	is_attacking = false
	atk_zone.reset_damage_cooldown()


func _on_enemy_died() -> void:
	is_attacking = false
