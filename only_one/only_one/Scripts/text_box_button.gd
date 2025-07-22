extends TextureButton

func _on_mouse_entered() -> void:
	$AnimationPlayer.play("text_button_flash")


func _on_mouse_exited() -> void:
	$AnimationPlayer.play("RESET")
