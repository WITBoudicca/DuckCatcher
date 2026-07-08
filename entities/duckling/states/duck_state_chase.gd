class_name DuckStateChaseStart
extends DuckState

var _timer: SceneTreeTimer


func enter(_data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.chase_started.emit()

	# TODO: replace with duckling animation_player.play("chase_start") and
	# connect to `animation_finished` instead of a flat timer
	_timer = duck.get_tree().create_timer(duck.chase_start_duration)
	_timer.timeout.connect(_on_anim_finished)


func _on_anim_finished() -> void:
	duck.change_state(DuckStateChase.new(duck))
