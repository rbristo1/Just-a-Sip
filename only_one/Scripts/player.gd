#holds player stats and data
extends Control

#stats
@export var playerName: String
@export var maxHP = 20
@export var HP = 20
@export var attack = 10
@export var speed = 10
@export var defense = 10
@export var inventoryid: Array # This is ONLY USED FOR SAVING. This is not used for storing items in game

@export var INVENTORY_ITEM_DISPLAYS: Array
@export var ITEM_INVENTORY_CAPACITY = 32
@export var MATERIAL_INVENTORY_CAPACITY = 32

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
var itemArea: Array
enum ItemTypes {D_HEALING, HEALING, P_HEALING, D_EXPLOSIVE, EXPLOSIVE, P_EXPLOSIVE,
				D_FIRE, FIRE, P_FIRE, D_ICE, ICE, P_ICE, D_POISON, POISON, P_POISON}
enum {NORMAL, EXPLOSION, FIRE, ICE, ELECTRIC, AIR, POISON, ACID, HEAL, ATK_BUFF,
		DEF_BUFF, SPD_BUFF, ATK_DROP, DEF_DROP, SPD_DROP, BURN, FREEZE, STATIC, KNOCKBACK}

#enemy 
var enemyIDs: Array
var enemyNames: Array

var enemyMaxHPs: Array
var enemyATKs: Array
var enemyDEFs: Array
var enemySPDs: Array

var enemyImagesNormal: Array
var enemyImagesCharging: Array
var enemyImagesAttacking: Array

var enemyWeaknesses: Array
var enemyResistances: Array
var enemySpecials: Array

var enemyAttackTexts: Array
var enemyAttackPowers: Array
var enemyAttackTypes: Array

var enemyBosses: Array
var enemyAreas: Array


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
	giveFreeItems()

# A comprehensive list of all types of items are in this function
func builditemJSON() -> void:
	#TODO add more items
	#create new items by appending its stats here using this format of 5 lines
	#will be removed in the final product, this is for ease of adding items.
	#please number items as you add more so indexes can be tracked
	
	#0
	itemIDs.append(ItemTypes.D_HEALING)
	itemNames.append("Diluted Healing Potion")
	itemPower.append(5)
	itemEffect.append(HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_highlighted.tres")
	itemArea.append([0, 1])
	
	#1
	itemIDs.append(ItemTypes.HEALING)
	itemNames.append("Healing Potion")
	itemPower.append(10)
	itemEffect.append(HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_highlighted.tres")
	itemArea.append([1, 2])
	
	#2
	itemIDs.append(ItemTypes.P_HEALING)
	itemNames.append("Potent Healing Potion")
	itemPower.append(15)
	itemEffect.append(HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/health_potion/health_potion_highlighted.tres")
	itemArea.append([2, 3])
	
	#3
	itemIDs.append(ItemTypes.D_EXPLOSIVE)
	itemNames.append("Diluted Explosive Flask")
	itemPower.append(5)
	itemEffect.append(EXPLOSION)
	itemImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_hover.tres")
	itemArea.append([0, 1])

	#4
	itemIDs.append(ItemTypes.EXPLOSIVE)
	itemNames.append("Explosive Flask")
	itemPower.append(10)
	itemEffect.append(EXPLOSION)
	itemImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_hover.tres")
	itemArea.append([1, 2])

	#5
	itemIDs.append(ItemTypes.P_EXPLOSIVE)
	itemNames.append("Potent Explosive Flask")
	itemPower.append(15)
	itemEffect.append(EXPLOSION)
	itemImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/explosive_flask/explosive_flask_hover.tres")
	itemArea.append([2, 3])
	
	#6
	itemIDs.append(ItemTypes.D_FIRE)
	itemNames.append("Diluted Fire Flask")
	itemPower.append(5)
	itemEffect.append(FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_hover.tres")
	itemArea.append([0, 1])

	#7
	itemIDs.append(ItemTypes.FIRE)
	itemNames.append("Fire Flask")
	itemPower.append(10)
	itemEffect.append(FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_hover.tres")
	itemArea.append([1, 2])
	
	#8
	itemIDs.append(ItemTypes.P_FIRE)
	itemNames.append("Potent Fire Flask")
	itemPower.append(15)
	itemEffect.append(FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/fire_flask/fire_flask_hover.tres")
	itemArea.append([2, 3])
	
	#9
	itemIDs.append(ItemTypes.D_ICE)
	itemNames.append("Diluted Ice Flask")
	itemPower.append(5)
	itemEffect.append(ICE)
	itemImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_hover.tres")
	itemArea.append([0, 1])
	
	#10
	itemIDs.append(ItemTypes.ICE)
	itemNames.append("Ice Flask")
	itemPower.append(10)
	itemEffect.append(ICE)
	itemImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_hover.tres")
	itemArea.append([1, 2])
	
	#11
	itemIDs.append(ItemTypes.P_ICE)
	itemNames.append("Potent Ice Flask")
	itemPower.append(15)
	itemEffect.append(ICE)
	itemImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/ice_flask/ice_flask_hover.tres")
	itemArea.append([2, 3])
	
	#12
	itemIDs.append(ItemTypes.D_POISON)
	itemNames.append("Diluted Poison Flask")
	itemPower.append(5)
	itemEffect.append(POISON)
	itemImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_hover.tres")
	itemArea.append([0, 1])
	
	#13
	itemIDs.append(ItemTypes.POISON)
	itemNames.append("Poison Flask")
	itemPower.append(10)
	itemEffect.append(POISON)
	itemImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_hover.tres")
	itemArea.append([1, 2])

	#14
	itemIDs.append(ItemTypes.P_POISON)
	itemNames.append("Potent Poison Flask")
	itemPower.append(15)
	itemEffect.append(POISON)
	itemImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/poison_flask/poison_flask_hover.tres")
	itemArea.append([2, 3])


	
	var save_dict = {
		"itemIDs" :itemIDs,
		"itemNames" : itemNames,
		"itemPower" : itemPower,
		"itemEffect" : itemEffect,
		"itemImage": itemImage,
		"itemHImage": itemHImage,
		"itemArea": itemArea
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
	enemyIDs.append(0)
	enemyNames.append("Whipkin") # A small rodent that is long like a weasel with big bunny like ears
	enemyMaxHPs.append(10)
	enemyATKs.append(4)
	enemyDEFs.append(6)
	enemySPDs.append(7)
	enemyImagesNormal.append("res://Art/Items/blue_potion.png")
	enemyImagesCharging.append(null)
	enemyImagesAttacking.append(null)
	enemyWeaknesses.append([])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Tail Slap"])
	enemyAttackPowers.append([2])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(false)
	enemyAreas.append([0, 1])
	
	#1
	enemyIDs.append(1)
	enemyNames.append("Slime")
	enemyMaxHPs.append(15)
	enemyATKs.append(5)
	enemyDEFs.append(5)
	enemySPDs.append(5)
	enemyImagesNormal.append("res://Art/Enemies/slime.png")
	enemyImagesCharging.append(null)
	enemyImagesAttacking.append(null)
	enemyWeaknesses.append([ICE])
	enemyResistances.append([FIRE])
	enemySpecials.append([ACID])
	enemyAttackTexts.append(["Bounce"])
	enemyAttackPowers.append([3])
	enemyAttackTypes.append([ACID])
	enemyBosses.append(false)
	enemyAreas.append([0, 1])
	
	#2
	enemyIDs.append(2)
	enemyNames.append("Noxious Shroom")
	enemyMaxHPs.append(13)
	enemyATKs.append(8)
	enemyDEFs.append(5)
	enemySPDs.append(8)
	enemyImagesNormal.append("res://Art/Enemies/Zombie Idle.png")
	enemyImagesCharging.append(null)
	enemyImagesAttacking.append(null)
	enemyWeaknesses.append([FIRE, ACID])
	enemyResistances.append([POISON])
	enemySpecials.append([])
	enemyAttackTexts.append(["Noxious Puff", "Ram"])
	enemyAttackPowers.append([2, 3])
	enemyAttackTypes.append([POISON, NORMAL])
	enemyBosses.append(false)
	enemyAreas.append([1])
	
	var save_dict = {
		"enemyIDs" : enemyIDs,
		"enemyNames" : enemyNames,
		"enemyMaxHPs" : enemyMaxHPs,
		"enemyATKs" : enemyATKs,
		"enemyDEFs" : enemyDEFs,
		"enemySPDs" : enemySPDs,
		"enemyImagesNormal" : enemyImagesNormal,
		"enemyImagesCharging" : enemyImagesCharging,
		"enemyImagesAttacking" : enemyImagesAttacking,
		"enemyWeaknesses" : enemyWeaknesses,
		"enemyResistances" : enemyResistances,
		"enemySpecials" : enemySpecials,
		"enemyAttackTexts" : enemyAttackTexts,
		"enemyAttackPowers" : enemyAttackPowers,
		"enemyAttackTypes" : enemyAttackTypes,
		"enemyBosses" : enemyBosses,
		"enemyAreas" : enemyAreas
	}
	
	var saveFile = FileAccess.open(enemiesFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)

#for manually creating or altering player savedata.
func createSave() -> void:
	inventoryid = [0, 0, 1]
	HP = 20
	var save_dict = {
		"maxhp" : maxHP,
		"hp" : HP,
		"spd" : speed,
		"def": defense,
		"atk": attack,
		"inventoryid": inventoryid
	}
	var saveFile = FileAccess.open(playerFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)

#saves player data
func savePlayer() -> void:
	var save_dict = {
		"maxhp" : maxHP,
		"hp" : HP,
		"spd" : speed,
		"def": defense,
		"atk": attack,
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

# Adds an item to the inventory array using the itemID
func addItemToInventory(id: int) -> void:
	var iName = itemNames[id]
	var iPower = itemPower[id]
	var iEffect = itemEffect[id]
	var iImage = load(itemImage[id])
	var iHImage = load(itemHImage[id])
	var iArea = itemArea[id]
	
	# Deferred to ensure the item exists completely before messing with its attributes
	if (itemInventoryNum != 32):
		itemInventory[itemInventoryNum].initialize(id, itemInventoryNum, iName, iEffect, iPower, iImage, iHImage, iArea)
		itemInventoryNum += 1
		shiftInventoryLeft(0)
		updateInventoryDisplay(-1, -1)

func removeItemFromInventory(slotNumber: int, mode: int) -> void:
	if (mode == 1):
		materialInventory[slotNumber].uninitialize()
	else:
		itemInventory[slotNumber].uninitialize()
		
	if (isCurrentlyDisplayed(slotNumber, mode)):
		@warning_ignore("integer_division")
		INVENTORY_ITEM_DISPLAYS[slotNumber/16].unlink()
	
	shiftInventoryLeft(mode)
	updateInventoryDisplay(-1, -1)

# Checks if the item in the given item slot number is currently being displayed
func isCurrentlyDisplayed(itemSlotNumber:int, mode: bool) -> bool:
	@warning_ignore("integer_division")
	if (inventoryMode != mode or itemSlotNumber/16 != inventoryPage):
		return false
	return true

# Shifts all items to the far left of the inventory to remove gaps
func shiftInventoryLeft(mode: int):
	var inventory
	if (mode == -1):
		mode = inventoryMode
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
		linkItemtoInventoryDisplay(i + (page * 16), mode, i)

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
							toLink.itemArea)

func findAndRemoveFromInventory(displayNum: int, swap: bool) -> void:
	# The index should be (displayNum - 1) * inventoryPage
	var inventory
	if (inventoryMode == 1):
		inventory = materialInventory
	else:
		inventory = itemInventory
	inventory[(displayNum - 1) * (inventoryPage + 1)].deinitialize()
	itemInventoryNum -= 1
	if (!swap):
		shiftInventoryLeft(-1)
	updateInventoryDisplay(-1, -1)

func findAndAddToInventory(toAdd: Dictionary, displayNum: int, swap: bool) -> void:
	if (inventoryMode == 1):
		pass # TODO add functionality when inventory_material is created
	else:
		toAdd["iSlot"] = (displayNum - 1) * (inventoryPage + 1)
		itemInventory[toAdd["iSlot"]].initializeDict(toAdd)
		itemInventoryNum += 1
	if (!swap):
		shiftInventoryLeft(-1)
	updateInventoryDisplay(-1, -1)

#for debugging file imports
func statLog() -> void:
	print("hp: ")
	print(HP)
	print("maxhp: ")
	print(maxHP)
	print("def: ")
	print(defense)
	print("spd: ")
	print(speed)
	print("atk: ")
	print(attack)
	print("inv: ")
	print(inventoryid)
	print(itemNames)
	print(itemPower)
	print(itemEffect)
	print(itemImage)
	print(itemArea)

func giveFreeItems() -> void:
	for i in 16:
		addItemToInventory(randi() % 15)
		
func takeDamage(amount: int) -> void:
		HP -= amount

func heal(amount: int) -> void:
	HP += amount
	if (HP > maxHP):
		HP = maxHP

func spawnRandomAreaItem(area: int, iDisplay: ItemDisplay) -> void:
	var itemPool: Array =[]
	for i in itemArea.size():
		for j in itemArea[i].size():
			if (itemArea[i][j] == area):
				itemPool.append(i)
	
	var iID = itemPool[randi_range(0, itemPool.size() - 1)]
	iDisplay.link(itemIDs[iID], itemNames[iID], itemEffect[iID], itemPower[iID],
	load(itemImage[iID]), load(itemHImage[iID]), itemArea[iID])
