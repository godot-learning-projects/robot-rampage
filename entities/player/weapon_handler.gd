extends Node3D

@export var weapon_1: Node3D
@export var weapon_2: Node3D
@export var ammo_label: Label
@export var ammo_handler: AmmoHandler

@export var max_weapons_carrying: int


var weapon_mouse_action_list = ["control_mouse_wheel_up", "control_mouse_wheel_down"]#Filled into the _ready function with system information
var weapon_action_list


var _weapons: Array[Weapon]
var _active_weapon_index: int

func _ready() -> void:
	var actions_list: Array = InputMap.get_actions()
	actions_list = actions_list.filter(func (action: String): return action.begins_with("control_weapon_"))
	actions_list = actions_list.map(func(action): return str(action))
	
	weapon_action_list = actions_list
	weapon_action_list.append_array(weapon_mouse_action_list)
	
	_weapons = [weapon_1, weapon_2]
	for weapon in _weapons:
		# Move it to the moment where the player acquires the weapon
		weapon.set_ammo_manager(ammo_label, ammo_handler)
	equip(-1)

func _unhandled_input(event: InputEvent) -> void:
	for weapon_action in weapon_action_list:
		if event.is_action_pressed(weapon_action):
			if weapon_action in weapon_mouse_action_list:
				_next_weapon(_control_definition(weapon_action) == "up")
			else:
				var weapon_number: int = (int(_control_definition(weapon_action)) - 1)
				if _weapons.size() <= weapon_number:
					push_warning("Tried to equip a nonexistent weapon at slot [" + str(weapon_number) + "]")
					equip(-1)
				else:
					equip(weapon_number)


func equip(weapon_index: int) -> void:
	_active_weapon_index = weapon_index
	var weapon: Weapon
	
	if _active_weapon_index < 0 or _active_weapon_index >= _weapons.size():
		weapon = null
	else:
		weapon = _weapons[_active_weapon_index]
	
	if weapon == null:
		ammo_label.text = ""
		_active_weapon_index = -1
		ammo_handler._display_stored_ammo(ammo_handler.ammo_type._none)
	else:
		ammo_label.text = str(weapon._ammo)
		ammo_handler._display_stored_ammo(weapon.ammo_type)
	
	for _weapon in _weapons:
		var state: bool = (_weapon == weapon)
		_weapon.visible = state
		_weapon.set_process(state)

func get_current_weapon_ammo_type() -> AmmoHandler.ammo_type:
	if _get_current_weapon_index() < 0:
		return ammo_handler.ammo_type._none
	return _weapons[_get_current_weapon_index()].ammo_type


func has_scope() -> float:
	if _active_weapon_index < 0: return 1.0
	return _weapons[_active_weapon_index].aim_magnification


func _next_weapon(next: bool) -> void:
	var index = _get_current_weapon_index()
	var is_next: int = 1
	if not next:
		is_next *= -1 # So, it's previous weapon
	index = wrapi(index + is_next, 0, _weapons.size())
	equip(index)

func _get_current_weapon_index() -> int:
	return _active_weapon_index

func _control_definition(action: String) -> String:
	return action.replace("control_weapon_", "").replace("control_mouse_wheel_", "")
