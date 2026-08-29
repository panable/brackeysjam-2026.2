extends PanelContainer
class_name InventoryUISlot

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel

var slot: SlotData
var inventory: Inventory


func set_slot(new_slot: SlotData, new_inventory: Inventory) -> void:
	slot = new_slot
	inventory = new_inventory

	if slot.is_empty():
		icon.texture = null
		quantity_label.text = ""
		tooltip_text = ""
	else:
		icon.texture = slot.item.texture
		quantity_label.text = str(slot.quantity) if slot.quantity > 1 else ""

		tooltip_text = "%s\n%s" % [
			slot.item.name,
			slot.item.description
		]


func _get_drag_data(_pos: Vector2) -> Variant:
	if slot == null or slot.is_empty():
		return null

	var preview := TextureRect.new()
	preview.texture = slot.item.texture
	preview.custom_minimum_size = Vector2(64, 64)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_drag_preview(preview)

	return {
		"slot": slot,
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

	if source_slot == slot:
		return

	var temp_item := slot.item
	var temp_quantity := slot.quantity

	slot.item = source_slot.item
	slot.quantity = source_slot.quantity

	source_slot.item = temp_item
	source_slot.quantity = temp_quantity

	inventory.inventory_changed.emit()
