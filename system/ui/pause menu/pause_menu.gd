extends Control

var is_muted

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	is_muted = false
	hide()




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			GameManager.resume()
		else:
			GameManager.pause()

func _on_mute_toggled(toggled_on: bool) -> void:
	is_muted = !is_muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), is_muted)


func _on_resume_pressed() -> void:
	GameManager.resume()


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()



func _on_quit_pressed() -> void:
	get_tree().quit()
