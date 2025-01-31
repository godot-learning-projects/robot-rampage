extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func animation_play(animation: String) -> void:
	animation_player.play(animation)
