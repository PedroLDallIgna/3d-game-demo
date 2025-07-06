extends Node3D

var winInterface = preload("res://Scenes/win_menu.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_win_area_body_entered(body: Player) -> void:
	if(body is Player):
		body.add_child(winInterface)
