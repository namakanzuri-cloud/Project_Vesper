extends Node
class_name InputSetup

func _ready() -> void:
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("dodge", KEY_SPACE)
	_add_key_action("retry", KEY_R)
	_add_key_action("debug_reset", KEY_F5)
	_add_mouse_action("light_attack", MOUSE_BUTTON_LEFT)
	_add_mouse_action("heavy_attack", MOUSE_BUTTON_RIGHT)

func _add_key_action(action_name: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	if InputMap.action_get_events(action_name).size() > 0:
		return

	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)

func _add_mouse_action(action_name: StringName, button_index: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	if InputMap.action_get_events(action_name).size() > 0:
		return

	var event := InputEventMouseButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action_name, event)
