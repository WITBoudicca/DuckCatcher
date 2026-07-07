class_name Pickables
extends Node

@export var mesh_instance: MeshInstance3D
@export var outline_mesh: MeshInstance3D
@export var interaction_label: String = "Pick up"

var _is_highlighted: bool = false

func _ready() -> void:
	if outline_mesh != null:
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
