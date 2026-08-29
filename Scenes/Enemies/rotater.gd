extends Node3D

@onready var player: Player = get_tree().get_first_node_in_group("player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	var direction := player.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() > 0.001:
		direction = direction.normalized()
		basis = Basis.looking_at(-direction, Vector3.UP)
