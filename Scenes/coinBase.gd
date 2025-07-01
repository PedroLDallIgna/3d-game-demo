extends Area3D

@export var rotate_speed: float = 50.0
@export var value: int = 2
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var som = preload("res://resources/Sons/coinSound.mp3")

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(rotate_speed * delta))

func _on_body_entered(body: Player) -> void:
	audio_stream_player_3d.stream = som
	audio_stream_player_3d.play()
	
	if(body.is_in_group("player")):
		body.collect_coins(value, audio_stream_player_3d)
		await get_tree().create_timer(0.2).timeout
		queue_free()
