extends Node

signal flag_changed(flag_name: String, value: bool)

var visited_rooms: Dictionary = {}

var flags: Dictionary = {
	# General game flags
	"locked Door": false,
	"flower_planted": false,
	"molly_dead": false,
	"molly_saved": false,
	"key_given_to_marjorie": false,
	"buck_paid": false,
	"billy_choices_correct": false,
	"pablo_cell_opened": false,
	"leonard_returned": false,

	# Roger's shop one-time purchase flags
	"shop_bought_Shop5": false,
	"shop_bought_Shop10": false,
	"shop_bought_ShopFlower": false,
	"shop_bought_ShopMap": false,
	"shop_bought_ShopRunningShoes": false,
	"shop_bought_ShopSword": false
}


func set_flag(flag_name: String, value: bool = true) -> void:
	if not flags.has(flag_name):
		print("ERROR: Unknown flag: ", flag_name)
		return

	flags[flag_name] = value

	flag_changed.emit(
		flag_name,
		value
	)

	print(
		"FLAG CHANGED: ",
		flag_name,
		" = ",
		value
	)


func get_flag(flag_name: String) -> bool:
	if not flags.has(flag_name):
		print(
			"ERROR: Unknown flag: ",
			flag_name
		)

		return false

	return flags[flag_name]


func reset_flag(flag_name: String) -> void:
	if not flags.has(flag_name):
		print(
			"ERROR: Unknown flag: ",
			flag_name
		)

		return

	flags[flag_name] = false

	flag_changed.emit(
		flag_name,
		false
	)

	print(
		"FLAG RESET: ",
		flag_name
	)


func reset_all_flags() -> void:
	for flag_name in flags.keys():
		flags[flag_name] = false

		flag_changed.emit(
			flag_name,
			false
		)

	visited_rooms.clear()

	print("ALL FLAGS RESET")
	
func visit_room(room_id: String) -> void:
	visited_rooms[room_id] = true


func has_visited_room(room_id: String) -> bool:
	return visited_rooms.has(room_id)	
