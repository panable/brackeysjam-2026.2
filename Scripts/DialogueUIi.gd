extends Control

# Signal for finished Conversation
signal dialogue_finished

@onready var speaker: Label = $BackgroundPanel/VBoxContainer/SpeakerLabel
@onready var content: Label = $BackgroundPanel/VBoxContainer/TextLabel
@onready var response: VBoxContainer = $BackgroundPanel/ChoicesBox

var _data: Dictionary = {}
var _current_id: String = ""
var _typing := Timer.new()

func _ready() -> void:
	_typing.timeout.connect(_on_typing_tick)
	add_child(_typing)
	hide()

# data and ID is passed in here.
func start(data: Dictionary, start_id: String) -> void:
	_data = data
	show()
	_show(start_id)


func _show(id: String) -> void:
	# Check for valid ID
	if not _data.has(id):
		_end()
		return
	_current_id = id
	var entry: Dictionary = _data[id]
	speaker.text = entry.get("speaker", "")
	content.text = entry.get("content", "...")
	content.visible_characters = 0
	_typing.start(0.05)
	for r in response.get_children():
		r.queue_free()

func _on_typing_tick() -> void:
	if content.visible_characters < content.get_total_character_count():
		content.visible_characters += 1
		return
	_typing.stop()

	var entry: Dictionary = _data[_current_id]
	if entry.has("choices"):
		_show_choices(entry["choices"])
	#elif entry.has("next_id"):
		#_show(entry["next_id"])
	#else:
		#_end()

func _show_choices(choices: Array) -> void:
	for choice in choices:
		var button := Button.new()
		button.text = choice["content"]
		button.pressed.connect(func() -> void: _show(choice["next_id"]))
		response.add_child(button)

func _input(event: InputEvent) -> void:
	# Ignore input if dialogue is not visible
	if not visible:
		return
	
	# Ignore released keys
	if not event.is_pressed():
		return
	
	# Ignore mouse movement
	if event is InputEventMouseMotion:
		return
		
	# Ignore mouse buttons other than left click
	if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
		return
		
	# Finish displaying text if it is still typing
	if not _typing.is_stopped():
		content.visible_characters = content.get_total_character_count()
		_typing.stop()
		var entry: Dictionary = _data[_current_id]
		if entry.has("choices"):
			_show_choices(entry["choices"])
		get_viewport().set_input_as_handled()
		return
	
	#  Get the current dialogue entry
	var entry: Dictionary = _data[_current_id]
	
	# Wait for the player to select a choice
	if entry.has("choices"):
		return
	
	# Move to the next dialogue entry
	if entry.has("next_id"):
		_show(entry["next_id"])
	
	# End dialogue if there is no next entry
	else:
		_end()
	get_viewport().set_input_as_handled()

func _end() -> void:
	hide()
	dialogue_finished.emit()
