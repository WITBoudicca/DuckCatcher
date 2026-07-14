class_name DuckStateChaseStart
extends DuckState


func enter(_data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.chase_started.emit()
	duck.anim.play("Duckling_Tag")
	duck.anim.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)


func _on_anim_finished(_anim_name: StringName) -> void:
	duck.change_state(DuckStateChase.new(duck))
