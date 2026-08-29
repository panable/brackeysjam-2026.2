extends MeshInstance3D

@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D

var attacking := false
var attack_queued := false

# Normal resting position
const REST_POS := Vector3(0.8, 0.3, -0.7)
const REST_ROT := Vector3(0, -40, 0)

# Attack wind-up position
const START_POS := Vector3(1.0, 0.3, -0.4)
const START_ROT := Vector3(0, -70, 0)

# Attack end position
const END_POS := Vector3(-1.0, 0.3, -0.4)
const END_ROT := Vector3(0, 70, 0)

const SWING_TIME := 0.16
const RETURN_TIME := 0.14


func _ready() -> void:
	# Make sure the sword starts in its normal position
	position = REST_POS
	rotation_degrees = REST_ROT


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1, global_position)


func activate_col() -> void:
	collision_shape_3d.disabled = false


func deactivate_col() -> void:
	collision_shape_3d.disabled = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):

		if attacking:
			attack_queued = true
		else:
			attack()


func attack() -> void:
	attacking = true
	attack_queued = false

	# Snap from resting position to the attack starting position
	position = START_POS
	rotation_degrees = START_ROT

	activate_col()

	var tween := get_tree().create_tween()

	# Swing RIGHT -> LEFT
	tween.tween_property(
		self,
		"position",
		END_POS,
		SWING_TIME
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.parallel().tween_property(
		self,
		"rotation_degrees",
		END_ROT,
		SWING_TIME
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Disable hitbox
	tween.tween_callback(deactivate_col)

	# Quickly return to normal resting position
	tween.tween_property(
		self,
		"position",
		REST_POS,
		RETURN_TIME
	).set_trans(Tween.TRANS_LINEAR)

	tween.parallel().tween_property(
		self,
		"rotation_degrees",
		REST_ROT,
		RETURN_TIME
	).set_trans(Tween.TRANS_LINEAR)

	# Finish attack
	tween.tween_callback(finish_attack)


func finish_attack() -> void:
	attacking = false

	if attack_queued:
		attack_queued = false
		attack()
