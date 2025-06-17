extends Node3D

class_name Item

@export var item_name: String
@export var description: String
@export var icon: Texture2D
@export var model_path: String # Caminho do modelo 3D
@export var consumivel: bool
@export var maxStack: int
@export var nivel: int
@export var raridade: String
