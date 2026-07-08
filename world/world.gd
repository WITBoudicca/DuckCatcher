extends Node3D

## Music
const DUCKJAZZ = preload("uid://c062xi7gfc6rc")

func _ready() -> void:
	AudioManager.play_ambience(DUCKJAZZ, -8)
