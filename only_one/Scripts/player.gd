#holds player stats and data
extends Control

#stats
@export var maxhp = 100
@export var hp = 100
@export var spd = 100
@export var def = 100
@export var atk = 100
@export var inventoryid: Array # This is ONLY USED FOR SAVING. This is not used for storing items in game

@export var INVENTORY_ITEM_DISPLAYS: Array
@export var ITEM_INVENTORY_CAPCITY = 32

# Inventory Stuff
# Item Inventory
var itemInventory: Array
var itemInventoryNum = 0 # The number of items currently in the inventory, max 32
# Material Inventory
var materialInventory: Array
var materialInventoryNum = 0
# General Inventory
var inventoryMode = 0 # 0 for item, 1 for materials
var inventoryPage = 0 # 16 slots per page, it IS 0 indexed in the code, even though it is not in display


#item lookup caching, for retrieval as indexes in constant time
var itemIDs: Array
var itemNames: Array
var itemPower: Array
var itemEffect: Array
var itemImage: Array
var itemHImage: Array
var itemSplash: Array
enum ItemTypes {D_HEALING, HEALING, P_HEALING, D_EXPLOSIVE, EXPLOSIVE, P_EXPLOSIVE,
				D_FIRE, FIRE, P_FIRE, D_ICE, ICE, P_ICE, D_POISON, POISON, P_POISON}
enum EType {HEAL, EXPLODE, FIRE, ICE, POISON}

#enemy 
var enemyIDs: Array
var enemyNames: Array
var enemyMaxHP: Array
var enemyHP: Array
var enemyATK: Array
var enemySPD: Array
var enemyDEF: Array
var enemyImage: Array
var enemySplash: Array
var enemyUndead: Array
var area: Array
enum EnemyTypes {SLIME, ZOMBIE}


#filename
@export var itemsFile = "res://JSONS/items.JSON"
@export var playerFile = "res://JSONS/player.JSON"
@export var enemiesFile = "res://JSONS/enemies.JSON"




func _ready() -> void:
	
	INVENTORY_ITEM_DISPLAYS = get_tree().get_nodes_in_group("Inventory Item Displays")
	
	# Create inventory
	itemInventory.resize(32)
	materialInventory.resize(32)
	
	var itemScene = preload("res://Scenes/inventory_item.tscn")
	
	for i in itemInventory.size(): 
		var instance = itemScene.instantiate()
		itemInventory[i] = instance
		
	builditemJSON()
	buildEnemyJSON()
	#TODO remove createSave and builditemJSON at completion
	#createSave()
	loadPlayer()
	loaditems()
	
	#TEST
	#statLog()
	
	




# A comprehensive list of all types of items are in this function
func builditemJSON() -> void:
	#TODO add more items
	#create new items by appending its stats here using this format of 5 lines
	#will be removed in the final product, this is for ease of adding items.
	#please number items as you add more so indexes can be tracked
	
	#0
	itemIDs.append(ItemTypes.D_HEALING)
	itemNames.append("Diluted Healing Potion")
	itemPower.append(50)
	itemEffect.append(EType.HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_highlighted.tres")
	itemSplash.append(false)
	
	#1
	itemIDs.append(ItemTypes.HEALING)
	itemNames.append("Healing Potion")
	itemPower.append(100)
	itemEffect.append(EType.HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_highlighted.tres")
	itemSplash.append(false)
	
	#2
	itemIDs.append(ItemTypes.P_HEALING)
	itemNames.append("Potent Healing Potion")
	itemPower.append(150)
	itemEffect.append(EType.HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_highlighted.tres")
	itemSplash.append(false)
	
	#3
	itemIDs.append(ItemTypes.D_EXPLOSIVE)
	itemNames.append("Diluted Explosive Flask")
	itemPower.append(50)
	itemEffect.append(EType.EXPLODE)
	itemImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_hover.tres")
	itemSplash.append(false)

	#4
	itemIDs.append(ItemTypes.EXPLOSIVE)
	itemNames.append("Explosive Flask")
	itemPower.append(100)
	itemEffect.append(EType.EXPLODE)
	itemImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_hover.tres")
	itemSplash.append(false)

	#5
	itemIDs.append(ItemTypes.P_EXPLOSIVE)
	itemNames.append("Potent Explosive Flask")
	itemPower.append(150)
	itemEffect.append(EType.EXPLODE)
	itemImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_hover.tres")
	itemSplash.append(false)
	
	#6
	itemIDs.append(ItemTypes.D_FIRE)
	itemNames.append("Diluted Fire Flask")
	itemPower.append(50)
	itemEffect.append(EType.FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_hover.tres")
	itemSplash.append(false)

	#7
	itemIDs.append(ItemTypes.FIRE)
	itemNames.append("Fire Flask")
	itemPower.append(100)
	itemEffect.append(EType.FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_hover.tres")
	itemSplash.append(false)
	
	#8
	itemIDs.append(ItemTypes.P_FIRE)
	itemNames.append("Potent Fire Flask")
	itemPower.append(150)
	itemEffect.append(EType.FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_hover.tres")
	itemSplash.append(false)
	
	#9
	itemIDs.append(ItemTypes.D_ICE)
	itemNames.append("Diluted Ice Flask")
	itemPower.append(50)
	itemEffect.append(EType.ICE)
	itemImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_hover.tres")
	itemSplash.append(false)
	
	#10
	itemIDs.append(ItemTypes.ICE)
	itemNames.append("Ice Flask")
	itemPower.append(100)
	itemEffect.append(EType.ICE)
	itemImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_hover.tres")
	itemSplash.append(false)
	
	#11
	itemIDs.append(ItemTypes.P_ICE)
	itemNames.append("Potent Ice Flask")
	itemPower.append(150)
	itemEffect.append(EType.ICE)
	itemImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_hover.tres")
	itemSplash.append(false)
	
	#12
	itemIDs.append(ItemTypes.D_POISON)
	itemNames.append("Diluted Poison Flask")
	itemPower.append(50)
	itemEffect.append(EType.POISON)
	itemImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_hover.tres")
	itemSplash.append(false)
	
	#13
	itemIDs.append(ItemTypes.POISON)
	itemNames.append("Poison Flask")
	itemPower.append(100)
	itemEffect.append(EType.POISON)
	itemImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_hover.tres")
	itemSplash.append(false)

	#14
	itemIDs.append(ItemTypes.P_POISON)
	itemNames.append("Potent Poison Flask")
	itemPower.append(150)
	itemEffect.append(EType.POISON)
	itemImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_hover.tres")
	itemSplash.append(false)


	
	var save_dict = {
		"itemIDs" :itemIDs,
		"itemNames" : itemNames,
		"itemPower" : itemPower,
		"itemEffect" : itemEffect,
		"itemImage": itemImage,
		"itemHImage": itemHImage,
		"itemSplash": itemSplash
	}
	var saveFile = FileAccess.open(itemsFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)






#builds enemy json like items
func buildEnemyJSON() -> void:
	#TODO add more enemies
	#create new enemies by appending its stats here using this format
	#will be removed in the final product, this is for ease of adding enemies.
	#please number items as you add more so indexes can be tracked
	
	#0
	enemyIDs.append(EnemyTypes.SLIME)
	enemyNames.append("Slime")
	enemyATK.append(100)
	enemyDEF.append(100)
	enemySPD.append(100)
	enemyMaxHP.append(100)
	enemyHP.append(100)
	enemyImage.append("res://Art/Enemies/slime.png")
	enemySplash.append(false)
	enemyUndead.append(false)
	area.append(0)
	
	#1
	enemyIDs.append(EnemyTypes.ZOMBIE)
	enemyNames.append("Zombie")
	enemyATK.append(100)
	enemyDEF.append(100)
	enemySPD.append(100)
	enemyMaxHP.append(100)
	enemyHP.append(100)
	enemyImage.append("res://Art/Enemies/Zombie Idle.png")
	enemySplash.append(false)
	enemyUndead.append(true)
	area.append(0)
	
	var save_dict = {
		"enemyIDs" : enemyIDs,
		"enemyNames" : enemyNames,
		"enemyATK" : enemyATK,
		"enemyDEF" : enemyDEF,
		"enemySPD" : enemySPD,
		"enemyMaxHP" : enemyMaxHP,
		"enemyHP" : enemyHP,
		"enemyImage" : enemyImage,
		"enemySplash" : enemySplash,
		"enemyUndead" : enemyUndead
	}
	var saveFile = FileAccess.open(enemiesFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)





#for manually creating or altering player savedata.
func createSave() -> void:
	inventoryid = [0, 0, 1]
	hp = 50
	var save_dict = {
		"maxhp" : maxhp,
		"hp" : hp,
		"spd" : spd,
		"def": def,
		"atk": atk,
		"inventoryid": inventoryid
	}
	var saveFile = FileAccess.open(playerFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)





#saves player data
func savePlayer() -> void:
	var save_dict = {
		"maxhp" : maxhp,
		"hp" : hp,
		"spd" : spd,
		"def": def,
		"atk": atk,
		"inventoryid": inventoryid
	}
	var saveFile = FileAccess.open(playerFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)





#loads player stats at initialization
func loadPlayer() -> void:
	if not FileAccess.file_exists(playerFile):
		return
	else:
		var save_file = FileAccess.open(playerFile, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var node_data = json.data
			for i in node_data.keys():
				set(i, node_data[i])





#loads items into arrays so that they can quickly and easily be retrived by index
func loaditems() -> void:
	if not FileAccess.file_exists(itemsFile):
		return
	else:
		var save_file = FileAccess.open(itemsFile, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)	
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var node_data = json.data
			for i in node_data.keys():
				set(i, node_data[i])
				

func AddItemToInventory(id: int) -> void:
	var iName = itemNames[id]
	var iPower = itemPower[id]
	var iEffect = itemEffect[id]
	var iImage = load(itemImage[id])
	var iHImage = load(itemHImage[id])
	var iSplash = itemSplash[id]
	var iSlotNum = 0
	
	# Deferred to ensure the item exists completely before messing with its attributes
	if (itemInventoryNum != 32):
		itemInventory[itemInventoryNum].initialize(id, itemInventoryNum, iName, iPower, iEffect, iImage, iHImage, iSplash)
		itemInventoryNum += 1
		ShiftInventoryLeft(0)
		updateInventoryDisplay(-1, -1)
	
func RemoveItemFromInventory(slotNumber: int, mode: int) -> void:
	if (mode == 1):
		materialInventory[slotNumber].uninitialize()
	else:
		itemInventory[slotNumber].uninitialize()
		
	if (isCurrentlyDisplayed(slotNumber, mode)):
		@warning_ignore("integer_division")
		INVENTORY_ITEM_DISPLAYS[slotNumber/16].unlink()
	
	ShiftInventoryLeft(mode)
	updateInventoryDisplay(-1, -1)
	
func isCurrentlyDisplayed(itemSlotNumber:int, mode: bool) -> bool:
	@warning_ignore("integer_division")
	if (inventoryMode != mode or itemSlotNumber/16 != inventoryPage):
		return false
	return true

func ShiftInventoryLeft(mode: int):
	var inventory
	if (mode == 1):
		inventory = materialInventory
	else:
		inventory = itemInventory
	
	var itemScene = preload("res://Scenes/inventory_item.tscn")
	
	var count = 0
	var tempArray: Array
	tempArray.resize(32)
	for i in inventory.size():
		if (inventory[i].itemID != -1):
			tempArray[count] = inventory[i]
			count += 1
			
	for c in range(count, tempArray.size()):
		tempArray[c] = itemScene.instantiate()
	if (mode == 1):
		materialInventory = tempArray
	else:
		itemInventory = tempArray

	

func updateInventoryDisplay(mode: int, page: int) -> void:
	if (mode == -1):
		mode = inventoryMode
	if (page == -1):
		page = inventoryPage
		
	inventoryMode = mode
	for i in 16:
		linkItemtoInventoryDisplay(i * (page + 1), mode, i)
	
func linkItemtoInventoryDisplay(item: int, mode: int, space: int) -> void:
	var inventory
	
	if (mode == 1):
		inventory = materialInventory
	else:
		inventory = itemInventory
		
	var toLink = inventory[item]
	
	if (toLink.itemID != null):
		# We need to link the thing from the itemInventory into the itemDisplay
		# Start by finding the item display we need
		var slot = find_child("InventoryItemSlot{0}".format([space + 1]), true)
	
		# Now we can replace any information in that spot by linking it
		slot.get_child(0).link(toLink.itemID, toLink.itemName, toLink.itemEffect, 
							toLink.itemPower, toLink.itemImage, toLink.itemHoverImage, 
							toLink.itemSplash)
	



#for debugging file imports
func statLog() -> void:
	print("hp: ")
	print(hp)
	print("maxhp: ")
	print(maxhp)
	print("def: ")
	print(def)
	print("spd: ")
	print(spd)
	print("atk: ")
	print(atk)
	print("inv: ")
	print(inventoryid)
	print(itemNames)
	print(itemPower)
	print(itemEffect)
	print(itemImage)
	print(itemSplash)
