class_name Health
extends Node

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died


@export_category("Health")
@export var max_health: float = 100.0
@export var starting_health: float = 100.0

@export_category("Hit Flash")
@export var hit_flash_duration: float = 0.12
@export var flash_emission_energy: float = 3.0

@export_category("Knockback")
@export var knockback_strength: float = 5.0
@export var knockback_speed: float = 5.0
@export var knockback_duration: float = 0.12


var current_health: float

var meshes: Array[MeshInstance3D] = []
var original_materials: Dictionary = {}

var knockback_velocity := Vector3.ZERO
var knockback_timer := 0.0


func _ready() -> void:
	current_health = clamp(starting_health, 0.0, max_health)

	for mesh in get_parent().find_children("*", "MeshInstance3D", true, false):
		meshes.append(mesh)
		original_materials[mesh] = mesh.material_override


func _physics_process(delta: float) -> void:
	if knockback_timer <= 0.0:
		return

	knockback_timer -= delta

	var character := get_parent() as CharacterBody3D

	if character == null:
		return

	character.velocity.x = knockback_velocity.x
	character.velocity.z = knockback_velocity.z
	character.move_and_slide()


func take_damage(amount: float, hit_position: Vector3 = Vector3.INF) -> void:
	if current_health <= 0.0:
		return

	if amount <= 0.0:
		return

	current_health = max(current_health - amount, 0.0)

	flash_white()

	if hit_position != Vector3.INF:
		apply_knockback(hit_position)

	damaged.emit(amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if current_health <= 0.0:
		return

	if amount <= 0.0:
		return

	var old_health := current_health

	current_health = min(current_health + amount, max_health)

	var actual_heal := current_health - old_health

	if actual_heal > 0.0:
		healed.emit(actual_heal)
		health_changed.emit(current_health, max_health)


func set_health(amount: float) -> void:
	current_health = clamp(amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)


func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0.0


func is_full() -> bool:
	return current_health >= max_health


func get_health_percent() -> float:
	if max_health <= 0.0:
		return 0.0

	return current_health / max_health


func apply_knockback(hit_position: Vector3) -> void:
	var character := get_parent() as CharacterBody3D

	if character == null:
		return

	var direction := character.global_position - hit_position

	direction.y = 0.0

	if direction.length_squared() < 0.01:
		direction = -character.global_transform.basis.z

	direction = direction.normalized()

	knockback_velocity = direction * knockback_speed * knockback_strength
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

	await get_tree().create_timer(hit_flash_duration).timeout

	for mesh in meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_override = original_materials[mesh]
