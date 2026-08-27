extends Node3D

@export var npc_name: String = "NPC"
@export_file("*.json") var dialogue_path: String
@export var entry_name: String
@export var head_return_speed: float = 3.0

@onready var interaction_area: Area3D = $Area3D
@onready var dialogue: Control = get_node("/root/RealGame/DialogueUI")


var skeleton: Skeleton3D
var in_range := false
var _data: Dictionary = {}
var player: Node3D = null
var is_talking := false
var head_bone: int = -1
var head_override_weight: float = 0.0
var head_rest_pose: Transform3D
var head_returning := false

func _ready() -> void:
	_load_dialogue()
	skeleton = _find_skeleton($ModelRoot)

	if skeleton:
		head_bone = skeleton.find_bone("Head")

		if head_bone != -1:
			head_rest_pose = skeleton.get_bone_global_pose(head_bone)
	else:
		print("No Skeleton3D found")
	
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)
	dialogue.dialogue_finished.connect(_on_finished)

func _process(delta: float) -> void:
	if in_range and player:
		head_returning = false
		_track_player(delta)
	elif head_returning:
		_return_head_to_animation(delta)


	if in_range and not is_talking and Input.is_action_just_pressed("interact"):
		interact()

func _load_dialogue() -> void:
	if dialogue_path.is_empty():
		return
	
	var file := FileAccess.open(dialogue_path, FileAccess.READ)
	if file:
		var parsed_data = JSON.parse_string(file.get_as_text())
		if parsed_data is Dictionary:
			_data = parsed_data

func interact() -> void:
	if player == null:
		return
	
	if _data.is_empty():
		return
	
	if is_talking:
		return
	
	player.can_move = false
	is_talking = true
	player.set_process_unhandled_input(false)
	dialogue.start(_data, entry_name)
	

# Check if player has entered range
func _enter_range(body: Node3D) -> void:
	in_range = true
	player = body
	head_returning = false
	print(player.name," entered interaction range of ", npc_name)

# Check if player has exited range
func _exit_range(body: Node3D) -> void:
	if body != player:
		return
	in_range = false
	head_returning = true
	print(player.name," left interaction range of ", npc_name)
	
func _on_finished() -> void:
	if player:
		player.set_process_unhandled_input(true)
		player.can_move = true
		is_talking = false

func _track_player(delta: float) -> void:
	if player == null:
		return

	if skeleton == null:
		return

	if head_bone == -1:
		return

	var head_pose: Transform3D = skeleton.get_bone_global_pose(head_bone)
	var player_local_position: Vector3 = skeleton.to_local(player.global_position)
	var direction: Vector3 = player_local_position - head_pose.origin

	if direction.length_squared() == 0:
		return
	var target_basis: Basis = Basis.looking_at(direction.normalized(),Vector3.UP)


	# Correction on X Axis (Tilt Down slightly)
	target_basis = target_basis.rotated(Vector3.LEFT,deg_to_rad(30.0))
	# Correction on Y Axis (Head is Inverted XD)
	target_basis = target_basis.rotated(Vector3.UP,deg_to_rad(180.0))
	
	
	head_pose.basis = target_basis
	head_override_weight = move_toward(head_override_weight,1.0,head_return_speed * delta)
	skeleton.set_bone_global_pose_override(head_bone,head_pose,head_override_weight,true)
	
	## TEMP SLOP TO FIND SKELETON
func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var result := _find_skeleton(child)
		if result:
			return result
	return null

func _return_head_to_animation(delta: float) -> void:
	if skeleton == null:
		return

	if head_bone == -1:
		return

	var current_pose: Transform3D = skeleton.get_bone_global_pose(head_bone)
	var current_rotation: Quaternion = current_pose.basis.get_rotation_quaternion()
	var rest_rotation: Quaternion = head_rest_pose.basis.get_rotation_quaternion()
	var blend_amount: float = clamp(head_return_speed * delta,0.0,1.0)
	var new_rotation: Quaternion = current_rotation.slerp(rest_rotation,blend_amount)
	
	current_pose.basis = Basis(new_rotation)
	skeleton.set_bone_global_pose_override(head_bone,current_pose,1.0,true)

	if new_rotation.angle_to(rest_rotation) < deg_to_rad(1.0):
		skeleton.set_bone_global_pose_override(head_bone,Transform3D.IDENTITY,0.0,false)
		head_override_weight = 0.0
		head_returning = false
