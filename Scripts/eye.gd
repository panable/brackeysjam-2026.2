extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var minimum_blink_delay: float = 2.0
@export var maximum_blink_delay: float = 7.0


func _ready() -> void:
	blink_loop()


func blink_loop() -> void:
	while true:
		var delay := randf_range(
			minimum_blink_delay,
			maximum_blink_delay
		)

		await get_tree().create_timer(delay).timeout

		animated_sprite.play("blink")

		await animated_sprite.animation_finished
