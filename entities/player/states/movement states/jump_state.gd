class_name JumpState
extends State

var _air_speed: float = 0.0

func enter() -> void:
	player.apply_jump()
	# preserve momentum from whichever state we jumped from
	if Input.is_action_pressed("sprint"):
		_air_speed = player.sprint_speed
	else:
		_air_speed = player.walk_speed

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	player.apply_movement(input_dir, _air_speed)

	if player.is_on_floor() and player.velocity.y <= 0.0:
		if input_dir.length() > 0:
			if Input.is_action_pressed("sprint"):
				state_machine.transition_to(player.sprint_state)
			else:
				state_machine.transition_to(player.walk_state)
		else:
			state_machine.transition_to(player.idle_state)
