class_name IdleState
extends State

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.transition_to(player.jump_state)
		return
	if input_dir.length() > 0:
		if Input.is_action_pressed("sprint"):
			state_machine.transition_to(player.sprint_state)
		else:
			state_machine.transition_to(player.walk_state)
		return

	player.apply_movement(Vector2.ZERO, 0.0)
