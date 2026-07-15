class_name PlayerController
extends CharacterBody3D

#region Exports
@export var debug: bool = false

@export_category("References")
@export_group("Camera")
@export var camera_effects: CameraEffects 

@export_group("States")
@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var jump_state: State

@export_category("Player Settings")
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var acceleration: float = 0.15
@export var deceleration: float = 0.35

@export_group("Jump")
@export var jump_velocity: float = 4.5
@export var fall_velocity_threshold: float = -5.0

@export_group("Stamina")
@export var max_stamina: float = 100.0
@export var stamina_drain_rate: float = 15.0   # per second while sprinting
@export var stamina_regen_rate: float = 15.0   # per second while regenerating
@export var stamina_regen_delay: float = 0.75  # seconds after last drain before regen starts
@export var min_stamina_to_sprint: float = 30.0 # must regen past this to sprint again once exhausted

@export_group("Interaction")
@export var interact_ray: RayCast3D
@export var ground_ray: RayCast3D
@export var hold_point: Marker3D
@export var interact_distance: float = 3.0
@export_subgroup("Holding Objects")
@export var drop_below_player: bool = false
@export var throw_force: float = 20.0
@export var follow_speed: float = 30.0
@export var max_distance_from_camera: float = 5.0
#endregion

#region Onready / State
@onready var state_machine: StateMachine = $StateMachine
#endregion

#region Stamina State (internal)
var current_stamina: float
var _regen_timer: float = 0.0
var _exhausted: bool = false
var _draining_this_frame: bool = false
#endregion

#region Held Objects And Interactables
var held_object: RigidBody3D = null
var held_duck: Duckling = null
var _hovered_target: Node = null
#endregion

#region Engine Callbacks
func _ready() -> void:
	current_stamina = max_stamina
	state_machine.init(self)
	SignalBus.stamina_changed.emit(current_stamina, max_stamina)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_draining_this_frame = false
	state_machine.physics_update(delta)
	
	if not _draining_this_frame:
		_regen_stamina(delta)
	
	_update_held_object()
	_update_hover()
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)
	
	if event.is_action_pressed("interact"):
		try_interact()
	if event.is_action_pressed("catch"):
		try_catch()
	if event.is_action_pressed("throw"):
		try_throw()
#endregion

#region Movement
func apply_movement(input_dir: Vector2, target_speed: float) -> void:
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_velocity = Vector2(velocity.x, velocity.z)
	
	if direction:
		current_velocity = current_velocity.lerp(Vector2(direction.x, direction.z) * target_speed, acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)
	
	velocity.x = current_velocity.x
	velocity.z = current_velocity.y

func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)
#endregion

#region Jump
func apply_jump() -> void:
	velocity.y = jump_velocity
#endregion

#region Stamina
func drain_stamina(amount: float) -> void:
	_draining_this_frame = true
	_regen_timer = 0.0
	
	current_stamina = max(current_stamina - amount, 0.0)
	if current_stamina <= 0.0:
		_exhausted = true
	
	SignalBus.stamina_changed.emit(current_stamina, max_stamina)

func _regen_stamina(delta: float) -> void:
	if current_stamina >= max_stamina:
		return
	
	_regen_timer += delta
	if _regen_timer < stamina_regen_delay:
		return
	
	current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)
	
	if _exhausted and current_stamina >= min_stamina_to_sprint:
		_exhausted = false
	
	SignalBus.stamina_changed.emit(current_stamina, max_stamina)

func can_sprint() -> bool:
	return not _exhausted and current_stamina > 0.0
#endregion

#region Interaction
func try_interact() -> void:
	var target = interact_ray.get_collider()
	
	if held_object != null:
		drop_held_object()
		return
	if held_duck != null:
		if target.has_method("return_duck"):
			target.return_duck(held_duck)
			target.call("interact", self)
		try_release_duck()
		return
	
	if interact_ray == null or not interact_ray.is_colliding():
		return
	
	
	if target.has_method("interact"):
		target.call("interact", self)
	
	elif target.get_node_or_null("Pickables") != null:
		set_held_object(target)

func try_release_duck() -> void:
	if held_duck == null:
		return
	release_duck()

func try_catch() -> void:
	_raycast_call("catch")

func try_throw() -> void:
	if held_object != null:
		throw_held_object()

func _raycast_call(method_name: String) -> void:
	if interact_ray == null or not interact_ray.is_colliding():
		return
	
	var target = interact_ray.get_collider()
	
	if target and target.has_method(method_name):
		target.call(method_name, self)
#endregion

#region Hover / Highlight

func _update_hover() -> void:
	if interact_ray == null:
		return
	
	var current: Node = null
	
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if collider:
			var pickable = collider.get_node_or_null("Pickables")
			if pickable != null:
				current = pickable
			elif collider.has_method("catch"):
				current = collider
			elif collider.has_method("interact"):
				current = collider
	
	if current == _hovered_target:
		return
	
	if _hovered_target is Pickables:
		_hovered_target.set_highlighted(false)
	
	if current is Pickables:
		current.set_highlighted(true)
	
	_hovered_target = current
	SignalBus.hovered_pickable_changed.emit(current)
#endregion

#region Held Objects
func set_held_object(body: RigidBody3D) -> void:
	if body == null:
		return
	
	held_object = body

func drop_held_object() -> void:
	if held_object == null:
		return
	
	var obj := held_object
	held_object = null
	
	if drop_below_player and ground_ray != null and ground_ray.is_colliding():
		obj.global_position = ground_ray.get_collision_point()

func throw_held_object() -> void:
	if held_object == null:
		return
	
	var obj := held_object
	held_object = null
	
	var aim_point: Vector3 = interact_ray.global_position - interact_ray.global_transform.basis.z * 50.0
	var throw_direction: Vector3 = (aim_point - obj.global_position).normalized()
	
	obj.apply_central_impulse(throw_direction * throw_force)

func _update_held_object() -> void:
	if held_object == null or hold_point == null:
		return
	
	if held_object.global_position.distance_to(camera_effects.global_position) > max_distance_from_camera:
		drop_held_object()
		return
	
	var to_target = hold_point.global_position - held_object.global_position
	held_object.linear_velocity = to_target * follow_speed
	#endregion

#region Hold Duck
func hold_duck(duck: Duckling) -> void:
	if held_duck != null:
		return
	held_duck = duck
	duck.set_physics_process(false)
	duck.velocity = Vector3.ZERO
	duck.get_parent().remove_child(duck)
	hold_point.add_child(duck)
	duck.transform = Transform3D.IDENTITY

func release_duck() -> void:
	if held_duck == null:
		return
	var duck := held_duck
	held_duck = null
	
	var world_transform := duck.global_transform
	hold_point.remove_child(duck)
	get_tree().current_scene.add_child(duck)
	duck.global_transform = world_transform
	duck.get_node("CollisionShape3D").disabled = false
	
	#endregion
