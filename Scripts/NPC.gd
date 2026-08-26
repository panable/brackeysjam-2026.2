extends Node3D

@onready var interaction_area: Area3D = $MeshInstance3D/InteractionArea
@onready var dialogue: Control = $"../DialogueUI"

var in_range := false
var _data: Dictionary = {}
var player: Node3D = null

func _ready() -> void:
	var file := FileAccess.open("res://dialogue.json", FileAccess.READ)
	if file:
		_data = JSON.parse_string(file.get_as_text())
	
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)
	dialogue.dialogue_finished.connect(_on_finished)

func _process(_delta: float) -> void:
	if in_range and Input.is_action_just_pressed("interact"):
			interact()

func interact() -> void:
	if player == null:
		return
	player.set_process_unhandled_input(false)
	dialogue.start(_data, "start")


# NPC Range (CollisionShape3D [Range: 2.0m])

# Check if player has entered range
func _enter_range(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true
		player = body
		print("player in range of NPC Interaction")


# Check if player has exited range
func _exit_range(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
		print("Player left range of NPC Interaction")

func _on_finished() -> void:
	if player:
		player.set_process_unhandled_input(true)
	
