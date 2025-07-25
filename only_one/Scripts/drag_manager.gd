extends Node

var tBox
@export var isDragging: bool = false:
	set(value):
		if (isDragging != value):
			isDragging = value
			OnDragStateChanged(value)
			
func _ready() -> void:
	tBox = get_tree().get_first_node_in_group("Main Text Box")

func OnDragStateChanged(value: bool):
	if (value == false):
		var hovered = get_viewport().gui_get_hovered_control()
		
		if (hovered is ItemDisplay and hovered.itemID != -1):
			hovered.displayText()
		else:
			tBox.stopShowingTempText()
