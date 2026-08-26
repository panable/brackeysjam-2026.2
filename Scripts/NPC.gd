extends Node3D

@onready var interaction_area: Area3D = $MeshInstance3D/InteractionArea
var in_range := false

func _ready() -> void:
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if in_range:
			interact()

func interact() -> void:
	print("interaction works")


# NPC Range (CollisionShape3D [Range: 2.0m])

# Check if player has entered range
func _enter_range(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true
		print("player in range of NPC Interaction")


# Check if player has exited range
func _exit_range(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
		print("Player left range of NPC Interaction")
