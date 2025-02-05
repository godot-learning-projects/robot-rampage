extends Node3D
class_name Weapon

@export var reload_time: float = 3.0 # Seconds to reload
@export var fire_rate: float = 2.0 # Times per second
@export var damage: int = 10

@export var _active_firing_mode: firing_modes = firing_modes.SINGLE
@export var possible_firing_modes: Array[firing_modes] = [
	firing_modes.SAFE,
	firing_modes.SINGLE
]

@export var ammo_max_capacity: int = 7
@export var recoil: float = 0.05

@export var hit_sparks: PackedScene

@export var weapon_mesh: Node3D
@onready var weapon_position: Vector3 = weapon_mesh.position


@onready var ray_cast: RayCast3D = $RayCast3D

@onready var misfire_sfx: AudioStreamPlayer3D = $SFX/Misfire
@onready var reload_sfx: AudioStreamPlayer3D = $SFX/Reload
@onready var fire_sfx: AudioStreamPlayer3D = $SFX/Fire

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var nozzle_particles: GPUParticles3D = $ActionParticles

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


var _ammo: int
func _ready() -> void:
	if _active_firing_mode not in possible_firing_modes:
		push_error(
			"The active firing mode got assigned as \"" +
				str(firing_modes.keys()[_active_firing_mode]) +
			"\" is not assinable for this weapon. \nThis weapon accept the following modes: " +
				str(_array_firing_modes_to_enum_keys(possible_firing_modes))
		)
		_active_firing_mode = possible_firing_modes[int(possible_firing_modes.size() > 1)]
	
	if(_array_remove_duplicity(possible_firing_modes).size() < possible_firing_modes.size()):
		push_warning(
			"There are duplicated firing modes into this weapon." +
			"\nFiring modes available at \"" + name + "\": " +
			str(_array_firing_modes_to_enum_keys(possible_firing_modes))
		)
	
	nozzle_particles.lifetime = 1.0 / fire_rate
	nozzle_particles.emitting = false
	nozzle_particles.one_shot = true
	_ammo = ammo_max_capacity


func _process(delta: float) -> void:
	var firing_function = Callable(Input, firing_types[_active_firing_mode])

	if firing_function.call("control_action"):
		if cooldown_timer.is_stopped():
			shoot(_active_firing_mode)
	elif Input.is_action_just_pressed("control_reload"):
		reload()
	
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta * 10.0)

func shoot(_firing_mode) -> void:
	if _ammo > 0 and _firing_mode != firing_modes.SAFE:
		weapon_mesh.position.z -= recoil
		cooldown_timer.start(1.0 / fire_rate)
		fire_sfx.play()
		nozzle_particles.restart()
		hit(ray_cast.get_collider(), ray_cast.get_collision_point())
		_ammo -= 1
	else:
		cooldown_timer.start(0.5)
		misfire_sfx.play()

func reload() -> void:
	cooldown_timer.start(reload_time)
	reload_sfx.play()
	_ammo = ammo_max_capacity

func hit(target: Object, collision_point: Vector3) -> void:
	if target:
		if target is Enemy:
			target.health -= damage
		
		var spark = hit_sparks.instantiate()
		add_child(spark)
		spark.global_position = collision_point


func _array_remove_duplicity(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func _array_firing_modes_to_enum_keys(array: Array[firing_modes]) -> Array:
	return array.map(func(type): return firing_modes.keys()[type])
