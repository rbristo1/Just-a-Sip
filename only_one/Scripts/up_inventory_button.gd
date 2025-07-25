extends TextureButton
var pHud
var downButton
func _ready() -> void:
	pHud = get_tree().get_first_node_in_group("Player Hud")
	var nodes = get_tree().get_nodes_in_group("Inventory Buttons")
	
	for node in nodes:
		if node != self:
			downButton = node
			
	if pHud.inventoryPage == 0:
		disabled = true
	


func _on_button_up() -> void:
	var mode = pHud.inventoryMode
	var page = pHud.inventoryPage
	
	# The plan is to have the item pages scroll when you use the arrows. The
	# player will not have the ablility to chose the inventory mode
	# (items or materials) both for simplicities sake, and to make it so the
	# player can't even try to add a material into a normal item slot.
	
	if (page != 0):
		pHud.ShiftInventoryLeft(-1)
		pHud.updateInventoryDisplay(-1, page - 1)
		pHud.inventoryPage = page - 1
		if (page - 1 <= 0):
			disabled = true
		else:
			disabled = false

		downButton.disabled = false
