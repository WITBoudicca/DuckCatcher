extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func resume():
	GameManager.unpause()
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	GameManager.pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_mute_toggled(toggled: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), toggled)

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	GameManager.unpause()
	GameManager.reset_game_state()

func _on_quit_pressed() -> void:
	get_tree().quit()
