extends Node3D

@export var shop_ui: Control

@onready var interaction_area: Area3D = $Area3D

var player_in_range := false
var player: Node3D = null
var shop_open := false


func _ready() -> void:
	interaction_area.body_entered.connect(_enter_range)
	interaction_area.body_exited.connect(_exit_range)

	if shop_ui != null:
		shop_ui.shop_closed.connect(_on_shop_closed)

	print("=========================")
	print("SHOP TABLE READY")
	print("=========================")

	print("Shop UI assigned: ", shop_ui != null)


func _process(_delta: float) -> void:
	if (
		player_in_range
		and not shop_open
		and Input.is_action_just_pressed("interact")
	):
		print("Shop table interaction pressed")
		open_shop()


func _enter_range(body: Node3D) -> void:
	player = body
	player_in_range = true

	print(
		body.name,
		" entered shop table range"
	)


func _exit_range(body: Node3D) -> void:
	if body != player:
		return

	print(
		body.name,
		" left shop table range"
	)

	player_in_range = false

	if not shop_open:
		player = null


func open_shop() -> void:
	print("-------------------------")
	print("OPEN SHOP ATTEMPT")
	print("-------------------------")

	if shop_ui == null:
		print("FAILED: Shop UI has not been assigned")
		return

	if player == null:
		print("FAILED: No player in interaction range")
		return

	print("Opening shop")

	shop_open = true

	player.can_move = false
	player.set_process_unhandled_input(false)

	shop_ui.open_shop()

	print("SUCCESS: Shop opened")


func _on_shop_closed() -> void:
	print("Shop closed")

	shop_open = false

	if player != null:
		player.can_move = true
		player.set_process_unhandled_input(true)

	if not player_in_range:
		player = null
