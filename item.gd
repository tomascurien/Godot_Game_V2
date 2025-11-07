extends Area2D
@onready var pickup_sound = $PickupSound
@export var item_name: String = "key"
@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("add_to_inventory"):
		body.add_to_inventory(item_name)
		collision.disabled = true
		sprite.visible = false # Oculta la llave
		
		pickup_sound.play()
		
		
		await pickup_sound.finished
		queue_free()
