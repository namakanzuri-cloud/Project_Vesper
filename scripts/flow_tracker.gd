extends Node
class_name FlowTracker

signal flow_changed(current_flow: float, max_flow: float)
signal flow_popup_requested(message: String, duration: float)

@export var max_flow: float = 100.0

@export_group("Flow Gains")
@export var parry_flow_gain: float = 20.0
@export var just_dodge_flow_gain: float = 12.0
@export var interrupt_flow_gain: float = 18.0
@export var counter_hit_flow_gain: float = 10.0
@export var heavy_punish_flow_gain: float = 20.0

@export_group("Flow Losses")
@export var damage_taken_flow_loss: float = 20.0
@export var combo_break_flow_loss: float = 5.0

@export_group("Flow Display")
@export var flow_popup_duration: float = 0.75

var current_flow: float = 0.0

func _ready() -> void:
	current_flow = clampf(current_flow, 0.0, max_flow)
	flow_changed.emit(current_flow, max_flow)

func add_flow(amount: float, reason: String) -> void:
	if amount <= 0.0:
		return

	_change_flow(amount, reason)

func lose_flow(amount: float, reason: String) -> void:
	if amount <= 0.0:
		return

	_change_flow(-amount, reason)

func reset_flow() -> void:
	var changed := not is_equal_approx(current_flow, 0.0)
	current_flow = 0.0
	if changed:
		flow_changed.emit(current_flow, max_flow)

func add_parry_flow() -> void:
	add_flow(parry_flow_gain, "PARRY")

func add_just_dodge_flow() -> void:
	add_flow(just_dodge_flow_gain, "JUST DODGE")

func add_interrupt_flow() -> void:
	add_flow(interrupt_flow_gain, "INTERRUPT")

func add_counter_hit_flow() -> void:
	add_flow(counter_hit_flow_gain, "COUNTER")

func add_heavy_punish_flow() -> void:
	add_flow(heavy_punish_flow_gain, "HEAVY PUNISH")

func lose_damage_taken_flow() -> void:
	lose_flow(damage_taken_flow_loss, "HIT")

func lose_combo_break_flow() -> void:
	lose_flow(combo_break_flow_loss, "COMBO BREAK")

func _change_flow(delta: float, reason: String) -> void:
	var previous_flow := current_flow
	current_flow = clampf(current_flow + delta, 0.0, max_flow)
	var actual_delta := current_flow - previous_flow
	if is_equal_approx(actual_delta, 0.0):
		return

	flow_changed.emit(current_flow, max_flow)
	var sign := "+" if actual_delta > 0.0 else "-"
	var amount := absf(actual_delta)
	flow_popup_requested.emit("%s%d FLOW / %s" % [sign, int(round(amount)), reason], flow_popup_duration)

