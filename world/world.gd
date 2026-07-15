class_name World
extends Node3D

## Music
const DUCKJAZZ = preload("uid://c062xi7gfc6rc")

@onready var ducklings: Array[Node] = get_tree().get_nodes_in_group("ducklings")


func _ready() -> void:
	AudioManager.play_ambience(DUCKJAZZ, -8)
	GameManager.set_ducks_total(ducklings.size())
