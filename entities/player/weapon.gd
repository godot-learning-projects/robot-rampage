extends Node3D

@export var reload_time: float = 3.0 # Seconds to reload
@export var fire_rate: float = 2.0 # Times per second
@export var damage: int = 10

@export var firing_mode: firing_modes = firing_modes.SINGLE
@export var ammo_max_capacity: int = 7
@export var recoil: float = 0.05

@export var weapon_mesh: Node3D
@onready var weapon_position: Vector3 = weapon_mesh.position

@onready var ray_cast: RayCast3D = $RayCast3D

@onready var misfire_sfx: AudioStreamPlayer3D = $SFX/Misfire
@onready var reload_sfx: AudioStreamPlayer3D = $SFX/Reload
@onready var fire_sfx: AudioStreamPlayer3D = $SFX/Fire

@onready var cooldown_timer: Timer = $CooldownTimer

@onready var weapon: Node3D = $glock


var ammo
func _ready() -> void:
	ammo = ammo_max_capacity

enum firing_modes {
	SAFE = 0,
	SINGLE = 1,
	BURST = 2,
	SEMI = 3,
	AUTO = 4
}

var firing_types: Dictionary = {
	firing_modes.SAFE: "is_action_just_pressed",
	firing_modes.SINGLE: "is_action_just_pressed",
	firing_modes.BURST: "is_action_pressed",
	firing_modes.SEMI: "is_action_just_pressed",
	firing_modes.AUTO: "is_action_pressed"
}



func _process(delta: float) -> void:
	var firing_function = Callable(Input, firing_types[firing_mode])
	if firing_function.call("control_action"):
		if cooldown_timer.is_stopped():
			shoot(firing_mode)
	elif Input.is_action_just_pressed("control_reload"):
		reload()
	
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta * 10.0)

func shoot(_firing_mode) -> void:
	if ammo > 0 and _firing_mode != firing_modes.SAFE:
		weapon_mesh.position.z -= recoil
		cooldown_timer.start(1.0 / fire_rate)
		fire_sfx.play()
		hit(ray_cast.get_collider())
		ammo -= 1
	else:
		cooldown_timer.start(0.5)
		misfire_sfx.play()

func reload() -> void:
	cooldown_timer.start(reload_time)
	reload_sfx.play()
	ammo = ammo_max_capacity

func hit(target) -> void:
	if target is Enemy:
		target.health -= damage
	pass
