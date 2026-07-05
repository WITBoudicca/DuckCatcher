class_name SprintState
extends State

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")

	if not Input.is_action_pressed("sprint") or input_dir.length() == 0 or not player.can_sprint():
		state_machine.transition_to(player.walk_state)
		return
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		state_machine.transition_to(player.jump_state)
		return

	player.drain_stamina(player.stamina_drain_rate * delta)
	player.apply_movement(input_dir, player.sprint_speed)
