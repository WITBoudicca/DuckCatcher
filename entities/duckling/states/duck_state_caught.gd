class_name DuckStateCaught
extends DuckState

const GROOVINDUCK = preload("uid://dh8qky612b2sn")
var caught_duck_sfx = [preload("uid://c67lci4ui3a2c"), preload("uid://q6hg5csfdhty"), preload("uid://dt2cdlaagql7l")]

func enter(data: Dictionary = {}) -> void:
	duck.velocity = Vector3.ZERO
	duck.anim.play("Duckling_Tag")
	duck.set_physics_process(false)
	
	var by = data.get("by")
	if by and by.has_method("hold_duck"):
		by.hold_duck(duck)
		AudioManager.play_sound_3d(caught_duck_sfx.pick_random(), duck.global_position, -8.0)
		duck.anim.play("Neutral")
	AudioManager.play_ambience(GROOVINDUCK, -8)
	duck.fully_caught.emit()


func on_returned_to_mama() -> void:
	GameManager.return_duck()
	duck.set_physics_process(true)
	duck.returned_to_mama.emit()
