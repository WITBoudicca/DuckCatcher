extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	GameManager.reset_game_state()
	SceneTransition.load_scene("res://world/world.tscn")
