class_name DoorController
extends Node3D

@onready var block: AnimationTree = $block/AnimationTree
@onready var collision_shape_3d: CollisionShape3D = $block/StaticBody3D/CollisionShape3D

func clear_room() -> void:
	block.set(
		"parameters/conditions/room_cleared",
		true
	)
	collision_shape_3d.disabled = true

func _ready() -> void:
	pass
