extends Node3D

@export var npc_name: String = "NPC"
@export_file("*.json") var dialogue_path: String
@export var entry_name: String 
@onready var interaction_area: Area3D = $MeshInstance3D/InteractionArea
@onready var dialogue: Control = $"../DialogueUI"

var in_range := false
var _data: Dictionary = {}
var player: Node3D = null

func _ready() -> void:
	_load_dialogue()
	
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)
	dialogue.dialogue_finished.connect(_on_finished)

func _process(_delta: float) -> void:
	if in_range and Input.is_action_just_pressed("interact"):
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
	player.can_move = false
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
