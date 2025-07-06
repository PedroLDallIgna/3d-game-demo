extends Control

@onready var label_moedas: Label = $Panel/Panel/labelMoedas
@onready var label_vidas: Label = $Panel/Panel/labelVidas
@onready var btn_proximo: Button = $Panel/VBoxContainer/btnProximo
@onready var btn_menu: Button = $Panel/VBoxContainer/btnMenu

var current_scene
var next_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_moedas.text = str(Globals.global_player.coins)
	label_vidas.text = str(Globals.global_player.Health)
	
	get_tree().paused = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	match (Globals.current_scene):
		"level1":
			next_scene = "res://world.tscn"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_btn_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_btn_proximo_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	get_tree().change_scene_to_file(next_scene)
