extends TextureButton

@onready var pHud = $"../../.."

func _on_button_up() -> void:
	pHud.createItem(randi() % 15)
