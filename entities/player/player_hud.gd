class_name PlayerHud
extends Control

@onready var reticle: CenterContainer = $Reticle
@onready var stamina_bar: Control = $StaminaBar
@onready var interaction_prompt: Label = $InteractionPrompt

func _ready() -> void:
	interaction_prompt.visible = false
	SignalBus.hovered_pickable_changed.connect(_on_hovered_pickable_changed)

func _on_hovered_pickable_changed(pickable: Node) -> void:
	if pickable == null:
		interaction_prompt.visible = false
		return
	
	if pickable is Pickables:
		interaction_prompt.text = pickable.interaction_label
		interaction_prompt.visible = true
