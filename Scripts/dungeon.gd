class_name Dungeon
extends Node3D

@export var room_id: String

signal transition_requested(destination_room: String, destination_entrace: String)

func _on_door_portal_player_entered(destination_room: String, destination_entrace: String) -> void:
	transition_requested.emit(destination_room, destination_entrace)
