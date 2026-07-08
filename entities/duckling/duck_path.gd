class_name DuckPath
extends Node


@export var point_a: NodePath
@export var point_b: NodePath

@export var nav_points: Array[NodePath] = []


func get_a() -> Node3D:
	return get_node(point_a)


func get_b() -> Node3D:
	return get_node(point_b)


func get_other(from_point: Node3D) -> Node3D:
	if get_a() == from_point:
		return get_b()
	elif get_b() == from_point:
		return get_a()
	return null


func get_ordered_points(from_point: Node3D) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for np in nav_points:
		points.append(get_node(np).global_position)

	if get_a() != from_point:
		points.reverse()

	if points.is_empty():
		points.append(get_other(from_point).global_position)

	return points
