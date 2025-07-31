#holds player stats and data
extends Control

#stats
@export var playerName: String
@export var maxHP = 20
@export var HP = 20
@export var attack = 10
@export var speed = 10
@export var defense = 10
var inventoryid: Array# This is ONLY USED FOR SAVING. This is not used for storing items in game

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
enum ItemTypes {D_HEALING, HEALING, P_HEALING, D_BLAST, BLAST, P_BLAST, D_FIRE, FIRE, P_FIRE, 
				D_ICE, ICE, P_ICE, D_ELECTRIC, ELECTRIC, P_ELECTRIC, D_WIND, WIND, P_WIND,
				D_POISON, POISON, P_POISON, D_ACID, ACID, P_ACID, D_STRENGTH, STRENGTH, P_STRENGTH,
				D_SHIELD, SHIELD, P_SHIELD, D_SWIFTNESS, SWIFTNESS, P_SWIFTNESS, D_WEAKNESS, WEAKNESS, P_WEAKNESS,
				D_VULNERABILITY, VULERABILITY, P_VULNERABILITY, D_SLOWNESS, SLOWNESS, P_SLOWNESS,
				D_BURN, BURN, P_BURN, D_FREEZE, FREEZE, P_FREEZE, D_STATIC, STATIC, P_STATIC,
				D_POISONING, POISONING, P_POISONING, D_CORROSION, CORROSION, P_CORROSION}
enum {NORMAL, EXPLOSION, FIRE, ICE, ELECTRIC, WIND, POISON, ACID, HEAL, ATK_BUFF,
		DEF_BUFF, SPD_BUFF, ATK_DROP, DEF_DROP, SPD_DROP, BURN, FREEZE, STATIC, KNOCKBACK, POISONING, CORROSION}

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
@export var mapFile = "res://JSONS/map.JSON"


func _ready() -> void:
	createEvents()
	
	INVENTORY_ITEM_DISPLAYS = get_tree().get_nodes_in_group("Inventory Item Displays")
	
	# Create inventory
	itemInventory.resize(32)
	materialInventory.resize(32)
	
	var itemScene = preload("res://Scenes/inventory_item.tscn")
	
	for i in itemInventory.size(): 
		var instance = itemScene.instantiate()
		itemInventory[i] = instance
	loaditems()
	builditemJSON()
	buildEnemyJSON()
	#giveFreeItems()
	#TODO remove createSave and builditemJSON at completion
	#savePlayer()
	#createSave()
	if FileAccess.file_exists(playerFile):
		loadPlayer()
	else:
			addItemToInventory(ItemTypes.D_HEALING)
			addItemToInventory(ItemTypes.D_BLAST)
			addItemToInventory(ItemTypes.D_FIRE)
			addItemToInventory(ItemTypes.D_ICE)
			addItemToInventory(ItemTypes.D_ELECTRIC)
			addItemToInventory(ItemTypes.D_WIND)
			addItemToInventory(ItemTypes.D_POISON)
			addItemToInventory(ItemTypes.D_ACID)
	
	
	#TEST

var events: Array = []
@export var eventsFile = "res://JSONS/events.JSON"

func createEvents() -> void:
	var temp = []
	temp.append("You stumble across a shelf lined with various flasks, now yours for the taking.")
	events.append(temp)
	temp = []
	temp.append("Nestled beneath the moss you find a satchel, brimming with glass bottles pulsing faintly.")
	events.append(temp)
	temp = []
	temp.append("You hear a soft clink, and spot some potions tucked beneath old bones.")
	events.append(temp)
	temp = []
	temp.append("The remnants of an alchemist’s workstation lie scattered across the floor.")
	temp.append("A few potions remain still vibrant, still volatile.")
	events.append(temp)
	temp = []
	temp.append("A skeletal hand juts from a collapsed tunnel wall, clutching a pouch.")
	temp.append("Inside, multiple vials rattle together.")
	events.append(temp)
	temp = []
	temp.append("You hear a soft clink, and spot a potion tucked beneath old bones.")
	events.append(temp)
	temp = []
	temp.append("A ritual circle stains the floor in dried ink and ash.")
	temp.append("Scattered around its edges are several potions, seeming to have been placed deliberately...")
	events.append(temp)
	var save_dict = {
		"events": events
	}
	var saveFile = FileAccess.open(eventsFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)

# A comprehensive list of all types of items are in this function
func builditemJSON() -> void:
	#TODO add more items
	#create new items by appending its stats here using this format of 5 lines
	#will be removed in the final product, this is for ease of adding items.
	#please number items as you add more so indexes can be tracked
	
	var powerMultiplier = 5
	
	#0
	itemIDs.append(ItemTypes.D_HEALING)
	itemNames.append("Diluted Healing Potion")
	itemPower.append(1)
	itemEffect.append(HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/Health/Diluted/Diluted_Health_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Health/Diluted/Diluted_Health_Hover.tres")
	itemArea.append([0, 1])
	
	#1
	itemIDs.append(ItemTypes.HEALING)
	itemNames.append("Healing Potion")
	itemPower.append(2)
	itemEffect.append(HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/Health/Normal/Normal_Health_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Health/Normal/Normal_Health_Hover.tres")
	itemArea.append([1, 2])
	
	#2
	itemIDs.append(ItemTypes.P_HEALING)
	itemNames.append("Potent Healing Potion")
	itemPower.append(3)
	itemEffect.append(HEAL)
	itemImage.append("res://Art/Atlas Textures/Items/Health/Potent/Potent_Health_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Health/Potent/Potent_Health_Hover.tres")
	itemArea.append([2, 3])
	
	#3
	itemIDs.append(ItemTypes.D_BLAST)
	itemNames.append("Diluted Blast Flask")
	itemPower.append(1)
	itemEffect.append(EXPLOSION)
	itemImage.append("res://Art/Atlas Textures/Items/Blast/Diluted/Diluted_Blast_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Blast/Diluted/Diluted_Blast_Hover.tres")
	itemArea.append([0, 1])

	#4
	itemIDs.append(ItemTypes.BLAST)
	itemNames.append("Blast Flask")
	itemPower.append(2)
	itemEffect.append(EXPLOSION)
	itemImage.append("res://Art/Atlas Textures/Items/Blast/Normal/Normal_Blast_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Blast/Normal/Normal_Blast_Hover.tres")
	itemArea.append([1, 2])

	#5
	itemIDs.append(ItemTypes.P_BLAST)
	itemNames.append("Potent Blast Flask")
	itemPower.append(3)
	itemEffect.append(EXPLOSION)
	itemImage.append("res://Art/Atlas Textures/Items/Blast/Potent/Potent_Blast_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Blast/Potent/Potent_Blast_Hover.tres")
	itemArea.append([2, 3])
	
	#6
	itemIDs.append(ItemTypes.D_FIRE)
	itemNames.append("Diluted Fire Flask")
	itemPower.append(1)
	itemEffect.append(FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/Fire/Diluted/Diluted_Fire_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Fire/Diluted/Diluted_Fire_Hover.tres")
	itemArea.append([0, 1])

	#7
	itemIDs.append(ItemTypes.FIRE)
	itemNames.append("Fire Flask")
	itemPower.append(2)
	itemEffect.append(FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/Fire/Normal/Normal_Fire_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Fire/Normal/Normal_Fire_Hover.tres")
	itemArea.append([1, 2])
	
	#8
	itemIDs.append(ItemTypes.P_FIRE)
	itemNames.append("Potent Fire Flask")
	itemPower.append(3)
	itemEffect.append(FIRE)
	itemImage.append("res://Art/Atlas Textures/Items/Fire/Potent/Potent_Fire_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Fire/Potent/Potent_Fire_Hover.tres")
	itemArea.append([2, 3])
	
	#9
	itemIDs.append(ItemTypes.D_ICE)
	itemNames.append("Diluted Ice Flask")
	itemPower.append(1)
	itemEffect.append(ICE)
	itemImage.append("res://Art/Atlas Textures/Items/Ice/Diluted/Diluted_Ice_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Ice/Diluted/Diluted_Ice_Hover.tres")
	itemArea.append([0, 1])
	
	#10
	itemIDs.append(ItemTypes.ICE)
	itemNames.append("Ice Flask")
	itemPower.append(2)
	itemEffect.append(ICE)
	itemImage.append("res://Art/Atlas Textures/Items/Ice/Normal/Normal_Ice_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Ice/Normal/Normal_Ice_Hover.tres")
	itemArea.append([1, 2])
	
	#11
	itemIDs.append(ItemTypes.P_ICE)
	itemNames.append("Potent Ice Flask")
	itemPower.append(3)
	itemEffect.append(ICE)
	itemImage.append("res://Art/Atlas Textures/Items/Ice/Potent/Potent_Ice_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Ice/Potent/Potent_Ice_Hover.tres")
	itemArea.append([2, 3])
	
	#12
	itemIDs.append(ItemTypes.D_ELECTRIC)
	itemNames.append("Diluted Electric Flask")
	itemPower.append(1)
	itemEffect.append(ELECTRIC)
	itemImage.append("res://Art/Atlas Textures/Items/Electric/Diluted/Diluted_Electric_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Electric/Diluted/Diluted_Electric_Hover.tres")
	itemArea.append([0, 1])
	
	#13
	itemIDs.append(ItemTypes.ELECTRIC)
	itemNames.append("Electric Flask")
	itemPower.append(2)
	itemEffect.append(ELECTRIC)
	itemImage.append("res://Art/Atlas Textures/Items/Electric/Normal/Normal_Electric_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Electric/Normal/Normal_Electric_Hover.tres")
	itemArea.append([1, 2])
	
	#14
	itemIDs.append(ItemTypes.P_ELECTRIC)
	itemNames.append("Potent Electric Flask")
	itemPower.append(3)
	itemEffect.append(ELECTRIC)
	itemImage.append("res://Art/Atlas Textures/Items/Electric/Potent/Potent_Electric_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Electric/Potent/Potent_Electric_Hover.tres")
	itemArea.append([2, 3])
	
	#15
	itemIDs.append(ItemTypes.D_WIND)
	itemNames.append("Diluted Wind Flask")
	itemPower.append(1)
	itemEffect.append(WIND)
	itemImage.append("res://Art/Atlas Textures/Items/Wind/Diluted/Diluted_Wind_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Wind/Diluted/Diluted_Wind_Hover.tres")
	itemArea.append([0, 1])
	
	#16
	itemIDs.append(ItemTypes.WIND)
	itemNames.append("Wind Flask")
	itemPower.append(2)
	itemEffect.append(WIND)
	itemImage.append("res://Art/Atlas Textures/Items/Wind/Normal/Normal_Wind_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Wind/Normal/Normal_Wind_Hover.tres")
	itemArea.append([1, 2])
	
	#17
	itemIDs.append(ItemTypes.P_WIND)
	itemNames.append("Potent Wind Flask")
	itemPower.append(3)
	itemEffect.append(WIND)
	itemImage.append("res://Art/Atlas Textures/Items/Wind/Potent/Potent_Wind_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Wind/Potent/Potent_Wind_Hover.tres")
	itemArea.append([2, 3])
	
	#18
	itemIDs.append(ItemTypes.D_POISON)
	itemNames.append("Diluted Poison Flask")
	itemPower.append(1)
	itemEffect.append(POISON)
	itemImage.append("res://Art/Atlas Textures/Items/Poison/Diluted/Diluted_Poison_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Poison/Diluted/Diluted_Poison_Hover.tres")
	itemArea.append([0, 1])
	
	#19
	itemIDs.append(ItemTypes.POISON)
	itemNames.append("Poison Flask")
	itemPower.append(2)
	itemEffect.append(POISON)
	itemImage.append("res://Art/Atlas Textures/Items/Poison/Normal/Normal_Poison_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Poison/Normal/Normal_Poison_Hover.tres")
	itemArea.append([1, 2])

	#20
	itemIDs.append(ItemTypes.P_POISON)
	itemNames.append("Potent Poison Flask")
	itemPower.append(3)
	itemEffect.append(POISON)
	itemImage.append("res://Art/Atlas Textures/Items/Poison/Potent/Potent_Poison_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Poison/Potent/Potent_Poison_Hover.tres")
	itemArea.append([2, 3])
	
	#21
	itemIDs.append(ItemTypes.D_ACID)
	itemNames.append("Diluted Acid Flask")
	itemPower.append(1)
	itemEffect.append(ACID)
	itemImage.append("res://Art/Atlas Textures/Items/Acid/Diluted/Diluted_Acid_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Acid/Diluted/Diluted_Acid_Hover.tres")
	itemArea.append([0, 1])
	
	#22
	itemIDs.append(ItemTypes.ACID)
	itemNames.append("Acid Flask")
	itemPower.append(2)
	itemEffect.append(ACID)
	itemImage.append("res://Art/Atlas Textures/Items/Acid/Normal/Normal_Acid_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Acid/Normal/Normal_Acid_Hover.tres")
	itemArea.append([1, 2])
	
	#23
	itemIDs.append(ItemTypes.P_ACID)
	itemNames.append("Potent Acid Flask")
	itemPower.append(3)
	itemEffect.append(ACID)
	itemImage.append("res://Art/Atlas Textures/Items/Acid/Potent/Potent_Acid_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Acid/Potent/Potent_Acid_Hover.tres")
	itemArea.append([2, 3])
	
	#24
	itemIDs.append(ItemTypes.D_STRENGTH)
	itemNames.append("Diluted Strength Potion")
	itemPower.append(1)
	itemEffect.append(ATK_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Strength/Diluted/Diluted_Strength_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Strength/Diluted/Diluted_Strength_Hover.tres")
	itemArea.append([0, 1])
	
	#25
	itemIDs.append(ItemTypes.STRENGTH)
	itemNames.append("Strength Potion")
	itemPower.append(2)
	itemEffect.append(ATK_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Strength/Normal/Normal_Strength_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Strength/Normal/Normal_Strength_Hover.tres")
	itemArea.append([1, 2])
	
	#26
	itemIDs.append(ItemTypes.P_STRENGTH)
	itemNames.append("Potent Strength Potion")
	itemPower.append(3)
	itemEffect.append(STATIC)
	itemImage.append("res://Art/Atlas Textures/Items/Strength/Potent/Potent_Strength_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Strength/Potent/Potent_Strength_Hover.tres")
	itemArea.append([2, 3])
	
	#27
	itemIDs.append(ItemTypes.D_SHIELD)
	itemNames.append("Diluted Shield Potion")
	itemPower.append(1)
	itemEffect.append(DEF_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Shield/Diluted/Diluted_Shield_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Shield/Diluted/Diluted_Shield_Hover.tres")
	itemArea.append([0, 1])
	
	#28
	itemIDs.append(ItemTypes.SHIELD)
	itemNames.append("Shield Potion")
	itemPower.append(2)
	itemEffect.append(DEF_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Shield/Normal/Normal_Shield_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Shield/Normal/Normal_Shield_Hover.tres")
	itemArea.append([1, 2])
	
	#29
	itemIDs.append(ItemTypes.P_SHIELD)
	itemNames.append("Potent Shield Potion")
	itemPower.append(3)
	itemEffect.append(DEF_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Shield/Potent/Potent_Shield_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Shield/Potent/Potent_Shield_Hover.tres")
	itemArea.append([2, 3])
	
	#30
	itemIDs.append(ItemTypes.D_SWIFTNESS)
	itemNames.append("Diluted Swiftness Potion")
	itemPower.append(1)
	itemEffect.append(SPD_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Swiftness/Diluted/Diluted_Swiftness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Swiftness/Diluted/Diluted_Swiftness_Hover.tres")
	itemArea.append([0, 1])
	
	#31
	itemIDs.append(ItemTypes.SWIFTNESS)
	itemNames.append("Swiftness Potion")
	itemPower.append(2)
	itemEffect.append(SPD_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Swiftness/Normal/Normal_Swiftness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Swiftness/Normal/Normal_Swiftness_Hover.tres")
	itemArea.append([1, 2])
	
	#32
	itemIDs.append(ItemTypes.P_SWIFTNESS)
	itemNames.append("Potent Swiftness Potion")
	itemPower.append(3)
	itemEffect.append(SPD_BUFF)
	itemImage.append("res://Art/Atlas Textures/Items/Swiftness/Potent/Potent_Swiftness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Swiftness/Potent/Potent_Swiftness_Hover.tres")
	itemArea.append([2, 3])
	
	#33
	itemIDs.append(ItemTypes.D_WEAKNESS)
	itemNames.append("Diluted Weakness Flask")
	itemPower.append(1)
	itemEffect.append(ATK_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Weakness/Diluted/Diluted_Weakness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Weakness/Diluted/Diluted_Weakness_Hover.tres")
	itemArea.append([0, 1])
	
	#34
	itemIDs.append(ItemTypes.WEAKNESS)
	itemNames.append("Weakness Flask")
	itemPower.append(2)
	itemEffect.append(ATK_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Weakness/Normal/Normal_Weakness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Weakness/Normal/Normal_Weakness_Hover.tres")
	itemArea.append([1, 2])
	
	#35
	itemIDs.append(ItemTypes.P_WEAKNESS)
	itemNames.append("Potent Weakness Flask")
	itemPower.append(3)
	itemEffect.append(ATK_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Weakness/Potent/Potent_Weakness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Weakness/Potent/Potent_Weakness_Hover.tres")
	itemArea.append([2, 3])
	
	#36
	itemIDs.append(ItemTypes.D_VULNERABILITY)
	itemNames.append("Diluted Vulnerability Flask")
	itemPower.append(1)
	itemEffect.append(DEF_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Vulnerability/Diluted/Diluted_Vulnerability_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Vulnerability/Diluted/Diluted_Vulnerability_Hover.tres")
	itemArea.append([0, 1])
	
	#37
	itemIDs.append(ItemTypes.VULERABILITY)
	itemNames.append("Vulnerability Flask")
	itemPower.append(2)
	itemEffect.append(DEF_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Vulnerability/Normal/Normal_Vulnerability_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Vulnerability/Normal/Normal_Vulnerability_Hover.tres")
	itemArea.append([1, 2])
	
	#38
	itemIDs.append(ItemTypes.P_VULNERABILITY)
	itemNames.append("Potent Vulnerability Flask")
	itemPower.append(3)
	itemEffect.append(DEF_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Vulnerability/Potent/Potent_Vulnerability_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Vulnerability/Potent/Potent_Vulnerability_Hover.tres")
	itemArea.append([2, 3])
	
	#39
	itemIDs.append(ItemTypes.D_SLOWNESS)
	itemNames.append("Diluted Slowness Flask")
	itemPower.append(1)
	itemEffect.append(SPD_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Slowness/Diluted/Diluted_Slowness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Slowness/Diluted/Diluted_Slowness_Hover.tres")
	itemArea.append([0, 1])
	
	#40
	itemIDs.append(ItemTypes.SLOWNESS)
	itemNames.append("Slowness Flask")
	itemPower.append(2)
	itemEffect.append(SPD_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Slowness/Normal/Normal_Slowness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Slowness/Normal/Normal_Slowness_Hover.tres")
	itemArea.append([1, 2])
	
	#41
	itemIDs.append(ItemTypes.P_SLOWNESS)
	itemNames.append("Potent Slowness Flask")
	itemPower.append(3)
	itemEffect.append(SPD_DROP)
	itemImage.append("res://Art/Atlas Textures/Items/Slowness/Potent/Potent_Slowness_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Slowness/Potent/Potent_Slowness_Hover.tres")
	itemArea.append([2, 3])
	
	#42
	itemIDs.append(ItemTypes.D_BURN)
	itemNames.append("Diluted Burn Flask")
	itemPower.append(1)
	itemEffect.append(BURN)
	itemImage.append("res://Art/Atlas Textures/Items/Burn/Diluted/Diluted_Burn_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Burn/Diluted/Diluted_Burn_Hover.tres")
	itemArea.append([0, 1])
	
	#43
	itemIDs.append(ItemTypes.BURN)
	itemNames.append("Burn Flask")
	itemPower.append(2)
	itemEffect.append(BURN)
	itemImage.append("res://Art/Atlas Textures/Items/Burn/Normal/Normal_Burn_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Burn/Normal/Normal_Burn_Hover.tres")
	itemArea.append([1, 2])
	
	#44
	itemIDs.append(ItemTypes.P_BURN)
	itemNames.append("Potent Burn Flask")
	itemPower.append(3)
	itemEffect.append(BURN)
	itemImage.append("res://Art/Atlas Textures/Items/Burn/Potent/Potent_Burn_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Burn/Potent/Potent_Burn_Hover.tres")
	itemArea.append([2, 3])
	
	#45
	itemIDs.append(ItemTypes.D_FREEZE)
	itemNames.append("Diluted Frost Flask")
	itemPower.append(1)
	itemEffect.append(FREEZE)
	itemImage.append("res://Art/Atlas Textures/Items/Freeze/Diluted/Diluted_Freeze_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Freeze/Diluted/Diluted_Freeze_Hover.tres")
	itemArea.append([0, 1])
	
	#46
	itemIDs.append(ItemTypes.FREEZE)
	itemNames.append("Frost Flask")
	itemPower.append(2)
	itemEffect.append(FREEZE)
	itemImage.append("res://Art/Atlas Textures/Items/Freeze/Normal/Normal_Freeze_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Freeze/Normal/Normal_Freeze_Hover.tres")
	itemArea.append([1, 2])
	
	#47
	itemIDs.append(ItemTypes.P_FREEZE)
	itemNames.append("Potent Frost Flask")
	itemPower.append(3)
	itemEffect.append(FREEZE)
	itemImage.append("res://Art/Atlas Textures/Items/Freeze/Potent/Potent_Freeze_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Freeze/Potent/Potent_Freeze_Hover.tres")
	itemArea.append([2, 3])
	
	#48
	itemIDs.append(ItemTypes.D_STATIC)
	itemNames.append("Diluted Static Flask")
	itemPower.append(1)
	itemEffect.append(STATIC)
	itemImage.append("res://Art/Atlas Textures/Items/Static/Diluted/Diluted_Static_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Static/Diluted/Diluted_Static_Hover.tres")
	itemArea.append([0, 1])
	
	#49
	itemIDs.append(ItemTypes.STATIC)
	itemNames.append("Static Flask")
	itemPower.append(2)
	itemEffect.append(STATIC)
	itemImage.append("res://Art/Atlas Textures/Items/Static/Normal/Normal_Static_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Static/Normal/Normal_Static_Hover.tres")
	itemArea.append([1, 2])
	
	#50
	itemIDs.append(ItemTypes.P_STATIC)
	itemNames.append("Potent Static Flask")
	itemPower.append(3)
	itemEffect.append(STATIC)
	itemImage.append("res://Art/Atlas Textures/Items/Static/Potent/Potent_Static_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Static/Potent/Potent_Static_Hover.tres")
	itemArea.append([2, 3])
	
	#51
	itemIDs.append(ItemTypes.D_POISONING)
	itemNames.append("Diluted Venomous Flask")
	itemPower.append(1)
	itemEffect.append(POISONING)
	itemImage.append("res://Art/Atlas Textures/Items/Poisoning/Diluted/Diluted_Poisoning_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Poisoning/Diluted/Diluted_Poisoning_Hover.tres")
	itemArea.append([0, 1])
	
	#52
	itemIDs.append(ItemTypes.POISONING)
	itemNames.append("Venomous Flask")
	itemPower.append(2)
	itemEffect.append(POISONING)
	itemImage.append("res://Art/Atlas Textures/Items/Poisoning/Normal/Normal_Poisoning_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Poisoning/Normal/Normal_Poisoning_Hover.tres")
	itemArea.append([1, 2])
	
	#53
	itemIDs.append(ItemTypes.P_POISONING)
	itemNames.append("Potent Venomous Flask")
	itemPower.append(3)
	itemEffect.append(POISONING)
	itemImage.append("res://Art/Atlas Textures/Items/Poisoning/Potent/Potent_Poisoning_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Poisoning/Potent/Potent_Poisoning_Hover.tres")
	itemArea.append([2, 3])

	#54
	itemIDs.append(ItemTypes.D_CORROSION)
	itemNames.append("Diluted Corrosive Flask")
	itemPower.append(1)
	itemEffect.append(CORROSION)
	itemImage.append("res://Art/Atlas Textures/Items/Corrosive/Diluted/Diluted_Corrosive_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Corrosive/Diluted/Diluted_Corrosive_Hover.tres")
	itemArea.append([0, 1])
	
	#55
	itemIDs.append(ItemTypes.CORROSION)
	itemNames.append("Corrosive Flask")
	itemPower.append(2)
	itemEffect.append(CORROSION)
	itemImage.append("res://Art/Atlas Textures/Items/Corrosive/Normal/Normal_Corrosive_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Corrosive/Normal/Normal_Corrosive_Hover.tres")
	itemArea.append([1, 2])
	
	#56
	itemIDs.append(ItemTypes.P_CORROSION)
	itemNames.append("Potent Corrosive Flask")
	itemPower.append(3)
	itemEffect.append(CORROSION)
	itemImage.append("res://Art/Atlas Textures/Items/Corrosive/Potent/Potent_Corrosive_Normal.tres")
	itemHImage.append("res://Art/Atlas Textures/Items/Corrosive/Potent/Potent_Corrosive_Hover.tres")
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
	enemyATKs.append(5)
	enemyDEFs.append(6)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Whipkin/Whipkin_Attack.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Whipkin/Whipkin_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Whipkin/Whipkin_Normal.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Tail Slap"])
	enemyAttackPowers.append([3])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(false)
	enemyAreas.append([0])
	
	#1
	enemyIDs.append(1)
	enemyNames.append("Slime")
	enemyMaxHPs.append(12)
	enemyATKs.append(7)
	enemyDEFs.append(7)
	enemySPDs.append(7)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Slime/Slime_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Slime/Slime_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Slime/Slime_Attack.tres")
	enemyWeaknesses.append([ICE])
	enemyResistances.append([FIRE])
	enemySpecials.append([ACID])
	enemyAttackTexts.append(["Bounce"])
	enemyAttackPowers.append([4])
	enemyAttackTypes.append([ACID])
	enemyBosses.append(false)
	enemyAreas.append([0])
	
	#2
	enemyIDs.append(2)
	enemyNames.append("Noxious Shroom")
	enemyMaxHPs.append(13)
	enemyATKs.append(6)
	enemyDEFs.append(5)
	enemySPDs.append(8)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Noxious Shroom/Noxious Shroom_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Noxious Shroom/Noxious Shroom_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Noxious Shroom/Noxious Shroom_Attack.tres")
	enemyWeaknesses.append([FIRE])
	enemyResistances.append([POISON])
	enemySpecials.append([])
	enemyAttackTexts.append(["Noxious Puff"])
	enemyAttackPowers.append([3])
	enemyAttackTypes.append([POISON])
	enemyBosses.append(false)
	enemyAreas.append([0])
	
	#3
	enemyIDs.append(3)
	enemyNames.append("Bristle")
	enemyMaxHPs.append(15)
	enemyATKs.append(5)
	enemyDEFs.append(8)
	enemySPDs.append(5)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Bristle/Bristle_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Bristle/Bristle_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Bristle/Bristle_Attack.tres")
	enemyWeaknesses.append([FIRE, POISON])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Vine Poke"])
	enemyAttackPowers.append([3])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(false)
	enemyAreas.append([0])
	
	#4
	enemyIDs.append(4)
	enemyNames.append("Giant Eagle")
	enemyMaxHPs.append(20)
	enemyATKs.append(10)
	enemyDEFs.append(10)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Giant Eagle/Giant Eagle_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Giant Eagle/Giant Eagle_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Giant Eagle/Giant Eagle_Attack.tres")
	enemyWeaknesses.append([ELECTRIC])
	enemyResistances.append([WIND])
	enemySpecials.append([])
	enemyAttackTexts.append(["Air Burst", "Soar"])
	enemyAttackPowers.append([6, 2])
	enemyAttackTypes.append([NORMAL, SPD_BUFF])
	enemyBosses.append(true)
	enemyAreas.append([0])
	
	#5
	enemyIDs.append(5)
	enemyNames.append("Ampcreste")
	enemyMaxHPs.append(16)
	enemyATKs.append(12)
	enemyDEFs.append(8)
	enemySPDs.append(12)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Ampcreste/Ampcreste_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Ampcreste/Ampcreste_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Ampcreste/Ampcreste_Attack.tres")
	enemyWeaknesses.append([ACID])
	enemyResistances.append([ELECTRIC])
	enemySpecials.append([])
	enemyAttackTexts.append(["Zap"])
	enemyAttackPowers.append([6])
	enemyAttackTypes.append([ELECTRIC])
	enemyBosses.append(false)
	enemyAreas.append([1])
	
	#6
	enemyIDs.append(6)
	enemyNames.append("Oozeweaver")
	enemyMaxHPs.append(18)
	enemyATKs.append(11)
	enemyDEFs.append(11)
	enemySPDs.append(7)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Oozeweaver/Oozeweaver_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Oozeweaver/Oozeweaver_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Oozeweaver/Oozeweaver_Attack.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([ACID])
	enemySpecials.append([])
	enemyAttackTexts.append(["Ooze Spit", "Web"])
	enemyAttackPowers.append([4, 1])
	enemyAttackTypes.append([ACID, SPD_DROP])
	enemyBosses.append(false)
	enemyAreas.append([1])
	
	#7
	enemyIDs.append(7)
	enemyNames.append("Skeleton Mage")
	enemyMaxHPs.append(14)
	enemyATKs.append(7)
	enemyDEFs.append(5)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Skeleton Mage/Skeleton Mage_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Skeleton Mage/Skeleton Mage_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Skeleton Mage/Skeleton Mage_Attack.tres")
	enemyWeaknesses.append([WIND])
	enemyResistances.append([FIRE, ICE, ELECTRIC])
	enemySpecials.append([])
	enemyAttackTexts.append(["Strengthen", "Fortify", "Hasten", "Blast"])
	enemyAttackPowers.append([2, 2, 2, 4])
	enemyAttackTypes.append([ATK_BUFF, DEF_BUFF, SPD_BUFF, EXPLOSION])
	enemyBosses.append(false)
	enemyAreas.append([1])
	
	#8
	enemyIDs.append(8)
	enemyNames.append("Dionydra")
	enemyMaxHPs.append(25)
	enemyATKs.append(15)
	enemyDEFs.append(15)
	enemySPDs.append(8)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Dionydra/Dionydra_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Dionydra/Dionydra_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Dionydra/Dionydra_Attack.tres")
	enemyWeaknesses.append([FIRE])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Bite", "Vine Wrap"])
	enemyAttackPowers.append([7, 3])
	enemyAttackTypes.append([NORMAL, DEF_BUFF])
	enemyBosses.append(true)
	enemyAreas.append([1])
	
	#9
	enemyIDs.append(9)
	enemyNames.append("Giant Bat")
	enemyMaxHPs.append(20)
	enemyATKs.append(12)
	enemyDEFs.append(11)
	enemySPDs.append(13)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Giant Bat/Giant Bat_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Giant Bat/Giant Bat_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Giant Bat/Giant Bat_Attack.tres")
	enemyWeaknesses.append([ELECTRIC])
	enemyResistances.append([WIND, POISON])
	enemySpecials.append([])
	enemyAttackTexts.append(["Screech", "Scare"])
	enemyAttackPowers.append([6, 2])
	enemyAttackTypes.append([WIND, ATK_DROP])
	enemyBosses.append(false)
	enemyAreas.append([2])
	
	#10
	enemyIDs.append(10)
	enemyNames.append("Fire Elemental")
	enemyMaxHPs.append(22)
	enemyATKs.append(15)
	enemyDEFs.append(10)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Fire Elemental/Fire Elemental_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Fire Elemental/Fire Elemental_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Fire Elemental/Fire Elemental_Attack.tres")
	enemyWeaknesses.append([ICE, WIND])
	enemyResistances.append([FIRE])
	enemySpecials.append([])
	enemyAttackTexts.append(["Fire Blast"])
	enemyAttackPowers.append([7])
	enemyAttackTypes.append([FIRE])
	enemyBosses.append(false)
	enemyAreas.append([2])
	
	#11
	enemyIDs.append(11)
	enemyNames.append("Ice Elemental")
	enemyMaxHPs.append(22)
	enemyATKs.append(10)
	enemyDEFs.append(15)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Ice Elemental/Ice Elemental_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Ice Elemental/Ice Elemental_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Ice Elemental/Ice Elemental_Attack.tres")
	enemyWeaknesses.append([FIRE, ELECTRIC])
	enemyResistances.append([ICE])
	enemySpecials.append([])
	enemyAttackTexts.append(["Ice Blast"])
	enemyAttackPowers.append([7])
	enemyAttackTypes.append([ICE])
	enemyBosses.append(false)
	enemyAreas.append([2])
	
	#12
	enemyIDs.append(12)
	enemyNames.append("Lightning Elemental")
	enemyMaxHPs.append(22)
	enemyATKs.append(10)
	enemyDEFs.append(10)
	enemySPDs.append(15)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Lightning Elemental/Lightning Elemental_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Lightning Elemental/Lightning Elemental_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Lightning Elemental/Lightning Elemental_Attack.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([ELECTRIC])
	enemySpecials.append([])
	enemyAttackTexts.append(["Lightning Blast"])
	enemyAttackPowers.append([7])
	enemyAttackTypes.append([ELECTRIC])
	enemyBosses.append(false)
	enemyAreas.append([2])
	
	#13
	enemyIDs.append(13)
	enemyNames.append("Elemental Amalgamate")
	enemyMaxHPs.append(30)
	enemyATKs.append(17)
	enemyDEFs.append(17)
	enemySPDs.append(17)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Elemental Amalgamate/Elemetnal Amalgamate_Charging.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Elemental Amalgamate/Elemental Amalgamate_Normal.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Elemental Amalgamate/Elemental Amalgamate_Attack.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([FIRE, ICE, ELECTRIC])
	enemySpecials.append([])
	enemyAttackTexts.append(["Fire Blast", "Ice Blast", "Lightning Blast"])
	enemyAttackPowers.append([10, 10, 10])
	enemyAttackTypes.append([FIRE, ICE, ELECTRIC])
	enemyBosses.append(true)
	enemyAreas.append([2])
	
	#14
	enemyIDs.append(14)
	enemyNames.append("Kobold")
	enemyMaxHPs.append(25)
	enemyATKs.append(16)
	enemyDEFs.append(12)
	enemySPDs.append(18)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Kobold/Kobold_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Kobold/Kobold_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Kobold/Kobold_Attack.tres")
	enemyWeaknesses.append([POISON])
	enemyResistances.append([FIRE])
	enemySpecials.append([])
	enemyAttackTexts.append(["Stab"])
	enemyAttackPowers.append([8])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(false)
	enemyAreas.append([3])
	
	#15
	enemyIDs.append(15)
	enemyNames.append("Skeleton Warrior")
	enemyMaxHPs.append(27)
	enemyATKs.append(16)
	enemyDEFs.append(15)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Skeleton Warrior/Skeleton Warrior_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Skeleton Warrior/Skeleton Warrior_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Skeleton Warrior/Skeleton Warrior_Attack.tres")
	enemyWeaknesses.append([EXPLOSION])
	enemyResistances.append([POISON])
	enemySpecials.append([])
	enemyAttackTexts.append(["Slash"])
	enemyAttackPowers.append([9])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(false)
	enemyAreas.append([3])
	
	#16
	enemyIDs.append(16)
	enemyNames.append("Necrodrake Head")
	enemyMaxHPs.append(35)
	enemyATKs.append(19)
	enemyDEFs.append(19)
	enemySPDs.append(13)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Necrodrake Head/Necrodrake Head_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Necrodrake Head/Necrodrake Head_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Necrodrake Head/Necrodrake Head_Attack.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Necrotic Blast"])
	enemyAttackPowers.append([15])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(true)
	enemyAreas.append([3])
	
	#17
	enemyIDs.append(17)
	enemyNames.append("Necrodrake Arm")
	enemyMaxHPs.append(25)
	enemyATKs.append(15)
	enemyDEFs.append(15)
	enemySPDs.append(15)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Necrodrake Arm (Left)/Necrodrake Arm (Left)_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Necrodrake Arm (Left)/Necrodrake Arm (Left)_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Necrodrake Arm (Left)/Necrodrake Arm (Left)_Attack.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Swipe"])
	enemyAttackPowers.append([12])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(true)
	enemyAreas.append([3])
	
	#18
	enemyIDs.append(18)
	enemyNames.append("Necrodrake Arm")
	enemyMaxHPs.append(25)
	enemyATKs.append(15)
	enemyDEFs.append(15)
	enemySPDs.append(15)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Necrodrake Arm (Right)/Necrodrake Arm (Right)_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Necrodrake Arm (Right)/Necrodrake Arm (Right)_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Necrodrake Arm (Right)/Necrodrake Arm (Right)_Attack.tres")
	enemyWeaknesses.append([])
	enemyResistances.append([])
	enemySpecials.append([])
	enemyAttackTexts.append(["Swipe"])
	enemyAttackPowers.append([12])
	enemyAttackTypes.append([NORMAL])
	enemyBosses.append(true)
	enemyAreas.append([3])
	
	#19
	enemyIDs.append(19)
	enemyNames.append("Slime")
	enemyMaxHPs.append(17)
	enemyATKs.append(10)
	enemyDEFs.append(10)
	enemySPDs.append(10)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Slime/Slime_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Slime/Slime_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Slime/Slime_Attack.tres")
	enemyWeaknesses.append([ICE])
	enemyResistances.append([FIRE])
	enemySpecials.append([ACID])
	enemyAttackTexts.append(["Bounce"])
	enemyAttackPowers.append([5])
	enemyAttackTypes.append([ACID])
	enemyBosses.append(false)
	enemyAreas.append([1])
	
	#20
	enemyIDs.append(20)
	enemyNames.append("Skeleton Mage")
	enemyMaxHPs.append(24)
	enemyATKs.append(12)
	enemyDEFs.append(13)
	enemySPDs.append(14)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Skeleton Mage/Skeleton Mage_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Skeleton Mage/Skeleton Mage_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Skeleton Mage/Skeleton Mage_Attack.tres")
	enemyWeaknesses.append([WIND])
	enemyResistances.append([FIRE, ICE, ELECTRIC])
	enemySpecials.append([])
	enemyAttackTexts.append(["Strengthen", "Fortify", "Hasten", "Blast"])
	enemyAttackPowers.append([3, 3, 3, 6])
	enemyAttackTypes.append([ATK_BUFF, DEF_BUFF, SPD_BUFF, EXPLOSION])
	enemyBosses.append(false)
	enemyAreas.append([3])
	
	#21
	enemyIDs.append(21)
	enemyNames.append("Giant Bat")
	enemyMaxHPs.append(24)
	enemyATKs.append(14)
	enemyDEFs.append(13)
	enemySPDs.append(15)
	enemyImagesNormal.append("res://Art/Atlas Textures/Enemies/Giant Bat/Giant Bat_Normal.tres")
	enemyImagesCharging.append("res://Art/Atlas Textures/Enemies/Giant Bat/Giant Bat_Charging.tres")
	enemyImagesAttacking.append("res://Art/Atlas Textures/Enemies/Giant Bat/Giant Bat_Attack.tres")
	enemyWeaknesses.append([ELECTRIC])
	enemyResistances.append([WIND, POISON])
	enemySpecials.append([])
	enemyAttackTexts.append(["Screech", "Scare"])
	enemyAttackPowers.append([7, 3])
	enemyAttackTypes.append([WIND, ATK_DROP])
	enemyBosses.append(false)
	enemyAreas.append([3])
	
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
	inventoryid = []
	for i in itemInventory.size():
		inventoryid.append(itemInventory[i].itemID)
		
	var save_dict = {
		"maxHP" : maxHP,
		"HP" : HP,
		"speed" : speed,
		"defense": defense,
		"attack": attack,
		"inventoryid": inventoryid,
		"itemInventoryNum": itemInventoryNum,
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
				if i == "maxhp":
					maxHP
				if (i == "itemInventoryNum"):
					continue
				set(i, node_data[i])
	for i in inventoryid.size():
		if inventoryid[i] != -1:
			addItemToInventory(int(inventoryid[i]))

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
		itemInventory[int(itemInventoryNum)].initialize(id, itemInventoryNum, iName, iEffect, iPower, iImage, iHImage, iArea)
		itemInventoryNum += 1
		shiftInventoryLeft(0)
		updateInventoryDisplay(-1, -1)

func removeItemFromInventory(slotNumber: int, mode: int) -> void:
	if (mode == 1):
		materialInventory[slotNumber].deinitialize()
	else:
		itemInventory[slotNumber].deinitialize()
		
	if (isCurrentlyDisplayed(slotNumber, mode)):
		@warning_ignore("integer_division")
		INVENTORY_ITEM_DISPLAYS[slotNumber/16].unlink()
	
	shiftInventoryLeft(mode)
	updateInventoryDisplay(-1, -1)

# Checks if the item in the given item slot number is currently being displayed
func isCurrentlyDisplayed(itemSlotNumber:int, mode: int) -> bool:
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
	# The index should be (displayNum - 1) * inventoryPage + 1
	var inventory
	if (inventoryMode == 1):
		inventory = materialInventory
	else:
		inventory = itemInventory
	inventory[inventoryPage * 16 + (displayNum - 1)].deinitialize()
	itemInventoryNum -= 1
	if (!swap):
		shiftInventoryLeft(-1)
	updateInventoryDisplay(-1, -1)

func findAndAddToInventory(toAdd: Dictionary, displayNum: int, swap: bool) -> void:
	if (inventoryMode == 1):
		pass # TODO add functionality when inventory_material is created
	else:
		toAdd["iSlot"] = inventoryPage * 16 + (displayNum - 1)
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
		addItemToInventory(randi() % 23)
		
func takeDamage(amount: int) -> void:
		HP -= amount

func heal(amount: int) -> void:
	HP += amount
	if (HP > maxHP):
		HP = maxHP

func spawnRandomAreaItem(area: int, iDisplay: ItemDisplay) -> void:
	var itemPool: Array = []
	for i in itemArea.size():
		for j in itemArea[i].size():
			if (itemArea[i][j] == area):
				itemPool.append(i)
	
	var poolHealing: Array= []
	var poolDamage: Array = []
	var poolStatus: Array = []
	var poolStats: Array = []
	
	for i in itemPool.size():
		if (itemPool[i].itemID <= 2):
			poolHealing.append(itemPool[i])
		elif (itemPool[i].itemID >= 3 and itemPool[i].itemID <= 23):
			poolDamage.append(itemPool[i])
		elif (itemPool[i].itemID >= 24 and itemPool[i].itemID <= 41):
			poolStatus.append(itemPool[i])
		elif (itemPool[i].itemID >= 42 and itemPool[i].itemID <= 56):
			poolStatus.append(itemPool[i])
	
	var choosePool = randf()
	var pool
	
	if (choosePool <= 0.7):
		pool = poolDamage
	elif (choosePool > 0.7 and choosePool <= 0.8):
		pool = poolHealing
	elif (choosePool > 0.8 and choosePool <= 0.9):
		pool = poolStatus
	elif (choosePool > 0.9):
		pool = poolStatus
	
	var iID = pool[randi_range(0, pool.size() - 1)]
	iDisplay.link(itemIDs[iID], itemNames[iID], itemEffect[iID], itemPower[iID],
	load(itemImage[iID]), load(itemHImage[iID]), itemArea[iID])
	
func spawnRandomAreaItemE(area: int) -> String:
	var itemPool: Array =[]
	for i in itemArea.size():
		for j in itemArea[i].size():
			if (itemArea[i][j] == area):
				itemPool.append(i)
	var id = itemPool[randi_range(0, itemPool.size() - 1)]
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
	var temp = "You gained a " + iName + "!"
	return temp
