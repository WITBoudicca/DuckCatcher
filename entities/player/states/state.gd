## State.gd
class_name State
extends Node

var player: PlayerController
var state_machine: StateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func handle_input(event: InputEvent) -> void:
	pass
