## GameManager - Autoload Singleton
extends Node

var is_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	## FOR RELEASE BUILD
	release_build()


#region PAUSE
func pause() -> void:
	is_paused = true
	get_tree().paused = true
	SignalBus.pause_changed.emit(true)

func unpause() -> void:
	is_paused = false
	get_tree().paused = false
	SignalBus.pause_changed.emit(false)

func toggle_pause() -> void:
	if is_paused:
		unpause()
	else:
		pause()
#endregion

#region RELEASE BUILD
func release_build() -> void:
	if OS.is_debug_build(): return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		print(self, " Fullscreen Toggled")
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
#endregion RELEASE BUILD
