class_name DuckStateCaught
extends DuckState


func enter(data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.set_physics_process(false)

	var by = data.get("by")
	if by and by.has_method("hold_duck"):
		by.hold_duck(duck)

	duck.fully_caught.emit()


func on_returned_to_mama() -> void:
	duck.set_physics_process(true)
	duck.returned_to_mama.emit()
	duck.change_state(DuckStateHiding.new(duck))
