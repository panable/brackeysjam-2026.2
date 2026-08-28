extends Node3D

@onready var sprite: Sprite3D = $Sprite3D
@onready var area: Area3D = $Area3D
@onready var viewport: SubViewport = $SubViewport

@onready var start_button: Button = $SubViewport/MenuContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $SubViewport/MenuContainer/VBoxContainer/SettingsButton
@onready var exit_button: Button = $SubViewport/MenuContainer/VBoxContainer/ExitButton


func _ready() -> void:
	area.input_event.connect(_on_area_input_event)

	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_area_input_event(
	_camera: Node,
	event: InputEvent,
	event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:

	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	var local_position := sprite.to_local(event_position)

	var sprite_size := Vector2(
		sprite.texture.get_width(),
		sprite.texture.get_height()
	)

	var world_width := sprite_size.x * sprite.pixel_size
	var world_height := sprite_size.y * sprite.pixel_size

	var uv := Vector2()

	uv.x = (local_position.x / world_width) + 0.5
	uv.y = 1.0 - ((local_position.y / world_height) + 0.5)

	uv.x = clamp(uv.x, 0.0, 1.0)
	uv.y = clamp(uv.y, 0.0, 1.0)

	var viewport_position := Vector2(
		uv.x * viewport.size.x,
		uv.y * viewport.size.y
	)

	var mouse_event := InputEventMouseButton.new()

	mouse_event.position = viewport_position
	mouse_event.global_position = viewport_position
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	mouse_event.pressed = event.pressed

	viewport.push_input(mouse_event)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/RealGame.tscn")


func _on_settings_pressed() -> void:
	print("SETTINGS PRESSED")


func _on_exit_pressed() -> void:
	get_tree().quit()
