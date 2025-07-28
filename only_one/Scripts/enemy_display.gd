extends TextureRect

var battleManager
var tBox
var enemyID
var animationPlayer
var disabled = false
var hovering = false
var eSlot
var normalTexture
var chargeTexture
var attackTexture
var activeTexture = -1

func _ready() -> void:
	battleManager = get_tree().get_first_node_in_group("Battle Manager")
	tBox = get_tree().get_first_node_in_group("Main Text Box")
	animationPlayer = get_child(0)
	
func _on_battle_manager_groups_populated() -> void:
	eSlot = battleManager.getEnemySlot(self, "eDisplays")
	
func changeActiveTexture(mode: int) -> void: # 0: normal, 1: charge, 2: attack
	activeTexture = mode
	if (activeTexture == 0 and normalTexture != null):
		texture = load(normalTexture)
	elif (activeTexture == 1 and chargeTexture != null):
		texture = load(chargeTexture)
	elif (activeTexture == 2 and attackTexture != null):
		texture = load(attackTexture)
	else:
		texture = null
	
func disable(killed: bool) -> void:
	disabled = true
	activeTexture = -1
	if (killed):
		animationPlayer.play("flashAndDie")
		await animationPlayer.animation_finished
		texture = null
	else:
		texture = null
	
func enable() -> void:
	disabled = false
	texture = activeTexture
	
func _on_mouse_entered() -> void:
	if (disabled == false):
		if (DragManager.isDragging == false):
			displayText()
		hovering = true

func _on_mouse_exited() -> void:
	if (disabled == false):
		if (DragManager.isDragging == false):
			stopDisplayingText()
		hovering = false

func displayText():
	if (disabled == false):
		if (tBox != null):
			var toTempDisplay = get_child(1).createText()
			tBox.showTempText(toTempDisplay)
	
func stopDisplayingText():
	if (disabled == false):
		if (tBox != null and DragManager.isDragging == false):
			tBox.stopShowingTempText()
