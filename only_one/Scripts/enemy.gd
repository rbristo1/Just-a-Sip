extends Control

# Here are all of the stats the enemy needs to keep track of
var ID
var enemyName
var maxHP
var HP
var attack
var defense
var speed

enum {NORMAL, EXPLOSION, FIRE, ICE, ELECTRIC, AIR, POISON, ACID, HEAL, ATK_BUFF,
		DEF_BUFF, SPD_BUFF, ATK_DROP, DEF_DROP, SPD_DROP, BURN, FREEZE, STATIC, KNOCKBACK, POISONED, CORRODED}
var damageTypeWeaknesses: Array
var damageTypeResistances: Array
var damageTypeSpecial: Array

var attackTexts: Array
var attackPowers: Array
var attackTypes: Array
var enemySlot

var area
var boss

var normalImage
var chargingImage
var attackingImage

# The following is for
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

var statusString = "ATK Down - 3 Turns"
@export var enemiesFile = "res://JSONS/enemies.JSON"

var battleManager

#holds generated enemy ids and their health
func _ready() -> void:
	loadEnemyCache()
	battleManager = get_tree().get_first_node_in_group("Battle Manager")

func loadEnemyCache() -> void:
	if not FileAccess.file_exists(enemiesFile):
		return
	else:
		var save_file = FileAccess.open(enemiesFile, FileAccess.READ)
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


func initialize(id: int, eSlot: int) -> void:
	enemySlot = eSlot
	ID = enemyIDs[id]
	enemyName = enemyNames[id]
	maxHP = enemyMaxHPs[id]
	HP = maxHP
	attack = enemyATKs[id]
	defense = enemyDEFs[id]
	speed = enemySPDs[id]
	damageTypeWeaknesses = enemyWeaknesses[id]
	damageTypeResistances = enemyResistances[id]
	damageTypeSpecial = enemySpecials[id]
	attackTexts = enemyAttackTexts[id]
	attackPowers = enemyAttackPowers[id]
	attackTypes = enemyAttackTypes[id]
	boss = enemyBosses[id]
	area = enemyAreas[id]
	normalImage = enemyImagesNormal[id]
	chargingImage = enemyImagesCharging[id]
	attackingImage = enemyImagesAttacking[id]
	
	get_parent().normalTexture = normalImage
	get_parent().chargeTexture = chargingImage
	get_parent().attackTexture = attackingImage
	get_parent().enemyID = ID

func createText() -> String:
	var toReturn: String
	toReturn = enemyName + " - " + str(HP) + "/" + str(maxHP) + " HP" + "\n" + statusString
	if (battleManager.enemyAttackModifiers[enemySlot] > 1):
		toReturn += ", ATK Up - " + str(battleManager.enemyAttackModifierTurns[enemySlot]) + " Turns"
	elif (battleManager.enemyAttackModifiers[enemySlot] < 0.75):
		toReturn += ", ATK Down - " + str(battleManager.enemyAttackModifierTurns[enemySlot]) + " Turns"

	if (battleManager.enemyDefenseModifiers[enemySlot] > 1):
		toReturn += ", DEF Up - " + str(battleManager.enemyDefenseModifierTurns[enemySlot]) + " Turns"
	elif (battleManager.enemyDefenseModifiers[enemySlot] < 0.75):
		toReturn += ", DEF Down - " + str(battleManager.enemyDefenseModifierTurns[enemySlot]) + " Turns"

	if (battleManager.enemySpeedModifiers[enemySlot] > 1):
		toReturn += ", SPD Up - " + str(battleManager.enemySpeedModifierTurns[enemySlot]) + " Turns"
	elif (battleManager.enemySpeedModifiers[enemySlot] < 0.75):
		toReturn += ", SPD Down - " + str(battleManager.enemySpeedModifierTurns[enemySlot]) + " Turns"

	return toReturn

func takeDamage(amount: int) -> void:
	HP -= amount
	battleManager.eHealthBars[enemySlot].value = max(HP, 0)

func buildStatusText(status: int, length: int) -> void:
	var statusName
	if (status == BURN):
		statusName = "Burn"
	elif (status == FREEZE):
		statusName = "Freeze"
	elif (status == STATIC):
		statusName = "Static"
	elif (status == POISONED):
		statusName = "Poison"
	elif (status == CORRODED):
		statusName = "Corrosion"
	statusString = statusName + " - " + str(length) + " Turns"
