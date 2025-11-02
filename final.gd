extends Area2D

signal door_opened

@export var required_item: String = "key"

@onready var sprite_closed: Sprite2D = $SpriteClosed
@onready var sprite_open: Sprite2D = $SpriteOpen

func _ready():
	sprite_open.visible = false  # puerta empieza cerrada
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and "inventory" in body:
		if required_item in body.inventory:
			print("¡Has ganado!")
			open_door()
		else:
			print("Te falta la llave...")

func open_door():
	sprite_closed.visible = false
	sprite_open.visible = true
	$CollisionShape2D.disabled = true
	door_opened.emit()
