extends Node

@onready var playa: CharacterBody3D = $"../playa"

@export
var current_dungeon: Dungeon

func transition_dungeon(destination_room: String, destination_entrace: String):
	current_dungeon.queue_free()
	var dungeon_scene := load(destination_room) as PackedScene
	current_dungeon = dungeon_scene.instantiate() as Dungeon
	current_dungeon.transition_requested.connect(transition_dungeon)
	get_tree().current_scene.add_child(current_dungeon)
	var exit: Marker3D = current_dungeon.get_node_or_null("Doorways/Exits/" + destination_entrace)
	print(destination_entrace)
	print(exit)
	if exit:
		print("Exit at " + str(exit.transform))
		playa.global_position = exit.global_position

func _ready() -> void:
	print("World manager is managing...")
	current_dungeon.transition_requested.connect(transition_dungeon)
