extends Node

@onready var playa: Player = $"../playa"

@export
var current_dungeon: Dungeon
var killed_enemies: Dictionary = {}

func _process(_delta: float) -> void:
	print(GameState.visited_rooms)
	var doors := get_tree().get_nodes_in_group("door")
	var enemies := get_tree().get_nodes_in_group("enemy")

	#if killed_enemies.get(current_dungeon.room_id, false) and enemies.size() > 0:
		#for enemy in enemies:
			#enemy.queue_free()

	if enemies.size() == 0:
		#killed_enemies[current_dungeon.room_id] = true

		for door in doors:
			door.clear_room()
			
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
	GameState.visit_room(current_dungeon.room_id)
	
func _ready() -> void:
	GameState.visit_room(current_dungeon.room_id)
	current_dungeon.transition_requested.connect(transition_dungeon)
