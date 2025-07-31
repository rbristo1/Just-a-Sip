extends TextureButton

signal run


func _on_button_down() -> void:
	$AnimationPlayer.play("run_button_pressed")
	await $AnimationPlayer.animation_finished

func _on_button_up() -> void:
	$AnimationPlayer.play("RESET")

func runComplete() -> void:
	run.emit()
