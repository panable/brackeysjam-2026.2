extends MeshInstance3D

@onready var timer: Timer = $Timer
var can_attack = true;
var currentSwordPos = position
var currentSwordRot = rotation_degrees
var extendSwordRot = Vector3.RIGHT * 0
var extendSwordPos = currentSwordPos - Vector3.BACK * 1
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var playa: CharacterBody3D = $"../.."
@onready var room: CSGBox3D = $"../../../room"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(rotation_degrees)
	pass
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	body.queue_free()
	
func activate_col(): 
	collision_shape_3d.disabled = false
func deactivate_col(): 
	collision_shape_3d.disabled = true
func activate_move():
	playa.can_move = true
func deactivate_move():
	playa.can_move = false

func _input(event: InputEvent) -> void:
	if event.is_action("attack") and can_attack:
		var tween = get_tree().create_tween()
		tween.tween_callback(deactivate_move)
		tween.tween_property(self, "position", extendSwordPos, 0.15)
		tween.tween_property(self, "rotation_degrees", extendSwordRot, 0.1)
		tween.tween_callback(activate_col)
		tween.tween_property(self, "rotation_degrees", currentSwordRot, 0.1)
		tween.tween_callback(deactivate_col)
		tween.tween_property(self, "position", currentSwordPos, 0.1)
		tween.tween_callback(activate_move)
		timer.start()
		can_attack = false
		#tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 2.0)
		#tween.tween_property(self, "scale", Vector3(0.2, 0.2, 0.2), 2.0)

func _on_timer_timeout() -> void:
	can_attack = true
