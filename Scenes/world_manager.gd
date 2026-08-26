extends Node

@onready var playa: Player = $"../playa"

@export
var current_dungeon: Dungeon

func transition_dungeon(destination_room: String, destination_entrace: String):
	playa.set_collision_layer_value(3, false)
	playa.set_collision_layer_value(1, false)
	playa.set_physics_process(false)
	
	current_dungeon.queue_free()
	await get_tree().physics_frame
	var dungeon_scene := load(destination_room) as PackedScene
	current_dungeon = dungeon_scene.instantiate() as Dungeon
	print("current_dungeon is " + current_dungeon.name)
	get_tree().current_scene.add_child(current_dungeon)
	
	var exit: Marker3D = current_dungeon.get_node_or_null("Doorways/Exits/" + destination_entrace)
	
	playa.global_position = exit.global_position
			
	current_dungeon.transition_requested.connect(transition_dungeon)
	await get_tree().physics_frame
	playa.set_collision_layer_value(3, true)
	playa.set_collision_layer_value(1, true)
	playa.set_physics_process(true)
	
func _ready() -> void:
	current_dungeon.transition_requested.connect(transition_dungeon)
