class_name DuckStateChase
extends DuckState

enum Mode { ESCAPE, RUN, TIRED }

var mode: Mode = Mode.ESCAPE
var current_speed: float = 0.0

var origin_point: Node3D
var target_point: Node3D
var current_path: DuckPath
var path_points: Array[Vector3] = []
var path_index: int = 0

var _tired_timer: float = 0.0
var _tired_delay: float = 0.0

var catch_cooldown = 0.0
var _delta = 0.0

var sfx_timer = 0.0

var angry_duck_sfx = preload("uid://dpp3567invew8")
var chase_sfx = preload("uid://bqe3rn4qn16oc")

func enter(_data: Dictionary = {}) -> void:
	mode = Mode.ESCAPE
	current_speed = duck.escape_speed
	_tired_timer = 0.0
	_tired_delay = randf_range(duck.run_to_tired_min, duck.run_to_tired_max)
	duck.anim.play("Duckling_Escape")

	if duck.last_wait_point == null:
		origin_point = duck.start_location
		target_point = duck.initial_wait_location
		current_path = null
		path_points = [target_point.global_position]
		path_index = 0
	else:
		origin_point = duck.last_wait_point
		_choose_next_target()



func physics_update(delta: float) -> void:
	_delta = delta
	if duck.player == null:
		return
	
	if sfx_timer <= 0.0:
		AudioManager.play_sound_3d(chase_sfx, duck.global_position, -8.0)
		sfx_timer = randi_range(2, 7)
	else:
		sfx_timer -= delta

	var player_pos: Vector3 = duck.player.global_position

	if duck.global_position.distance_to(player_pos) > duck.give_up_distance:
		duck.change_state(DuckStateDisappearing.new(duck))
		return

	_update_speed(delta)
	_check_reversal(player_pos)
	_travel(delta)


func on_catch_attempt(by: Node) -> void:
	var dist := duck.global_position.distance_to(duck.player.global_position)
	if dist > duck.catch_radius:
		return
	
	if catch_cooldown <= 0:
		duck.catch_count += 1
		duck.catch_progress.emit(duck.catch_count)
		if duck.catch_count >= Duckling.MAX_CATCHES:
			duck.change_state(DuckStateCaught.new(duck), {"by": by})
		else:
			duck.change_state(DuckStateChaseStart.new(duck))
			AudioManager.play_sound_3d(angry_duck_sfx, duck.global_position, -8.0)
			catch_cooldown = 2.0
	else:
		catch_cooldown -= _delta


func _update_speed(delta: float) -> void:
	match mode:
		Mode.ESCAPE:
			current_speed = duck.escape_speed
		Mode.RUN:
			current_speed = duck.run_speed
			_tired_timer += delta
			if _tired_timer >= _tired_delay:
				mode = Mode.TIRED
				duck.anim.play("Duckling_Tired")
		Mode.TIRED:
			var rate := (duck.run_speed - duck.tired_speed) / duck.tired_transition_duration
			current_speed = move_toward(current_speed, duck.tired_speed, rate * delta)


func _check_reversal(player_pos: Vector3) -> void:
	if current_path == null or path_points.is_empty():
		return

	var d_origin := origin_point.global_position.distance_to(player_pos)
	var d_target := target_point.global_position.distance_to(player_pos)

	if d_origin > d_target:
		var tmp := origin_point
		origin_point = target_point
		target_point = tmp
		path_points.reverse()
		path_index = path_points.size() - 1 - path_index


func _travel(delta: float) -> void:
	if path_index >= path_points.size():
		_arrive()
		return

	var reached := duck.seek(path_points[path_index], current_speed, delta)
	if reached:
		path_index += 1
		if path_index >= path_points.size():
			_arrive()


func _arrive() -> void:
	duck.last_wait_point = target_point

	if mode == Mode.ESCAPE:
		mode = Mode.RUN
		_tired_timer = 0.0
		duck.anim.play("Duckling_Run")

	origin_point = target_point
	_choose_next_target()


func _choose_next_target() -> void:
	var candidates := duck.get_paths_from(origin_point)

	if candidates.is_empty():
		if current_path != null:
			var tmp := origin_point
			origin_point = target_point
			target_point = tmp
			path_points = current_path.get_ordered_points(origin_point)
			path_index = 0
		return

	var player_pos: Vector3 = duck.player.global_position
	var best_other: Node3D = null
	var best_dist := -1.0

	for p in candidates:
		var other := p.get_other(origin_point)
		var d := other.global_position.distance_to(player_pos)
		if d > best_dist:
			best_dist = d
			best_other = other

	var options: Array[DuckPath] = []
	for p in candidates:
		if p.get_other(origin_point) == best_other:
			options.append(p)

	current_path = options[randi() % options.size()]
	target_point = best_other
	path_points = current_path.get_ordered_points(origin_point)
	path_index = 0
