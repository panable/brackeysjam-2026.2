extends Node3D

@export var inventory: Inventory

var flower: ItemData = preload("res://Resources/Flower.tres")

@onready var interaction_area: Area3D = $Area3D

var player_in_range := false
var player: Node3D = null


func _ready() -> void:
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)

	print("=========================")
	print("PLANT POT READY")
	print("=========================")

	print("Inventory assigned: ", inventory != null)
	print("Flower resource loaded: ", flower)

	if inventory != null:
		print("Plant Pot inventory path: ", inventory.resource_path)
		print("Plant Pot inventory ID: ", inventory.get_instance_id())


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("Plant pot interaction pressed")
		plant_flower()


func _enter_range(body: Node3D) -> void:
	player = body
	player_in_range = true

	print(body.name, " entered plant pot range")


func _exit_range(body: Node3D) -> void:
	if body != player:
		return

	print(body.name, " left plant pot range")

	player = null
	player_in_range = false


func plant_flower() -> void:
	print("-------------------------")
	print("PLANT FLOWER ATTEMPT")
	print("-------------------------")

	if inventory == null:
		print("FAILED: Inventory has not been assigned")
		return

	print("Plant Pot inventory path: ", inventory.resource_path)
	print("Plant Pot inventory ID: ", inventory.get_instance_id())

	print(
		"Current flower_planted flag: ",
		GameState.get_flag("flower_planted")
	)

	if GameState.get_flag("flower_planted"):
		print("FAILED: Flower has already been planted")
		return

	print("Flower resource: ", flower)

	print("-------------------------")
	print("INVENTORY BEFORE REMOVAL")
	print("-------------------------")

	for i in range(inventory.slots.size()):
		var slot: SlotData = inventory.slots[i]

		if slot.item == null:
			print("Slot ", i, ": EMPTY")
		else:
			print(
				"Slot ", i,
				": item=", slot.item,
				" | name=", slot.item.name,
				" | quantity=", slot.quantity
			)

	print("Checking inventory for Flower...")

	if not inventory.has_item(flower):
		print("FAILED: Player does not have the required flower")
		return

	print("Flower found in inventory")

	if not inventory.remove_item(flower, 1):
		print("FAILED: Could not remove flower")
		return

	print("Flower removed from inventory")

	print("-------------------------")
	print("INVENTORY AFTER REMOVAL")
	print("-------------------------")

	for i in range(inventory.slots.size()):
		var slot: SlotData = inventory.slots[i]

		if slot.item == null:
			print("Slot ", i, ": EMPTY")
		else:
			print(
				"Slot ", i,
				": item=", slot.item,
				" | name=", slot.item.name,
				" | quantity=", slot.quantity
			)

	GameState.set_flag("flower_planted", true)

	print(
		"flower_planted flag is now: ",
		GameState.get_flag("flower_planted")
	)

	print("SUCCESS: Flower planted")
