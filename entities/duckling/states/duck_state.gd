class_name DuckState
extends RefCounted

var duck: Duckling


func _init(p_duck: Duckling) -> void:
	duck = p_duck

func enter(_data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func on_catch_attempt(_by: Node) -> void:
	pass

func on_returned_to_mama() -> void:
	pass
