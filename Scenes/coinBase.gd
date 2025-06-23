extends Area3D

@export var rotate_speed: float = 50.0
@export var value: int = 2

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(rotate_speed * delta))

func _on_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player")):
		body.collect_coins(value)
		queue_free()
