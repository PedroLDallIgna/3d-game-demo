extends Node3D

@export var jump_force: float = 25.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_jump_area_body_entered(body: Player) -> void:
	if body.is_in_group("player"):
		var velocity = body.velocity
		velocity.y = jump_force
		body.velocity = velocity
