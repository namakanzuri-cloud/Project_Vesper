extends Node3D
class_name CombatPrototypeMain

@onready var player: PlayerController = $Player
@onready var enemy: EnemyController = $Enemy
@onready var ui: CombatUI = $UI
@onready var hit_stop = $HitStop
@onready var camera: CameraFollow = $Camera3D
@onready var combo_tracker: ComboTracker = $ComboTracker
@onready var flow_tracker: FlowTracker = $FlowTracker
@onready var combat_stats = $CombatStats

enum CombatState { PLAYING, VICTORY, DEFEAT }

var _player_spawn_transform: Transform3D
var _enemy_spawn_transform: Transform3D
var _combat_state: int = CombatState.PLAYING

func _ready() -> void:
	hit_stop.cancel()
	Engine.time_scale = 1.0
	camera.reset_follow()
	_player_spawn_transform = player.global_transform
	_enemy_spawn_transform = enemy.global_transform
	player.health.died.connect(_on_player_died)
	enemy.health.died.connect(_on_enemy_died)
	_connect_combat_stats()
	ui.set_end_overlay_visible(false)
	ui.clear_temporary_message()
	ui.clear_flow_popup()
	_reset_combo_state()
	_reset_flow_state()
	_reset_combat_stats()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_reset"):
		reset_combat()
		return

	if _combat_state != CombatState.PLAYING and Input.is_action_just_pressed("retry"):
		reset_combat()

func reset_combat() -> void:
	_clear_active_hit_vfx()
	hit_stop.cancel()
	Engine.time_scale = 1.0
	camera.cancel_shake()
	_combat_state = CombatState.PLAYING
	player.global_transform = _player_spawn_transform
	enemy.global_transform = _enemy_spawn_transform

	player.set_control_enabled(true)
	enemy.set_ai_enabled(true)
	player.reset_combat_state()
	enemy.reset_combat_state()
	player.health.reset_health()
	enemy.health.reset_health()
	player.stamina.reset_stamina()
	camera.reset_follow()
	ui.set_end_overlay_visible(false)
	ui.clear_temporary_message()
	ui.clear_flow_popup()
	_reset_combo_state()
	_reset_flow_state()
	_reset_combat_stats()

func _reset_combo_state() -> void:
	if combo_tracker != null:
		combo_tracker.reset_combo()

func _reset_flow_state() -> void:
	if flow_tracker != null:
		flow_tracker.reset_flow()

func _connect_combat_stats() -> void:
	if combat_stats == null:
		return

	if not player.damage_taken.is_connected(combat_stats.record_damage_taken):
		player.damage_taken.connect(combat_stats.record_damage_taken)
	if not player.parry_succeeded.is_connected(combat_stats.record_parry):
		player.parry_succeeded.connect(combat_stats.record_parry)
	if not player.normal_parry_succeeded.is_connected(combat_stats.record_normal_parry):
		player.normal_parry_succeeded.connect(combat_stats.record_normal_parry)
	if not player.rhythm_deflect_succeeded.is_connected(combat_stats.record_deflect):
		player.rhythm_deflect_succeeded.connect(combat_stats.record_deflect)
	if not player.parry_failed.is_connected(combat_stats.record_parry_fail):
		player.parry_failed.connect(combat_stats.record_parry_fail)
	if not player.just_dodge_succeeded.is_connected(combat_stats.record_just_dodge):
		player.just_dodge_succeeded.connect(combat_stats.record_just_dodge)
	if not player.riposte_hit.is_connected(combat_stats.record_riposte_hit):
		player.riposte_hit.connect(combat_stats.record_riposte_hit)
	if not player.vesper_counter_hit.is_connected(combat_stats.record_vesper_counter_hit):
		player.vesper_counter_hit.connect(combat_stats.record_vesper_counter_hit)
	if not player.just_dodge_counter_hit.is_connected(combat_stats.record_just_dodge_counter_hit):
		player.just_dodge_counter_hit.connect(combat_stats.record_just_dodge_counter_hit)
	if not player.vesper_art_used.is_connected(combat_stats.record_vesper_art_used):
		player.vesper_art_used.connect(combat_stats.record_vesper_art_used)
	if not player.vesper_art_hit.is_connected(combat_stats.record_vesper_art_hit):
		player.vesper_art_hit.connect(combat_stats.record_vesper_art_hit)
	if not player.vesper_art_missed.is_connected(combat_stats.record_vesper_art_miss):
		player.vesper_art_missed.connect(combat_stats.record_vesper_art_miss)
	if not player.blood_rend_used.is_connected(combat_stats.record_blood_rend_used):
		player.blood_rend_used.connect(combat_stats.record_blood_rend_used)
	if not player.blood_rend_hit.is_connected(combat_stats.record_blood_rend_hit):
		player.blood_rend_hit.connect(combat_stats.record_blood_rend_hit)
	if not player.blood_scent_success.is_connected(combat_stats.record_blood_scent_success):
		player.blood_scent_success.connect(combat_stats.record_blood_scent_success)
	if not player.blood_scent_hit_taken.is_connected(combat_stats.record_blood_scent_hit_taken):
		player.blood_scent_hit_taken.connect(combat_stats.record_blood_scent_hit_taken)
	if not enemy.interrupt_succeeded.is_connected(combat_stats.record_interrupt):
		enemy.interrupt_succeeded.connect(combat_stats.record_interrupt)
	if not enemy.interrupt_succeeded.is_connected(player.record_blood_scent_interrupt_success):
		enemy.interrupt_succeeded.connect(player.record_blood_scent_interrupt_success)
	if combo_tracker != null and not combo_tracker.combo_changed.is_connected(combat_stats.record_combo_changed):
		combo_tracker.combo_changed.connect(combat_stats.record_combo_changed)
	if flow_tracker != null and not flow_tracker.flow_changed.is_connected(combat_stats.record_flow_changed):
		flow_tracker.flow_changed.connect(combat_stats.record_flow_changed)

func _reset_combat_stats() -> void:
	if combat_stats != null:
		combat_stats.reset_for_combat()

func _finish_combat_stats() -> void:
	if combat_stats == null:
		return

	var current_flow := 0.0
	if flow_tracker != null:
		current_flow = flow_tracker.current_flow
	combat_stats.finish_combat(current_flow)

func _clear_active_hit_vfx() -> void:
	for hit_vfx in get_tree().get_nodes_in_group(&"hit_vfx"):
		if is_instance_valid(hit_vfx):
			hit_vfx.queue_free()

func _on_player_died() -> void:
	_enter_defeat()

func _on_enemy_died() -> void:
	if player.health.is_dead():
		_enter_defeat()
		return

	_enter_victory()

func _enter_victory() -> void:
	if _combat_state != CombatState.PLAYING:
		return

	hit_stop.cancel()
	Engine.time_scale = 1.0
	camera.cancel_shake()
	_combat_state = CombatState.VICTORY
	player.set_control_enabled(false)
	enemy.set_ai_enabled(false)
	ui.clear_temporary_message()
	ui.clear_flow_popup()
	_finish_combat_stats()
	var result_text := ""
	var result_json := ""
	var result_log_text := ""
	if combat_stats != null:
		result_text = combat_stats.get_result_text()
		result_json = combat_stats.generate_result_json("victory")
		result_log_text = combat_stats.get_result_log_summary()
	_reset_combo_state()
	_reset_flow_state()
	ui.set_end_overlay_visible(true, "VICTORY", "Enemy Defeated  |  R: Retry  |  F5: Reset  |  F9: Copy Log", result_text, result_log_text, result_json)

func _enter_defeat() -> void:
	if _combat_state == CombatState.DEFEAT:
		return

	hit_stop.cancel()
	Engine.time_scale = 1.0
	camera.cancel_shake()
	_combat_state = CombatState.DEFEAT
	player.set_control_enabled(false)
	enemy.set_ai_enabled(false)
	ui.clear_temporary_message()
	ui.clear_flow_popup()
	_finish_combat_stats()
	var result_json := ""
	var result_log_text := ""
	if combat_stats != null:
		result_json = combat_stats.generate_result_json("death")
		result_log_text = combat_stats.get_result_log_summary()
	_reset_combo_state()
	_reset_flow_state()
	ui.set_end_overlay_visible(true, "YOU DIED", "Press R to retry  |  F5 resets anytime  |  F9 copies log", "", result_log_text, result_json)
