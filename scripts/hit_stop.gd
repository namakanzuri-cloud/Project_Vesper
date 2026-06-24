extends Node
class_name HitStop

@export_group("Durations")
@export var light_attack_hit_stop_duration: float = 0.05
@export var heavy_attack_hit_stop_duration: float = 0.10
@export var enemy_attack_hit_stop_duration: float = 0.06

@export_group("Time Scale")
@export_range(0.03, 0.08, 0.005) var hit_stop_time_scale: float = 0.05

var _active: bool = false
var _restore_time_scale: float = 1.0
var _ends_at_usec: int = 0

func _ready() -> void:
	set_process(false)

func request_light_attack_hit_stop() -> void:
	request_hit_stop(light_attack_hit_stop_duration)

func request_heavy_attack_hit_stop() -> void:
	request_hit_stop(heavy_attack_hit_stop_duration)

func request_enemy_attack_hit_stop() -> void:
	request_hit_stop(enemy_attack_hit_stop_duration)

func request_hit_stop(duration: float) -> void:
	if duration <= 0.0:
		return

	var now_usec := Time.get_ticks_usec()
	var requested_end_usec := now_usec + int(duration * 1000000.0)

	if not _active:
		_active = true
		_restore_time_scale = Engine.time_scale
		_ends_at_usec = requested_end_usec
		set_process(true)
	else:
		_ends_at_usec = maxi(_ends_at_usec, requested_end_usec)

	Engine.time_scale = hit_stop_time_scale

func cancel() -> void:
	_active = false
	_ends_at_usec = 0
	Engine.time_scale = _restore_time_scale
	set_process(false)

func _process(_delta: float) -> void:
	if _active and Time.get_ticks_usec() >= _ends_at_usec:
		cancel()

func _exit_tree() -> void:
	cancel()
