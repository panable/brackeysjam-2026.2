extends SubViewport


func _ready() -> void:
	_update_viewport_size()

	get_tree().root.size_changed.connect(_update_viewport_size)


func _update_viewport_size() -> void:
	size = get_tree().root.get_visible_rect().size
