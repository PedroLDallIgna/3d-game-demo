extends Node3D

var armaduraEquipada
@onready var skeleton_3d: Skeleton3D = %Skeleton3D

var armorScene = preload("res://Personagens/Protagonista/armaduras/itemArmor.tscn");
var nodeName = "mantoTerceiraCategoria";

func _ready() -> void:
	armaduraEquipada = armorScene.instantiate()
	
	# Acessa o SkinnedMeshInstance3D da armadura
	var skin = armaduraEquipada.get_node(nodeName)  # Nome correto do nó
	
	if skin:
		# Define o caminho do esqueleto (NodePath)
		skin.skeleton = skeleton_3d.get_path()  # Convertendo a referência para um NodePath
	else:
		print("Erro: SkinnedMeshInstance3D não encontrado na cena da armadura.")
	
	add_child(armaduraEquipada)
