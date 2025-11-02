extends CharacterBody2D 
 
const GRAVITY = 1000 
const SPEED = 80 
const TOLERANCE = 6
const PAUSE_TIME = 0.15
 
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D 
@onready var point_a: Node2D = $PatrolPointA 
@onready var point_b: Node2D = $PatrolPointB 

enum State { MOVING, PAUSED, DYING }
var current_state = State.MOVING
var patrol_target: Vector2
var pause_elapsed: float = 0.0
var point_a_pos: Vector2
var point_b_pos: Vector2
 
func _ready() -> void:
	point_a_pos = point_a.global_position
	point_b_pos = point_b.global_position
	patrol_target = point_b_pos
	anim.play("walk")
	anim.animation_finished.connect(_on_animation_finished)
	
	print("Enemy listo: ", name)
 
func _physics_process(delta: float) -> void:
	if current_state == State.DYING:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0
		velocity.x = 0
		move_and_slide()
		return
	
	if not is_on_floor(): 
		velocity.y += GRAVITY * delta 
	else: 
		velocity.y = 0
	
	match current_state:
		State.MOVING:
			_handle_movement()
		State.PAUSED:
			_handle_pause(delta)
	
	move_and_slide()

func _handle_movement() -> void:
	var dx = patrol_target.x - global_position.x
	
	if abs(dx) <= TOLERANCE:
		global_position.x = patrol_target.x
		velocity.x = 0
		anim.play("IDLE")
		current_state = State.PAUSED
		pause_elapsed = 0.0
		return
	
	var direction = sign(dx)
	velocity.x = direction * SPEED
	anim.flip_h = (direction < 0)
	
	if anim.animation != "walk":
		anim.play("walk")

func _handle_pause(delta: float) -> void:
	velocity.x = 0
	pause_elapsed += delta
	
	if pause_elapsed >= PAUSE_TIME:
		_switch_target()
		current_state = State.MOVING

func _switch_target() -> void:
	if patrol_target.is_equal_approx(point_b_pos):
		patrol_target = point_a_pos
	else:
		patrol_target = point_b_pos

func take_damage() -> void:
	if current_state == State.DYING:
		return
	
	print("¡ENEMIGO MURIENDO!")
	current_state = State.DYING
	velocity.x = 0
	velocity.y = 0
	
	# Solo desactivar collision_layer para que el player no colisione con él
	# PERO mantener collision_mask para que siga detectando el piso
	collision_layer = 0  # Nadie lo detecta
	# collision_mask lo dejamos como está para que siga colisionando con el piso
	
	if has_node("DetectionArea"):
		$DetectionArea.monitoring = false
		$DetectionArea.monitorable = false
	
	anim.play("die")
	
	# Esperar la duración de la animación
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_animation_finished() -> void:
	print("Animación enemigo terminada: ", anim.animation)
	if anim.animation == "die":
		print("Eliminando enemigo...")
		queue_free()
