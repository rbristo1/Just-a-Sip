extends TextureButton



func _on_button_down() -> void:
	$AnimationPlayer.play("run_button_pressed")


func _on_button_up() -> void:
	$AnimationPlayer.play("RESET")
