@tool
extends Control

@export var radius: float = 30.0 : set = set_crosshair_radius
@export var thickness: float = 1.0 : set = set_crosshair_thickness
@export var color: Color = Color.WHITE : set = set_crosshair_color
@export var gap_angle: float = 45.0 : set = set_crosshair_gap_angle
@export var segments: int = 32 : set = set_crosshair_segments

@export_group("Point Reticle")
@export var use_point: bool = false : set = set_use_point
@export var point_radius: float = 2.0 : set = set_point_radius


func _draw() -> void:
	if use_point:
		draw_point_crosshair()
	else:
		draw_circle_crosshair()


func draw_circle_crosshair() -> void:
	var center = size / 2.0
	var gap_rad = deg_to_rad(gap_angle)
	
	# 4 gaps evenly spaced around the circle (N/E/S/W)
	var gap_positions = [0.0, PI / 2.0, PI, PI * 1.5]
	
	for gap_center in gap_positions:
		var arc_start = gap_center + gap_rad / 2.0
		var arc_end = gap_center + (PI / 2.0) - (gap_rad / 2.0)
		draw_arc(center, radius, arc_start, arc_end, segments, color, thickness, true)


func draw_point_crosshair() -> void:
	var center = size / 2.0
	draw_circle(center, point_radius, color)


func set_crosshair_radius(value: float) -> void:
	radius = value
	queue_redraw()

func set_crosshair_thickness(value: float) -> void:
	thickness = value
	queue_redraw()

func set_crosshair_color(value: Color) -> void:
	color = value
	queue_redraw()

func set_crosshair_gap_angle(value: float) -> void:
	gap_angle = value
	queue_redraw()

func set_crosshair_segments(value: int) -> void:
	segments = value
	queue_redraw()

func set_use_point(value: bool) -> void:
	use_point = value
	queue_redraw()

func set_point_radius(value: float) -> void:
	point_radius = value
	queue_redraw()
