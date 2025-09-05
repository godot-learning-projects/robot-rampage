extends Area3D

@export var _ammo_type: AmmoHandler.ammo_type
@export var _amount: int = 2


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		queue_free()
		body.pickup(_ammo_type, _amount)
