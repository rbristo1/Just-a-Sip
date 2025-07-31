extends Node
@export var playerFile = "res://JSONS/player.JSON"
@export var mapFile = "res://JSONS/map.JSON"
func _on_texture_button_pressed() -> void:
	if FileAccess.file_exists(mapFile):
		DirAccess.remove_absolute(mapFile)
	if FileAccess.file_exists(playerFile):
		DirAccess.remove_absolute(playerFile)
	get_tree().change_scene_to_file("res://Scenes/map.tscn")
