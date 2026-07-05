class_name CameraEffects 
extends Camera3D

@export var debug: bool = false

@export_category("References")
@export var player : PlayerController

@export_category("Effects")
@export var enable_tilt : bool = true
@export var enable_fall_kick : bool = true
@export var enable_headbob : bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
## Run Tilt Angle
@export var run_pitch : float = 0.2 # Degrees
## Sway Tilt Angle
@export var run_roll : float = 0.25 # Degrees
@export var max_pitch : float = 1.0
@export var max_roll : float = 2.5

@export_group("Camera Kick")
@export_subgroup("Fall Kick")
@export var fall_time: float = 0.3

@export_group("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch : float = 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll : float = 0.025
@export_range(0.0, 0.4, 0.001) var bob_up : float = 0.005
@export_range(1.0, 8.0, 0.1) var bob_frequency : float = 1.6


var _fall_value : float = 0.0
var _fall_timer : float = 0.0

var _step_timer : float = 0.0

func _process(delta: float) -> void:
	calculate_view_offset(delta)

func calculate_view_offset(delta):
	if not player: return
	
	_fall_timer -= delta 
	
	var velocity = player.velocity
	
	#Headbob Step Timer and Sin Value
	var speed = Vector2(velocity.x, velocity.z).length()
	if speed > 0.1 and player.is_on_floor():
		_step_timer += delta * (speed / player.walk_speed) * bob_frequency
		_step_timer = fmod(_step_timer, 1.0)
	else:
		_step_timer = 0.0
	var bob_sin = sin(_step_timer * 2.0 * PI) *0.5 # 0.5 reduces the magnitude of the sin wave, i.e. less movement
	
	
	var angles = Vector3.ZERO
	var offset = Vector3.ZERO
	
	## Camera Tilt
	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x
		
		var forward_dot = velocity.dot(forward)
		var forward_tilt = clamp(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x += forward_tilt
		
		var right_dot = velocity.dot(right)
		var side_tilt = clamp(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z -= side_tilt
	
	
	## Fall Kick
	if enable_fall_kick:
		var fall_ratio = max(0.0, _fall_timer / fall_time)
		var fall_kick_amount = fall_ratio * _fall_value
		angles.x -= fall_kick_amount
		offset.x -= fall_kick_amount
	
	
	## Headbob
	if enable_headbob:
		var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		angles.x -= pitch_delta
		var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.z -= roll_delta
		var bob_height = bob_sin * speed * bob_up
		offset.y += bob_height 
	
	
	
	position = offset
	rotation = angles

func add_fall_kick(fall_strenght : float)-> void:
	_fall_value = deg_to_rad(fall_strenght)
	_fall_timer = fall_time
	pass
