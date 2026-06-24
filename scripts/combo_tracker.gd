extends Node
class_name ComboTracker

signal combo_changed(combo_count: int, rating_text: String)

@export_group("Combo Timing")
@export var combo_timeout: float = 1.5

@export_group("Combo Rating")
@export var minimum_visible_combo: int = 2
@export var good_threshold: int = 2
@export var stylish_threshold: int = 4
@export var vesper_threshold: int = 7
@export var good_label: String = "GOOD"
@export var stylish_label: String = "STYLISH"
@export var vesper_label: String = "VESPER"

var combo_count: int = 0
var _time_remaining: float = 0.0

func _process(delta: float) -> void:
	if combo_count <= 0:
		return

	_time_remaining = maxf(0.0, _time_remaining - delta)
	if _time_remaining <= 0.0:
		reset_combo()

func add_hit(amount: int = 1, custom_timeout: float = -1.0) -> void:
	if amount <= 0:
		return

	combo_count += amount
	_refresh_combo_timer(custom_timeout)
	combo_changed.emit(combo_count, get_rating_text())

func extend_combo(custom_timeout: float = -1.0) -> void:
	if combo_count <= 0:
		return

	_refresh_combo_timer(custom_timeout)
	combo_changed.emit(combo_count, get_rating_text())

func reset_combo() -> void:
	if combo_count <= 0 and _time_remaining <= 0.0:
		return

	combo_count = 0
	_time_remaining = 0.0
	combo_changed.emit(combo_count, "")

func get_rating_text() -> String:
	if combo_count >= vesper_threshold:
		return vesper_label
	if combo_count >= stylish_threshold:
		return stylish_label
	if combo_count >= good_threshold:
		return good_label
	return ""

func _refresh_combo_timer(custom_timeout: float = -1.0) -> void:
	var timeout := combo_timeout if custom_timeout <= 0.0 else custom_timeout
	_time_remaining = maxf(0.0, timeout)
