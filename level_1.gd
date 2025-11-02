extends Node2D
@export var player_node : Node2D

func _ready():
	$Player.died.connect(_on_player_died)
	
func _on_player_died():
	print("Señal 'died' recibida del jugador. Mostrando pantalla de muerte.")
	$Muerte.show()
	get_tree().paused = true


func _on_final_door_opened() -> void:
	print("¡Señal 'door_opened' recibida! El jugador ha ganado.")
	
	$FinalLabel.show()
	
	get_tree().paused = true
