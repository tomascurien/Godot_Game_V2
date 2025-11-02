extends CanvasLayer  

func _on_Jugar_pressed():
	print("Boton jugar apretado")
	get_tree().change_scene_to_file("res://level_1.tscn")
