extends Camera3D

@export var player: CharacterBody3D

@export var speed := 20.0
var fps_view_mode: bool = true

func _physics_process(delta: float) -> void:
	var weight := clampf(delta * speed, 0.0, 1.0)
	
	global_transform = global_transform.interpolate_with(
		get_parent().global_transform, weight
	)
	
	global_position = get_parent().global_position


func change_view_mode() -> void:
	if fps_view_mode:
		fps_view_mode = false
		get_parent().global_position = get_parent().global_position + Vector3(0,1.2,-2.4)
		global_position = get_parent().global_position
	else:
		fps_view_mode = true
		get_parent().global_position = player.global_position + Vector3(0,1.3,-0.4)
		global_position = get_parent().global_position
