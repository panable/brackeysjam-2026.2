extends Node3D

@export var npc_name: String = "NPC"
@export_file("*.json") var dialogue_path: String
@export var entry_name: String 
@onready var interaction_area: Area3D = $InteractionArea
@onready var dialogue: Control = $"../DialogueUI"
@export var rotation_speed: float = 5.0

var in_range := false
var _data: Dictionary = {}
var player: Node3D = null
var is_talking := false

func _ready() -> void:
	_load_dialogue()
	
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)
	dialogue.dialogue_finished.connect(_on_finished)

func _process(delta: float) -> void:
	if in_range and player:
		_track_player(delta)

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


# NPC Range (CollisionShape3D [Range: 2.0m])

# Check if player has entered range
func _enter_range(body: Node3D) -> void:
	in_range = true
	player = body
	print(player.name," entered interaction range of ", npc_name)

# Check if player has exited range
func _exit_range(body: Node3D) -> void:
	if body != player:
		return
	in_range = false
	print(player.name," left interaction range of ", npc_name)

func _on_finished() -> void:
	if player:
		player.set_process_unhandled_input(true)
		player.can_move = true
		is_talking = false

func _track_player(delta: float) -> void:
	var target_position := player.global_position
	target_position.y = global_position.y
	var direction := target_position - global_position
	if direction.length_squared() == 0:
		return
	var target_rotation := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y,target_rotation,rotation_speed * delta)
