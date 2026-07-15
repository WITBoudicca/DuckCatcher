## GameManager - Autoload Singleton
extends Node

var is_paused: bool = false
var flags: Dictionary = {}


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


#region FLAGS
func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value
	SignalBus.flag_changed.emit(flag_name, value)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func clear_flag(flag_name: String) -> void:
	flags.erase(flag_name)
#endregion

#region RESET
func reset_game_state() -> void:
	flags.clear()
	ducks_returned = 0
	ducks_total = 0
	SignalBus.ducks_returned_changed.emit(ducks_returned, ducks_total)
#endregion

#region DUCKS
var ducks_returned: int = 0
var ducks_total: int = 0

func set_ducks_total(amount: int) -> void:
	ducks_total = amount
	SignalBus.ducks_returned_changed.emit(ducks_returned, ducks_total)

func return_duck() -> void:
	ducks_returned += 1
	SignalBus.ducks_returned_changed.emit(ducks_returned, ducks_total)

	if ducks_returned >= ducks_total:
		set_flag("duckling_returned")
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
