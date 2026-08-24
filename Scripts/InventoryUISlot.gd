extends PanelContainer
class_name InventoryUISlot

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel
var slot_data: SlotData
var inventory: InventoryData

func set_slot_data(new_slot_data: SlotData, new_inventory: InventoryData) -> void:
	slot_data = new_slot_data
	inventory = new_inventory

	if slot_data.is_empty():
		icon.texture = null
		quantity_label.text = ""
	else:
		icon.texture = slot_data.item_data.texture
		quantity_label.text = str(slot_data.quantity) if slot_data.quantity > 1 else ""

func _get_drag_data(_pos: Vector2) -> Variant:
	if slot_data == null or slot_data.is_empty():
		return null
	var preview := TextureRect.new()
	preview.texture = slot_data.item_data.texture
	preview.custom_minimum_size = Vector2(64, 64)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)
	return {
		"slot": slot_data,
		"source": self
	}

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	return (
		data is Dictionary
		and data.has("slot")
		and data["slot"] is SlotData
	)

func _drop_data(_pos: Vector2, data: Variant) -> void:
	var source_slot: SlotData = data["slot"]
	
	if source_slot == slot_data:
		return
	var temp_item := slot_data.item_data
	var temp_quantity := slot_data.quantity
	slot_data.item_data = source_slot.item_data
	slot_data.quantity = source_slot.quantity
	source_slot.item_data = temp_item
	source_slot.quantity = temp_quantity
	inventory.inventory_changed.emit()
