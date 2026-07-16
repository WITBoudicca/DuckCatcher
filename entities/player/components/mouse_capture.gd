class_name MouseCaptureComponent
extends Node

@export var debug: bool = false
@export_category("Mouse Capture Settings")
@export var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity: float = 0.005

var _capture_mouse: bool
var mouse_input: Vector2 = Vector2.ZERO

func _ready() -> void:
	if OS.get_name() == "Web":
		get_viewport().gui_focus_changed.connect(_on_focus_changed)
		get_viewport().get_base_window().mouse_entered.connect(_request_capture)
	else:
		Input.mouse_mode = current_mouse_mode

func _request_capture() -> void:
	Input.mouse_mode = current_mouse_mode

func _on_focus_changed(_control: Control) -> void:
	Input.mouse_mode = current_mouse_mode

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if OS.get_name() == "Web" and Input.mouse_mode != current_mouse_mode:
			Input.mouse_mode = current_mouse_mode
			return
	_capture_mouse = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _capture_mouse:
		mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		mouse_input.y += -event.screen_relative.y * mouse_sensitivity
	if debug:
		print(mouse_input)
