extends RigidBody3D

@export_file("*.json") var dialogue_file: String

var dialogue: Dictionary = {}
var player
@onready var anim = $MamaDuck/AnimationPlayer


func _ready() -> void:
	_load_dialogue()
	freeze = true
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	while DialogueManager.dialogue_playing:
		anim.play("MamaDuck_Talk")
		await anim.animation_finished
	
func interact(_player) -> void:
	if dialogue.is_empty() or DialogueManager.dialogue_playing:
		return
	
	var lines := _get_dialogue_lines()
	if lines.is_empty():
		push_warning("No dialogue found on %s" % name)
		return
	
	DialogueManager.start_dialogue(lines)
	
	if not GameManager.has_flag("met_mama_duck"):
		GameManager.set_flag("met_mama_duck")
		
	if player.held_duck != null:
		GameManager.return_duck()

#region Dialog
func _load_dialogue() -> void:
	if dialogue_file.is_empty():
		push_warning("No dialogue file set on %s" % name)
		return

	var file := FileAccess.open(dialogue_file, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file: %s" % dialogue_file)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("Failed to parse dialogue JSON: %s" % dialogue_file)
		return

	dialogue = parsed



func _get_dialogue_lines() -> Array[String]:
	var raw: Array
	if GameManager.has_flag("duckling_returned"):
		raw = dialogue.get("duckling_returned", [])
	elif GameManager.has_flag("met_mama_duck"):
		raw = dialogue.get("reminder", [[]]).pick_random()
	else:
		raw = dialogue.get("first_meet", [])
	
	var lines: Array[String] = []
	for line in raw:
		lines.append(str(line))
	return lines

#endregion Dialog
