class_name PlayerController
extends CharacterBody3D

@export var debug: bool = false

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 0.15
@export var deceleration: float = 0.25

@export_group("Jump")
@export var jump_velocity: float = 4.5

@export_group("States")
@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var jump_state: State

@export_group("Interaction")
@export var interact_ray: RayCast3D
@export var interact_distance: float = 3.0

@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	state_machine.init(self)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	state_machine.physics_update(delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

	if event.is_action_pressed("interact"):
		try_interact()
	if event.is_action_pressed("catch"):
		try_catch()

func apply_movement(input_dir: Vector2, target_speed: float) -> void:
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_velocity = Vector2(velocity.x, velocity.z)

	if direction:
		current_velocity = current_velocity.lerp(Vector2(direction.x, direction.z) * target_speed, acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)

	velocity.x = current_velocity.x
	velocity.z = current_velocity.y

func apply_jump() -> void:
	velocity.y = jump_velocity

func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

func try_interact() -> void:
	_raycast_call("interact")

func try_catch() -> void:
	_raycast_call("catch")

func _raycast_call(method_name: String) -> void:
	if interact_ray == null or not interact_ray.is_colliding():
		return
	var target = interact_ray.get_collider()
	if target and target.has_method(method_name):
		target.call(method_name, self)
