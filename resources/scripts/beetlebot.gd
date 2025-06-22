extends CharacterBody3D

class_name Enemy

@export var HEALTH = 2
@export var SPEED = 180.0
@export var CHASE_RANGE = 8.0
@export var ATTACK_RANGE = 2.0
@export var JUMP_VELOCITY = 4.5

var target: CharacterBody3D
@onready var navigation_3d: NavigationAgent3D = $Navigation3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine

func _ready() -> void:
	target = Globals.global_player
	
	state_machine = animation_tree.get("parameters/StateMachine/playback")

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Idle":
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		"Walk":
			if(global_position.distance_to(target.global_position) < CHASE_RANGE):
				navigation_3d.set_target_position(target.global_transform.origin)
				var nextPoint = navigation_3d.get_next_path_position()
				velocity = (nextPoint - global_transform.origin).normalized() * SPEED * delta
				look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		"Attack":
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
			
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	animation_tree.set("parameters/StateMachine/conditions/walk", chase_player() and !attack_player())
	animation_tree.set("parameters/StateMachine/conditions/idle", !chase_player() and !attack_player())
	animation_tree.set("parameters/StateMachine/conditions/attack", attack_player())
	
	move_and_slide()

func chase_player():
	return global_position.distance_to(target.global_position) < CHASE_RANGE
	
func attack_player():
	return global_position.distance_to(target.global_position) < ATTACK_RANGE
