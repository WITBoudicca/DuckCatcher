class_name Duckling
extends CharacterBody3D

const MAX_CATCHES : float = 3

signal chase_started
signal catch_progress(count: int)
signal fully_caught
signal gave_up
signal returned_to_mama

@export var start_location: Marker3D
@export var initial_wait_location: Marker3D
@export var paths_container: Node3D

@export_group("Movement")
@export var acceleration: float = 5.0
@export var rotation_speed: float = 10.0
@export var stopping_distance: float = 0.3

@export_group("Speeds")
@export var escape_speed: float = 9.0
@export var run_speed: float = 7.0
@export var tired_speed: float = 5.0
@export var run_to_tired_min: float = 10.0
@export var run_to_tired_max: float = 30.0
@export var tired_transition_duration: float = 4.0

@export_group("Catch")
@export var catch_radius: float = 1.5
@export var give_up_distance: float = 30.0
@export var chase_start_duration: float = 1.2
@export var disappear_duration: float = 1.0

var player: CharacterBody3D

var catch_count := 0

var last_wait_point: Node3D = null

var _duck_paths: Array[DuckPath] = []
var _current_state: DuckState


func _ready() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	for child in paths_container.get_children():
		if child is DuckPath:
			_duck_paths.append(child)

	change_state(DuckStateHiding.new(self))


func _physics_process(delta: float) -> void:
	_current_state.physics_update(delta)
	move_and_slide()


func change_state(new_state: DuckState, data: Dictionary = {}) -> void:
	if _current_state:
		_current_state.exit()
	_current_state = new_state
	_current_state.enter(data)


@warning_ignore("unused_parameter")
func catch(by: Node = null) -> void:
	_current_state.on_catch_attempt(by)


func notify_returned_to_mama() -> void:
	_current_state.on_returned_to_mama()


func seek(point: Vector3, speed: float, delta: float) -> bool:
	var direction := point - global_position
	direction.y = 0
	var distance := direction.length()

	if distance <= stopping_distance:
		velocity = velocity.move_toward(Vector3.ZERO, acceleration * delta)
		return true

	direction = direction.normalized()
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	_rotate_towards(direction, delta)
	return false


func _rotate_towards(direction: Vector3, delta: float) -> void:
	var target_angle := atan2(-direction.x, -direction.z)
	rotation.y = rotate_toward(rotation.y, target_angle, rotation_speed * delta)


func get_paths_from(point: Node3D) -> Array[DuckPath]:
	var result: Array[DuckPath] = []
	for p in _duck_paths:
		if p.get_a() == point or p.get_b() == point:
			result.append(p)
	return result
