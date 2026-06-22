extends Node
class_name Stamina

signal changed(current_stamina: float, max_stamina: float)

@export var max_stamina: float = 100.0
@export var recovery_per_second: float = 28.0
@export var recovery_delay: float = 0.35

var current_stamina: float = 0.0
var _recovery_blocked_for: float = 0.0

func _ready() -> void:
	current_stamina = max_stamina
	changed.emit(current_stamina, max_stamina)

func _process(delta: float) -> void:
	if _recovery_blocked_for > 0.0:
		_recovery_blocked_for = maxf(0.0, _recovery_blocked_for - delta)
		return

	if current_stamina >= max_stamina:
		return

	current_stamina = minf(max_stamina, current_stamina + recovery_per_second * delta)
	changed.emit(current_stamina, max_stamina)

func can_spend(amount: float) -> bool:
	return amount <= 0.0 or current_stamina >= amount

func try_spend(amount: float) -> bool:
	if not can_spend(amount):
		return false

	current_stamina = maxf(0.0, current_stamina - amount)
	_recovery_blocked_for = recovery_delay
	changed.emit(current_stamina, max_stamina)
	return true

func reset_stamina() -> void:
	current_stamina = max_stamina
	_recovery_blocked_for = 0.0
	changed.emit(current_stamina, max_stamina)
