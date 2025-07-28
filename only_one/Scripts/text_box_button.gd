extends TextureButton

var animationPlayer
var tBox
func _ready() -> void:
	animationPlayer = get_child(0)
	tBox = get_tree().get_first_node_in_group("Main Text Box")

func _on_mouse_entered() -> void:
	animationPlayer.play("text_button_flash")


func _on_mouse_exited() -> void:
	animationPlayer.play("RESET")
