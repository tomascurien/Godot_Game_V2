extends RigidBody2D

const PUSH_FORCE = 80  # Ajusta este valor

func _integrate_forces(state):
	# Limitar velocidad horizontal para que no se deslice infinitamente
	if abs(linear_velocity.x) > 200:
		linear_velocity.x = sign(linear_velocity.x) * 200
	
	# Agregar un poco de fricción extra cuando está quieta
	if abs(linear_velocity.x) < 5:
		linear_velocity.x = 0
