class_name DuckStateHiding
extends DuckState


func enter(_data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.catch_count = 0
	duck.set_physics_process(true)
	duck.visible = true
	# TODO: play idle/hiding animation


func on_catch_attempt(_by: Node) -> void:
	duck.change_state(DuckStateChaseStart.new(duck))
