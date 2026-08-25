extends Resource
class_name SlotData

@export var item: ItemData = null
@export var quantity: int = 0

func is_empty() -> bool:
	return item == null

func can_stack(new_item: ItemData) -> bool:
	return item == new_item and quantity < item.max_stack

# SlotData - checks if empty & if stackable
