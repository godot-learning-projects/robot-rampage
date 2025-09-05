extends Node
class_name  AmmoHandler

@onready var acquired_ammo_scene: PackedScene = preload("res://entities/player/acquired_ammo_scene.tscn")
@export var acquired_ammo_stack: VBoxContainer
@export var stored_ammo_label: Label


enum ammo_type {
	_none,
	_380,
	_22LR,
	_40_S_W,
	_9mm,
	_10mm,
	_45ACP,
	_38_Spl,
	_5_7x28mm,
	_357_Mag,
	_30_Carbine,
	_300_Blackout,
	_7_62x39mm,
	_223_Remington,
	_5_56x45mm,
	_308_Winchester,
	_7_62x51mm,
	_7_62x54mmR,
	_30_06,
	_50_BMG,
	_12GA,
}

const ammo_description: Dictionary = {
	ammo_type._none: "None",
	ammo_type._380: ".380",
	ammo_type._22LR: ".22LR",
	ammo_type._40_S_W: ".40 S&W",
	ammo_type._9mm: "9mm",
	ammo_type._10mm: "10mm",
	ammo_type._45ACP: ".45ACP",
	ammo_type._38_Spl: ".38 Spl",
	ammo_type._5_7x28mm: "5.7x28mm",
	ammo_type._357_Mag: ".357 Mag",
	ammo_type._30_Carbine: ".30 Carbine",
	ammo_type._300_Blackout: ".300 Blackout",
	ammo_type._7_62x39mm: "7.62x39mm",
	ammo_type._223_Remington: ".223 Remington",
	ammo_type._5_56x45mm: "5.56x45mm",
	ammo_type._308_Winchester: ".308 Winchester",
	ammo_type._7_62x51mm: "7.62x51mm",
	ammo_type._7_62x54mmR: "7.62x54mmR",
	ammo_type._30_06: ".30-06",
	ammo_type._50_BMG: ".50 BMG",
	ammo_type._12GA: "12 GA"
}

var ammo_storage: Dictionary = {
	ammo_type._380: 0,
	ammo_type._22LR: 0,
	ammo_type._40_S_W: 0,
	ammo_type._9mm: 10,
	ammo_type._10mm: 0,
	ammo_type._45ACP: 0,
	ammo_type._38_Spl: 0,
	ammo_type._5_7x28mm: 0,
	ammo_type._357_Mag: 0,
	ammo_type._30_Carbine: 0,
	ammo_type._300_Blackout: 0,
	ammo_type._7_62x39mm: 0,
	ammo_type._223_Remington: 0,
	ammo_type._5_56x45mm: 0,
	ammo_type._308_Winchester: 1,
	ammo_type._7_62x51mm: 0,
	ammo_type._7_62x54mmR: 0,
	ammo_type._30_06: 0,
	ammo_type._50_BMG: 0,
	ammo_type._12GA: 0,
}



func available_ammo(type: ammo_type) -> int:
	return ammo_storage[type]


func use_ammo(type: ammo_type, amount: int) -> int:
	var _storage_available_ammo: int = ammo_storage[type]
	
	if _storage_available_ammo > amount:
		ammo_storage[type] -= amount
		_storage_available_ammo = amount
	else:
		ammo_storage[type] = 0
	
	_display_stored_ammo(type)
	return _storage_available_ammo


func store_ammo(type: ammo_type, amount: int, current_ammo_type: ammo_type) -> void:
	ammo_storage[type] += amount
	
	_display_acquired_ammo(type, amount)
	if type == current_ammo_type:
		_display_stored_ammo(type)


func get_ammo_description(type: ammo_type) -> String:
	return ammo_description[type]


func _display_acquired_ammo(type: ammo_type, amount: int) -> void:
	var content = {
		"stored_ammo": str(amount),
		"type": get_ammo_description(type)
	}
	
	var scene = acquired_ammo_scene.instantiate()
	acquired_ammo_stack.add_child(scene)
	scene.play("+{stored_ammo}  {type}".format(content))


func _display_stored_ammo(type: ammo_type) -> void:
	if type == ammo_type._none:
		stored_ammo_label.text = ""
		return
	
	var content = {
		"stored_ammo": str(ammo_storage[type]),
		"type": get_ammo_description(type)
	}
	stored_ammo_label.text = "{stored_ammo}  {type}".format(content)
