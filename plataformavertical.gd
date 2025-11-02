extends AnimatableBody2D

var is_moving_up: bool = false
var is_moving_down: bool = false
var target_position_up: Vector2
var target_position_down: Vector2
var movement_speed: float = 35.0  # Píxeles por segundo

func _ready():
	# Guardar las posiciones objetivo
	target_position_down = position  # Posición inicial (abajo)
	target_position_up = position + Vector2(0, -145)  # 200 píxeles arriba (ajusta según necesites)

func activate():
	print("Plataforma: señal de activación recibida")
	
	if is_moving_up:
		return
	
	# Cancelar el tween actual si existe
	if is_moving_down:
		is_moving_down = false
	
	print("Plataforma subiendo...")
	is_moving_up = true
	
	# Crear tween para mover suavemente
	var tween = create_tween()
	var distance = position.distance_to(target_position_up)
	var duration = distance / movement_speed
	
	tween.tween_property(self, "position", target_position_up, duration)
	await tween.finished
	
	is_moving_up = false
	print("Plataforma arriba")

func deactivate():
	print("Plataforma: señal de desactivación recibida")
	
	if is_moving_down:
		return
	
	# Cancelar el tween actual si existe
	if is_moving_up:
		is_moving_up = false
	
	print("Plataforma bajando...")
	is_moving_down = true
	
	# Crear tween para mover suavemente
	var tween = create_tween()
	var distance = position.distance_to(target_position_down)
	var duration = distance / movement_speed
	
	tween.tween_property(self, "position", target_position_down, duration)
	await tween.finished
	
	is_moving_down = false
	print("Plataforma abajo")
