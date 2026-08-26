extends Camera3D
@export var playa: CharacterBody3D

var xMovePos: float = 30.8
var zMovePos: float = 17.6

var movePos: Vector3 = global_position

var t: float = 0.0
var moving = false

func _ready() -> void:
	set_screen_position(0)
	await get_tree().process_frame
	print(playa.velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_screen_position(delta)
	
func set_screen_position(delta: float):
	if moving:
		t += delta * 0.2
		global_position = global_position.lerp(movePos, t)
		if global_position.distance_to(movePos) <= 0.01:
			print("Done")
			moving = false
			t = 0.0
		return

	var plane = (playa.global_position - Vector3(global_position.x, playa.global_position.y, global_position.z))

	if abs(plane.x) >= 16:
		print("Moving")
		movePos = global_position
		movePos.x += sign(plane.x) * xMovePos
		moving = true
	elif abs(plane.z) >= 9:
		print("Moving")
		movePos = global_position
		movePos.z += sign(plane.z) * zMovePos
		moving = true
	
	
