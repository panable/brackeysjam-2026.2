extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var atk_zone: atk_zone = $AtkZone
@onready var enemy_health: EnemyHealth = $EnemyHealth
@onready var stump: AnimationTree = $stump/AnimationTree

@onready var player: Node3D = get_tree().get_first_node_in_group("molly")

@export_category("Movement")
@export var speed := 2.5
@export var gravity := 9.8

var dead := false


func _ready() -> void:
	enemy_health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if GameState.get_flag("molly_saved"):
		get_parent().queue_free()
		return
	apply_gravity(delta)

	# Don't do anything else while dead.
	if dead:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# Knockback takes priority over normal movement.
	if enemy_health.is_knocked_back():
		apply_knockback()
		_set_animation_moving()
		move_and_slide()
		return

	if is_instance_valid(player):
		nav.target_position = player.global_position

		var next_location := nav.get_next_path_position()
		var direction := next_location - global_position
		direction.y = 0.0

		if direction.length_squared() > 0.01:
			direction = direction.normalized()

			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

			_set_animation_moving()
		else:
			velocity.x = 0.0
			velocity.z = 0.0

			_set_animation_idle()
	else:
		velocity.x = 0.0
		velocity.z = 0.0

		_set_animation_idle()

	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -2.0


func apply_knockback() -> void:
	velocity.x = enemy_health.knockback_velocity.x
	velocity.z = enemy_health.knockback_velocity.z


func _on_died() -> void:
	print("FKEN DIED")

	if not GameState.get_flag("molly_died"):
		GameState.set_flag("molly_saved")

	dead = true

	velocity.x = 0.0
	velocity.z = 0.0

	stump.set(
		"parameters/conditions/is_dead",
		true
	)

	stump.set(
		"parameters/conditions/is_moving",
		false
	)

	stump.set(
		"parameters/conditions/is_idle",
		false
	)


func _set_animation_moving() -> void:
	stump.set(
		"parameters/conditions/is_moving",
		true
	)

	stump.set(
		"parameters/conditions/is_idle",
		false
	)


func _set_animation_idle() -> void:
	stump.set(
		"parameters/conditions/is_moving",
		false
	)

	stump.set(
		"parameters/conditions/is_idle",
		true
	)
