extends Node3D

@onready var collision_fall: Area3D = $collisionFall

func _on_collision_fall_body_entered(body: Player) -> void:
	if(body.is_in_group("player")):
		get_tree().paused = true
		await get_tree().create_timer(0.4).timeout
		body.interface_morte.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
