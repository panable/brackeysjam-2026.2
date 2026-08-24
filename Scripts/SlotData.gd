extends Resource
class_name SlotData

@export var item_data: ItemData = null
@export var quantity: int = 0

func is_empty() -> bool:
	return item_data == null

func can_stack(new_item: ItemData) -> bool:
	return item_data == new_item and quantity < item_data.max_stack
