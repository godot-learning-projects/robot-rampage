extends CharacterBody3D
class_name Enemy

const SPEED = 2.5
const JUMP_VELOCITY = 4.5

var player: CharacterBody3D

var provoked: bool = false

@export var max_health: int = 50
var health: int = max_health:
	set(value):
		provoked = true
		health = value
		if health <= 0:
			queue_free()

@export var damage: int = 20
@export var attack_cooldown: float = 2.0 #Seconds
@export var attack_range: float = 1.5
@export var aggressive_range: float = 10.0
@export var watch_range: float = aggressive_range + 5.0


@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var godot_robot: Node3D = $"GodotRobot"

@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("PLAYER")

func _process(_delta: float) -> void:
	navigation_agent_3d.target_position = player.global_position

func _physics_process(delta: float) -> void:
	var next_position = navigation_agent_3d.get_next_path_position()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := global_position.direction_to(next_position)
	var distance = global_position.distance_to(player.global_position)
	
	
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	if distance < aggressive_range:
		provoked = true


		
	if distance < attack_range and cooldown_timer.is_stopped():
		attack()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if provoked:
		look_at_target(direction)
		if distance > attack_range:
			godot_robot.animation_play("Run")
		move_and_slide()
	elif distance < watch_range:
		look_at_target(direction)
	else:
		godot_robot.animation_play("Idle")
		
		
func look_at_target(target: Vector3) -> void:
	var target_vector = target
	target_vector.y = 0
	target_vector = global_position + target_vector
	if abs(self.position.angle_to(target_vector)) > 0.001:
		look_at(target_vector, Vector3.UP, true)

func attack() -> void:
	godot_robot.animation_play("Kick")
	player.health -= damage
	cooldown_timer.start(attack_cooldown)
