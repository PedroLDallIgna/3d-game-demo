extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_spikes: Area3D = $areaSpikes
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var som = preload("res://resources/Sons/metalSpike.mp3")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("show-hide")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_damage() -> void:
	var body_collision = (global_position - Globals.global_player.global_position)
	var force = -body_collision
	force *= 15.0
	
	audio_stream_player_3d.stream = som
	audio_stream_player_3d.play()
	
	if(area_spikes.overlaps_body(Globals.global_player)):
		Globals.global_player.knockback(body_collision, force)
		Globals.global_player.update_health(1)
