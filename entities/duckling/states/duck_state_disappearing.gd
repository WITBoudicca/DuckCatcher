class_name DuckStateDisappearing
extends DuckState


func enter(_data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.gave_up.emit()  # TODO hook: stop chase music, spawn disappear particles

	# TODO: disappear animation here instead of hiding the mesh.
	duck.visible = false

	var timer := duck.get_tree().create_timer(duck.disappear_duration)
	timer.timeout.connect(_on_vanish_finished)


func _on_vanish_finished() -> void:
	duck.global_position = duck.start_location.global_position
	duck.rotation = duck.start_location.rotation
	duck.last_wait_point = null
	duck.change_state(DuckStateHiding.new(duck))
