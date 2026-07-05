extends ProgressBar

@export var idle_delay: float = 0.5

var _fade_tween: Tween
var _idle_timer: float = 0.0

func _ready() -> void:
	SignalBus.stamina_changed.connect(_on_stamina_changed)
	max_value = 100.0
	modulate.a = 0.0

func _process(delta: float) -> void:
	if value >= max_value:
		_idle_timer += delta
		if _idle_timer >= idle_delay:
			_fade_to(0.0, 0.2)
	else:
		_idle_timer = 0.0

func _on_stamina_changed(current: float, stamina_max: float) -> void:
	max_value = stamina_max
	value = current

	if current < stamina_max:
		_idle_timer = 0.0
		_fade_to(1.0, 0.3)

func _fade_to(target_alpha: float, fade_duration: float) -> void:
	if _fade_tween and _fade_tween.is_valid() and is_equal_approx(modulate.a, target_alpha):
		return

	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", target_alpha, fade_duration)
