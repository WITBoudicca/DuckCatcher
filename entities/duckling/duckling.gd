class_name Duckling
extends CharacterBody3D

@export_group("Movement")
@export var move_speed: float = 3.0
@export var acceleration: float = 12.0
@export var rotation_speed: float = 12.0
@export var stopping_distance: float = 0.15

@export_group("Wander")
@export var wander_radius: float = 4.0
@export var min_wander_distance: float = 1.0
@export var max_wander_distance: float = 4.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0

@onready var brain_timer: Timer = $BrainTimer

var home_position: Vector3
var target_position: Vector3


func _ready() -> void:
	randomize()

	home_position = global_position

	brain_timer.timeout.connect(_choose_new_target)

	_choose_new_target()


func _physics_process(delta: float) -> void:
	move_to_target(delta)
	move_and_slide()


func move_to_target(delta: float) -> void:

	var direction := target_position - global_position
	direction.y = 0

	var distance := direction.length()

	if distance <= stopping_distance:

		velocity = velocity.move_toward(
			Vector3.ZERO,
			acceleration * delta
		)

		if brain_timer.is_stopped():
			brain_timer.start(randf_range(min_idle_time, max_idle_time))

		return

	direction = direction.normalized()

	velocity = velocity.move_toward(
		direction * move_speed,
		acceleration * delta
	)

	rotate_towards(direction, delta)


func rotate_towards(direction: Vector3, delta: float) -> void:

	var target_angle := atan2(-direction.x, -direction.z)

	rotation.y = rotate_toward(
		rotation.y,
		target_angle,
		rotation_speed * delta
	)


func _choose_new_target() -> void:

	var angle := randf() * TAU

	var distance := randf_range(
		min_wander_distance,
		max_wander_distance
	)

	var offset := Vector3(
		cos(angle),
		0,
		sin(angle)
	) * distance

	target_position = home_position + offset


@warning_ignore("unused_parameter")
func catch(by: PlayerController) -> void:
	queue_free() #TODO caught behavior
