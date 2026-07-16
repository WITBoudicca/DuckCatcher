extends Node3D

@onready var credits = $CanvasLayer/RichTextLabel


func _ready() -> void:
	credits.modulate.a = 0.0
	await get_tree().create_timer(2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(credits, "modulate:a", 2.0, 2.0)
	await get_tree().create_timer(5).timeout
	SceneTransition.load_scene("res://system/ui/start menu/start_menu.tscn")
