extends RigidBody3D

@export_file("*.json") var dialogue_file : String

@onready var dialoguebox = $DialogueBox

var dialogue : Dictionary

func _ready():
	var file = FileAccess.open(dialogue_file, FileAccess.READ)
	var json_text = file.get_as_text()
	dialogue = JSON.parse_string(json_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact():
	pass
