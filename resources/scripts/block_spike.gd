extends Node3D

@onready var area_spikes: Area3D = $areaSpikes
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var som = preload("res://resources/Sons/metalSpike.mp3")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_spikes_body_entered(body: Player) -> void:
	var body_collision = (global_position - Globals.global_player.global_position)
	var force = -body_collision
	force *= 15.0
	
	audio_stream_player_3d.stream = som
	audio_stream_player_3d.play()
	body.knockback(body_collision, force)
	body.update_health(1)
