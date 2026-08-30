extends Node

@export var timer_duration := 5.0

var timer: float = 0.0
var timer_active := false


func _ready() -> void:
	# Molly has already been saved, so do nothing.
	if GameState.get_flag("molly_saved"):
		return

	timer_active = true
	GameState.flag_changed.connect(_on_flag_changed)


func _process(delta: float) -> void:
	print("MOLLIE: molly_saved = ", GameState.get_flag("molly_saved"))
	print("MOLLIE: molly_died = ", GameState.get_flag("molly_dead"))
	if not timer_active:
		return

	timer += delta

	if timer >= timer_duration:
		_on_timer_finished()


func _on_flag_changed(flag_name: String, value: bool) -> void:
	if flag_name != "molly_saved":
		return

	if value:
		timer_active = false


func _on_timer_finished() -> void:
	timer_active = false

	# Hide the parent
	get_parent().visible = false

	# Mark Molly as no longer available
	GameState.set_flag("molly_dead")
