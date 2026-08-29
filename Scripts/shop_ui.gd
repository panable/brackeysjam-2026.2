extends Control

signal shop_closed
signal special_action_triggered(action: String)

@export var shop_slot_scene: PackedScene
@export var offers: Array[ShopOffer] = []

var player_inventory: Inventory = preload(
	"res://Resources/PlayerInventory.tres"
)

@onready var items_grid: GridContainer = \
	$ShopPanel/VBoxContainer/CenterContainer/ItemsGrid

@onready var item_name: Label = \
	$ShopPanel/VBoxContainer/DescriptionPanel/VBoxContainer/ItemName

@onready var description: Label = \
	$ShopPanel/VBoxContainer/DescriptionPanel/VBoxContainer/Description

@onready var buy_button: Button = \
	$ShopPanel/VBoxContainer/ButtonRow/BuyButton

@onready var continue_button: Button = \
	$ShopPanel/VBoxContainer/ButtonRow/ContinueButton

@onready var close_button: Button = \
	$ShopPanel/VBoxContainer/ButtonRow/CloseButton


var selected_offer: ShopOffer = null
var selected_slot: ShopSlot = null


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	close_button.pressed.connect(_on_close_pressed)

	_build_shop()
	_clear_selection()

	hide()


func open_shop() -> void:
	_clear_selection()
	show()


func close_shop() -> void:
	hide()
	shop_closed.emit()


func _build_shop() -> void:
	for child in items_grid.get_children():
		child.queue_free()

	for offer in offers:
		var slot: ShopSlot = shop_slot_scene.instantiate()

		items_grid.add_child(slot)

		slot.setup(offer)

		slot.offer_selected.connect(
			_on_offer_selected
		)

		if offer.one_time_purchase:
			var purchase_flag := _get_purchase_flag(
				offer
			)

			var already_bought := GameState.get_flag(
				purchase_flag
			)

			print("-------------------------")
			print("BUILDING SHOP SLOT")
			print("-------------------------")
			print("Offer: ", offer.offer_name)
			print("One time: ", offer.one_time_purchase)
			print("Purchase flag: ", purchase_flag)
			print("Already bought: ", already_bought)

			if already_bought:
				slot.mark_sold()


func _get_purchase_flag(
	offer: ShopOffer
) -> String:

	var file_name := offer.resource_path.get_file()
	var offer_id := file_name.get_basename()

	return "shop_bought_" + offer_id


func _on_offer_selected(
	offer: ShopOffer,
	slot: ShopSlot
) -> void:

	selected_offer = offer
	selected_slot = slot

	item_name.text = offer.offer_name
	description.text = offer.preview_description

	buy_button.show()
	continue_button.hide()

	print("-------------------------")
	print("SHOP OFFER SELECTED")
	print("-------------------------")
	print("Offer: ", offer.offer_name)
	print("One time: ", offer.one_time_purchase)
	print("Resource path: ", offer.resource_path)

	if offer.one_time_purchase:
		var purchase_flag := _get_purchase_flag(
			offer
		)

		print("Purchase flag: ", purchase_flag)
		print(
			"Current flag value: ",
			GameState.get_flag(purchase_flag)
		)

	_update_buy_button()


func _update_buy_button() -> void:
	if selected_offer == null:
		buy_button.disabled = true
		return

	if selected_offer.cost_item == null:
		buy_button.disabled = true
		return

	if selected_offer.one_time_purchase:
		var purchase_flag := _get_purchase_flag(
			selected_offer
		)

		var already_bought := GameState.get_flag(
			purchase_flag
		)

		print("-------------------------")
		print("UPDATE BUY BUTTON")
		print("-------------------------")
		print("Offer: ", selected_offer.offer_name)
		print("Purchase flag: ", purchase_flag)
		print("Already bought: ", already_bought)

		if already_bought:
			print("BUY DISABLED: Item already purchased")

			buy_button.disabled = true
			return

	var can_afford := player_inventory.has_item(
		selected_offer.cost_item,
		selected_offer.cost_amount
	)

	print(
		"Can afford ",
		selected_offer.offer_name,
		": ",
		can_afford
	)

	buy_button.disabled = not can_afford


func _on_buy_pressed() -> void:
	print("-------------------------")
	print("BUY BUTTON PRESSED")
	print("-------------------------")

	if selected_offer == null:
		print("FAILED: No offer selected")
		return

	print("Offer: ", selected_offer.offer_name)

	if selected_offer.cost_item == null:
		print(
			"FAILED: No cost item assigned"
		)

		description.text = (
			"This item has no price configured."
		)

		return

	if selected_offer.one_time_purchase:
		var purchase_flag := _get_purchase_flag(
			selected_offer
		)

		var already_bought := GameState.get_flag(
			purchase_flag
		)

		print("One time purchase: true")
		print("Purchase flag: ", purchase_flag)
		print("Already bought: ", already_bought)

		if already_bought:
			print(
				"FAILED: One-time item already purchased"
			)

			description.text = (
				"This item has already been purchased."
			)

			buy_button.disabled = true
			return

	var can_afford := player_inventory.has_item(
		selected_offer.cost_item,
		selected_offer.cost_amount
	)

	print("Can afford: ", can_afford)

	if not can_afford:
		print("FAILED: Not enough currency")

		description.text = "You can't afford this."
		return

	_purchase_selected_offer()


func _purchase_selected_offer() -> void:
	var offer := selected_offer

	print("")
	print("===================================")
	print("SHOP PURCHASE")
	print("===================================")
	print("Offer: ", offer.offer_name)
	print("Cost item: ", offer.cost_item.name)
	print("Cost amount: ", offer.cost_amount)

	if offer.reward_item != null:
		print("Reward item: ", offer.reward_item.name)
		print("Reward amount: ", offer.reward_amount)

		var remaining := player_inventory.add_item(
			offer.reward_item,
			offer.reward_amount
		)

		print(
			"Remaining reward after add_item: ",
			remaining
		)

		if remaining > 0:
			var amount_added := (
				offer.reward_amount
				- remaining
			)

			print(
				"Could not add full reward"
			)

			print(
				"Amount temporarily added: ",
				amount_added
			)

			if amount_added > 0:
				player_inventory.remove_item(
					offer.reward_item,
					amount_added
				)

			description.text = (
				"Your inventory is full."
			)

			print(
				"FAILED: Inventory full"
			)

			return
	else:
		print("Reward item: NONE")

	var payment_removed := player_inventory.remove_item(
		offer.cost_item,
		offer.cost_amount
	)

	print(
		"Payment successfully removed: ",
		payment_removed
	)

	if not payment_removed:
		print(
			"FAILED: Could not remove payment"
		)

		if offer.reward_item != null:
			print(
				"Removing reward because payment failed"
			)

			player_inventory.remove_item(
				offer.reward_item,
				offer.reward_amount
			)

		description.text = (
			"Something went wrong with the purchase."
		)

		return

	print(
		"Paid ",
		offer.cost_amount,
		"x ",
		offer.cost_item.name
	)

	if offer.reward_item != null:
		print(
			"Received ",
			offer.reward_amount,
			"x ",
			offer.reward_item.name
		)

	if offer.one_time_purchase:
		var purchase_flag := _get_purchase_flag(
			offer
		)

		print("-------------------------")
		print("SETTING PURCHASE FLAG")
		print("-------------------------")
		print("Flag: ", purchase_flag)

		GameState.set_flag(
			purchase_flag,
			true
		)

		print(
			"Flag after setting: ",
			GameState.get_flag(purchase_flag)
		)

		if selected_slot != null:
			selected_slot.mark_sold()

			print(
				"Slot marked as SOLD"
			)

	_show_purchase_reveal()

	if not offer.special_action.is_empty():
		print(
			"Special action: ",
			offer.special_action
		)

		special_action_triggered.emit(
			offer.special_action
		)

	print("PURCHASE SUCCESSFUL")
	print("===================================")
	print("")


func _show_purchase_reveal() -> void:
	if selected_offer == null:
		return

	item_name.text = (
		selected_offer.offer_name
		+ " - PURCHASED"
	)

	description.text = (
		selected_offer.full_description
	)

	buy_button.hide()
	continue_button.show()


func _on_continue_pressed() -> void:
	_clear_selection()


func _on_close_pressed() -> void:
	close_shop()


func _clear_selection() -> void:
	selected_offer = null
	selected_slot = null

	item_name.text = "Select an item"
	description.text = "Take a look around."

	buy_button.hide()
	continue_button.hide()
