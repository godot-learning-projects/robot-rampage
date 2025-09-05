extends Node


@onready var acquired_ammo_label: Label = $AcquiredAmmoMarginContainer/AcquiredAmmoLabel

@onready var ammo_handler_animation: AnimationPlayer = $AmmoHandlerAnimation


func play(content: String) -> void:
	acquired_ammo_label.text = content
	ammo_handler_animation.play("AcquiredAmmo")


func _on_ammo_handler_animation_animation_finished(anim_name: StringName) -> void:
	queue_free()
