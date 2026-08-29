class_name atk_zone
extends Area3D

@export var damage := 34
@export var damage_cooldown := 0.5

var damage_timer := 0.0
var player_inside := false
var player: Player


func _process(delta: float) -> void:
	if not player_inside:
		return

	damage_timer -= delta

	if damage_timer <= 0.0:
		damage_player()


func _on_body_entered(body: Node3D) -> void:
	print("entarange")
	player = body as Player
	player_inside = true

	damage_player()


func _on_body_exited(body: Node3D) -> void:

	player_inside = false
	player = null

	reset_damage_cooldown()


func damage_player() -> void:
	if not is_instance_valid(player):
		return

	player.health.take_damage(damage)
	reset_damage_cooldown()


func reset_damage_cooldown() -> void:
	damage_timer = damage_cooldown
