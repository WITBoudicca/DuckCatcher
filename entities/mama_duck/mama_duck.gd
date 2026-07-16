extends RigidBody3D

@export_file("*.json") var dialogue_file: String
@export var marker_group: String = "duck_return_markers"

var dialogue: Dictionary = {}
var available_markers: Array[Marker3D] = []
var player

@export var happy_duck_sfx: Array[AudioStream]
@onready var anim = $MamaDuck/AnimationPlayer


func _ready() -> void:
	add_to_group("mama_duck")
	_load_dialogue()
	_load_markers()
	_connect_ducklings()
	freeze = true
	
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	_face_player(self)
	if DialogueManager.dialogue_playing:
		anim.play("MamaDuck_Talk")
	else:
		anim.play("Netural")
	
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
	
	if GameManager.has_flag("all_ducklings_returned"):
		while DialogueManager.dialogue_playing:
			await get_tree().process_frame
		await get_tree().create_timer(0.5).timeout
		SceneTransition.load_scene("res://system/ending/ending.tscn")


#region Marker
func _load_markers() -> void:
	for node in get_tree().get_nodes_in_group(marker_group):
		if node is Marker3D:
			available_markers.append(node)


func _connect_ducklings() -> void:
	for duck in get_tree().get_nodes_in_group("ducklings"):
		duck.returned_to_mama.connect(_on_duck_returned.bind(duck))


func _on_duck_returned(duck: Node) -> void:
	var marker := claim_marker()
	if marker != null:
		duck.global_transform = marker.global_transform
		duck.anim.play("Duckling_Neutral")
		AudioManager.play_sound_3d(happy_duck_sfx.pick_random(), global_position, -8.0)
	
	_face_player(duck)
	
	duck.set_physics_process(false)
	duck.set_process(false)

func _face_player(duck: Node3D) -> void:
	var look_pos : Vector3 = player.global_position
	look_pos.y = duck.global_position.y
	duck.look_at(look_pos, Vector3.UP)

func claim_marker() -> Marker3D:
	if available_markers.is_empty():
		push_warning("No free duck return markers left on %s" % name)
		return null
	return available_markers.pop_back()

#endregion


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
	if GameManager.has_flag("all_ducklings_returned"):
		raw = dialogue.get("all_ducklings_returned", [])
	elif GameManager.has_flag("duckling_returned"):
		raw = dialogue.get("duckling_returned", [[]]).pick_random()
		GameManager.clear_flag("duckling_returned")
	elif GameManager.has_flag("met_mama_duck"):
		raw = dialogue.get("reminder", [[]]).pick_random()
	else:
		raw = dialogue.get("first_meet", [])
	
	var lines: Array[String] = []
	for line in raw:
		lines.append(str(line))
	return lines

#endregion Dialog
