extends Node3D

@onready var animation_player: AnimationPlayer = get_parent().get_node("AnimationPlayer")


func _ready() -> void:
	if GameState.get_flag("flower_planted"):
		show()
		_set_finished_state()
	else:
		hide()


func plant_flower() -> void:
	print("plant_flower called")

	show()

	GameState.set_flag("flower_planted", true)

	if animation_player == null:
		print("ERROR: AnimationPlayer is null")
		return

	if not animation_player.has_animation("FlowerBloom"):
		print("ERROR: FlowerBloom animation does not exist")
		print("Available animations: ", animation_player.get_animation_list())
		return

	print("Playing FlowerBloom")
	animation_player.play("FlowerBloom")


func _set_finished_state() -> void:
	if animation_player == null:
		return

	if not animation_player.has_animation("FlowerBloom"):
		return

	animation_player.play("FlowerBloom")
	animation_player.seek(
		animation_player.get_animation("FlowerBloom").length,
		true
	)
	animation_player.stop()
