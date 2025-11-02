extends StaticBody2D

@export var lore_text: String = "Una voz susurra desde los libros: 'El rey teme lo que no puede controlar.'"

var player_in_range = false
var popup_instance = null

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		player_in_range = true
		show_lore_popup(lore_text)

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_in_range = false
		hide_lore_popup()

func show_lore_popup(text: String):
	if popup_instance:
		return
	var popup = preload("res://lore_popup.tscn").instantiate()
	popup.set_text(text)
	get_tree().current_scene.add_child(popup)
	popup_instance = popup

func hide_lore_popup():
	if popup_instance:
		popup_instance.queue_free()
		popup_instance = null
