extends "res://Scripts/NPC.gd"

@export var shop_ui: Control


func interact() -> void:
	if not in_range:
		return

	if shop_ui == null:
		print("ERROR: Roger has no ShopUI assigned.")
		return

	print("Roger shop opened")

	is_talking = true

	# Stop the player from moving while the shop is open.
	if player:
		player.set_process_unhandled_input(false)

	# Open the shop instead of dialogue.
	shop_ui.show()
