class_name PlayerHud
extends Control

@onready var reticle_draw: Control = $Reticle/ReticleDraw
@onready var reticle_hand: TextureRect = $Reticle/ReticleHand
@onready var stamina_bar: Control = $StaminaBar
@onready var interaction_prompt: Label = %InteractionPrompt
@onready var instruction: Label = %Instruction
@onready var duck_counter: Label = %DuckCounter

func _ready() -> void:
	interaction_prompt.visible = false
	reticle_hand.visible = false
	SignalBus.hovered_pickable_changed.connect(_on_hovered_pickable_changed)
	SignalBus.ducks_returned_changed.connect(_on_ducks_returned_changed)

	duck_counter.text = "Ducks returned: %d / %d" % [GameManager.ducks_returned, GameManager.ducks_total]


func _on_ducks_returned_changed(current: int, total: int) -> void:
	duck_counter.text = "Ducks returned: %d / %d" % [current, total]

func _on_hovered_pickable_changed(target: Node) -> void:
	if target == null:
		interaction_prompt.visible = false
		reticle_hand.visible = false
		return
	
	reticle_hand.visible = true
	interaction_prompt.visible = true
	
	if target is Pickables:
		interaction_prompt.text = target.interaction_label
	elif target.has_method("catch"):
		interaction_prompt.text = "Catch"
	elif target.has_method("interact"):
		interaction_prompt.text = "Interact"
