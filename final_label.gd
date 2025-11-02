extends CanvasLayer

func _on_VolverAlMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://portada.tscn")
