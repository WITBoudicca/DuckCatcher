## SignalBus - Autoload Singleton
extends Node

signal pause_changed(bool)

signal stamina_changed(current_stamina: float, max_stamina: float)

signal hovered_pickable_changed(pickable: Node)

signal flag_changed(flag_name: String, value: bool)

signal ducks_returned_changed(current: int, total: int)
