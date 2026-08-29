extends Button
class_name ShopSlot

signal offer_selected(
	offer: ShopOffer,
	slot: ShopSlot
)

@onready var item_icon: TextureRect = \
	$VBoxContainer/Icon

@onready var name_label: Label = \
	$VBoxContainer/NameLabel

@onready var price_label: Label = \
	$VBoxContainer/PriceLabel

var offer: ShopOffer
var sold := false


func setup(new_offer: ShopOffer) -> void:
	offer = new_offer
	sold = false

	if offer == null:
		hide()
		return

	show()

	disabled = false

	item_icon.texture = offer.icon
	name_label.text = offer.offer_name

	_set_price_text()


func _set_price_text() -> void:
	if offer.cost_item == null:
		price_label.text = str(
			offer.cost_amount
		)
		return

	if offer.cost_item.name == "Money":
		price_label.text = "$%d" % (
			offer.cost_amount
		)

	else:
		price_label.text = "%d %s" % [
			offer.cost_amount,
			offer.cost_item.name
		]


func mark_sold() -> void:
	sold = true
	disabled = true

	price_label.text = "SOLD"


func _pressed() -> void:
	if offer == null:
		return

	if sold:
		return

	offer_selected.emit(
		offer,
		self
	)
