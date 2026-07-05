class_name StateMachine
extends Node

@export var debug: bool = false
@export var initial_state: State

var current_state: State
var player: PlayerController

func init(p: PlayerController) -> void:
	player = p
	for child in get_children():
		if child is State:
			child.player = player
			child.state_machine = self
	current_state = initial_state
	current_state.enter()

func physics_update(delta: float) -> void:
	if debug: print(current_state)
	if current_state:
		current_state.physics_update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func transition_to(new_state: State) -> void:
	if new_state == current_state:
		return
	current_state.exit()
	current_state = new_state
	current_state.enter()
