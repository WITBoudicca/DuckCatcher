class_name CameraController
extends Node3D

@export var debug: bool = false

@export_category("References")
@export var player_controller : PlayerController
@export var component_mouse_capture : MouseCaptureComponent

@export_category("Camera Settings")
@export_group("Camera tilt")
@export_range(-90, -45) var tilt_lower_limit : int = -60
@export_range(45, 90) var tilt_upper_limit : int = 45


var _rotation : Vector3

func _process(_delta):
	if not component_mouse_capture:
		printerr(self, "No Mouse Capture Component Attached")
		return
	update_camera_rotation(component_mouse_capture.mouse_input)
	component_mouse_capture.mouse_input = Vector2.ZERO

func update_camera_rotation(input : Vector2) -> void:
	if debug:
		print(input)
	
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
	
	var _player_rotation = Vector3(0.0, _rotation.y, 0.0)
	var _camera_rotation = Vector3(_rotation.x ,0.0 , 0.0)
	
	transform.basis = Basis.from_euler(_camera_rotation)
	player_controller.update_rotation(_player_rotation)
	
	rotation.z = 0.0
	pass
