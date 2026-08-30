extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var player: Player = get_tree().get_first_node_in_group("player")

@export var speed := 2.5
@export var gravity := 9.8


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -2.0

	# Only do navigation movement if we have a player.
	if is_instance_valid(player):
		nav.target_position = player.global_position

		var next_location := nav.get_next_path_position()
		var direction := next_location - global_position
		direction.y = 0.0

		if direction.length_squared() > 0.01:
			direction = direction.normalized()

			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()
