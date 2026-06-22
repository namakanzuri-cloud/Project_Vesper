extends CharacterBody3D
class_name EnemyController

@export var target_path: NodePath
@export var target_group: StringName = &"player"

@export_group("Movement")
@export var move_speed: float = 3.4
@export var rotation_speed: float = 12.0

@export_group("Attack")
@export var attack_range: float = 1.45
@export var attack_radius: float = 0.75
@export var attack_damage: float = 12.0
@export var attack_cooldown: float = 1.35
@export var attack_windup: float = 0.45

@export_group("Collision")
@export_flags_3d_physics var player_collision_mask: int = 2

@onready var health: Health = $Health
@onready var attack_hitbox: CombatHitbox = $AttackHitbox

var _target: Node3D
var _attack_cooldown_remaining: float = 0.0
var _attack_windup_remaining: float = 0.0
var _attack_pending: bool = false

func _ready() -> void:
	_resolve_target()

func _physics_process(delta: float) -> void:
	if health.is_dead():
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		if _target == null:
			return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	_update_attack_windup(delta)

	var to_target := _target.global_position - global_position
	to_target.y = 0.0

	if to_target.length_squared() <= 0.001:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var direction := to_target.normalized()
	_rotate_toward(direction, delta)

	if to_target.length() > attack_range:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		_try_start_attack()

	velocity.y = 0.0
	move_and_slide()

func _resolve_target() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	if _target == null:
		_target = get_tree().get_first_node_in_group(target_group) as Node3D

func _rotate_toward(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-rotation_speed * delta))

func _try_start_attack() -> void:
	if _attack_pending or _attack_cooldown_remaining > 0.0:
		return

	_attack_pending = true
	_attack_windup_remaining = attack_windup
	_attack_cooldown_remaining = attack_cooldown

func _update_attack_windup(delta: float) -> void:
	if not _attack_pending:
		return

	_attack_windup_remaining -= delta
	if _attack_windup_remaining > 0.0:
		return

	_attack_pending = false
	_resolve_attack()

func _resolve_attack() -> void:
	var forward := -global_transform.basis.z
	attack_hitbox.global_position = global_position + forward * attack_range
	attack_hitbox.radius = attack_radius
	attack_hitbox.target_group = &"player"
	attack_hitbox.collision_mask = player_collision_mask
	attack_hitbox.strike(attack_damage, self)
func reset_combat_state() -> void:
	velocity = Vector3.ZERO
	_attack_cooldown_remaining = 0.0
	_attack_windup_remaining = 0.0
	_attack_pending = false
	_resolve_target()

