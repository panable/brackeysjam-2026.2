extends Node3D
@export var room_id_link: String = ""
@onready var one_way_door_collider: StaticBody3D = $one_way_door_collider
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.has_visited_room(room_id_link):
		animation_player.active = true
		animation_player.play("OpenDoubleDoor")
		one_way_door_collider.process_mode = Node.PROCESS_MODE_DISABLED
	pass
