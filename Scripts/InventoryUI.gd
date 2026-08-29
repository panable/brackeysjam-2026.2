extends Control

@export var inventory: Inventory
@export var slot_scene: PackedScene

@onready var grid: HBoxContainer = $CenterContainer/GridContainer


func _ready() -> void:
	if inventory == null:
		print("ERROR: InventoryUI has no Inventory assigned")
		return

	if slot_scene == null:
		print("ERROR: InventoryUI has no Slot Scene assigned")
		return

	inventory.inventory_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	if inventory == null:
		return

	for child in grid.get_children():
		child.queue_free()

	for slot in inventory.slots:
		var ui_slot = slot_scene.instantiate()
		grid.add_child(ui_slot)
		ui_slot.set_slot(slot, inventory)
