extends Label
@onready var playa: Health = $"../playa/Health"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str(playa.get_health_percent() * 100)
	pass
