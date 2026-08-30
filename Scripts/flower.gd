extends Node3D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var flower: Node3D = $"."


func _ready() -> void:
	# If the flower has already been planted, show the completed state.
	if GameState.get_flag("flower_planted"):
		flower.show()
		animation_player.play("FlowerBloom")
		animation_player.seek(animation_player.current_animation_length, true)
	else:
		flower.hide()


func plant_flower() -> void:
	# Prevent planting it multiple times.
	if GameState.get_flag("flower_planted"):
		return

	GameState.set_flag("flower_planted", true)

	flower.show()

	animation_player.play("FlowerBloom")

	print("Flower planted!")
