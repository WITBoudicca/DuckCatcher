extends CanvasLayer

@onready var anim = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func load_scene(scene):
	visible = true
	anim.play("fade_in")
	await anim.animation_finished
	get_tree().change_scene_to_file(scene)
	anim.play("fade_out")
	await anim.animation_finished
