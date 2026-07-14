extends Control

@export var line_delay: float = 2.0
@export var dialog_speed: float = 0.05

@onready var dialog_label: RichTextLabel = %DialogLabel
@onready var button: Button = %Button

var lines: Array[String] = []
var index: int = 0
var current_line: String = ""

var dialogue_playing: bool = false
var line_complete: bool = false

var char_timer: float = 0.0
var line_timer: float = 0.0


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_advance()

func _process(delta: float) -> void:
	visible = dialogue_playing
	if not dialogue_playing:
		return
	
	if dialog_label.visible_characters < current_line.length():
		_advance_typing(delta)
	else:
		_advance_line_timer(delta)


func _advance_typing(delta: float) -> void:
	char_timer += delta
	if char_timer >= dialog_speed:
		dialog_label.visible_characters += 1
		char_timer = 0.0


func _advance_line_timer(delta: float) -> void:
	line_complete = true
	line_timer += delta
	if line_timer >= line_delay:
		next_line()


func _on_button_pressed() -> void:
	_advance()


func _advance() -> void:
	if not dialogue_playing:
		return
	
	if line_complete:
		next_line()
	else:
		dialog_label.visible_characters = current_line.length()


func start_dialogue(new_lines: Array[String]) -> void:
	lines = new_lines
	index = 0
	current_line = lines[index]
	
	_set_line_text(current_line)
	
	dialogue_playing = true
	line_complete = false
	line_timer = 0.0
	char_timer = 0.0


func next_line() -> void:
	index += 1
	if index >= lines.size():
		dialogue_playing = false
		return
	
	current_line = lines[index]
	_set_line_text(current_line)
	
	line_complete = false
	char_timer = 0.0
	line_timer = 0.0


func _set_line_text(text: String) -> void:
	dialog_label.text = text
	dialog_label.visible_characters = 0
	await get_tree().process_frame
	dialog_label.visible_characters = 0
