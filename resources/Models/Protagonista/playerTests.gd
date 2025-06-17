extends CharacterBody3D

var SPEED: float = 12.0
var RUN_SPEED: float = 18.0
var current_speed = SPEED

const TURN_SPEED = 4
const JUMP_VELOCITY = 12.0
const MOUSE_SENSIVITY = 0.05

@onready var pivot = $Pivot
@onready var mesh = $mesh
#@onready var animation_tree: AnimationTree = $mesh/protagonistaMesh/AnimationPlayer/AnimationTree
@onready var animation_tree_Basic: AnimationTree = $mesh/protagonistaMesh/AnimationPlayer/AnimationTree
@onready var animation_player: AnimationPlayer = $mesh/protagonistaMesh/AnimationPlayer
@onready var player: CharacterBody3D = $"."

func _input(event):
	# Remove o cursor do mouse
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Rotação da câmera
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-(event as InputEventMouseMotion).relative.x * MOUSE_SENSIVITY))
		mesh.rotate_y(deg_to_rad((event as InputEventMouseMotion).relative.x * MOUSE_SENSIVITY))
		
		pivot.rotate_x(deg_to_rad(-(event as InputEventMouseMotion).relative.y * MOUSE_SENSIVITY))
		pivot.rotation.x = deg_to_rad(clamp(rad_to_deg(pivot.rotation.x), -75, -25))

func _physics_process(delta: float) -> void:
	# Verifica se o personagem está parado
	var idle = velocity == Vector3.ZERO
	
	# animation_player.speed_scale = 2

	# Atualiza as condições da animação
	animation_tree_Basic.set("parameters/BasicMove/conditions/idle", idle)
	animation_tree_Basic.set("parameters/BasicMove/conditions/walk", !idle and not Input.is_action_pressed("run"))
	animation_tree_Basic.set("parameters/BasicMove/conditions/run", !idle and Input.is_action_pressed("run"))

	# Adiciona gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtém direção do input
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Verifica se está correndo
	
	if Input.is_action_pressed("run"):
		current_speed = RUN_SPEED
	else:
		current_speed = SPEED

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		var prev_y = mesh.rotation.y
		mesh.look_at(Vector3(position.x, position.y - 2.8, position.z) + -direction)
		var target_y = mesh.rotation.y
		mesh.rotation.y = lerp_angle(prev_y, target_y, delta * TURN_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
