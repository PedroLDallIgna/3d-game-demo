extends CharacterBody3D

class_name Enemy

var player: CharacterBody3D
var idle: bool = true
var is_attacking: bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $mesh/protagonistaMesh/AnimationPlayer
@onready var attackTimer: Timer = $attackTimer
@onready var foot_steps: AudioStreamPlayer3D = $footSteps
@onready var area_collision: Area3D = $mesh/protagonistaMesh/root/Skeleton3D/rightHandBone/weapon/espadaBasicaTeste/AreaCollision
@onready var detection_area: Area3D = $detectionArea

var player_in_detection_area: bool = false
var random_direction: Vector3 = Vector3.ZERO  # Direção para movimento aleatório
var change_direction_timer: float = 0.0  # Temporizador para mudar direção
var change_direction_interval: float = randf_range(3.0, 8.0) # Intervalo em segundos para mudar direção

@export var moveSpeed: float = 10.0
@export var attackRange: float = 2.5
@export var attackDamageRange: Vector2 = Vector2(15, 25)
@export var healthEnemy: int = 100

# Limites para o movimento aleatório
@export var min_random_distance: float = 5.0
@export var max_random_distance: float = 10.0

var combo_count: int = 0
@export var max_sword_combo: int = 3

@export_category("Passos")
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

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	attackTimer.connect("timeout", _on_attack_timer_timeout)
	detection_area.connect("body_entered", _on_detection_area_body_entered)
	detection_area.connect("body_exited", _on_detection_area_body_exited)
	_setup_animation_blends()

func _process(delta: float) -> void:
	if player_in_detection_area:
		# Seguir o jogador usando a navmesh
		is_attacking = attack_in_range()
		if is_attacking:
			_update_attack_anim()
		else:
			_update_movement_anim()
		navigation_agent.set_target_position(player.global_position)
	else:
		# Movimento aleatório dentro da navmesh
		change_direction_timer += delta
		if change_direction_timer >= change_direction_interval:
			change_direction_timer = 0.0
			# Gerar um ponto aleatório dentro de um raio limitado
			var random_point = _get_random_point_in_navmesh()
			navigation_agent.set_target_position(random_point)
		_update_movement_anim()

	# Olhar na direção do próximo ponto do caminho
	if not navigation_agent.is_navigation_finished():
		var nextPos = navigation_agent.get_next_path_position()
		look_at(Vector3(nextPos.x, global_position.y, nextPos.z), Vector3.UP)

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
	else:
		var nextPos: Vector3 = navigation_agent.get_next_path_position()
		velocity = global_position.direction_to(nextPos) * moveSpeed

	idle = velocity.length_squared() < 0.01
	move_and_slide()
	
func die():
	self.queue_free()

func in_self_damage(playerAttack: Vector2):
	healthEnemy -= randi_range(playerAttack.x, playerAttack.y)
	print("dano inimigo: ", str(healthEnemy))
	
	if(healthEnemy <= 0):
		die()

func attack_in_range() -> bool:
	return global_position.distance_to(player.global_position) < attackRange

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	area_collision.monitoring = false

func _on_area_collision_body_entered(body: Node3D) -> void:
	if (body is Player and is_attacking):
		var spawn_location = body.global_transform.origin
		spawn_location.y += 1
		Globais.spawn_blood(spawn_location)
		Globais.damage_player(attackDamageRange.x, attackDamageRange.y)

func _update_attack_anim():
	if not attackTimer.is_stopped():
		return
	is_attacking = true
	area_collision.monitoring = true

	match combo_count:
		0:
			animation_player.play("attackCombo1")
			play_timer(0.56)
			combo_count = 1
		1:
			animation_player.play("attackCombo2")
			play_timer(0.36)
			combo_count = 2
		2:
			animation_player.play("attackCombo3")
			play_timer(0.56)
			combo_count = 0

func _update_movement_anim():
	if is_attacking:
		return
	
	if idle:
		if not animation_player.is_playing() or animation_player.current_animation != "idlev3":
			animation_player.play("idlev3")
	else:
		if not animation_player.is_playing() or animation_player.current_animation != "runv4":
			animation_player.play("runv4")

func play_timer(time: float):
	attackTimer.stop()
	attackTimer.wait_time = time
	attackTimer.one_shot = true
	attackTimer.start()

func _setup_animation_blends() -> void:
	var anims = ["idlev3", "runv4", "attackCombo1", "attackCombo2", "attackCombo3"]
	for from_anim in anims:
		for to_anim in anims:
			if from_anim != to_anim:
				animation_player.set_blend_time(from_anim, to_anim, 0.2)

func _get_random_point_in_navmesh() -> Vector3:
	# Gerar uma distância aleatória entre min_random_distance e max_random_distance
	var distance = randf_range(min_random_distance, max_random_distance)
	# Gerar uma direção aleatória em 2D (no plano XZ)
	var angle = randf() * 2.0 * PI
	var random_direction = Vector3(cos(angle), 0.0, sin(angle)).normalized()
	# Calcular o ponto candidato
	var candidate_point = global_position + random_direction * distance
	# Garantir que o ponto está na NavMesh
	var nav_map = navigation_agent.get_navigation_map()
	var closest_point = NavigationServer3D.map_get_closest_point(nav_map, candidate_point)
	return closest_point

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
		return

	if texture_index == null or texture_index == -1:
		return

	texture_index = int(texture_index)
	if step_sounds.has(texture_index):
		foot_steps.stream = step_sounds[texture_index]
		foot_steps.play()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body == player:
		player_in_detection_area = true

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == player:
		player_in_detection_area = false
