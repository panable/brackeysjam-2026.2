extends Node3D

@export var npc_name: String = "NPC"
@export_file("*.json") var dialogue_path: String
@export var entry_name: String
@export var head_return_speed: float = 3.0

@export var condition_flag: String = ""
@export var false_entry: String = ""
@export var true_entry: String = ""

# Optional flag that can be set by a dialogue choice.
@export var dialogue_flag: String = ""

# Optional item this NPC can take from the player.
# The amount is controlled by "take_amount" in the dialogue JSON.
@export var take_item: ItemData

var player_camera : Camera3D
var cutscene_camera: Camera3D

@onready var interaction_area: Area3D = $Area3D
@onready var dialogue: Control = get_node("/root/RealGame/DialogueUI")

var player_inventory: Inventory = preload("res://Resources/PlayerInventory.tres")

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
	dialogue.dialogue_choice_selected.connect(_on_dialogue_choice_selected)


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

	if file == null:
		print("ERROR: Could not open dialogue file for ", npc_name)
		return

	var parsed_data = JSON.parse_string(file.get_as_text())

	if parsed_data is Dictionary:
		_data = parsed_data
	else:
		print("ERROR: Invalid dialogue JSON for ", npc_name)


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
	player_camera = get_viewport().get_camera_3d()
	cutscene_camera = player.get_node("Pivot").get_node("CutsceneCamera")
	cutscene_camera.make_current()

	var selected_entry := entry_name

	if not condition_flag.is_empty():
		if GameState.get_flag(condition_flag):
			if not true_entry.is_empty():
				selected_entry = true_entry
		else:
			if not false_entry.is_empty():
				selected_entry = false_entry

	dialogue.start(_data, selected_entry)


func _on_dialogue_choice_selected(choice: Dictionary) -> void:
	# DialogueUI is shared between every NPC.
	# Ignore choices if this NPC is not currently talking.
	if not is_talking:
		return

	var action_successful := true

	# Take an item from the player.
	if choice.has("take_amount"):
		action_successful = _handle_take_item(choice)

	# Only continue with the other actions if taking succeeded.
	if not action_successful:
		return

	# Give an item to the player.
	if choice.has("give_item"):
		action_successful = _handle_give_item(choice)

	# Don't set the flag if giving the item failed.
	if not action_successful:
		return

	# Set this NPC's dialogue flag if requested.
	_handle_set_flag(choice)


func _handle_take_item(choice: Dictionary) -> bool:
	if take_item == null:
		print(
			"WARNING: ",
			npc_name,
			" has a take_amount dialogue choice but no Take Item assigned."
		)
		return false

	var amount: int = choice.get("take_amount", 0)

	if amount <= 0:
		print(
			"WARNING: Invalid take_amount for ",
			npc_name,
			": ",
			amount
		)
		return false

	if not player_inventory.has_item(take_item, amount):
		print(
			npc_name,
			" tried to take ",
			amount,
			"x ",
			take_item.name,
			", but the player does not have enough."
		)
		return false

	var removed := player_inventory.remove_item(
		take_item,
		amount
	)

	if not removed:
		print(
			"ERROR: ",
			npc_name,
			" failed to remove ",
			amount,
			"x ",
			take_item.name
		)
		return false

	print(
		npc_name,
		" took ",
		amount,
		"x ",
		take_item.name
	)

	return true


func _handle_give_item(choice: Dictionary) -> bool:
	var item_path: String = choice.get(
		"give_item",
		""
	)

	if item_path.is_empty():
		print(
			"WARNING: ",
			npc_name,
			" has a give_item action with no item path."
		)
		return false

	var item_to_give = load(item_path)

	if item_to_give == null:
		print(
			"ERROR: ",
			npc_name,
			" could not load item: ",
			item_path
		)
		return false

	if not item_to_give is ItemData:
		print(
			"ERROR: ",
			item_path,
			" is not an ItemData resource."
		)
		return false

	var amount: int = choice.get(
		"give_amount",
		1
	)

	if amount <= 0:
		print(
			"WARNING: Invalid give_amount for ",
			npc_name,
			": ",
			amount
		)
		return false

	var remaining: int = player_inventory.add_item(
		item_to_give,
		amount
	)

	if remaining > 0:
		print(
			"WARNING: ",
			npc_name,
			" could not give all of ",
			item_to_give.name,
			". Remaining: ",
			remaining
		)

		return false

	print(
		npc_name,
		" gave ",
		amount,
		"x ",
		item_to_give.name
	)

	return true


func _handle_set_flag(choice: Dictionary) -> void:
	var should_set_flag: bool = choice.get(
		"set_flag",
		false
	)

	if not should_set_flag:
		return

	if dialogue_flag.is_empty():
		print(
			"WARNING: ",
			npc_name,
			" has set_flag=true but no Dialogue Flag assigned."
		)
		return

	GameState.set_flag(
		dialogue_flag,
		true
	)

	print(
		npc_name,
		" set flag ",
		dialogue_flag,
		" = true"
	)


func _enter_range(body: Node3D) -> void:
	in_range = true
	player = body
	head_returning = false

	print(
		player.name,
		" entered interaction range of ",
		npc_name
	)


func _exit_range(body: Node3D) -> void:
	if body != player:
		return

	in_range = false
	head_returning = true

	print(
		player.name,
		" left interaction range of ",
		npc_name
	)


func _on_finished() -> void:
	if player:
		player.set_process_unhandled_input(true)
		player.can_move = true
		player_camera.make_current()

	is_talking = false


func _track_player(delta: float) -> void:
	if player == null:
		return

	if skeleton == null:
		return

	if head_bone == -1:
		return

	var head_pose: Transform3D = skeleton.get_bone_global_pose(
		head_bone
	)

	var player_local_position: Vector3 = skeleton.to_local(
		player.global_position
	)

	var direction: Vector3 = (
		player_local_position
		- head_pose.origin
	)

	if direction.length_squared() == 0:
		return

	var target_basis: Basis = Basis.looking_at(
		direction.normalized(),
		Vector3.UP
	)

	target_basis = target_basis.rotated(
		Vector3.LEFT,
		deg_to_rad(30.0)
	)

	target_basis = target_basis.rotated(
		Vector3.UP,
		deg_to_rad(180.0)
	)

	head_pose.basis = target_basis

	head_override_weight = move_toward(
		head_override_weight,
		1.0,
		head_return_speed * delta
	)

	skeleton.set_bone_global_pose_override(
		head_bone,
		head_pose,
		head_override_weight,
		true
	)


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

	var current_pose: Transform3D = skeleton.get_bone_global_pose(
		head_bone
	)

	var current_rotation: Quaternion = (
		current_pose.basis.get_rotation_quaternion()
	)

	var rest_rotation: Quaternion = (
		head_rest_pose.basis.get_rotation_quaternion()
	)

	var blend_amount: float = clamp(
		head_return_speed * delta,
		0.0,
		1.0
	)

	var new_rotation: Quaternion = current_rotation.slerp(
		rest_rotation,
		blend_amount
	)

	current_pose.basis = Basis(new_rotation)

	skeleton.set_bone_global_pose_override(
		head_bone,
		current_pose,
		1.0,
		true
	)

	if new_rotation.angle_to(
		rest_rotation
	) < deg_to_rad(1.0):

		skeleton.set_bone_global_pose_override(
			head_bone,
			Transform3D.IDENTITY,
			0.0,
			false
		)

		head_override_weight = 0.0
		head_returning = false
