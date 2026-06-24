extends Node3D
class_name CombatPrototypeMain

@onready var player: PlayerController = $Player
@onready var enemy: EnemyController = $Enemy
@onready var ui: CombatUI = $UI
@onready var hit_stop = $HitStop
@onready var camera: CameraFollow = $Camera3D

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
	ui.set_end_overlay_visible(false)

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
	ui.set_end_overlay_visible(true, "VICTORY", "Enemy Defeated  |  R: Retry  |  F5: Reset")

func _enter_defeat() -> void:
	if _combat_state == CombatState.DEFEAT:
		return

	hit_stop.cancel()
	Engine.time_scale = 1.0
	camera.cancel_shake()
	_combat_state = CombatState.DEFEAT
	player.set_control_enabled(false)
	enemy.set_ai_enabled(false)
	ui.set_end_overlay_visible(true, "YOU DIED", "Press R to retry  |  F5 resets anytime")
