extends CharacterBody2D 
 
const GRAVITY = 1000 
const SPEED = 80 
const TOLERANCE = 6
const PAUSE_TIME = 0.15
 
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D 
@onready var point_a: Node2D = $PatrolPointA 
@onready var point_b: Node2D = $PatrolPointB 
@onready var attack_area: Area2D = $AttackArea
var target_player: Node = null
enum State { MOVING, ATTACK, PAUSED, DYING }
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
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)
	attack_area.body_entered.connect(_on_attack_area_entered)
	attack_area.monitoring = true

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
		State.ATTACK:
			velocity.x = 0
	
	move_and_slide()

func _handle_movement() -> void:
	var dx = patrol_target.x - global_position.x
	
	if abs(dx) <= TOLERANCE:
		global_position.x = patrol_target.x
		velocity.x = 0
		anim.play("idle")
		current_state = State.PAUSED
		pause_elapsed = 0.0
		return
	
	var direction = sign(dx)
	velocity.x = direction * SPEED
	if direction != 0:
		# 1. Voltear el Sprite (Visual)
		anim.flip_h = (direction < 0)
		
		# 2. Voltear el Area de Ataque (Física)
		# Si va a la derecha (1), scale.x = 1. Si va a la izquierda (-1), scale.x = -1.
		attack_area.scale.x = direction
	
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
	
func _on_attack_area_entered(body):
	print("ALGO entró en el área de ataque: ", body.name) # DEBUG 1
	
	if current_state == State.DYING:
		print("El enemigo está muriendo, ignora ataque.")
		return

	if body.is_in_group("player"):
		print("¡Es el Player! Llamando a _start_attack") # DEBUG 2
		_start_attack(body)
	else:
		print("El objeto NO está en el grupo player. Grupos: ", body.get_groups()) # DEBUG 3

func _start_attack(player):
	if current_state == State.ATTACK:
		return  # ya estoy atacando
	print("Iniciando ataque...") ### Debug
	current_state = State.ATTACK
	target_player = player
	velocity.x = 0
	anim.play("attack")


func _on_animation_finished() -> void:
	print("Animación enemigo terminada: ", anim.animation)
	if anim.animation == "die":
		print("Eliminando enemigo...")
	if anim.animation == "attack":
		# Verificamos si el jugador sigue en el área de ataque al momento del golpe
		if is_instance_valid(target_player) and attack_area.overlaps_body(target_player):
			if target_player.has_method("die"):
				target_player.die()
				print("El enemigo golpeó al jugador!")
				anim.play("IDLE")
				current_state = State.PAUSED
				
				pause_elapsed = -9999.0
				return
		
		# Volver a patrullar después de atacar
		print("Ataque terminado, volviendo a patrulla")
		current_state = State.MOVING
		target_player = null
