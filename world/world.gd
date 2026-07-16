class_name World
extends Node3D

## Music
const GROOVINDUCK = preload("uid://dh8qky612b2sn")

@onready var ducklings: Array[Node] = get_tree().get_nodes_in_group("ducklings")


func _ready() -> void:
	AudioManager.play_ambience(GROOVINDUCK, -8)
	GameManager.set_ducks_total(ducklings.size())
