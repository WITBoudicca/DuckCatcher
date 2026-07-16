class_name DuckStateChaseStart
extends DuckState

const CHASEMUSIC = preload("uid://d3imog8gl5c08")
var angry_duck_sfx = preload("uid://dpp3567invew8")

func enter(_data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.chase_started.emit()
	duck.anim.play("Duckling_Tag")
	duck.anim.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)
	AudioManager.play_ambience(CHASEMUSIC, -8)
	AudioManager.play_sound_3d(angry_duck_sfx, duck.global_position, -8.0)


func _on_anim_finished(_anim_name: StringName) -> void:
	duck.change_state(DuckStateChase.new(duck))
	
