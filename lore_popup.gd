extends CanvasLayer

@onready var label: Label = $Label
@onready var color_rect: ColorRect = $ColorRect

func set_text(text: String):
	if label:
		label.text = text
	else:
		push_warning("Label no encontrado en LorePopup")
