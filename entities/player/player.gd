extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.005
const SPEED = 5.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_motion := Vector2.ZERO


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
@export var jump_height: float = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var smooth_camera: Camera3D = $CameraPivot/SmoothCamera
@onready var camera_pivot: Node3D = $CameraPivot
@onready var godot_robot: Node3D = $GodotRobot

@onready var game_over_menu: Control = $GameOverMenu
@onready var aim_dot: CenterContainer = $AimDot


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
		godot_robot.animation_play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		godot_robot.animation_play("Idle")
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = -event.relative * MOUSE_SENSITIVITY
		
	if event.is_action_pressed("control_options"):
		if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		return
		
	if event.is_action_pressed("control_view"):
		smooth_camera.change_view_mode()
		
	if event.is_action_pressed("control_cancel"):
		get_tree().quit()

func _handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x,
		-70.0, 80.0
	)
	mouse_motion = Vector2.ZERO

func _take_damage() -> void:
	animation_player.play("DamageView")

func _heal() -> void:
	pass
