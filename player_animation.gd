extends Node3D
class_name PlayerAnimation

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


func _ready() -> void:
	animation_tree.active = true

func die() -> void:
	animation_tree.set(
		"parameters/conditions/is_moving",
		false
	)

	animation_tree.set(
		"parameters/conditions/is_idle",
		false
	)
	animation_tree.set(
		"parameters/conditions/is_dead",
		true
	)

func set_moving(moving: bool) -> void:
	animation_tree.set(
		"parameters/conditions/is_moving",
		moving
	)

	animation_tree.set(
		"parameters/conditions/is_idle",
		!moving
	)

	print("Moving: ", moving)


func set_movement_direction(direction: Vector2) -> void:
	animation_tree.set(
		"parameters/Running/blend_position",
		direction
	)

	print("Blend: ", direction)
