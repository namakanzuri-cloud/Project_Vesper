extends Node
class_name Health

signal changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 100.0

var current_health: float = 0.0

func _ready() -> void:
	current_health = max_health
	changed.emit(current_health, max_health)

func take_damage(amount: float) -> bool:
	if is_dead() or amount <= 0.0:
		return false

	var previous_health := current_health
	current_health = maxf(0.0, current_health - amount)
	changed.emit(current_health, max_health)

	if is_dead():
		died.emit()

	return current_health < previous_health

func heal(amount: float) -> void:
	if is_dead() or amount <= 0.0:
		return

	current_health = minf(max_health, current_health + amount)
	changed.emit(current_health, max_health)

func reset_health() -> void:
	current_health = max_health
	changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0.0
