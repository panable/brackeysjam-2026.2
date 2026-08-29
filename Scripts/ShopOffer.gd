extends Resource
class_name ShopOffer

@export_group("Display")
@export var offer_name: String = ""
@export_multiline var preview_description: String = ""
@export_multiline var full_description: String = ""
@export var icon: Texture2D

@export_group("Cost")
@export var cost_item: ItemData
@export var cost_amount: int = 1

@export_group("Reward")
@export var reward_item: ItemData
@export var reward_amount: int = 1

@export_group("Behaviour")
@export var one_time_purchase: bool = true
@export var special_action: String = ""
