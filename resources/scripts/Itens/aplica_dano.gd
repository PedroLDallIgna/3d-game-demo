extends Node3D



func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_collision_body_entered(body: Node3D) -> void:
	if(body is Enemy):
		var player = Globais.playerSelf
		var spawn_location = body.global_transform.origin
		
		spawn_location.y += 1
		Globais.spawn_blood(spawn_location)
		body.in_self_damage(Globais.current_attack)
