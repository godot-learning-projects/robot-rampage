extends CharacterBody3D

@export var max_health: int = 50
var health: int = max_health:
	set(value):
		if(value < health):
			_take_damage()
		else:
			_heal()
		health = value
		if health <= 0:
			aim_dot.visible = false
			game_over_menu.game_over()


@export var fall_multiplier: float = 2.0
@export var jump_height: float = 1.0

@onready var ammo_handler: AmmoHandler = $WeaponCamera/SubViewport/WeaponCamera/AmmoHandler
@onready var weapon_handler: Node3D = $WeaponCamera/SubViewport/WeaponCamera/WeaponHandler
#@onready var weapon_handler: Node3D = $CameraPivot/PlayerCamera/WeaponHandler
#@onready var ammo_handler: AmmoHandler = $CameraPivot/PlayerCamera/AmmoHandler

@onready var weapon_camera: Camera3D = $WeaponCamera/SubViewport/WeaponCamera
@onready var weapon_camera_fov: float = weapon_camera.fov

@onready var player_camera: Camera3D = $CameraPivot/PlayerCamera
@onready var player_camera_fov: float = player_camera.fov

@onready var player_animation: AnimationPlayer = $PlayerAnimation
@onready var camera_pivot: Node3D = $CameraPivot
@onready var godot_robot: Node3D = $GodotRobot

@onready var game_over_menu: Control = $GameOverMenu
@onready var aim_dot: CenterContainer = $AimDot

const MOUSE_SENSITIVITY = 0.005
const SPEED = 5.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_motion := Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		var aim_multiplier = weapon_handler.has_scope()
		_camera_aim_fov(player_camera, player_camera_fov * aim_multiplier, delta * 20.0)
		_camera_aim_fov(weapon_camera, weapon_camera_fov * aim_multiplier, delta * 20.0)
	else:
		_camera_aim_fov(player_camera, player_camera_fov, delta * 30.0)
		_camera_aim_fov(weapon_camera, weapon_camera_fov, delta * 30.0)


func _physics_process(delta: float) -> void:
	_handle_camera_rotation()
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier
	
	# Handle jump.
	if Input.is_action_just_pressed("control_jump") and is_on_floor():
		velocity.y = sqrt(jump_height * fall_multiplier * gravity)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI ac tions with custom gameplay actions.
	var input_dir := Input.get_vector("control_left", "control_right", "control_up", "control_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if Input.is_action_pressed("aim"):
			var aim_multiplier = weapon_handler.has_scope()
			velocity.x *= aim_multiplier
			velocity.z *= aim_multiplier
		godot_robot.animation_play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		godot_robot.animation_play("Idle")
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = -event.relative * MOUSE_SENSITIVITY
		if Input.is_action_pressed("aim"):
			mouse_motion *= weapon_handler.has_scope()
		
	if event.is_action_pressed("control_options"):
		if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		return
		
	if event.is_action_pressed("control_view"):
		player_camera.change_view_mode()
		
	if event.is_action_pressed("control_cancel"):
		get_tree().quit()


func pickup(type: AmmoHandler.ammo_type, amount: int) -> void:
	ammo_handler.store_ammo(type, amount, weapon_handler.get_current_weapon_ammo_type())


func _handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x,
		-70.0, 80.0
	)
	mouse_motion = Vector2.ZERO


func _take_damage() -> void:
	player_animation.play("DamageView")


func _heal() -> void:
	pass


func _camera_aim_fov(camera: Camera3D, camera_fov: float, delta: float) -> void:
	camera.fov = lerp(camera.fov, camera_fov, delta)
