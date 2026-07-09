extends Control


@onready var dialoguebox = $Panel/RichTextLabel


const speed = 0.05
var lines: Array
var index = 0
var dialogue_playing = false
var line_complete = false
var line
var char_timer = 0.0
var line_timer= 0.0
const line_delay = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !dialogue_playing:
		visible = false
		return
	
	visible = true
	
	if dialoguebox.visible_characters < line.length():
		char_timer += delta
		if char_timer >= speed:
			dialoguebox.visible_characters += 1
			char_timer = 0.0
		else:
			line_complete = true
			line_timer += delta
			if line_timer >= line_delay:
				next_line()



func _on_button_pressed() -> void:
	if !dialogue_playing:
		return
	if line_complete:
		next_line()
	else:
		dialoguebox.visible_characters = line.length()
	
	if index >= lines.size():
		dialogue_playing = false
		return
	

func next_line():
	index += 1
	if index >= lines.size():
		dialogue_playing = false
		return
	
	line = lines[index]
	dialoguebox.visible_characters = 0
	dialoguebox.text = line
	
	line_complete = false
	char_timer = 0.0
	line_timer = 0.0
	


func start_dialogue(new_lines: Array):
	lines = new_lines
	index = 0
	line = lines[index]
	dialoguebox.text = line
	dialoguebox.visible_characters = 0
	dialogue_playing = true
	line_complete = false
	
