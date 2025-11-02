extends Area2D

signal lever_activated
signal lever_deactivated

var is_active: bool = false
var bodies_on_lever: int = 0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Configurar para detectar solo Layer 1 (caja y jugador)
	collision_layer = 0
	collision_mask = 1

func _on_body_entered(body):
	print("Cuerpo entró en palanca: ", body.name)
	bodies_on_lever += 1
	
	if not is_active:
		is_active = true
		print("¡Palanca ACTIVADA!")
		lever_activated.emit()
		# Opcional: cambiar sprite o animación
		modulate = Color(0, 1, 0)  # Verde cuando está activada

func _on_body_exited(body):
	print("Cuerpo salió de palanca: ", body.name)
	bodies_on_lever -= 1
	
	if bodies_on_lever <= 0 and is_active:
		is_active = false
		bodies_on_lever = 0  # Asegurar que no sea negativo
		print("¡Palanca DESACTIVADA!")
		lever_deactivated.emit()
		# Opcional: cambiar sprite
		modulate = Color(1, 1, 1)  # Blanco normal
