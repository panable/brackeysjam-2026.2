extends Resource
class_name Inventory

signal inventory_changed

@export var slots: Array[SlotData] = []
@export var max_slots: int = 5


func _init() -> void:
	for i in range(max_slots):
		slots.append(SlotData.new())

	starting_inventory()

func starting_inventory() -> void:

	var money: ItemData = preload("res://Resources/Money.tres")
	add_item(money, 20)
	
	
func add_item(new_item: ItemData, amount: int = 1) -> int:
	if not new_item:
		return amount

	var remaining := amount

	for slot in slots:
		if remaining <= 0:
			break

		if slot.can_stack(new_item):
			var space := new_item.max_stack - slot.quantity
			var to_add := mini(remaining, space)

			slot.quantity += to_add
			remaining -= to_add

	for slot in slots:
		if remaining <= 0:
			break

		if slot.is_empty():
			slot.item = new_item

			var to_add := mini(remaining, new_item.max_stack)

			slot.quantity = to_add
			remaining -= to_add

	inventory_changed.emit()

	return remaining


func has_item(target_item: ItemData, amount: int = 1) -> bool:
	var total_found := 0

	for slot in slots:
		if slot.item == target_item:
			total_found += slot.quantity

			if total_found >= amount:
				return true

	return false


func remove_item(target_item: ItemData, amount: int = 1) -> bool:
	var remaining := amount

	for slot in slots:
		if remaining <= 0:
			break

		if slot.item == target_item:
			var to_remove := mini(remaining, slot.quantity)

			slot.quantity -= to_remove
			remaining -= to_remove

			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0

	inventory_changed.emit()

	return remaining <= 0
