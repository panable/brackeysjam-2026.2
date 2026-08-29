extends Control

# Signals
signal dialogue_finished
signal dialogue_choice_selected(choice: Dictionary)

@onready var speaker: Label = $BackgroundPanel/VBoxContainer/SpeakerLabel
@onready var content: Label = $BackgroundPanel/VBoxContainer/TextLabel
@onready var response: VBoxContainer = $ChoicesPanel/ChoicesBox
@onready var choices_panel: PanelContainer = $ChoicesPanel

# Shared player inventory
var player_inventory: Inventory = preload("res://Resources/PlayerInventory.tres")

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
	if not _data.has(id):
		_end()
		return

	_current_id = id

	var entry: Dictionary = _data[id]

	choices_panel.hide()

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


func _show_choices(choices: Array) -> void:
	for child in response.get_children():
		child.queue_free()

	var valid_choices := 0

	for choice in choices:

		# Required item check
		if choice.has("required_item"):
			var item_path: String = choice["required_item"]
			var required_item: ItemData = load(item_path)

			if required_item == null:
				print(
					"ERROR: Dialogue required item could not be loaded: ",
					item_path
				)
				continue

			var required_amount: int = choice.get("required_amount", 1)

			if not player_inventory.has_item(required_item, required_amount):
				print(
					"Dialogue choice hidden. Missing ",
					required_amount,
					"x ",
					required_item.name
				)
				continue

		var button := Button.new()

		button.text = choice.get(
			"content",
			choice.get("text", "...")
		)

		var next_id: String = choice.get("next_id", "")

		button.pressed.connect(
			func() -> void:
				# Send the whole choice to the NPC.
				dialogue_choice_selected.emit(choice)

				if next_id.is_empty() or next_id == "end":
					_end()
				else:
					_show(next_id)
		)

		response.add_child(button)

		valid_choices += 1

	if valid_choices > 0:
		choices_panel.show()
	else:
		choices_panel.hide()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	var interact_pressed := false

	# Keyboard controls
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_E:
			interact_pressed = true

	# Mouse controls
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact_pressed = true

	if not interact_pressed:
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

	var entry: Dictionary = _data[_current_id]

	# Wait for the player to click a choice
	if entry.has("choices"):
		return

	# Move to next dialogue entry
	if entry.has("next_id"):
		var next_id: String = entry["next_id"]

		if next_id.is_empty() or next_id == "end":
			_end()
		else:
			_show(next_id)

	else:
		_end()

	get_viewport().set_input_as_handled()


func _end() -> void:
	_typing.stop()
	choices_panel.hide()
	hide()
	dialogue_finished.emit()
