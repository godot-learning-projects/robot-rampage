extends Node3D

@export var weapon_1: Node3D
@export var weapon_2: Node3D

var weapon_mouse_action_list = ["control_mouse_wheel_up", "control_mouse_wheel_down"]#Filled into the _ready function with system information
var weapon_action_list
func _ready() -> void:
	# Get system actions that are into the pattern of "control_weapon_\d"
	var actions_list: Array = InputMap.get_actions().filter(_is_control_action)
	# Convert StringName into string array
	weapon_action_list = actions_list.map(func(action): return str(action))
	weapon_action_list.append_array(weapon_mouse_action_list)
	equip(weapon_1)

func _unhandled_input(event: InputEvent) -> void:
	var a: String
	for weapon in weapon_action_list:
		if event.is_action_pressed(weapon):
			if weapon in weapon_mouse_action_list:
				_next_weapon(_control_definition(weapon) == "up")
			else:
				var weapon_number: int = (int(_control_definition(weapon)) - 1)
				if get_child_count() <= weapon_number:
					push_warning("Tried to equip a nonexistent weapon at slot [" + str(weapon_number) + "]")
					equip(null)
				else:
					equip(get_child(weapon_number))


func equip(active_weapon: Node3D) -> void:
	for child in get_children():
		var state: bool = (child == active_weapon)
		child.visible = state
		child.set_process(state)


func _next_weapon(next: bool) -> void:
	var index = _get_current_weapon_index()
	var is_next: int = 1
	if not next:
		is_next *= -1 # So, it's previous weapon
	index = wrapi(index + is_next, 0, get_child_count())
	equip(get_child(index))

func _get_current_weapon_index() -> int:
	for index in get_child_count():
		if get_child(index).visible:
			return index
	return -1


func _is_control_action(action: String) -> bool:
	return action.begins_with("control_weapon_")


func _control_definition(action: String) -> String:
	return action.replace("control_weapon_", "").replace("control_mouse_wheel_", "")
