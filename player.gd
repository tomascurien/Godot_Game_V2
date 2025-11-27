extends CharacterBody2D

const SPEED = 150
const JUMP_VELOCITY = -400
const GRAVITY = 1000

var inventory = []
var is_attacking: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_sound = $Ataque
@onready var jump_sound = $Salto
@onready var movement_sound = $Movimiento
@onready var death_sound = $Muerte
@onready var footstep_timer = $FootstepTimer
var is_dead: bool = false

signal died

func _ready():
	# Conectar señales
	anim.animation_finished.connect(_on_anim_finished)
	attack_area.body_entered.connect(_on_attack_hit)
	
	# Desactivar el área de ataque al inicio
	attack_area.monitoring = false
	
	print("Player listo. AttackArea: ", attack_area)

func _physics_process(delta: float) -> void:
	if is_dead:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED) # Frena suavemente
		move_and_slide()
		return 
	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Salto
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_attacking:
			anim.play("jump")
			jump_sound.play()
	# Ataque
	if Input.is_action_just_pressed("move_attack") and not is_attacking:
		print("¡ATAQUE INICIADO!")
		is_attacking = true
		velocity.x = 0
		anim.play("attack")
		attack_sound.play()
		
		# Activar área de ataque
		attack_area.monitoring = true
		print("AttackArea activada: ", attack_area.monitoring)
		
		move_and_slide()
		return
	
	# Si está atacando, no moverse
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	
	# Movimiento lateral
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if is_on_floor() and anim.animation != "jump":
			anim.play("walk")
			manage_footstep_sound()
		anim.flip_h = direction < 0
		
		# Voltear el AttackArea según la dirección
		attack_area.scale.x = -1 if direction < 0 else 1
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and anim.animation != "jump":
			anim.play("IDLE")
	
	move_and_slide()
	
	_push_boxes()

func _on_anim_finished():
	print("Animación terminada: ", anim.animation)
	
	if anim.animation == "attack":
		attack_area.monitoring = false
		is_attacking = false
		print("AttackArea desactivada")
	
	if anim.animation in ["attack", "jump"]:
		anim.play("IDLE")

func _on_attack_hit(body):
	
	if body.has_method("take_damage"):
		body.take_damage()

func add_to_inventory(item_name):
	inventory.append(item_name)
	print("Inventario: ", inventory)
	
func _push_boxes():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		
		if collider is RigidBody2D:

			
			var push_direction = collision.get_normal() * -1
			var push_force = push_direction * 5000  # Fuerza MUY alta para testear
			
			collider.apply_central_impulse(push_force * get_physics_process_delta_time())

func die():
	if is_dead:
		return

	print("El jugador ha muerto. Emitiendo señal.")
	
	is_dead = true # Esto activa el bloqueo en physics_process
	
	velocity.x = 0
	# Desactivamos la Layer 1 (o donde esté el player) para que los enemigos no lo detecten.
	# PERO NO tocamos la Mask, así que el suelo lo sigue sosteniendo.
	collision_layer = 0
	anim.play("die")
	death_sound.play()
	
	await anim.animation_finished
	print("Animación terminada. Emitiendo señal.")
	# Emite la señal para que el nivel la escuche
	died.emit()

func manage_footstep_sound():
	# Comprueba si el jugador se está moviendo Y está en el suelo
	if (velocity.x != 0) and is_on_floor():
		# Comprueba si el temporizador no está corriendo
		if footstep_timer.is_stopped():
			movement_sound.play()
			footstep_timer.start()
