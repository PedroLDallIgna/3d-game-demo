extends Control

@onready var conteiner_niveis: Panel = $conteinerNiveis

func _ready() -> void:
	conteiner_niveis.visible = false

func _on_btn_comecar_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")

func _on_btn_escolher_pressed() -> void:
	if(conteiner_niveis.visible == true):
		conteiner_niveis.visible = false
	else:
		conteiner_niveis.visible = true

func _on_btn_sair_pressed() -> void:
	get_tree().quit()
