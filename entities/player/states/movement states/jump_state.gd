class_name JumpState
extends State

var _air_speed: float = 0.0
var _current_fall_velocity: float 

func enter() -> void:
	player.apply_jump()
	
	# preserve momentum from whichever state we jumped from
	if Input.is_action_pressed("sprint") and player.can_sprint():
		_air_speed = player.sprint_speed
	else:
		_air_speed = player.walk_speed

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	player.apply_movement(input_dir, _air_speed)
	
	if player.is_on_floor():
		if _check_fall_speed():
			player.camera_effects.add_fall_kick(2.0)
	
		if input_dir.length() > 0:
			if Input.is_action_pressed("sprint"):
				state_machine.transition_to(player.sprint_state)
			else:
				state_machine.transition_to(player.walk_state)
		else:
			state_machine.transition_to(player.idle_state)
	
	_current_fall_velocity = player.velocity.y

func _check_fall_speed() -> bool:
	var hit_hard = _current_fall_velocity < player.fall_velocity_threshold
	_current_fall_velocity = 0.0
	return hit_hard
