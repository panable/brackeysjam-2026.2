class_name EnemyHealth
extends Node


signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal died


@export_category("Health")
@export var max_health: float = 3.0

@export_category("ToFree")
@export var free_me: Node

@export_category("Hit Flash")
@export var hit_flash_duration: float = 0.12
@export var flash_emission_energy: float = 3.0


@export_category("Knockback")
@export var knockback_speed: float = 50.0
@export var knockback_duration: float = 0.12


@export_category("Hit Animation")
@export var hit_scale := Vector3(1.3, 0.7, 1.3)
@export var hit_rotation := 8.0


var current_health: float

var knockback_velocity := Vector3.ZERO
var knockback_timer := 0.0

var original_scale := Vector3.ONE

var meshes: Array[MeshInstance3D] = []
var original_materials: Dictionary = {}

var is_hit := false

var player: Player


func _ready() -> void:
	current_health = max_health

	var enemy := get_parent()

	original_scale = enemy.scale

	player = get_tree().get_first_node_in_group("player")

	for mesh in enemy.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	):
		meshes.append(mesh)
		original_materials[mesh] = mesh.material_override


func _physics_process(delta: float) -> void:
	if knockback_timer <= 0.0:
		return

	knockback_timer -= delta

	if knockback_timer <= 0.0:
		knockback_timer = 0.0
		knockback_velocity = Vector3.ZERO


func take_damage(amount: float) -> void:
	if is_hit:
		return

	if current_health <= 0.0:
		return

	if amount <= 0.0:
		return

	is_hit = true

	current_health = max(
		current_health - amount,
		0.0
	)

	health_changed.emit(
		current_health,
		max_health
	)

	damaged.emit(amount)

	flash_white()
	apply_knockback()
	hit_animation()

	if current_health <= 0.0:
		died.emit()

		await get_tree().create_timer(
			knockback_duration
		).timeout

		die()

		return

	await get_tree().create_timer(
		hit_flash_duration
	).timeout

	is_hit = false


func apply_knockback() -> void:
	var enemy := get_parent() as CharacterBody3D

	if enemy == null:
		return

	if not is_instance_valid(player):
		return

	var direction := enemy.global_position - player.global_position

	direction.y = 0.0

	if direction.length_squared() < 0.01:
		direction = -enemy.global_transform.basis.z

	direction = direction.normalized()

	knockback_velocity = direction * knockback_speed
	knockback_timer = knockback_duration


func flash_white() -> void:
	for mesh in meshes:
		if not is_instance_valid(mesh):
			continue

		var flash_material := StandardMaterial3D.new()

		flash_material.albedo_color = Color.WHITE

		flash_material.emission_enabled = true
		flash_material.emission = Color.WHITE
		flash_material.emission_energy_multiplier = flash_emission_energy

		mesh.material_override = flash_material

	await get_tree().create_timer(
		hit_flash_duration
	).timeout

	for mesh in meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_override = original_materials[mesh]


func hit_animation() -> void:
	var enemy := get_parent() as Node3D

	if enemy == null:
		return

	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		enemy,
		"scale",
		original_scale * hit_scale,
		0.05
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		enemy,
		"rotation_degrees",
		enemy.rotation_degrees + Vector3(
			0.0,
			0.0,
			hit_rotation
		),
		0.05
	)

	tween.chain()

	tween.tween_property(
		enemy,
		"scale",
		original_scale,
		0.12
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


func die() -> void:
	await get_tree().create_timer(1.2).timeout
	free_me.queue_free()

func is_dead() -> bool:
	return current_health <= 0.0


func is_knocked_back() -> bool:
	return knockback_timer > 0.0
