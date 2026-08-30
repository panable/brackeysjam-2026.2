extends Node3D

@onready var sword: MeshInstance3D = $Sword
@onready var stick: MeshInstance3D = $Stick
const PLAYER_INVENTORY = preload("uid://cib86xegispic")
var sword_dat: ItemData = preload("res://Resources/BrokenSword.tres")
var broken_sword_dat: ItemData = preload("res://Resources/BrokenSword.tres")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PLAYER_INVENTORY.has_item(sword_dat, 1) or PLAYER_INVENTORY.has_item(broken_sword_dat, 1):
		sword.process_mode = Node.PROCESS_MODE_INHERIT
		sword.visible = true
		stick.process_mode = Node.PROCESS_MODE_DISABLED
		stick.visible = false
	else:
		sword.process_mode = Node.PROCESS_MODE_DISABLED
		sword.visible = false
		stick.process_mode = Node.PROCESS_MODE_INHERIT
		stick.visible = true
