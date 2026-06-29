extends CharacterBody3D
class_name EnemyController

signal interrupt_succeeded

enum EnemyState { CHASE, TELEGRAPH, ACTIVE, RECOVERY, PATTERN_GAP, PATTERN_RECOVERY, STUNNED, DEAD }
enum AttackType { FAST_SLASH, DELAYED_HEAVY, GRAB, ARMOR_SLAM, RETREAT_SLASH }
enum AttackPattern { FAST_COMBO, GRAB_MIX, SIMPLE_PRESSURE, PRESSURE_INTO_SLAM, SLASH_SLAM_MIX, RETREAT_PRESSURE }
enum FastComboFinisher { HEAVY_FINISH, GRAB_FINISH, SLAM_FINISH }
enum DistanceBand { CLOSE, MID, FAR }
enum TelegraphVisualMode { FULL_DEBUG, MINIMAL, OFF }

@export var target_path: NodePath
@export var target_group: StringName = &"player"

@export_group("Movement")
@export var move_speed: float = 3.4
@export var rotation_speed: float = 12.0

@export_group("Attack Selection")
@export var attack_cooldown: float = 0.15
@export var close_range_distance: float = 2.2
@export var mid_range_distance: float = 2.65
@export var far_range_distance: float = 3.05
@export var repeat_pattern_avoid_chance: float = 0.65
@export var repeat_pattern_weight_multiplier: float = 0.35
@export var recent_pattern_memory_count: int = 2
@export var dangerous_outcome_repeat_weight_multiplier: float = 0.35
@export var slam_suppression_count: int = 2
@export var slam_suppression_multiplier: float = 0.18
@export var anti_parry_stock_threshold: int = 2
@export var anti_parry_grab_weight_bonus: float = 1.4
@export var anti_parry_armor_weight_bonus: float = 1.12
@export var aggression_check_window: float = 2.0
@export var aggression_attack_count_threshold: int = 3
@export var anti_aggression_weight_bonus: float = 1.25
@export var blood_scent_pressure_weight_bonus: float = 1.2
@export var debug_log_attack_types: bool = false
@export var debug_log_attack_patterns: bool = false
@export var show_ai_debug_text: bool = false

@export_group("Attack Patterns")
# Combo roles:
# Fast Combo = Deflect showcase into a final read.
# Simple Pressure = short pressure, Grab Mix = early parry-habit punish.
# Slam patterns = anti-mash / anti-blind-parry punishment.
@export var fast_combo_weight: float = 3.0
@export var grab_mix_weight: float = 1.4
@export var simple_pressure_weight: float = 3.2
@export var pressure_into_slam_weight: float = 0.6
@export var slash_slam_mix_weight: float = 0.5
@export var retreat_pressure_weight: float = 1.0
@export var fast_combo_step_interval: float = 0.04
@export var grab_mix_step_interval: float = 0.06
@export var simple_pressure_step_interval: float = 0.04
@export var pressure_into_slam_step_interval: float = 0.05
@export var slash_slam_mix_step_interval: float = 0.06
@export var pattern_end_recovery_time: float = 0.42
@export var pattern_chain_recovery_multiplier: float = 0.45
@export var pattern_abort_distance: float = 4.8

@export_group("Fast Combo Finishers")
@export var fast_combo_heavy_finish_weight: float = 82.0
@export var fast_combo_grab_finish_weight: float = 13.0
@export var fast_combo_slam_finish_weight: float = 5.0
@export var suppress_dangerous_finisher_after_dangerous_outcome: bool = true
@export var fast_combo_finisher_transition_time: float = 0.32

@export_group("Telegraph Tracking")
@export var telegraph_tracking_enabled: bool = true
@export var fast_slash_telegraph_tracking_turn_speed: float = 2.2
@export var delayed_heavy_telegraph_tracking_turn_speed: float = 0.9
@export var grab_telegraph_tracking_turn_speed: float = 1.6
@export var armor_slam_telegraph_tracking_turn_speed: float = 0.0
@export var retreat_slash_telegraph_tracking_turn_speed: float = 2.2

@export_group("Floor Telegraph Visuals")
@export_enum("FULL_DEBUG", "MINIMAL", "OFF") var floor_telegraph_visual_mode: int = TelegraphVisualMode.FULL_DEBUG
@export var floor_telegraph_toggle_enabled: bool = true
@export var floor_telegraph_toggle_action: StringName = &"toggle_floor_telegraph_mode"
@export var minimal_telegraph_color: Color = Color(0.72, 0.76, 0.78, 0.22)
@export var minimal_telegraph_emission_energy: float = 0.12
@export var minimal_telegraph_scale_multiplier: float = 1.0

@export_group("Fast Slash")
@export var fast_slash_range: float = 1.75
@export var fast_slash_radius: float = 0.92
@export var fast_slash_damage: float = 11.0
@export var fast_slash_telegraph_time: float = 0.47
@export var fast_slash_active_time: float = 0.12
@export var fast_slash_recovery_time: float = 0.34
@export var fast_slash_parryable: bool = true
@export var fast_slash_parry_stops_enemy: bool = false
@export var fast_slash_parry_grants_riposte: bool = false
@export var fast_slash_is_rhythm_deflect: bool = true
@export var fast_slash_deflect_flow_gain: float = 7.0
@export var fast_slash_parry_flow_gain: float = 0.0
@export var fast_slash_interruptible: bool = false
@export var fast_slash_interrupt_window_start: float = 0.0
@export var fast_slash_interrupt_window_end: float = 0.0
@export var fast_slash_interrupt_requires_heavy: bool = false
@export var fast_slash_interrupt_stun_duration: float = 0.62
@export var fast_slash_telegraph_color: Color = Color(0.08, 0.82, 1.0, 0.42)

@export_group("Delayed Heavy Slash")
@export var delayed_heavy_range: float = 2.1
@export var delayed_heavy_radius: float = 1.15
@export var delayed_heavy_damage: float = 24.0
@export var delayed_heavy_telegraph_time: float = 1.05
@export var delayed_heavy_active_time: float = 0.18
@export var delayed_heavy_recovery_time: float = 0.68
@export var delayed_heavy_parryable: bool = true
@export var delayed_heavy_parry_stops_enemy: bool = true
@export var delayed_heavy_parry_grants_riposte: bool = true
@export var delayed_heavy_is_rhythm_deflect: bool = false
@export var delayed_heavy_deflect_flow_gain: float = 0.0
@export var delayed_heavy_parry_flow_gain: float = 20.0
@export var delayed_heavy_interruptible: bool = true
@export var delayed_heavy_interrupt_window_start: float = 0.35
@export var delayed_heavy_interrupt_window_end: float = 1.0
@export var delayed_heavy_interrupt_requires_heavy: bool = false
@export var delayed_heavy_interrupt_stun_duration: float = 0.62
@export var delayed_heavy_telegraph_color: Color = Color(1.0, 0.34, 0.02, 0.5)

@export_group("Grab")
@export var grab_range: float = 1.35
@export var grab_radius: float = 0.82
@export var grab_damage: float = 20.0
@export var grab_telegraph_time: float = 0.7
@export var grab_active_time: float = 0.18
@export var grab_recovery_time: float = 0.56
@export var grab_parryable: bool = false
@export var grab_parry_stops_enemy: bool = false
@export var grab_parry_grants_riposte: bool = false
@export var grab_is_rhythm_deflect: bool = false
@export var grab_deflect_flow_gain: float = 0.0
@export var grab_parry_flow_gain: float = 0.0
@export var grab_interruptible: bool = false
@export var grab_interrupt_window_start: float = 0.0
@export var grab_interrupt_window_end: float = 0.0
@export var grab_interrupt_requires_heavy: bool = false
@export var grab_interrupt_stun_duration: float = 0.62
@export var grab_telegraph_color: Color = Color(0.7, 0.05, 1.0, 0.45)

@export_group("Armor Slam")
@export var armor_slam_range: float = 1.95
@export var armor_slam_radius: float = 1.38
@export var armor_slam_damage: float = 32.0
@export var armor_slam_telegraph_time: float = 1.25
@export var armor_slam_active_time: float = 0.2
@export var armor_slam_recovery_time: float = 0.92
@export var armor_slam_parryable: bool = false
@export var armor_slam_parry_stops_enemy: bool = false
@export var armor_slam_parry_grants_riposte: bool = false
@export var armor_slam_is_rhythm_deflect: bool = false
@export var armor_slam_deflect_flow_gain: float = 0.0
@export var armor_slam_parry_flow_gain: float = 0.0
@export var armor_slam_interruptible: bool = false
@export var armor_slam_interrupt_window_start: float = 0.0
@export var armor_slam_interrupt_window_end: float = 0.0
@export var armor_slam_interrupt_requires_heavy: bool = true
@export var armor_slam_interrupt_stun_duration: float = 0.62
@export var armor_slam_telegraph_color: Color = Color(1.0, 0.74, 0.08, 0.58)
@export var armor_slam_body_color: Color = Color(1.0, 0.58, 0.08, 1.0)
@export var armor_slam_body_scale: float = 1.12
@export var armor_slam_hit_vfx_scale: float = 1.35
@export var armor_slam_hit_stop_duration: float = 0.1
@export var armor_slam_camera_shake_strength: float = 0.2
@export var armor_slam_camera_shake_duration: float = 0.16
@export var armor_slam_active_pose_tween_time: float = 0.0

@export_group("Retreat Slash")
@export var retreat_slash_range: float = 1.75
@export var retreat_slash_radius: float = 0.92
@export var retreat_slash_damage: float = 11.0
@export var retreat_slash_telegraph_time: float = 0.64
@export var retreat_slash_active_time: float = 0.12
@export var retreat_slash_recovery_time: float = 0.38
@export var retreat_slash_parryable: bool = true
@export var retreat_slash_parry_stops_enemy: bool = false
@export var retreat_slash_parry_grants_riposte: bool = false
@export var retreat_slash_is_rhythm_deflect: bool = true
@export var retreat_slash_deflect_flow_gain: float = 7.0
@export var retreat_slash_parry_flow_gain: float = 0.0
@export var retreat_slash_interruptible: bool = false
@export var retreat_slash_interrupt_window_start: float = 0.0
@export var retreat_slash_interrupt_window_end: float = 0.0
@export var retreat_slash_interrupt_requires_heavy: bool = false
@export var retreat_slash_interrupt_stun_duration: float = 0.62
@export var retreat_slash_telegraph_color: Color = Color(0.08, 0.82, 1.0, 0.42)
@export var retreat_slash_retreat_distance: float = 0.42
@export var retreat_slash_retreat_duration: float = 0.3

@export_group("Interrupt")
@export var interrupt_stun_time: float = 0.62
@export var interrupt_message: String = "INTERRUPT!"
@export var interrupt_message_duration: float = 0.65
@export var interrupt_hit_stop_duration: float = 0.08
@export var interrupt_camera_shake_strength: float = 0.13
@export var interrupt_camera_shake_duration: float = 0.1

@export_group("Pose")
@export var pose_tween_time: float = 0.08
@export var telegraph_pose_progress_enabled: bool = true

@export_group("Collision")
@export_flags_3d_physics var player_collision_mask: int = 2

@export_group("Hit Stop")
@export var hit_stop_path: NodePath

@export_group("Camera Shake")
@export var camera_follow_path: NodePath

@export_group("Combo")
@export var combo_tracker_path: NodePath

@export_group("Flow")
@export var flow_tracker_path: NodePath

@export_group("UI")
@export var combat_ui_path: NodePath

@export_group("Hit VFX")
@export var hit_vfx_scene: PackedScene = preload("res://scenes/HitVfx.tscn")
@export var enemy_hit_vfx_scale: float = 1.05
@export var hit_vfx_lifetime: float = 0.22
@export var hit_vfx_vertical_offset: float = 0.85

@export_group("Debug")
@export var normal_body_color: Color = Color(1.0, 0.25, 0.2, 1.0)
@export var stunned_body_color: Color = Color(0.35, 0.75, 1.0, 1.0)

@onready var health: Health = $Health
@onready var attack_hitbox: CombatHitbox = $AttackHitbox
@onready var body_mesh: MeshInstance3D = $Body
@onready var attack_telegraph: Node3D = get_node_or_null("AttackTelegraph") as Node3D
@onready var right_arm: Node3D = get_node_or_null("AttackPoseRig/RightArm") as Node3D
@onready var left_arm: Node3D = get_node_or_null("AttackPoseRig/LeftArm") as Node3D
@onready var weapon: Node3D = get_node_or_null("AttackPoseRig/Weapon") as Node3D

var _target: Node3D
var _state: int = EnemyState.CHASE
var _state_time_remaining: float = 0.0
var _attack_cooldown_remaining: float = 0.0
var _attack_direction: Vector3 = Vector3.FORWARD
var _current_attack_type: int = AttackType.FAST_SLASH
var _current_attack_pattern: int = AttackPattern.SIMPLE_PRESSURE
var _current_attack_telegraph_elapsed: float = 0.0
var _retreat_distance_remaining: float = 0.0
var _pattern_steps: Array[int] = []
var _pattern_step_index: int = 0
var _pattern_active: bool = false
var _last_attack_pattern: int = -1
var _last_dangerous_outcome_attack_type: int = -1
var _slam_suppression_remaining: int = 0
var _recent_attack_patterns: Array[int] = []
var _last_ai_distance_band: int = DistanceBand.CLOSE
var _attack_damaged_targets: Array[Node] = []
var _just_dodged_targets: Array[Node] = []
var _ai_enabled: bool = true
var _body_material: StandardMaterial3D
var _telegraph_material: StandardMaterial3D
var _hit_stop
var _camera_follow: CameraFollow
var _combo_tracker: ComboTracker
var _flow_tracker: FlowTracker
var _combat_ui: CombatUI
var _pose_tween: Tween
var _body_base_scale: Vector3 = Vector3.ONE
var _body_base_position: Vector3 = Vector3.ZERO
var _body_base_rotation_degrees: Vector3 = Vector3.ZERO

func _ready() -> void:
	_resolve_hit_stop()
	_resolve_camera_follow()
	_resolve_combo_tracker()
	_resolve_flow_tracker()
	_resolve_combat_ui()
	_resolve_target()
	_setup_body_material()
	_setup_telegraph_material()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(false)

func _unhandled_input(event: InputEvent) -> void:
	if not floor_telegraph_toggle_enabled:
		return
	if not InputMap.has_action(floor_telegraph_toggle_action):
		return
	if event.is_action_pressed(floor_telegraph_toggle_action):
		cycle_floor_telegraph_visual_mode()

func _physics_process(delta: float) -> void:
	if not _ai_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if health.is_dead():
		_enter_dead_state()
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		if _target == null:
			return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)

	match _state:
		EnemyState.CHASE:
			_update_chase(delta)
		EnemyState.TELEGRAPH:
			_update_telegraph(delta)
		EnemyState.ACTIVE:
			_update_active_attack(delta)
		EnemyState.RECOVERY:
			_update_recovery(delta)
		EnemyState.PATTERN_GAP:
			_update_pattern_gap(delta)
		EnemyState.PATTERN_RECOVERY:
			_update_pattern_recovery(delta)
		EnemyState.STUNNED:
			_update_stunned(delta)
		EnemyState.DEAD:
			velocity = Vector3.ZERO

	velocity.y = 0.0
	move_and_slide()

func _update_chase(delta: float) -> void:
	var to_target := _get_flat_to_target()

	if to_target.length_squared() <= 0.001:
		velocity = Vector3.ZERO
		return

	var direction := to_target.normalized()
	_rotate_toward(direction, delta)

	var distance := to_target.length()
	var should_approach := distance > _get_pattern_entry_range()
	if should_approach:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if _attack_cooldown_remaining <= 0.0:
			_start_attack_pattern(distance)

func _update_telegraph(delta: float) -> void:
	_current_attack_telegraph_elapsed += delta
	_update_telegraph_tracking(delta)
	_update_telegraph_movement(delta)
	_update_telegraph_pose_progress()
	_update_attack_telegraph_transform()
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_enter_active_attack()

func _update_telegraph_tracking(delta: float) -> void:
	if not telegraph_tracking_enabled:
		return

	var turn_speed := _get_current_telegraph_tracking_turn_speed()
	if turn_speed <= 0.0:
		return

	var target_direction := _get_flat_to_target()
	if target_direction.length_squared() <= 0.001:
		return

	target_direction = target_direction.normalized()
	if _attack_direction.length_squared() <= 0.001:
		_attack_direction = target_direction
		_face_direction(_attack_direction)
		return

	var blend := clampf(1.0 - exp(-turn_speed * delta), 0.0, 1.0)
	_attack_direction = _attack_direction.lerp(target_direction, blend).normalized()
	_face_direction(_attack_direction)

func _update_telegraph_movement(delta: float) -> void:
	velocity = Vector3.ZERO
	if _current_attack_type != AttackType.RETREAT_SLASH:
		return
	if retreat_slash_retreat_duration <= 0.0 or _retreat_distance_remaining <= 0.0:
		return

	var retreat_distance := maxf(0.0, retreat_slash_retreat_distance)
	if retreat_distance <= 0.0:
		return

	var retreat_direction := -_attack_direction
	if retreat_direction.length_squared() <= 0.001:
		return

	var current_distance := _get_flat_to_target().length()
	var max_followup_distance := _get_current_attack_range() + _get_current_attack_radius() - 0.08
	var available_retreat_room := maxf(0.0, max_followup_distance - current_distance)
	if available_retreat_room <= 0.0:
		return

	var retreat_speed := retreat_distance / retreat_slash_retreat_duration
	var retreat_step := minf(_retreat_distance_remaining, retreat_speed * delta)
	retreat_step = minf(retreat_step, available_retreat_room)
	if retreat_step <= 0.0:
		return

	_retreat_distance_remaining -= retreat_step
	velocity.x = retreat_direction.x * retreat_step / maxf(delta, 0.001)
	velocity.z = retreat_direction.z * retreat_step / maxf(delta, 0.001)

func _update_active_attack(delta: float) -> void:
	velocity = Vector3.ZERO
	_strike_active_attack_targets()
	if _state != EnemyState.ACTIVE:
		return

	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_enter_recovery()

func _update_recovery(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_finish_attack_recovery()

func _update_pattern_gap(delta: float) -> void:
	velocity = Vector3.ZERO
	if not _pattern_active:
		_state = EnemyState.CHASE
		_apply_body_debug_color()
		return

	if _should_abort_pattern_for_distance():
		_abort_pattern_to_chase()
		return

	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_start_current_pattern_step()

func _update_pattern_recovery(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_clear_attack_pattern_state()
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _update_stunned(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _resolve_target() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	if _target == null:
		_target = get_tree().get_first_node_in_group(target_group) as Node3D

func _rotate_toward(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-rotation_speed * delta))

func _face_direction(direction: Vector3) -> void:
	if direction.length_squared() <= 0.001:
		return

	rotation.y = atan2(-direction.x, -direction.z)

func _start_attack_pattern(distance_to_target: float) -> void:
	_current_attack_pattern = _select_attack_pattern(distance_to_target)
	_remember_attack_pattern(_current_attack_pattern)
	_pattern_steps = _get_pattern_steps(_current_attack_pattern)
	_update_slam_suppression_from_steps(_pattern_steps)
	_remember_dangerous_outcome_from_steps(_pattern_steps)
	_pattern_step_index = 0
	_pattern_active = true

	_debug_log_selected_pattern()
	_start_current_pattern_step()

func _start_current_pattern_step() -> void:
	if not _pattern_active:
		_state = EnemyState.CHASE
		_apply_body_debug_color()
		return

	if _pattern_step_index >= _pattern_steps.size():
		_enter_pattern_recovery()
		return

	if _should_abort_pattern_for_distance():
		_abort_pattern_to_chase()
		return

	var direction := _get_flat_to_target()
	if direction.length_squared() > 0.001:
		direction = direction.normalized()
	else:
		direction = -global_transform.basis.z.normalized()

	_start_attack_step(_pattern_steps[_pattern_step_index], direction)

func _start_attack_step(attack_type: int, direction: Vector3) -> void:
	_current_attack_type = attack_type
	_attack_direction = direction.normalized()
	if _attack_direction.length_squared() <= 0.001:
		_attack_direction = -global_transform.basis.z.normalized()

	_face_direction(_attack_direction)
	_state = EnemyState.TELEGRAPH
	_state_time_remaining = maxf(0.0, _get_current_attack_telegraph_time())
	_current_attack_telegraph_elapsed = 0.0
	_retreat_distance_remaining = maxf(0.0, retreat_slash_retreat_distance) if _current_attack_type == AttackType.RETREAT_SLASH else 0.0
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_set_attack_pose(_current_attack_type, false)
	_apply_body_debug_color()
	_show_attack_telegraph()

	if debug_log_attack_types:
		print("Enemy attack: %s" % _get_attack_type_name(_current_attack_type))

	if _state_time_remaining <= 0.0:
		_enter_active_attack()

func _enter_active_attack() -> void:
	_state = EnemyState.ACTIVE
	_state_time_remaining = maxf(0.0, _get_current_attack_active_time())
	_hide_attack_telegraph()
	_set_attack_pose(_current_attack_type, true)
	_apply_body_debug_color()
	_set_attack_hitbox_enabled(true)
	_strike_active_attack_targets()

	if _state_time_remaining <= 0.0:
		_enter_recovery()

func _enter_recovery() -> void:
	_state = EnemyState.RECOVERY
	_state_time_remaining = maxf(0.0, _get_current_attack_recovery_time() * _get_current_pattern_chain_recovery_multiplier())
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()

	if _state_time_remaining <= 0.0:
		_finish_attack_recovery()

func _finish_attack_recovery() -> void:
	if _pattern_active:
		_advance_attack_pattern()
		return

	_state = EnemyState.CHASE
	_apply_body_debug_color()

func _advance_attack_pattern() -> void:
	_pattern_step_index += 1
	if _pattern_step_index >= _pattern_steps.size():
		_enter_pattern_recovery()
		return

	var next_attack_type := _pattern_steps[_pattern_step_index]
	var interval := _get_pattern_gap_before_step(next_attack_type)
	if interval <= 0.0:
		_start_current_pattern_step()
		return

	_state = EnemyState.PATTERN_GAP
	_state_time_remaining = interval
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	if _should_preview_fast_combo_finisher(next_attack_type):
		_set_fast_combo_finisher_transition_pose(next_attack_type)
	else:
		reset_attack_pose(true)
	_apply_body_debug_color()

func _get_pattern_gap_before_step(next_attack_type: int) -> float:
	if _should_preview_fast_combo_finisher(next_attack_type):
		return maxf(0.0, fast_combo_finisher_transition_time)

	return _get_current_pattern_step_interval()

func _should_preview_fast_combo_finisher(next_attack_type: int) -> bool:
	return _current_attack_pattern == AttackPattern.FAST_COMBO and _pattern_step_index == 3 and next_attack_type != AttackType.FAST_SLASH

func _set_fast_combo_finisher_transition_pose(attack_type: int) -> void:
	_current_attack_type = attack_type
	_set_attack_pose(attack_type, false)

func _get_current_pattern_chain_recovery_multiplier() -> float:
	if not _has_next_pattern_step():
		return 1.0

	return maxf(0.0, pattern_chain_recovery_multiplier)

func _has_next_pattern_step() -> bool:
	return _pattern_active and _pattern_step_index + 1 < _pattern_steps.size()

func _enter_pattern_recovery() -> void:
	_state = EnemyState.PATTERN_RECOVERY
	_state_time_remaining = maxf(0.0, pattern_end_recovery_time)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()

	if _state_time_remaining <= 0.0:
		_clear_attack_pattern_state()
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _abort_pattern_to_chase() -> void:
	_clear_attack_pattern_state()
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_state = EnemyState.CHASE
	_apply_body_debug_color()

func _strike_active_attack_targets() -> void:
	attack_hitbox.global_position = _get_current_attack_center()
	attack_hitbox.radius = _get_current_attack_radius()
	attack_hitbox.target_group = &"player"
	attack_hitbox.collision_mask = player_collision_mask
	attack_hitbox.refresh_debug_visual()

	var handled_targets: Array[Node] = []
	handled_targets.append_array(_attack_damaged_targets)
	var targets_in_hitbox := attack_hitbox.get_targets(self, handled_targets)
	var damaged: Array[Node] = []

	for target in targets_in_hitbox:
		if _get_current_attack_parryable() and target.has_method("try_parry_attack"):
			var did_parry := target.call("try_parry_attack", self) as bool
			if did_parry:
				if not _attack_damaged_targets.has(target):
					_attack_damaged_targets.append(target)
				return

		if _try_resolve_dodge_contact(target):
			continue

		var health_node := target.get_node_or_null("Health")
		if health_node != null and health_node.has_method("take_damage"):
			var did_damage := health_node.take_damage(_get_current_attack_damage()) as bool
			if did_damage:
				_attack_damaged_targets.append(target)
				damaged.append(target)
				_spawn_hit_vfx_for_target(target)
				_reset_combo_from_player_hit()
				_lose_flow_from_player_hit()

	_try_resolve_near_just_dodges(targets_in_hitbox)

	if not damaged.is_empty():
		_request_enemy_hit_stop()
		_request_enemy_camera_shake()

func _try_resolve_dodge_contact(target: Node) -> bool:
	if target == null or _just_dodged_targets.has(target):
		return false

	if target.has_method("try_just_dodge_attack"):
		var did_just_dodge := target.call("try_just_dodge_attack", self, _get_current_attack_center()) as bool
		if did_just_dodge:
			_just_dodged_targets.append(target)
			_attack_damaged_targets.append(target)
			return true

	if target.has_method("is_dodge_invulnerable"):
		var is_invulnerable := target.call("is_dodge_invulnerable") as bool
		if is_invulnerable:
			_attack_damaged_targets.append(target)
			return true

	return false

func _try_resolve_near_just_dodges(excluded_targets: Array[Node]) -> void:
	var margin := _get_target_just_dodge_detection_margin()
	if margin <= 0.0:
		return

	var previous_radius := attack_hitbox.radius
	attack_hitbox.radius = _get_current_attack_radius() + margin
	var ignored_targets: Array[Node] = []
	ignored_targets.append_array(_attack_damaged_targets)
	for target in excluded_targets:
		if not ignored_targets.has(target):
			ignored_targets.append(target)

	for target in attack_hitbox.get_targets(self, ignored_targets):
		if _just_dodged_targets.has(target):
			continue
		if target.has_method("try_just_dodge_attack"):
			var did_just_dodge := target.call("try_just_dodge_attack", self, _get_current_attack_center()) as bool
			if did_just_dodge:
				_just_dodged_targets.append(target)
				_attack_damaged_targets.append(target)

	attack_hitbox.radius = previous_radius
	attack_hitbox.refresh_debug_visual()

func _get_target_just_dodge_detection_margin() -> float:
	if _target != null and is_instance_valid(_target):
		var margin = _target.get("just_dodge_detection_margin")
		if margin is float or margin is int:
			return maxf(0.0, float(margin))

	return 0.0

func _get_current_attack_center() -> Vector3:
	return global_position + _attack_direction * _get_current_attack_range()

func receive_player_attack_hit(_attack_name: StringName, _attacker: Node) -> bool:
	if _state != EnemyState.TELEGRAPH:
		return false

	if not _can_current_attack_be_interrupted(_attack_name):
		return false

	_interrupt_current_attack(_get_current_attack_interrupt_stun_duration())
	_add_flow_from_interrupt()
	interrupt_succeeded.emit()
	return true

func _interrupt_current_attack(stun_duration: float) -> void:
	_state = EnemyState.STUNNED
	_state_time_remaining = maxf(0.0, stun_duration)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	velocity = Vector3.ZERO
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()
	_show_interrupt_message()
	_request_interrupt_hit_stop()
	_request_interrupt_camera_shake()

	if debug_log_attack_types:
		print("Enemy attack interrupted: %s" % _get_attack_type_name(_current_attack_type))

	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _resolve_combo_tracker() -> void:
	if combo_tracker_path != NodePath(""):
		_combo_tracker = get_node_or_null(combo_tracker_path) as ComboTracker

	if _combo_tracker == null:
		_combo_tracker = get_tree().get_first_node_in_group(&"combo_tracker") as ComboTracker

func _resolve_flow_tracker() -> void:
	if flow_tracker_path != NodePath(""):
		_flow_tracker = get_node_or_null(flow_tracker_path) as FlowTracker

	if _flow_tracker == null:
		_flow_tracker = get_tree().get_first_node_in_group(&"flow_tracker") as FlowTracker

func _reset_combo_from_player_hit() -> void:
	if _combo_tracker == null or not is_instance_valid(_combo_tracker):
		_resolve_combo_tracker()

	if _combo_tracker != null:
		_combo_tracker.reset_combo()

func _lose_flow_from_player_hit() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		_flow_tracker.lose_damage_taken_flow()

func _add_flow_from_interrupt() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		_flow_tracker.add_interrupt_flow()

func _spawn_hit_vfx_for_target(target: Node) -> void:
	if hit_vfx_scene == null:
		return

	var target_3d := target as Node3D
	if target_3d == null:
		return

	var hit_vfx := hit_vfx_scene.instantiate() as HitVfx
	if hit_vfx == null:
		return

	var vfx_scale := armor_slam_hit_vfx_scale if _current_attack_type == AttackType.ARMOR_SLAM else enemy_hit_vfx_scale
	hit_vfx.configure(HitVfx.HitKind.ENEMY, vfx_scale, hit_vfx_lifetime)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent == null:
		hit_vfx.queue_free()
		return

	parent.add_child(hit_vfx)
	hit_vfx.global_position = target_3d.global_position + Vector3.UP * hit_vfx_vertical_offset

func _show_attack_telegraph() -> void:
	if attack_telegraph == null:
		return

	if floor_telegraph_visual_mode == TelegraphVisualMode.OFF:
		attack_telegraph.visible = false
		return

	_update_attack_telegraph_transform()
	attack_telegraph.visible = true
	_apply_telegraph_color()

func _update_attack_telegraph_transform() -> void:
	if attack_telegraph == null:
		return

	var telegraph_position := global_position + _attack_direction * _get_current_attack_range()
	telegraph_position.y = global_position.y + 0.03
	attack_telegraph.global_position = telegraph_position
	attack_telegraph.global_rotation.y = rotation.y
	attack_telegraph.scale = _get_current_telegraph_scale()


func _hide_attack_telegraph() -> void:
	if attack_telegraph != null:
		attack_telegraph.visible = false


func _set_attack_hitbox_enabled(value: bool) -> void:
	if attack_hitbox == null:
		return

	attack_hitbox.set_enabled(value)

func _resolve_hit_stop() -> void:
	if hit_stop_path != NodePath(""):
		_hit_stop = get_node_or_null(hit_stop_path)

	if _hit_stop == null:
		_hit_stop = get_tree().get_first_node_in_group(&"hit_stop")

func _request_enemy_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	if _current_attack_type == AttackType.ARMOR_SLAM:
		_hit_stop.request_hit_stop(armor_slam_hit_stop_duration)
	else:
		_hit_stop.request_enemy_attack_hit_stop()

func _request_interrupt_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	_hit_stop.request_hit_stop(interrupt_hit_stop_duration)

func _resolve_camera_follow() -> void:
	if camera_follow_path != NodePath(""):
		_camera_follow = get_node_or_null(camera_follow_path) as CameraFollow

	if _camera_follow == null:
		_camera_follow = get_viewport().get_camera_3d() as CameraFollow

func _request_enemy_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	if _current_attack_type == AttackType.ARMOR_SLAM:
		_camera_follow.request_shake(armor_slam_camera_shake_strength, armor_slam_camera_shake_duration)
	else:
		_camera_follow.request_enemy_attack_shake()

func _request_interrupt_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	_camera_follow.request_shake(interrupt_camera_shake_strength, interrupt_camera_shake_duration)

func _resolve_combat_ui() -> void:
	if combat_ui_path != NodePath(""):
		_combat_ui = get_node_or_null(combat_ui_path) as CombatUI

	if _combat_ui == null:
		_combat_ui = get_tree().get_first_node_in_group(&"combat_ui") as CombatUI

func _show_interrupt_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(interrupt_message, interrupt_message_duration)

func receive_just_dodge_counter_stun(stun_time: float) -> void:
	receive_parry_stun(stun_time)

func get_current_parry_response() -> Dictionary:
	return {
		"parryable": _get_current_attack_parryable(),
		"parry_stops_enemy": _get_current_attack_parry_stops_enemy(),
		"parry_grants_riposte": _get_current_attack_parry_grants_riposte(),
		"is_rhythm_deflect": _get_current_attack_is_rhythm_deflect(),
		"deflect_flow_gain": _get_current_attack_deflect_flow_gain(),
		"parry_flow_gain": _get_current_attack_parry_flow_gain(),
		"attack_type": _get_attack_type_name(_current_attack_type)
	}

func receive_parry_stun(stun_time: float) -> void:
	if health.is_dead():
		return

	_state = EnemyState.STUNNED
	_state_time_remaining = maxf(0.0, stun_time)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	velocity = Vector3.ZERO
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()

	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _enter_dead_state() -> void:
	if _state == EnemyState.DEAD:
		return

	_state = EnemyState.DEAD
	_state_time_remaining = 0.0
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(false)
	_apply_body_debug_color()

func _select_attack_pattern(distance_to_target: float) -> int:
	_last_ai_distance_band = _get_distance_band(distance_to_target)
	var anti_parry_active := _get_target_parry_stock() >= anti_parry_stock_threshold
	var anti_aggression_active := _is_target_attack_aggressive()
	var options: Array[Dictionary] = []

	_append_pattern_option(options, AttackPattern.FAST_COMBO, distance_to_target, anti_parry_active, anti_aggression_active)
	_append_pattern_option(options, AttackPattern.GRAB_MIX, distance_to_target, anti_parry_active, anti_aggression_active)
	_append_pattern_option(options, AttackPattern.SIMPLE_PRESSURE, distance_to_target, anti_parry_active, anti_aggression_active)
	_append_pattern_option(options, AttackPattern.PRESSURE_INTO_SLAM, distance_to_target, anti_parry_active, anti_aggression_active)
	_append_pattern_option(options, AttackPattern.SLASH_SLAM_MIX, distance_to_target, anti_parry_active, anti_aggression_active)
	_append_pattern_option(options, AttackPattern.RETREAT_PRESSURE, distance_to_target, anti_parry_active, anti_aggression_active)

	if options.is_empty():
		return _get_fallback_pattern_for_distance_band(_last_ai_distance_band)

	options = _avoid_last_attack_pattern_if_possible(options)
	return _pick_weighted_pattern(options)

func _append_pattern_option(options: Array[Dictionary], pattern: int, distance_to_target: float, anti_parry_active: bool, anti_aggression_active: bool) -> void:
	if not _is_pattern_valid_for_distance_band(pattern, _last_ai_distance_band):
		return

	var weight := _get_pattern_distance_weight(pattern, _last_ai_distance_band)
	if weight <= 0.0:
		return

	var first_attack := _get_pattern_first_attack(pattern)
	if distance_to_target > _get_attack_start_range_for_type(first_attack) + 0.05:
		return

	weight = _apply_pattern_weight_modifiers(pattern, weight, anti_parry_active, anti_aggression_active)
	if weight <= 0.0:
		return

	options.append({ "pattern": pattern, "weight": weight })

func _pick_weighted_pattern(options: Array[Dictionary]) -> int:
	var total_weight := 0.0
	for option in options:
		total_weight += option["weight"] as float

	if total_weight <= 0.0:
		return options[0]["pattern"] as int

	var roll := randf() * total_weight
	for option in options:
		roll -= option["weight"] as float
		if roll <= 0.0:
			return option["pattern"] as int

	return options.back()["pattern"] as int

func _avoid_last_attack_pattern_if_possible(options: Array[Dictionary]) -> Array[Dictionary]:
	if options.size() <= 1 or _last_attack_pattern < 0:
		return options

	var avoid_chance := clampf(repeat_pattern_avoid_chance, 0.0, 1.0)
	if avoid_chance <= 0.0 or randf() >= avoid_chance:
		return options

	var filtered_options: Array[Dictionary] = []
	for option in options:
		if (option["pattern"] as int) != _last_attack_pattern:
			filtered_options.append(option)

	return filtered_options if not filtered_options.is_empty() else options

func _is_pattern_valid_for_distance_band(pattern: int, distance_band: int) -> bool:
	match distance_band:
		DistanceBand.CLOSE:
			match pattern:
				AttackPattern.FAST_COMBO, AttackPattern.GRAB_MIX, AttackPattern.SIMPLE_PRESSURE, AttackPattern.SLASH_SLAM_MIX, AttackPattern.RETREAT_PRESSURE:
					return true
		DistanceBand.MID:
			match pattern:
				AttackPattern.SIMPLE_PRESSURE, AttackPattern.PRESSURE_INTO_SLAM, AttackPattern.SLASH_SLAM_MIX, AttackPattern.RETREAT_PRESSURE:
					return true
		DistanceBand.FAR:
			match pattern:
				AttackPattern.SIMPLE_PRESSURE, AttackPattern.PRESSURE_INTO_SLAM, AttackPattern.SLASH_SLAM_MIX:
					return true

	return false

func _get_fallback_pattern_for_distance_band(distance_band: int) -> int:
	return AttackPattern.SIMPLE_PRESSURE

func _get_pattern_distance_weight(pattern: int, distance_band: int) -> float:
	var base_weight := _get_pattern_base_weight(pattern)
	match distance_band:
		DistanceBand.CLOSE:
			match pattern:
				AttackPattern.FAST_COMBO:
					return base_weight * 1.15
				AttackPattern.GRAB_MIX:
					return base_weight * 1.25
				AttackPattern.SIMPLE_PRESSURE:
					return base_weight * 1.25
				AttackPattern.SLASH_SLAM_MIX:
					return base_weight * 0.75
				AttackPattern.RETREAT_PRESSURE:
					return base_weight * 0.9
				AttackPattern.PRESSURE_INTO_SLAM:
					return base_weight * 0.65

		DistanceBand.MID:
			match pattern:
				AttackPattern.RETREAT_PRESSURE:
					return base_weight
				AttackPattern.PRESSURE_INTO_SLAM:
					return base_weight * 0.9
				AttackPattern.SLASH_SLAM_MIX:
					return base_weight * 0.75

				AttackPattern.SIMPLE_PRESSURE:
					return base_weight * 0.8
				AttackPattern.FAST_COMBO:
					return base_weight * 0.65
				AttackPattern.GRAB_MIX:
					return base_weight * 0.45
		DistanceBand.FAR:
			match pattern:
				AttackPattern.SIMPLE_PRESSURE:
					return base_weight * 0.7
				AttackPattern.PRESSURE_INTO_SLAM:
					return base_weight * 0.35
				AttackPattern.SLASH_SLAM_MIX:
					return base_weight * 0.25
				AttackPattern.RETREAT_PRESSURE:
					return 0.0
				_:
					return 0.0

	return base_weight

func _get_pattern_base_weight(pattern: int) -> float:
	match pattern:
		AttackPattern.FAST_COMBO:
			return fast_combo_weight
		AttackPattern.GRAB_MIX:
			return grab_mix_weight

		AttackPattern.PRESSURE_INTO_SLAM:
			return pressure_into_slam_weight

		AttackPattern.SLASH_SLAM_MIX:
			return slash_slam_mix_weight
		AttackPattern.RETREAT_PRESSURE:
			return retreat_pressure_weight
		_:
			return simple_pressure_weight

func _apply_pattern_weight_modifiers(pattern: int, weight: float, anti_parry_active: bool, anti_aggression_active: bool) -> float:
	var modified_weight := weight * _get_pattern_memory_multiplier(pattern)

	if anti_parry_active:
		match pattern:
			AttackPattern.GRAB_MIX:
				modified_weight *= anti_parry_grab_weight_bonus
			AttackPattern.PRESSURE_INTO_SLAM, AttackPattern.SLASH_SLAM_MIX:
				modified_weight *= anti_parry_armor_weight_bonus

	if anti_aggression_active:
		match pattern:
			AttackPattern.FAST_COMBO, AttackPattern.SIMPLE_PRESSURE:
				modified_weight *= anti_aggression_weight_bonus

	if _is_target_blood_scent_active():
		match pattern:
			AttackPattern.FAST_COMBO, AttackPattern.SIMPLE_PRESSURE:
				modified_weight *= blood_scent_pressure_weight_bonus

	if _should_suppress_dangerous_outcome() and _is_dangerous_attack_pattern(pattern):
		modified_weight *= maxf(0.0, dangerous_outcome_repeat_weight_multiplier)

	if _should_suppress_slam_outcome() and _is_slam_attack_pattern(pattern):
		modified_weight *= _get_slam_suppression_multiplier()

	return modified_weight

func _get_pattern_memory_multiplier(pattern: int) -> float:
	var multiplier := 1.0
	var repeat_multiplier := maxf(0.0, repeat_pattern_weight_multiplier)
	for recent_pattern in _recent_attack_patterns:
		if recent_pattern == pattern:
			multiplier *= repeat_multiplier

	return multiplier

func _remember_attack_pattern(pattern: int) -> void:
	_last_attack_pattern = pattern
	if recent_pattern_memory_count <= 0:
		_recent_attack_patterns.clear()
		return

	_recent_attack_patterns.push_front(pattern)
	while _recent_attack_patterns.size() > recent_pattern_memory_count:
		_recent_attack_patterns.pop_back()

func _get_distance_band(distance_to_target: float) -> int:
	if distance_to_target <= _get_close_range_limit():
		return DistanceBand.CLOSE
	if distance_to_target <= _get_mid_range_limit():
		return DistanceBand.MID

	return DistanceBand.FAR

func _get_close_range_limit() -> float:
	return maxf(0.0, close_range_distance)

func _get_mid_range_limit() -> float:
	return maxf(_get_close_range_limit(), mid_range_distance)

func _get_far_range_limit() -> float:
	return maxf(_get_mid_range_limit(), far_range_distance)

func _get_pattern_entry_range() -> float:
	return minf(_get_multi_attack_pattern_entry_range(), _get_far_range_limit())

func _get_multi_attack_pattern_entry_range() -> float:
	return _get_attack_start_range_for_type(AttackType.FAST_SLASH)

func _get_distance_band_name(distance_band: int) -> String:
	match distance_band:
		DistanceBand.CLOSE:
			return "close"
		DistanceBand.MID:
			return "mid"
		_:
			return "far"

func _get_target_parry_stock() -> int:
	if _target == null or not is_instance_valid(_target):
		return 0

	if _target.has_method("get_parry_stock"):
		return int(_target.call("get_parry_stock"))

	var stock = _target.get("parry_stock")
	if stock is int or stock is float:
		return int(stock)

	return 0

func _is_target_attack_aggressive() -> bool:
	if aggression_check_window <= 0.0 or aggression_attack_count_threshold <= 0:
		return false
	if _target == null or not is_instance_valid(_target) or not _target.has_method("get_recent_attack_count"):
		return false

	var attack_count := int(_target.call("get_recent_attack_count", aggression_check_window))
	return attack_count >= aggression_attack_count_threshold

func _is_target_blood_scent_active() -> bool:
	if _target == null or not is_instance_valid(_target) or not _target.has_method("is_blood_scent_active"):
		return false

	return bool(_target.call("is_blood_scent_active"))

func _debug_log_selected_pattern() -> void:
	if not debug_log_attack_patterns and not show_ai_debug_text:
		return

	var tags: Array[String] = []
	if _get_target_parry_stock() >= anti_parry_stock_threshold:
		tags.append("anti-parry")
	if _is_target_attack_aggressive():
		tags.append("anti-aggression")
	if _is_target_blood_scent_active():
		tags.append("blood-scent")

	var context := ""
	if not tags.is_empty():
		var tag_text := tags[0]
		for index in range(1, tags.size()):
			tag_text += ", " + tags[index]
		context = " / %s" % tag_text

	print("AI: %s / %s%s" % [_get_distance_band_name(_last_ai_distance_band), _get_attack_pattern_name(_current_attack_pattern), context])

func _get_pattern_steps(pattern: int) -> Array[int]:
	var steps: Array[int] = []
	match pattern:
		AttackPattern.FAST_COMBO:
			# Keep the existing three-hit Deflect rhythm, then branch into a readable finisher.
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
			steps.append(_get_fast_combo_finisher_attack_type())
		AttackPattern.GRAB_MIX:
			# Early parry-habit punishment: short fast slash into grab.
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.GRAB)

		AttackPattern.PRESSURE_INTO_SLAM:
			# Short pressure into armor punishment; keep separate from Fast Combo finishers.
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.ARMOR_SLAM)

		AttackPattern.SLASH_SLAM_MIX:
			# Compact anti-mash / anti-blind-parry route; weight remains tunable.
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.ARMOR_SLAM)
		AttackPattern.RETREAT_PRESSURE:
			# Wait/read check: a visible pull-away feint into a fast Deflect slash.
			steps.append(AttackType.RETREAT_SLASH)
		_:
			# Simple Pressure stays intentionally short.
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
	return steps

func _get_fast_combo_finisher_attack_type() -> int:
	match _select_fast_combo_finisher():
		FastComboFinisher.GRAB_FINISH:
			return AttackType.GRAB
		FastComboFinisher.SLAM_FINISH:
			return AttackType.ARMOR_SLAM
		_:
			return AttackType.DELAYED_HEAVY

func _select_fast_combo_finisher() -> int:
	if _should_force_safe_fast_combo_finisher():
		return FastComboFinisher.HEAVY_FINISH

	var options: Array[Dictionary] = []
	_append_fast_combo_finisher_option(options, FastComboFinisher.HEAVY_FINISH, fast_combo_heavy_finish_weight)
	_append_fast_combo_finisher_option(options, FastComboFinisher.GRAB_FINISH, fast_combo_grab_finish_weight)
	_append_fast_combo_finisher_option(options, FastComboFinisher.SLAM_FINISH, fast_combo_slam_finish_weight)

	if options.is_empty():
		return FastComboFinisher.HEAVY_FINISH

	return _pick_weighted_fast_combo_finisher(options)

func _append_fast_combo_finisher_option(options: Array[Dictionary], finisher: int, weight: float) -> void:
	var adjusted_weight := weight
	if finisher == FastComboFinisher.SLAM_FINISH and _should_suppress_slam_outcome():
		adjusted_weight *= _get_slam_suppression_multiplier()
	if adjusted_weight <= 0.0:
		return

	options.append({ "finisher": finisher, "weight": adjusted_weight })

func _pick_weighted_fast_combo_finisher(options: Array[Dictionary]) -> int:
	var total_weight := 0.0
	for option in options:
		total_weight += option["weight"] as float

	if total_weight <= 0.0:
		return FastComboFinisher.HEAVY_FINISH

	var roll := randf() * total_weight
	for option in options:
		roll -= option["weight"] as float
		if roll <= 0.0:
			return option["finisher"] as int

	return options.back()["finisher"] as int

func _should_force_safe_fast_combo_finisher() -> bool:
	return suppress_dangerous_finisher_after_dangerous_outcome and _should_suppress_dangerous_outcome()

func _should_suppress_dangerous_outcome() -> bool:
	return _is_dangerous_attack_type(_last_dangerous_outcome_attack_type)

func _is_dangerous_attack_pattern(pattern: int) -> bool:
	match pattern:
		AttackPattern.GRAB_MIX, AttackPattern.PRESSURE_INTO_SLAM, AttackPattern.SLASH_SLAM_MIX:
			return true
		_:
			return false

func _is_slam_attack_pattern(pattern: int) -> bool:
	match pattern:
		AttackPattern.PRESSURE_INTO_SLAM, AttackPattern.SLASH_SLAM_MIX:
			return true
		_:
			return false

func _update_slam_suppression_from_steps(steps: Array[int]) -> void:
	if _steps_include_slam(steps):
		_slam_suppression_remaining = maxi(0, slam_suppression_count)
	elif _slam_suppression_remaining > 0:
		_slam_suppression_remaining -= 1

func _should_suppress_slam_outcome() -> bool:
	return _slam_suppression_remaining > 0 and _get_slam_suppression_multiplier() < 1.0

func _get_slam_suppression_multiplier() -> float:
	return clampf(slam_suppression_multiplier, 0.0, 1.0)

func _steps_include_slam(steps: Array[int]) -> bool:
	for step in steps:
		if step == AttackType.ARMOR_SLAM:
			return true

	return false

func _remember_dangerous_outcome_from_steps(steps: Array[int]) -> void:
	_last_dangerous_outcome_attack_type = -1
	for step in steps:
		if _is_dangerous_attack_type(step):
			_last_dangerous_outcome_attack_type = step
			return

func _is_dangerous_attack_type(attack_type: int) -> bool:
	return attack_type == AttackType.GRAB or attack_type == AttackType.ARMOR_SLAM

func _get_pattern_first_attack(pattern: int) -> int:
	if pattern == AttackPattern.RETREAT_PRESSURE:
		return AttackType.RETREAT_SLASH

	return AttackType.FAST_SLASH

func _get_current_pattern_step_interval() -> float:
	match _current_attack_pattern:
		AttackPattern.FAST_COMBO:
			return fast_combo_step_interval
		AttackPattern.GRAB_MIX:
			return grab_mix_step_interval

		AttackPattern.PRESSURE_INTO_SLAM:
			return pressure_into_slam_step_interval

		AttackPattern.SLASH_SLAM_MIX:
			return slash_slam_mix_step_interval
		_:
			return simple_pressure_step_interval

func _get_attack_pattern_name(pattern: int) -> String:
	match pattern:
		AttackPattern.FAST_COMBO:
			return "Fast Combo"
		AttackPattern.GRAB_MIX:
			return "Grab Mix"

		AttackPattern.PRESSURE_INTO_SLAM:
			return "Pressure into Slam"

		AttackPattern.SLASH_SLAM_MIX:
			return "Slash Slam Mix"
		AttackPattern.RETREAT_PRESSURE:
			return "Retreat Pressure"
		_:
			return "Simple Pressure"

func _should_abort_pattern_for_distance() -> bool:
	if not _pattern_active or pattern_abort_distance <= 0.0:
		return false

	var to_target := _get_flat_to_target()
	if to_target.length_squared() <= 0.001:
		return false

	return to_target.length() > pattern_abort_distance

func _clear_attack_pattern_state() -> void:
	_pattern_active = false
	_pattern_step_index = 0
	_pattern_steps.clear()


func _get_attack_start_range_for_type(attack_type: int) -> float:
	if attack_type == AttackType.RETREAT_SLASH:
		return maxf(0.1, _get_attack_range(attack_type) + _get_attack_radius(attack_type) - maxf(0.0, retreat_slash_retreat_distance) - 0.15)

	return _get_attack_range(attack_type) + _get_attack_radius(attack_type)

func _get_current_attack_range() -> float:
	return _get_attack_range(_current_attack_type)

func _get_current_attack_radius() -> float:
	return _get_attack_radius(_current_attack_type)

func _get_current_attack_damage() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_damage
		AttackType.RETREAT_SLASH:
			return retreat_slash_damage
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_damage
		AttackType.GRAB:
			return grab_damage
		_:
			return fast_slash_damage

func _get_current_attack_telegraph_time() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_telegraph_time
		AttackType.RETREAT_SLASH:
			return retreat_slash_telegraph_time
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_telegraph_time
		AttackType.GRAB:
			return grab_telegraph_time
		_:
			return fast_slash_telegraph_time

func _get_current_attack_active_time() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_active_time
		AttackType.RETREAT_SLASH:
			return retreat_slash_active_time
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_active_time
		AttackType.GRAB:
			return grab_active_time
		_:
			return fast_slash_active_time

func _get_current_attack_recovery_time() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_recovery_time
		AttackType.RETREAT_SLASH:
			return retreat_slash_recovery_time
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_recovery_time
		AttackType.GRAB:
			return grab_recovery_time
		_:
			return fast_slash_recovery_time

func _get_current_attack_parryable() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_parryable
		AttackType.RETREAT_SLASH:
			return retreat_slash_parryable
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_parryable
		AttackType.GRAB:
			return grab_parryable
		_:
			return fast_slash_parryable

func _get_current_attack_parry_stops_enemy() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_parry_stops_enemy
		AttackType.RETREAT_SLASH:
			return retreat_slash_parry_stops_enemy
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_parry_stops_enemy
		AttackType.GRAB:
			return grab_parry_stops_enemy
		_:
			return fast_slash_parry_stops_enemy

func _get_current_attack_parry_grants_riposte() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_parry_grants_riposte
		AttackType.RETREAT_SLASH:
			return retreat_slash_parry_grants_riposte
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_parry_grants_riposte
		AttackType.GRAB:
			return grab_parry_grants_riposte
		_:
			return fast_slash_parry_grants_riposte

func _get_current_attack_is_rhythm_deflect() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_is_rhythm_deflect
		AttackType.RETREAT_SLASH:
			return retreat_slash_is_rhythm_deflect
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_is_rhythm_deflect
		AttackType.GRAB:
			return grab_is_rhythm_deflect
		_:
			return fast_slash_is_rhythm_deflect

func _get_current_attack_deflect_flow_gain() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_deflect_flow_gain
		AttackType.RETREAT_SLASH:
			return retreat_slash_deflect_flow_gain
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_deflect_flow_gain
		AttackType.GRAB:
			return grab_deflect_flow_gain
		_:
			return fast_slash_deflect_flow_gain

func _get_current_attack_parry_flow_gain() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_parry_flow_gain
		AttackType.RETREAT_SLASH:
			return retreat_slash_parry_flow_gain
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_parry_flow_gain
		AttackType.GRAB:
			return grab_parry_flow_gain
		_:
			return fast_slash_parry_flow_gain

func _get_current_attack_interruptible() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interruptible
		AttackType.RETREAT_SLASH:
			return retreat_slash_interruptible
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interruptible
		AttackType.GRAB:
			return grab_interruptible
		_:
			return fast_slash_interruptible

func _get_attack_range(attack_type: int) -> float:
	match attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_range
		AttackType.RETREAT_SLASH:
			return retreat_slash_range
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_range
		AttackType.GRAB:
			return grab_range
		_:
			return fast_slash_range

func _get_attack_radius(attack_type: int) -> float:
	match attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_radius
		AttackType.RETREAT_SLASH:
			return retreat_slash_radius
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_radius
		AttackType.GRAB:
			return grab_radius
		_:
			return fast_slash_radius

func _get_current_telegraph_scale() -> Vector3:
	var scale := Vector3.ONE
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			scale = Vector3(armor_slam_radius * 1.22, 1.0, armor_slam_radius * 1.22)
		AttackType.RETREAT_SLASH:
			scale = Vector3(retreat_slash_radius * 0.9, 1.0, retreat_slash_radius * 0.72)
		AttackType.DELAYED_HEAVY:
			scale = Vector3(delayed_heavy_radius * 1.15, 1.0, delayed_heavy_radius * 1.15)
		AttackType.GRAB:
			scale = Vector3(grab_radius * 0.82, 1.0, grab_radius * 1.35)
		_:
			scale = Vector3(fast_slash_radius, 1.0, fast_slash_radius * 0.9)

	if floor_telegraph_visual_mode == TelegraphVisualMode.MINIMAL:
		var multiplier := maxf(0.0, minimal_telegraph_scale_multiplier)
		scale.x *= multiplier
		scale.z *= multiplier

	return scale


func _get_current_attack_telegraph_color() -> Color:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_telegraph_color
		AttackType.RETREAT_SLASH:
			return retreat_slash_telegraph_color
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_telegraph_color
		AttackType.GRAB:
			return grab_telegraph_color
		_:
			return fast_slash_telegraph_color

func _get_current_telegraph_tracking_turn_speed() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_telegraph_tracking_turn_speed
		AttackType.RETREAT_SLASH:
			return retreat_slash_telegraph_tracking_turn_speed
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_telegraph_tracking_turn_speed
		AttackType.GRAB:
			return grab_telegraph_tracking_turn_speed
		_:
			return fast_slash_telegraph_tracking_turn_speed

func _get_attack_pose_tween_time(attack_type: int, is_active: bool) -> float:
	if attack_type == AttackType.ARMOR_SLAM and is_active:
		return maxf(0.0, armor_slam_active_pose_tween_time)

	return pose_tween_time

func _get_attack_type_name(attack_type: int) -> String:
	match attack_type:
		AttackType.ARMOR_SLAM:
			return "Armor Slam"
		AttackType.RETREAT_SLASH:
			return "Retreat Slash"
		AttackType.DELAYED_HEAVY:
			return "Delayed Heavy Slash"
		AttackType.GRAB:
			return "Grab"
		_:
			return "Fast Slash"

func _get_flat_to_target() -> Vector3:
	if _target == null:
		return Vector3.ZERO

	var to_target := _target.global_position - global_position
	to_target.y = 0.0
	return to_target

func _setup_body_material() -> void:
	if body_mesh == null:
		return

	_body_base_scale = body_mesh.scale
	_body_base_position = body_mesh.position
	_body_base_rotation_degrees = body_mesh.rotation_degrees
	var material := body_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		_body_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		body_mesh.set_surface_override_material(0, _body_material)

	_apply_body_debug_color()

func _setup_telegraph_material() -> void:
	var telegraph_mesh := attack_telegraph as MeshInstance3D
	if telegraph_mesh == null:
		return

	var material := telegraph_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		_telegraph_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		telegraph_mesh.set_surface_override_material(0, _telegraph_material)

func _apply_telegraph_color() -> void:
	if _telegraph_material == null:
		return

	var color := _get_current_attack_telegraph_color()
	var emission_energy := 0.4
	if floor_telegraph_visual_mode == TelegraphVisualMode.MINIMAL:
		color = minimal_telegraph_color
		emission_energy = maxf(0.0, minimal_telegraph_emission_energy)
	elif _current_attack_type == AttackType.ARMOR_SLAM:
		emission_energy = 0.85
	elif _current_attack_type == AttackType.DELAYED_HEAVY:
		emission_energy = 0.65

	_telegraph_material.albedo_color = color
	_telegraph_material.emission = Color(color.r, color.g, color.b, 1.0)
	_telegraph_material.emission_energy_multiplier = emission_energy

func _apply_body_debug_color() -> void:
	if _body_material == null:
		return

	if _state == EnemyState.STUNNED:
		_body_material.albedo_color = stunned_body_color
		_body_material.emission_enabled = true
		_body_material.emission = Color(stunned_body_color.r, stunned_body_color.g, stunned_body_color.b, 1.0)
		_body_material.emission_energy_multiplier = 0.18
	elif _current_attack_type == AttackType.ARMOR_SLAM and (_state == EnemyState.TELEGRAPH or _state == EnemyState.ACTIVE or _is_fast_combo_finisher_transition_active()):
		_body_material.albedo_color = armor_slam_body_color
		_body_material.emission_enabled = true
		_body_material.emission = Color(armor_slam_body_color.r, armor_slam_body_color.g, armor_slam_body_color.b, 1.0)
		_body_material.emission_energy_multiplier = 0.42
	else:
		_body_material.albedo_color = normal_body_color
		_body_material.emission_enabled = false
		_body_material.emission_energy_multiplier = 0.0

func _is_fast_combo_finisher_transition_active() -> bool:
	return _state == EnemyState.PATTERN_GAP and _pattern_active and _current_attack_pattern == AttackPattern.FAST_COMBO and _pattern_step_index == 3

func _can_current_attack_be_interrupted(attack_name: StringName) -> bool:
	if not _get_current_attack_interruptible():
		return false
	if _get_current_attack_interrupt_requires_heavy() and attack_name != &"heavy":
		return false

	var window_start := _get_current_attack_interrupt_window_start()
	var window_end := _get_current_attack_interrupt_window_end()
	if window_end <= 0.0:
		window_end = _get_current_attack_telegraph_time()

	return _current_attack_telegraph_elapsed >= window_start and _current_attack_telegraph_elapsed <= window_end

func _get_current_attack_interrupt_window_start() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_window_start
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_window_start
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_window_start
		AttackType.GRAB:
			return grab_interrupt_window_start
		_:
			return fast_slash_interrupt_window_start

func _get_current_attack_interrupt_window_end() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_window_end
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_window_end
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_window_end
		AttackType.GRAB:
			return grab_interrupt_window_end
		_:
			return fast_slash_interrupt_window_end

func _get_current_attack_interrupt_requires_heavy() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_requires_heavy
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_requires_heavy
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_requires_heavy
		AttackType.GRAB:
			return grab_interrupt_requires_heavy
		_:
			return fast_slash_interrupt_requires_heavy

func _get_current_attack_interrupt_stun_duration() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_stun_duration
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_stun_duration
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_stun_duration
		AttackType.GRAB:
			return grab_interrupt_stun_duration
		_:
			return fast_slash_interrupt_stun_duration

func _set_attack_pose(attack_type: int, is_active: bool) -> void:
	var duration := _get_attack_pose_tween_time(attack_type, is_active)
	_begin_pose_change(duration)
	_apply_body_visual_pose(attack_type, is_active, duration)

	match attack_type:
		AttackType.ARMOR_SLAM:
			if is_active:
				_apply_pose_values(Vector3(0.34, 0.88, -0.64), Vector3(88, 0, -22), Vector3(-0.34, 0.88, -0.62), Vector3(88, 0, 22), Vector3(0.0, 0.62, -0.82), Vector3(104, 0, 0), true, duration)
			else:
				_apply_pose_values(Vector3(0.48, 1.92, 0.12), Vector3(-98, -12, -30), Vector3(-0.44, 1.76, 0.08), Vector3(-88, 12, 28), Vector3(0.18, 2.26, 0.22), Vector3(-104, 0, -12), true, duration)
		AttackType.RETREAT_SLASH:
			if is_active:
				_apply_pose_values(Vector3(0.28, 1.0, -0.56), Vector3(56, 58, -22), Vector3(-0.44, 0.98, -0.16), Vector3(20, 0, 14), Vector3(0.06, 0.98, -1.0), Vector3(84, 78, -12), true, duration)
			else:
				_apply_pose_values(Vector3(0.64, 1.08, 0.34), Vector3(-18, -86, -14), Vector3(-0.5, 1.02, 0.02), Vector3(14, 0, 20), Vector3(1.02, 1.06, 0.18), Vector3(-22, -96, -12), true, duration)
		AttackType.DELAYED_HEAVY:
			if is_active:
				_apply_pose_values(Vector3(0.2, 1.06, -0.7), Vector3(58, -18, -46), Vector3(-0.4, 0.94, -0.22), Vector3(18, 0, 12), Vector3(0.08, 0.92, -1.08), Vector3(92, 38, -40), true, duration)
			else:
				_apply_pose_values(Vector3(0.56, 1.58, 0.18), Vector3(-72, -28, -28), Vector3(-0.44, 1.0, -0.16), Vector3(18, 0, 12), Vector3(0.66, 2.08, 0.28), Vector3(-98, -22, -24), true, duration)
		AttackType.GRAB:
			if is_active:
				_apply_pose_values(Vector3(0.28, 1.08, -0.8), Vector3(82, 0, -16), Vector3(-0.28, 1.08, -0.86), Vector3(86, 0, 16), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false, duration)
			else:
				_apply_pose_values(Vector3(0.34, 1.06, -0.5), Vector3(58, 0, -14), Vector3(-0.24, 1.1, -0.62), Vector3(70, 0, 18), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false, duration)
		_:
			if is_active:
				_apply_pose_values(Vector3(0.24, 1.04, -0.52), Vector3(40, 42, -30), Vector3(-0.42, 1.0, -0.14), Vector3(18, 0, 12), Vector3(0.08, 1.04, -0.9), Vector3(72, 68, -18), true, duration)
			else:
				_apply_pose_values(Vector3(0.56, 1.02, 0.06), Vector3(-8, -56, -10), Vector3(-0.42, 1.0, -0.12), Vector3(16, 0, 12), Vector3(0.82, 1.0, -0.04), Vector3(-10, -62, -10), true, duration)

func _update_telegraph_pose_progress() -> void:
	if not telegraph_pose_progress_enabled:
		return

	var telegraph_time := _get_current_attack_telegraph_time()
	if telegraph_time <= 0.0:
		return

	var progress := clampf(_current_attack_telegraph_elapsed / telegraph_time, 0.0, 1.0)
	progress = progress * progress * (3.0 - 2.0 * progress)
	_begin_pose_change(0.0)
	_apply_body_visual_pose_progress(_current_attack_type, progress)

	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			_apply_pose_progress(Vector3(0.48, 1.92, 0.12), Vector3(-98, -12, -30), Vector3(-0.44, 1.76, 0.08), Vector3(-88, 12, 28), Vector3(0.18, 2.26, 0.22), Vector3(-104, 0, -12), true, Vector3(0.34, 0.88, -0.64), Vector3(88, 0, -22), Vector3(-0.34, 0.88, -0.62), Vector3(88, 0, 22), Vector3(0.0, 0.62, -0.82), Vector3(104, 0, 0), true, progress)
		AttackType.RETREAT_SLASH:
			_apply_pose_progress(Vector3(0.64, 1.08, 0.34), Vector3(-18, -86, -14), Vector3(-0.5, 1.02, 0.02), Vector3(14, 0, 20), Vector3(1.02, 1.06, 0.18), Vector3(-22, -96, -12), true, Vector3(0.28, 1.0, -0.56), Vector3(56, 58, -22), Vector3(-0.44, 0.98, -0.16), Vector3(20, 0, 14), Vector3(0.06, 0.98, -1.0), Vector3(84, 78, -12), true, progress)
		AttackType.DELAYED_HEAVY:
			_apply_pose_progress(Vector3(0.56, 1.58, 0.18), Vector3(-72, -28, -28), Vector3(-0.44, 1.0, -0.16), Vector3(18, 0, 12), Vector3(0.66, 2.08, 0.28), Vector3(-98, -22, -24), true, Vector3(0.2, 1.06, -0.7), Vector3(58, -18, -46), Vector3(-0.4, 0.94, -0.22), Vector3(18, 0, 12), Vector3(0.08, 0.92, -1.08), Vector3(92, 38, -40), true, progress)
		AttackType.GRAB:
			_apply_pose_progress(Vector3(0.34, 1.06, -0.5), Vector3(58, 0, -14), Vector3(-0.24, 1.1, -0.62), Vector3(70, 0, 18), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false, Vector3(0.28, 1.08, -0.8), Vector3(82, 0, -16), Vector3(-0.28, 1.08, -0.86), Vector3(86, 0, 16), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false, progress)
		_:
			_apply_pose_progress(Vector3(0.56, 1.02, 0.06), Vector3(-8, -56, -10), Vector3(-0.42, 1.0, -0.12), Vector3(16, 0, 12), Vector3(0.82, 1.0, -0.04), Vector3(-10, -62, -10), true, Vector3(0.24, 1.04, -0.52), Vector3(40, 42, -30), Vector3(-0.42, 1.0, -0.14), Vector3(18, 0, 12), Vector3(0.08, 1.04, -0.9), Vector3(72, 68, -18), true, progress)

func _apply_pose_progress(
	right_start_position: Vector3,
	right_start_rotation_degrees: Vector3,
	left_start_position: Vector3,
	left_start_rotation_degrees: Vector3,
	weapon_start_position: Vector3,
	weapon_start_rotation_degrees: Vector3,
	weapon_start_visible: bool,
	right_end_position: Vector3,
	right_end_rotation_degrees: Vector3,
	left_end_position: Vector3,
	left_end_rotation_degrees: Vector3,
	weapon_end_position: Vector3,
	weapon_end_rotation_degrees: Vector3,
	weapon_end_visible: bool,
	progress: float
) -> void:
	_apply_pose_values(
		right_start_position.lerp(right_end_position, progress),
		right_start_rotation_degrees.lerp(right_end_rotation_degrees, progress),
		left_start_position.lerp(left_end_position, progress),
		left_start_rotation_degrees.lerp(left_end_rotation_degrees, progress),
		weapon_start_position.lerp(weapon_end_position, progress),
		weapon_start_rotation_degrees.lerp(weapon_end_rotation_degrees, progress),
		weapon_start_visible or weapon_end_visible,
		0.0
	)

func reset_attack_pose(use_tween: bool = false) -> void:
	var duration := pose_tween_time if use_tween else 0.0
	_begin_pose_change(duration)
	_apply_body_visual_neutral(duration)
	_apply_pose_values(Vector3(0.55, 0.78, -0.02), Vector3(90, 0, 0), Vector3(-0.55, 0.78, -0.02), Vector3(90, 0, 0), Vector3(0.66, 0.7, -0.08), Vector3(90, 0, 0), true, duration)

func _apply_body_visual_neutral(duration: float) -> void:
	if body_mesh == null:
		return

	body_mesh.scale = _body_base_scale
	_move_pose_node(body_mesh, _body_base_position, _body_base_rotation_degrees, true, duration)

func _apply_body_visual_pose(attack_type: int, is_active: bool, duration: float) -> void:
	if body_mesh == null:
		return

	var body_pose := _get_body_visual_pose(attack_type, is_active)
	body_mesh.scale = _body_base_scale * (armor_slam_body_scale if attack_type == AttackType.ARMOR_SLAM else 1.0)
	_move_pose_node(body_mesh, body_pose["position"] as Vector3, body_pose["rotation_degrees"] as Vector3, true, duration)

func _apply_body_visual_pose_progress(attack_type: int, progress: float) -> void:
	if body_mesh == null:
		return

	var start_pose := _get_body_visual_pose(attack_type, false)
	var end_pose := _get_body_visual_pose(attack_type, true)
	body_mesh.scale = _body_base_scale * (armor_slam_body_scale if attack_type == AttackType.ARMOR_SLAM else 1.0)
	_move_pose_node(
		body_mesh,
		(start_pose["position"] as Vector3).lerp(end_pose["position"] as Vector3, progress),
		(start_pose["rotation_degrees"] as Vector3).lerp(end_pose["rotation_degrees"] as Vector3, progress),
		true,
		0.0
	)

func _get_body_visual_pose(attack_type: int, is_active: bool) -> Dictionary:
	var position := _body_base_position
	var rotation := _body_base_rotation_degrees
	match attack_type:
		AttackType.ARMOR_SLAM:
			position += Vector3(0.0, -0.18, -0.08) if is_active else Vector3(0.0, -0.13, 0.04)
			rotation += Vector3(12, 0, 0) if is_active else Vector3(-16, 0, -3)
		AttackType.RETREAT_SLASH:
			position += Vector3(0.02, -0.04, -0.08) if is_active else Vector3(-0.03, -0.02, 0.18)
			rotation += Vector3(5, 0, 8) if is_active else Vector3(-9, 0, 11)
		AttackType.DELAYED_HEAVY:
			position += Vector3(0.04, -0.1, -0.1) if is_active else Vector3(0.06, -0.12, 0.08)
			rotation += Vector3(10, 0, -7) if is_active else Vector3(-13, 0, -9)
		AttackType.GRAB:
			position += Vector3(0.0, -0.06, -0.18) if is_active else Vector3(0.0, -0.04, -0.1)
			rotation += Vector3(13, 0, 0) if is_active else Vector3(7, 0, 0)
		_:
			position += Vector3(0.04, -0.03, -0.06) if is_active else Vector3(0.05, -0.02, 0.02)
			rotation += Vector3(4, 0, -6) if is_active else Vector3(-2, 0, -5)

	return {
		"position": position,
		"rotation_degrees": rotation
	}

func _begin_pose_change(duration: float) -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()

	_pose_tween = null
	if duration > 0.0:
		_pose_tween = create_tween()
		_pose_tween.set_parallel(true)

func _apply_pose_values(
	right_position: Vector3,
	right_rotation_degrees: Vector3,
	left_position: Vector3,
	left_rotation_degrees: Vector3,
	weapon_position: Vector3,
	weapon_rotation_degrees: Vector3,
	weapon_visible: bool,
	duration: float
) -> void:
	_move_pose_node(right_arm, right_position, right_rotation_degrees, true, duration)
	_move_pose_node(left_arm, left_position, left_rotation_degrees, true, duration)
	_move_pose_node(weapon, weapon_position, weapon_rotation_degrees, weapon_visible, duration)

func _move_pose_node(node: Node3D, target_position: Vector3, target_rotation_degrees: Vector3, is_visible: bool, duration: float) -> void:
	if node == null:
		return

	node.visible = is_visible
	if duration <= 0.0 or _pose_tween == null:
		node.position = target_position
		node.rotation_degrees = target_rotation_degrees
		return

	_pose_tween.tween_property(node, "position", target_position, duration)
	_pose_tween.tween_property(node, "rotation_degrees", target_rotation_degrees, duration)

func get_debug_current_pattern_name() -> String:
	if not _pattern_active and _state == EnemyState.CHASE:
		return "None"

	return _get_attack_pattern_name(_current_attack_pattern)

func get_debug_slam_status_text() -> String:
	var is_slam_selected := _pattern_active and _steps_include_slam(_pattern_steps)
	return "%s / Supp %d" % ["YES" if is_slam_selected else "NO", _slam_suppression_remaining]

func get_debug_distance_band() -> String:
	var distance_band := _last_ai_distance_band
	var to_target := _get_flat_to_target()
	if to_target.length_squared() > 0.001:
		distance_band = _get_distance_band(to_target.length())

	return _get_distance_band_name(distance_band).to_upper()

func get_debug_state_text() -> String:
	var state_text := _get_enemy_state_name(_state)
	if _state == EnemyState.TELEGRAPH or _state == EnemyState.ACTIVE or _state == EnemyState.RECOVERY:
		state_text += " / " + _get_attack_type_name(_current_attack_type)
	if _pattern_active:
		state_text += " / Step %d/%d" % [mini(_pattern_step_index + 1, _pattern_steps.size()), _pattern_steps.size()]

	return state_text

func cycle_floor_telegraph_visual_mode() -> void:
	var next_mode := int(floor_telegraph_visual_mode) + 1
	if next_mode > TelegraphVisualMode.OFF:
		next_mode = TelegraphVisualMode.FULL_DEBUG

	set_floor_telegraph_visual_mode(next_mode)

func set_floor_telegraph_visual_mode(mode: int) -> void:
	floor_telegraph_visual_mode = clampi(mode, TelegraphVisualMode.FULL_DEBUG, TelegraphVisualMode.OFF)
	if _state == EnemyState.TELEGRAPH:
		_show_attack_telegraph()
	else:
		_hide_attack_telegraph()

func get_floor_telegraph_visual_mode_name() -> String:
	match floor_telegraph_visual_mode:
		TelegraphVisualMode.MINIMAL:
			return "MINIMAL"
		TelegraphVisualMode.OFF:
			return "OFF"
		_:
			return "FULL_DEBUG"

func _get_enemy_state_name(state: int) -> String:
	match state:
		EnemyState.TELEGRAPH:
			return "Telegraph"
		EnemyState.ACTIVE:
			return "Active"
		EnemyState.RECOVERY:
			return "Recovery"
		EnemyState.PATTERN_GAP:
			return "Pattern Gap"
		EnemyState.PATTERN_RECOVERY:
			return "Pattern Recovery"
		EnemyState.STUNNED:
			return "Stunned"
		EnemyState.DEAD:
			return "Dead"
		_:
			return "Chase"

func set_ai_enabled(value: bool) -> void:
	_ai_enabled = value
	if not _ai_enabled:
		velocity = Vector3.ZERO
		_state_time_remaining = 0.0
		_attack_cooldown_remaining = 0.0
		_clear_attack_pattern_state()
		_attack_damaged_targets.clear()
		_just_dodged_targets.clear()
		_set_attack_hitbox_enabled(false)
		_hide_attack_telegraph()
		reset_attack_pose(false)
		_state = EnemyState.DEAD if health.is_dead() else EnemyState.CHASE
		_apply_body_debug_color()

func reset_combat_state() -> void:
	_ai_enabled = true
	velocity = Vector3.ZERO
	_state = EnemyState.CHASE
	_state_time_remaining = 0.0
	_attack_cooldown_remaining = 0.0
	_attack_direction = Vector3.FORWARD
	_current_attack_type = AttackType.FAST_SLASH
	_current_attack_pattern = AttackPattern.SIMPLE_PRESSURE
	_current_attack_telegraph_elapsed = 0.0
	_retreat_distance_remaining = 0.0
	_clear_attack_pattern_state()
	_last_attack_pattern = -1
	_last_dangerous_outcome_attack_type = -1
	_slam_suppression_remaining = 0
	_recent_attack_patterns.clear()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(false)
	_apply_body_debug_color()
	_resolve_target()
