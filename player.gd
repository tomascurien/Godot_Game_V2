extends CharacterBody2D

const SPEED = 150
const JUMP_VELOCITY = -400
const GRAVITY = 1000

var inventory = []
var is_attacking: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
signal died

func _ready():
	# Conectar señales
	anim.animation_finished.connect(_on_anim_finished)
	attack_area.body_entered.connect(_on_attack_hit)
	
	# Desactivar el área de ataque al inicio
	attack_area.monitoring = false
	
	print("Player listo. AttackArea: ", attack_area)

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Salto
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if not is_attacking:
			anim.play("jump")
	
	# Ataque
	if Input.is_action_just_pressed("move_attack") and not is_attacking:
		print("¡ATAQUE INICIADO!")
		is_attacking = true
		velocity.x = 0
		anim.play("attack")
		
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
		anim.flip_h = direction < 0
		
		# NUEVO: Voltear el AttackArea según la dirección
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
	if $CollisionShape2D.disabled:
		return 

	print("El jugador ha muerto. Emitiendo señal.")
	
	# 3. Emite la señal para que el nivel la escuche
	died.emit()
	
	# Desactiva al jugador
	$CollisionShape2D.disabled = true
	anim.play("die")
	
