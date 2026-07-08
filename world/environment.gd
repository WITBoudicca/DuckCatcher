extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment

@export var drift_speed := 0.005

func _process(delta: float) -> void:
	world_environment.environment.sky_rotation.y += delta * drift_speed
