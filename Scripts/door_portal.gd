class_name DoorPortal
extends Area3D
@onready var dungeon: Dungeon = $"../../.."
@export var rotation_amt: float = 0

signal player_entered(destination_room: String, destination_entrace: String)

@export_file("Scenes/Dungeons/*.tcsn")
var destination_room: String

@export
var destination_entrace: String

func _ready() -> void:
	player_entered.connect(dungeon._on_door_portal_player_entered)

func _on_body_entered(body: Node3D) -> void:
	var player = body as Player
	player.pivot.rotate_y(deg_to_rad(rotation_amt))
	player_entered.emit(destination_room, destination_entrace)
