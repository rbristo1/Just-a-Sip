extends TextureButton

var pHud
var upButton
var itemCapacity
var materialCapacity
func _ready() -> void:
	pHud = get_tree().get_first_node_in_group("Player Hud")
	var nodes = get_tree().get_nodes_in_group("Inventory Buttons")
	itemCapacity = pHud.ITEM_INVENTORY_CAPACITY / 16
	materialCapacity = pHud.MATERIAL_INVENTORY_CAPACITY/ 16
	for node in nodes:
		if node != self:
			upButton = node
			
		if pHud.inventoryMode != 1 and pHud.inventoryPage >= pHud.ITEM_INVENTORY_CAPACITY / 16:
			disabled = true
		elif pHud.inventoryMode == 1 and pHud.inventoryPage >= pHud.MATERIAL_INVENTORY_CAPACITY / 16:
			disabled = true
		else:
			disabled = false


func _on_button_up() -> void:
	var mode = pHud.inventoryMode
	var page = pHud.inventoryPage
	
	# The plan is to have the item pages scroll when you use the arrows. The
	# player will not have the ablility to chose the inventory mode
	# (items or materials) both for simplicities sake, and to make it so the
	# player can't even try to add a material into a normal item slot.

	if mode != 1 and page != itemCapacity:
		pHud.shiftInventoryLeft(-1)
		pHud.updateInventoryDisplay(-1, page + 1)
		pHud.inventoryPage = page + 1
		upButton.disabled = false
		if page + 2 >= itemCapacity:
			disabled = true
		
	elif mode == 1 and page != materialCapacity:
		pHud.shiftInventoryLeft(-1)
		pHud.updateInventoryDisplay(-1, page + 1)
		pHud.inventoryPage = page + 1
		upButton.disabled = false
		if page + 2 >= materialCapacity:
			disabled = true
			
