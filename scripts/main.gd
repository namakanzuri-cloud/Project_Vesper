extends Node3D
class_name CombatPrototypeMain

@onready var player: PlayerController = $Player
@onready var enemy: EnemyController = $Enemy
@onready var ui: CombatUI = $UI

var _player_spawn_transform: Transform3D
var _enemy_spawn_transform: Transform3D
var _game_over: bool = false

func _ready() -> void:
	_player_spawn_transform = player.global_transform
	_enemy_spawn_transform = enemy.global_transform
	player.health.died.connect(_on_player_died)
	ui.set_death_visible(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_reset"):
		reset_combat()
		return

	if _game_over and Input.is_action_just_pressed("retry"):
		reset_combat()

func reset_combat() -> void:
	_game_over = false
	player.global_transform = _player_spawn_transform
	enemy.global_transform = _enemy_spawn_transform

	player.reset_combat_state()
	enemy.reset_combat_state()
	player.health.reset_health()
	enemy.health.reset_health()
	player.stamina.reset_stamina()
	ui.set_death_visible(false)

func _on_player_died() -> void:
	_game_over = true
	ui.set_death_visible(true, "YOU DIED", "Press R to retry  |  F5 resets anytime")
