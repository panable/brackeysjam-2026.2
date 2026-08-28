extends Sprite3D

@export var distance_from_camera: float = 25.0
@export var overscan: float = 1.08

@onready var camera: Camera3D = get_parent() as Camera3D


func _ready() -> void:
	if camera == null:
		push_error("EyeBackdrop must be a child of a Camera3D.")
		return

	_update_position()

	await get_tree().process_frame
	_update_backdrop_size()

	get_viewport().size_changed.connect(_update_backdrop_size)


func _process(_delta: float) -> void:
	_update_position()


func _update_position() -> void:
	position = Vector3(0.0, 0.0, -distance_from_camera)
	rotation = Vector3.ZERO


func _update_backdrop_size() -> void:
	if camera == null or texture == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size

	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return

	var aspect_ratio := viewport_size.x / viewport_size.y

	var required_width: float
	var required_height: float

	if camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
		var fov := deg_to_rad(camera.fov)

		if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
			required_height = 2.0 * distance_from_camera * tan(fov / 2.0)
			required_width = required_height * aspect_ratio
		else:
			required_width = 2.0 * distance_from_camera * tan(fov / 2.0)
			required_height = required_width / aspect_ratio

	elif camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		required_height = camera.size
		required_width = required_height * aspect_ratio

	else:
		return

	required_width *= overscan
	required_height *= overscan

	var texture_size := Vector2(
		texture.get_width(),
		texture.get_height()
	)

	if texture_size.x <= 0 or texture_size.y <= 0:
		return

	pixel_size = max(
		required_width / texture_size.x,
		required_height / texture_size.y
	)
