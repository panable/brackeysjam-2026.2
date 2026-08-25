extends CharacterBody3D
@onready var nav: NavigationAgent3D = $NavigationAgent3D
var speed = 9.5
var gravity = 9.8
@onready var playa: CharacterBody3D = $"../playa"


func _process(delta):
	target_position(playa.global_position)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y -= 2
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()

func target_position(target):
	nav.target_position = target
