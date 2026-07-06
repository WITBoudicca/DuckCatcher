class_name Pickables
extends RigidBody3D

@export var mesh_instance: MeshInstance3D
@export var outline_mesh: MeshInstance3D
@export var interaction_label: String = "Pick up"

var _is_highlighted: bool = false

func _ready() -> void:
	if mesh_instance == null:
		push_warning("Pickables: mesh_instance not assigned on %s" % name)
	if outline_mesh == null:
		push_warning("Pickables: outline_mesh not assigned on %s" % name)
	else:
		outline_mesh.visible = false

func set_highlighted(value: bool) -> void:
	if _is_highlighted == value:
		return
	_is_highlighted = value

	if outline_mesh != null:
		outline_mesh.visible = _is_highlighted

	if _is_highlighted:
		SignalBus.hovered_pickable_changed.emit(self)
	else:
		SignalBus.hovered_pickable_changed.emit(null)
