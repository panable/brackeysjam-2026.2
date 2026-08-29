class_name Player
extends CharacterBody3D

@export var speed := 14.0
@export var fall_acceleration := 75.0

var can_move := true
var target_velocity := Vector3.ZERO

@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var pivot: Node3D = $Pivot
@onready var player_animation: PlayerAnimation = $Pivot/Player


func _process(_delta):
	var mouse := get_viewport().get_mouse_position()
	var center := get_viewport().get_visible_rect().size / 2.0

	var direction := center - mouse

	pivot.rotation.y = atan2(direction.x, direction.y)


func DisableCollider():
	collider.set_deferred("disabled", true)


func EnableCollider():
	collider.set_deferred("disabled", false)


func _physics_process(delta):
	var input_direction := Vector2.ZERO

	if can_move:
		input_direction = Input.get_vector(
			"move_left",
			"move_right",
			"move_forward",
			"move_back"
		)

	var is_moving := input_direction != Vector2.ZERO

	player_animation.set_moving(is_moving)

	if is_moving:
		var world_direction := Vector3(
			input_direction.x,
			0.0,
			input_direction.y
		)

		# Convert world-space movement into the player's local space.
		var local_direction := pivot.global_basis.inverse() * world_direction

		# Animation BlendSpace2D:
		# X = left/right
		# Y = forward/backward
		var animation_direction := Vector2(
			-local_direction.x,
			local_direction.z
		)

		player_animation.set_movement_direction(animation_direction)

	# Movement
	var direction := Vector3(
		input_direction.x,
		0.0,
		input_direction.y
	)

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Gravity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0.0

	velocity = target_velocity
	move_and_slide()
