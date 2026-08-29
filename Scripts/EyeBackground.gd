extends Control

@export var eye_scene: PackedScene
@export var eye_count: int = 80

@export var base_spacing: float = 35.0
@export var size_spacing_multiplier: float = 55.0
@export var max_attempts_per_eye: int = 60

@onready var eyes: Control = $ColorRect/Eyes


func _ready() -> void:
	await get_tree().process_frame
	spawn_eyes()


func spawn_eyes() -> void:
	if eye_scene == null:
		push_error("Eye scene has not been assigned.")
		return

	var placed_eyes: Array[Dictionary] = []

	for i in range(eye_count):
		var eye_scale := _get_random_eye_scale()

		var spawn_position := _find_valid_position(
			placed_eyes,
			eye_scale
		)

		if spawn_position == Vector2(-1.0, -1.0):
			continue

		_spawn_eye(spawn_position, eye_scale)

		placed_eyes.append({
			"position": spawn_position,
			"scale": eye_scale
		})


func _get_random_eye_scale() -> float:
	var random_value := randf()

	if random_value < 0.70:
		return randf_range(0.12, 0.30)

	elif random_value < 0.90:
		return randf_range(0.30, 0.65)

	else:
		return randf_range(0.65, 1.20)


func _find_valid_position(
	placed_eyes: Array[Dictionary],
	eye_scale: float
) -> Vector2:

	for attempt in range(max_attempts_per_eye):
		var spawn_position := Vector2(
			randf_range(0.0, eyes.size.x),
			randf_range(0.0, eyes.size.y)
		)

		if _position_is_valid(
			spawn_position,
			eye_scale,
			placed_eyes
		):
			return spawn_position

	return Vector2(-1.0, -1.0)


func _position_is_valid(
	spawn_position: Vector2,
	eye_scale: float,
	placed_eyes: Array[Dictionary]
) -> bool:

	for existing_eye in placed_eyes:
		var existing_position: Vector2 = existing_eye["position"]
		var existing_scale: float = existing_eye["scale"]

		var required_distance := (
			base_spacing
			+ (eye_scale * size_spacing_multiplier)
			+ (existing_scale * size_spacing_multiplier)
		)

		if spawn_position.distance_to(existing_position) < required_distance:
			return false

	return true


func _spawn_eye(
	spawn_position: Vector2,
	eye_scale: float
) -> void:

	var eye := eye_scene.instantiate()

	eyes.add_child(eye)

	eye.position = spawn_position
	eye.scale = Vector2.ONE * eye_scale

	eye.rotation = deg_to_rad(
		randf_range(-12.0, 12.0)
	)
