#holds player stats and data
extends Node2D

#stats
@export var maxhp = 100
@export var hp = 100
@export var spd = 100
@export var def = 100
@export var atk = 100
@export var inventoryid: Array

#item lookup caching, for retrieval as indexes in constant time
var itemIDs: Array
var itemNames: Array
var itemPower: Array
var itemEffect: Array
var itemImage: Array
var itemSplash: Array
enum ItemTypes {HEALING, EXPLOSIVE}
enum EType {DAMAGING, HEALING, STUNNING, BUFF_ATK, BUFF_DEF, BUFF_SPD}

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
enum EnemyTypes {SLIME, ZOMBIE}


#filename
@export var itemsFile = "res://JSONS/items.JSON"
@export var playerFile = "res://JSONS/player.JSON"
@export var enemiesFile = "res://JSONS/enemies.JSON"




func _ready() -> void:
	builditemJSON()
	buildEnemyJSON()
	#TODO remove createSave and builditemJSON at completion
	#createSave()
	loadPlayer()
	loaditems()
	statLog()
	
	





func _physics_process(delta: float) -> void:
	if (hp <= 0):
		print("died!")
		#TODO add game over here
	




# A comprehensive list of all types of items are in this function
func builditemJSON() -> void:
	#TODO add more items
	#create new items by appending its stats here using this format of 5 lines
	#will be removed in the final product, this is for ease of adding items.
	#please number items as you add more so indexes can be tracked
	
	#0
	itemIDs.append(ItemTypes.HEALING)
	itemNames.append("Healing")
	itemPower.append(100)
	itemEffect.append(EType.HEALING)
	itemImage.append("res://Art/blue_potion.png")
	itemSplash.append(false)
	
	#1
	itemIDs.append(ItemTypes.EXPLOSIVE)
	itemNames.append("Explosive")
	itemPower.append(100)
	itemEffect.append(EType.HEALING)
	itemImage.append("res://Art/blue_potion.png")
	itemSplash.append(true)
	
	var save_dict = {
		"itemIDs" :itemIDs,
		"itemNames" : itemNames,
		"itemPower" : itemPower,
		"itemEffect" : itemEffect,
		"itemImage": itemImage,
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
	enemyImage.append("res://Art/item.png")
	enemySplash.append(false)
	enemyUndead.append(false)
	
	#1
	enemyIDs.append(EnemyTypes.ZOMBIE)
	enemyNames.append("Zombie")
	enemyATK.append(100)
	enemyDEF.append(100)
	enemySPD.append(100)
	enemyMaxHP.append(100)
	enemyHP.append(100)
	enemyImage.append("res://Art/item.png")
	enemySplash.append(false)
	enemyUndead.append(true)
	
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
				

func createItem(id: int) -> void:
	pass






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
