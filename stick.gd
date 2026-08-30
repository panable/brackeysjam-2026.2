extends MeshInstance3D
const MONEY = preload("uid://btgvq5f64h3as")
const PLAYER_INVENTORY = preload("uid://cib86xegispic")
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D

var attacking := false
var attack_on_cooldown := false

# Normal resting position
var REST_POS: Vector3
var REST_ROT: Vector3

# Attack wind-up position
const START_POS := Vector3(-0.68, 0.6, 0.82)
const START_ROT := Vector3(-72, -121, -92)

# Attack end position
const END_POS := Vector3(0.6, 0.3, 0.8)
const END_ROT := Vector3(-72, -54, -92)
@onready var area_3d: Area3D = $Area3D

const SWING_TIME := 0.16
const RETURN_TIME := 0.14
const ATTACK_COOLDOWN := 0.1


func _ready() -> void:
	area_3d.body_entered.connect(_on_area_3d_body_entered)
	REST_POS = position
	REST_ROT = rotation_degrees


func _on_area_3d_body_entered(body: Node3D) -> void:
	if "enemy_health" in body:
		body.enemy_health.take_damage(1)


func activate_col() -> void:
	collision_shape_3d.disabled = false


func deactivate_col() -> void:
	collision_shape_3d.disabled = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if not attacking and not attack_on_cooldown:
			attack()


func attack() -> void:
	attacking = true
	attack_on_cooldown = true

	# Snap to attack starting position
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

	# Return to resting position
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

	# Start cooldown independently from the attack animation
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	attack_on_cooldown = false
