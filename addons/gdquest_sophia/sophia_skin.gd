extends CharacterBody3D

class_name Player

@export_category("Movement")
@export var SPEED: float = 5.0
@export var RUN_SPEED: float = 18.0
@export var TURN_SPEED = 5  # Aumentado para rotação mais suave
@export var JUMP_VELOCITY = 12.0
var current_speed = SPEED

@onready var animation_player: AnimationPlayer = $mesh/AnimationPlayer
#@onready var animation_tree = %AnimationTree
#@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path : String = "parameters/StateMachine/Move/tilt/add_amount"

#var run_tilt = 0.0 : set = _set_run_tilt

@export var blink = true : set = set_blink
@onready var blink_timer = %BlinkTimer
@onready var closed_eyes_timer = %ClosedEyesTimer
@onready var eye_mat = $mesh/rig/Skeleton3D/Sophia.get("surface_material_override/2")

var knockbacked: bool = false
@export var coins: int = 0
@onready var coin_amount: Label = $Interface/CoinContainer/coinAmount
@export var Health: int = 5
@onready var health_amount: Label = $Interface/HealthContainer/healthAmount

@onready var interface_morte: Control = $Interface/telaDerrota


func _physics_process(delta: float) -> void:
	if(velocity == Vector3.ZERO):
		animation_player.play("Idle")
	
	if not is_on_floor():
		velocity += (get_gravity() * 2) * delta
		animation_player.play("Fall")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		animation_player.play("Jump")
		velocity.y = JUMP_VELOCITY
		
	var horizontal_rotation = $camera/horizontal.global_transform.basis.get_euler().y
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, horizontal_rotation)

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if(not velocity == Vector3.ZERO and is_on_floor()):
			animation_player.play("Run")
		
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
		
	move_and_slide()

func _ready():
	Globals.global_player = self
	coin_amount.text = str(coins)
	_setup_animation_blends()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	blink_timer.connect("timeout", func():
		eye_mat.set("uv1_offset", Vector3(0.0, 0.5, 0.0))
		closed_eyes_timer.start(0.2)
		)
		
	closed_eyes_timer.connect("timeout", func():
		eye_mat.set("uv1_offset", Vector3.ZERO)
		blink_timer.start(randf_range(1.0, 4.0))
		)
		
func collect_coins(quant: int):
	coins += quant
	coin_amount.text = str(coins)
	
func update_health(dano: int):
	Health -= dano
	health_amount.text = str(Health)
	if(Health <= 0):
		get_tree().paused = true
		await get_tree().create_timer(0.4).timeout
		interface_morte.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func set_blink(state : bool):
	if blink == state: return
	blink = state
	if blink:
		blink_timer.start(0.2)
	else:
		blink_timer.stop()
		closed_eyes_timer.stop()
		
func knockback(impact_point: Vector3, force: Vector3):
	force.y = abs(force.y)
	velocity = force.limit_length(15.0)
		
func _setup_animation_blends() -> void:
	var anims = ["Idle", "Run", "Jump", "Fall"]
	for from_anim in anims:
		for to_anim in anims:
			if from_anim != to_anim:
				animation_player.set_blend_time(from_anim, to_anim, 0.2)

func _on_damage_attack_body_entered(body: Node3D) -> void:
	if(body.is_in_group("enemy") or body.is_in_group("spike")):
		var body_collision = (body.global_position - global_position)
		var force = -body_collision
		force *= 15.0
		knockback(body_collision, force)
		body.HEALTH = body.HEALTH - 1
		knockbacked = true
		await get_tree().create_timer(0.3).timeout
		knockbacked = false
		if(body.HEALTH <= 0):
			collect_coins(10)
			await get_tree().create_timer(1.0).timeout
			body.queue_free()
