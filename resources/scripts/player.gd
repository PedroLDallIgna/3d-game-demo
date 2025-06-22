extends CharacterBody3D

class_name Player2

@export_category("Movement")
@export var SPEED: float = 10.0
@export var RUN_SPEED: float = 18.0
@export var TURN_SPEED = 5  # Aumentado para rotação mais suave
@export var JUMP_VELOCITY = 12.0
var current_speed = SPEED

@export_category("BasicStats")
@export var HEALTH: int = 100
@export var MAX_HEALTH: int = 100
var current_health = HEALTH
@export var KI: int = 100
@export var MAX_KI: int = 100
var current_ki = KI
@export var defence: int = 0
@export var peso: int = 0

@export_category("RPGStats")
#@export var stats: CharacterStats

@onready var animation_tree_Basic: AnimationTree = $mesh/protagonistaMesh/AnimationPlayer/AnimationTree
@onready var animation_player: AnimationPlayer = $mesh/protagonistaMesh/AnimationPlayer
@onready var player: CharacterBody3D = $"./"
@onready var skeleton_3d: Skeleton3D = %Skeleton3D

@onready var lampiao: BoneAttachment3D = $mesh/protagonistaMesh/root/Skeleton3D/lampiao

@onready var attackTimer: Timer = $attackTimer
@onready var trail_espada: GPUTrail3D = $mesh/protagonistaMesh/root/Skeleton3D/rightHandBone/weapon/GPUTrail3D

@onready var fundo_morte: TextureRect = $playerInfo/fundoMorte
@onready var btn_ultimo_save: Button = $playerInfo/fundoMorte/btnUltimoSave
@onready var btn_voltar_menu: Button = $playerInfo/fundoMorte/btnVoltarMenu

var isAttacking: bool = false
var idle: bool

var currentArmor = null
var currentWeapon = null

var combo_count: int = 0
@export var max_sword_combo: int = 3

var interacao_ativa: bool
var first_movement = true

@export_category("Equipament")
@onready var foot_steps: AudioStreamPlayer3D = $footSteps

@export_category("Outros")
@export var step_sounds: Dictionary = {
	0: preload("res://Musicas/footSteps/Footsteps_Walk_Grass_Mono_23.wav"),
	1: preload("res://Musicas/footSteps/Footsteps_Rock_Walk_05.wav"),
	2: preload("res://Musicas/footSteps/Footsteps_DirtyGround_Walk_10.wav"),
	3: preload("res://Musicas/footSteps/Footsteps_Sand_Walk_16.wav"),
	4: preload("res://Musicas/footSteps/Footsteps_Tile_Walk_04.wav"),
	5: preload("res://Musicas/footSteps/Footsteps_Rock_Walk_05.wav"),
}

@export var step_sounds_group: Dictionary = {
	"concreto": preload("res://Musicas/footSteps/Footsteps_Rock_Walk_05.wav"),
	"pedra": preload("res://Musicas/footSteps/Footsteps_Rock_Walk_05.wav"),
	"madeira": preload("res://Musicas/footSteps/Footsteps_Rock_Walk_05.wav"),
	"tecido": preload("res://Musicas/footSteps/Footsteps_Rock_Walk_05.wav")
}

signal _update_health_bar(health, max_health)
signal _update_ki_bar(ki, max_ki)
signal _update_current_armor(id)
signal _update_current_weapon(id)

		
func update_health(health: int, max_health: int):
	if(current_health <= 0):
		die_player()
		
	_update_health_bar.emit(health, max_health)
	
func die_player():
	fundo_morte.visible = true
	var anim_interface = $playerInfo/AnimationPlayer
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	anim_interface.play("fade_in_dead")
	get_tree().paused = true
	
func _on_btn_voltar_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func update_ki(ki: int, max_ki: int):
	_update_ki_bar.emit(current_ki, max_ki)
	
func equip_armor(itemId, armorInstance, defesa, peso):
	_update_current_armor.emit(itemId)
	if(currentArmor):
		currentArmor.queue_free()
		defesa = 0
		peso = 0
		
	currentArmor = armorInstance
	defesa = Globais.current_defense
	peso = Globais.current_peso
	$mesh/protagonistaMesh/root/Skeleton3D/armor.add_child(currentArmor)
	
func equip_weapon(itemId, weaponInstance, ataque, peso):
	_update_current_weapon.emit(itemId)
	if(currentWeapon):
		currentWeapon.queue_free()
		ataque = 5
		peso = 0
		
	currentWeapon = weaponInstance
	ataque = Globais.current_attack
	peso = Globais.current_peso
	$mesh/protagonistaMesh/root/Skeleton3D/rightHandBone/weapon.add_child(currentWeapon)
	
func show_interact(texto: String, visibilidade: bool):
	var interface_interacao: TextureRect = $playerInfo/interfaceInteracao
	var texto_interacao: Label = $playerInfo/interfaceInteracao/textoInteracao
	var btn_interacao: Label = $playerInfo/interfaceInteracao/btnInteracao

	if(visibilidade == true):
		interface_interacao.visible = true
		interacao_ativa = true
		texto_interacao.text = texto
	else:
		interface_interacao.visible = false
		interacao_ativa = false
	
	if(btn_interacao.text == "E"):
		print("teclado")
	else:
		print("controle")

func get_current_texture():
	var ray_cast_3d = $RayCast3D
	ray_cast_3d.force_raycast_update()
	
	if ray_cast_3d.is_colliding():
		var terrain = ray_cast_3d.get_collider()
		
		if terrain is Terrain3D:
			var pos = terrain.to_global(ray_cast_3d.get_collision_point())
			var texture_index = terrain.data.get_texture_id(pos)
			return texture_index.y
			
	return -1
		
func get_current_surface_group():
	var ray_cast_3d = $RayCast3D
	ray_cast_3d.force_raycast_update()
	
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		
		if collider.is_in_group("madeira"):
			return "madeira"
		elif collider.is_in_group("concreto"):
			return "concreto"
		elif collider.is_in_group("pedra"):
			return "pedra"
		elif collider.is_in_group("tecido"):
			return "tecido"
	return ""

func play_step_sound():
	var texture_index = get_current_texture()
	var surface_group = get_current_surface_group()
	
	if surface_group != "" and step_sounds_group.has(surface_group):
		foot_steps.stream = step_sounds_group[surface_group]
		foot_steps.play()
		texture_index = null
	
	if texture_index == null or texture_index == -1:
		return
		
	texture_index = int(texture_index)
	
	if step_sounds.has(texture_index):
		foot_steps.stream = step_sounds[texture_index]
		foot_steps.play()

func _update_attack_anim():
	if not attackTimer.is_stopped():
		return
	
	isAttacking = true
	animation_tree_Basic.set("parameters/conditions/isAttack", isAttacking)
	
	if combo_count == 0:
		play_timer(0.56)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack1", true)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack2", false)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack3", false)
		combo_count = 1
		
	elif combo_count == 1:
		play_timer(0.36)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack1", false)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack2", true)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack3", false)
		combo_count = 2
		
	elif combo_count == 2:
		play_timer(0.56)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack1", false)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack2", false)
		animation_tree_Basic.set("parameters/swordCombo/conditions/attack3", true)
		combo_count = 0

	#animation_tree_Basic.set("parameters/conditions/isAttack", false)
	
	current_ki = current_ki - 10

func _input(event):
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if(Input.is_action_just_pressed("light") and lampiao.visible):
		lampiao.visible = false
	elif(Input.is_action_just_pressed("light") and not lampiao.visible):
		lampiao.visible = true

func _ready() -> void:
	if Globais.playerSelf != null:
		queue_free()
	else:
		Globais.playerSelf = player
	
	Globais.equipArmor(1, $".")
	Globais.equipWeapon(1, $".")
	
	for bone in skeleton_3d.get_children():
		if bone is PhysicalBone3D:
			bone.collision_layer = 0
			bone.collision_mask = 0
	
	#skeleton_3d.physical_bones_stop_simulation()
	trail_espada.visible = false
	
	#attackTimer.wait_time = 0.5
	#attackTimer.one_shot = true
	attackTimer.connect("timeout", _on_attack_timer_timeout)
	

func _physics_process(delta: float) -> void:
	idle = velocity == Vector3.ZERO

	#print("ataque atual: ", Globais.current_attack.x, " maximo: ", Globais.current_attack.y)
	
	emit_signal("_update_ki_bar", current_ki, MAX_KI)
	emit_signal("_update_health_bar", current_health, MAX_HEALTH)

	animation_tree_Basic.set("parameters/BasicMove/conditions/idle", idle)
	animation_tree_Basic.set("parameters/BasicMove/conditions/walk", !idle and not Input.is_action_pressed("run"))
	animation_tree_Basic.set("parameters/BasicMove/conditions/run", !idle and Input.is_action_pressed("run"))

	if Input.is_action_just_pressed("basicAttack") and attackTimer.is_stopped():
		_update_attack_anim()

	animation_tree_Basic.set("parameters/conditions/basicMove", !isAttacking)
	
	if not is_on_floor():
		velocity += (get_gravity() * 2) * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var horizontal_rotation = $camera/horizontal.global_transform.basis.get_euler().y
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, horizontal_rotation)

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	
		# Cria um Transform3D temporário
		var temp_transform = Transform3D(Basis(), global_transform.origin)
		
		# Aplica look_at no transform temporário
		var target_position = global_transform.origin - direction
		temp_transform = temp_transform.looking_at(target_position, Vector3.UP)
		
		# Interpola a rotação Y entre a atual e a do transform temporário
		$mesh.rotation.y = lerp_angle($mesh.rotation.y, temp_transform.basis.get_euler().y, delta * TURN_SPEED)
		
		# Mantém apenas a rotação no eixo Y
		$mesh.rotation.x = 0
		$mesh.rotation.z = 0
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	if isAttacking:
		current_speed = 2.0
	else:
		current_speed = RUN_SPEED if Input.is_action_pressed("run") else SPEED
			
	move_and_slide()
	
func play_timer(time: float):
	attackTimer.wait_time = time
	attackTimer.one_shot = true
	attackTimer.connect("timeout", _on_attack_timer_timeout)
	attackTimer.start()

func _on_attack_timer_timeout() -> void:
	isAttacking = false
	animation_tree_Basic.set("parameters/conditions/isAttack", isAttacking)
	current_speed = SPEED
	animation_tree_Basic.set("parameters/conditions/basicMove", true)
