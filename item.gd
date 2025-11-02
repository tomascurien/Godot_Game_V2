extends Area2D

@export var item_name: String = "key"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("add_to_inventory"):
		body.add_to_inventory(item_name)
		queue_free()
