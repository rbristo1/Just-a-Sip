extends PanelContainer

var battleManager
var leftDisplay
var rightDisplay
var player

func _ready() -> void:
	battleManager = get_tree().get_first_node_in_group("Battle Manager")
	leftDisplay = find_child("StatsTextLeft", true)
	rightDisplay = find_child("StatsTextRight", true)
	player = get_tree().get_first_node_in_group("Player Hud")
	updateStats()

func updateStats() -> void:
	var ATKMult = 1
	var DEFMult = 1
	var SPDMult = 1
	if (battleManager != null):
		ATKMult = battleManager.playerAttackModifier
		DEFMult = battleManager.playerDefenseModifier
		SPDMult = battleManager.playerSpeedModifier
	
	var leftText = "HP:" + str(player.HP) + "/" + str(player.maxHP) + "\n"
	leftText += "ATK:" + str(player.attack * ATKMult) + "\n" + "DEF:" + str(player.defense * DEFMult) + "\n"
	leftText += "SPD:" + str(player.speed * SPDMult)
	leftDisplay.text = leftText
	
	var rightText = "Items:\n" + str(player.itemInventoryNum) + "/" + str(player.ITEM_INVENTORY_CAPACITY) + "\n"
	rightText += "Materials:\n" + str(player.materialInventoryNum) + "/" + str(player.MATERIAL_INVENTORY_CAPACITY) + "\n"
	rightDisplay.text = rightText
