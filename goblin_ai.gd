extends CharacterBody3D
@onready var atk_zone: atk_zone = $AtkZone

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export_category("Movement")
@export var movement_speed := 11.0 ## Normal movement speed.
@export var detection_range := 25.0 ## Maximum distance at which the enemy notices the player.
@export var orbit_distance := 6.0 ## Distance from the player while circling them.

@export_category("Attack")
@export var attack_range := 6.0 ## Distance at which the enemy can start attacking.
@export var attack_cooldown := 1.0 ## Time between attacks.
@export var lunge_speed := 45.0 ## Speed of the attack lunge.
@export var lunge_duration := 0.20 ## How long the lunge lasts.
@export var attack_telegraph := 0.12 ## Short delay before the lunge begins.
@export var hit_radius := 1.5 ## Distance required to hit the player.

@export_category("Health")
@export var max_health := 3 ## Number of hits the enemy can take.
@export var knockback_strength := 10.0 ## Distance of the knockback.
@export var knockback_speed := 50.0 ## Speed at which knockback happens.
@export var knockback_duration := 0.12 ## How long the knockback lasts.
@export var hit_flash_duration := 0.12 ## How long the hit flash lasts.

@export_category("Behaviour")
@export var orbit_direction_change_time := Vector2(0.8, 1.8) ## Random interval for changing orbit direction.

var health := max_health
var is_attacking := false
var attack_timer := 0.0
var orbit_direction := 1.0
var orbit_timer := 0.0
var is_hit := false
var knockback_velocity := Vector3.ZERO
var knockback_timer := 0.0

var original_scale := Vector3.ONE
var meshes: Array[MeshInstance3D] = []
var original_materials: Dictionary = {}


func _ready() -> void:
	print(player.name)
	original_scale = scale

	for mesh in find_children("*", "MeshInstance3D", true, false):
		meshes.append(mesh)
		original_materials[mesh] = mesh.material_override


func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		move_and_slide()
		return

	if is_attacking:
		return

	if attack_timer > 0.0:
		attack_timer -= delta

	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -2.0

	var direction_to_player := player.global_position - global_position
	direction_to_player.y = 0.0

	var distance_to_player := direction_to_player.length()

	if distance_to_player > detection_range:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	orbit_timer -= delta

	if orbit_timer <= 0.0:
		orbit_timer = randf_range(
			orbit_direction_change_time.x,
			orbit_direction_change_time.y
		)
		orbit_direction *= -1.0

	if distance_to_player <= attack_range and attack_timer <= 0.0:
		start_attack()
		return

	var movement_direction := Vector3.ZERO

	if distance_to_player > orbit_distance:
		navigation_agent.target_position = player.global_position

		var next_position := navigation_agent.get_next_path_position()
		var direction := next_position - global_position
		direction.y = 0.0

		if direction.length_squared() > 0.01:
			movement_direction = direction.normalized()
	else:
		var forward := direction_to_player.normalized()
		movement_direction = Vector3(
			-forward.z,
			0.0,
			forward.x
		) * orbit_direction

	var target_velocity := movement_direction * movement_speed

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

	#look_at(
		#Vector3(
			#player.global_position.x,
			#global_position.y,
			#player.global_position.z
		#),
		#Vector3.UP
	#)

	move_and_slide()


func start_attack() -> void:
	is_attacking = true
	attack_timer = attack_cooldown

	velocity.x = 0.0
	velocity.z = 0.0

	var target_position := player.global_position
	target_position.y = global_position.y

	#look_at(target_position, Vector3.UP)

	await get_tree().create_timer(attack_telegraph).timeout

	if not is_instance_valid(player):
		finish_attack()
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

	velocity.x = lunge_direction.x * lunge_speed
	velocity.z = lunge_direction.z * lunge_speed

	var elapsed := 0.0

	while elapsed < lunge_duration:
		var delta := get_physics_process_delta_time()

		velocity.x = lunge_direction.x * lunge_speed
		velocity.z = lunge_direction.z * lunge_speed

		move_and_slide()

		elapsed += delta
		await get_tree().physics_frame

	velocity.x = 0.0
	velocity.z = 0.0

	if is_instance_valid(player):
		var distance_to_player := global_position.distance_to(player.global_position)

		if distance_to_player <= hit_radius:
			damage_player()

	await get_tree().create_timer(0.15).timeout

	finish_attack()


func take_damage(amount: int, hit_position: Vector3) -> void:
	if is_hit:
		return

	is_hit = true
	health -= amount

	flash_white()
	apply_knockback(hit_position)
	hit_animation()

	if health <= 0:
		await get_tree().create_timer(knockback_duration).timeout
		die()
	else:
		await get_tree().create_timer(hit_flash_duration).timeout
		is_hit = false

func flash_white() -> void:
	for mesh in meshes:
		var flash_material := StandardMaterial3D.new()
		flash_material.albedo_color = Color.WHITE
		flash_material.emission_enabled = true
		flash_material.emission = Color.WHITE
		flash_material.emission_energy_multiplier = 3.0
		mesh.material_override = flash_material

	await get_tree().create_timer(hit_flash_duration).timeout

	for mesh in meshes:
		mesh.material_override = original_materials[mesh]

func apply_knockback(hit_position: Vector3) -> void:
	var direction := global_position - player.global_position
	direction.y = 0.0

	if direction.length_squared() < 0.01:
		direction = -global_transform.basis.z

	direction = direction.normalized()

	knockback_velocity = direction * knockback_speed
	knockback_timer = knockback_duration

func hit_animation() -> void:
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		original_scale * Vector3(1.3, 0.7, 1.3),
		0.05
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees + Vector3(0.0, 0.0, 8.0),
		0.05
	)

	tween.chain()

	tween.tween_property(
		self,
		"scale",
		original_scale,
		0.12
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func die() -> void:
	queue_free()


func finish_attack() -> void:
	is_attacking = false
	atk_zone.reset_damage_cooldown


func damage_player() -> void:
	atk_zone.reset_damage_cooldown()
