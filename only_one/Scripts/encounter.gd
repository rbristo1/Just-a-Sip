extends Node2D
# enemies, and items. It will keep track of things such as turn order, status
# effects, etc.

enum {NORMAL, EXPLOSION, FIRE, ICE, ELECTRIC, AIR, POISON, ACID, HEAL, ATK_BUFF,
		DEF_BUFF, SPD_BUFF, ATK_DROP, DEF_DROP, SPD_DROP, BURN, FREEZE, STATIC, KNOCKBACK, POISONED, CORRODED}

# These are all scenes either being created and instatiated in this script, or
# being linked from the scene tree
var eDisplays: Array # Will hold the enenmy displays from left to right
var iAttackSlots: Array # Will hold the item attack slots from left to right
var eHealthBars: Array # Will hold the enemy health bars from left to right
var enemies: Array = [null, null, null]# Will hold the actual enemy information
var player # Will link to the player_hud
var nextButton # Will link to the 'next' button
var tBox
var playerStatsDisplay

# These are all arrays pertaining to the enemies
var enemyIDs: Array = [-1, -1, -1]
var speedCounters: Array = [0, 0, 0]
var enemiesAttacking: Array = [false, false, false]
var enemyTextureModes: Array = [-1, -1, -1]
var enemyStatuses: Array = [-1, -1, -1]
var enemyStatusTurns: Array = [0, 0, 0]
var enemyAttackModifiers: Array = [1, 1, 1]
var enemyAttackModifierTurns: Array = [0, 0, 0]
var enemyDefenseModifiers: Array = [1, 1, 1]
var enemyDefenseModifierTurns: Array = [0, 0, 0]
var enemySpeedModifiers: Array = [1, 1, 1]
var enemySpeedModifierTurns: Array = [0, 0, 0]

# These are all variables pertaining to the item attack slots
var attackItemsExist: Array = [false, false, false]

# These are all variables pertaining to the player
var playerStatus = -1
var playerStatusTurns = 0
var playerAttackModifier = 1
var playerAttackModifierTurns = 0
var playerDefenseModifier = 1
var playerDefenseModifierTurns = 0
var playerSpeedModifier = 1
var playerSpeedModifierTurns = 0

# These are all variables that have to do with battle management
var speedThreshold = 0
enum {BATTLE_ONGOING, BATTLE_LOST, BATTLE_WON}
var battleEnded = BATTLE_ONGOING

# These are all the variables that will influence what types of enemies spawn
var area = 0
var bossBattle = false
var numEnemies
var enemyAreas: Array
var enemyBosses: Array


@export var enemiesFile = "res://JSONS/enemies.JSON"

# TODO - remove this. This is for testing only
func _ready() -> void:
	#loadEnemyAreaList()
	
	#for i in enemies.size():
		#var scene = load("res://Scenes/enemy.tscn").instantiate()
		#enemies[i] = scene # We need to ensure that the enemy scenes have loaded
							# everything off of their JSON files before moving on
	
	# Link up nodes from groups to trees, then sort them if need be
	eDisplays = GeneralFunctions.sortGroup(get_tree().get_nodes_in_group("Enemy Displays"))
	eDisplays[0].disabled = true
	eDisplays[1].disabled = true
	eDisplays[2].disabled = true
	iAttackSlots = GeneralFunctions.sortGroup(get_tree().get_nodes_in_group("Attack Item Displays"))
	eHealthBars = GeneralFunctions.sortGroup(get_tree().get_nodes_in_group("Enemy Health Bars"))
	eHealthBars[0].z_index = -100
	eHealthBars[1].z_index = -100
	eHealthBars[2].z_index = -100
	player = get_tree().get_first_node_in_group("Player Hud")
	tBox = get_tree().get_first_node_in_group("Main Text Box")
	nextButton = get_tree().get_first_node_in_group("Next Button")
	playerStatsDisplay = get_tree().get_first_node_in_group("Player Stats Display")
	
	tBox.textProgressed.connect(onTextProgressed)
	for i in iAttackSlots.size():
		iAttackSlots[i].itemInAttackSlot.connect(onItemAttackSlotChange)
		
	
	#for i in eDisplays.size(): # enemies MUST be added to the scene tree, as that is when _ready() calls
		#eDisplays[i].add_child(enemies[i])
	endBattle()
	
	


func endBattle():
		
			
		
		
		tBox.queueText("test")
		#tBox.queueTextsFromArray()
		tBox.queueText("SIGNAL_CLICKED_THROUGH")
		tBox.tempTextDisabled = true
		await tBox.clickedThroughText
		tBox.tempTextDisabled = false
		
		var temp = randi()%3+1
		# Now we need to give the players the ability to get items after battle
		if (temp == 1):
			iAttackSlots[1].enable()
			iAttackSlots[1].spawnRandomAreaItem(area)
		elif (temp == 2):
			iAttackSlots[0].enable()
			iAttackSlots[2].enable()
			iAttackSlots[0].spawnRandomAreaItem(area)
			iAttackSlots[2].spawnRandomAreaItem(area)
		elif (temp == 3):
			iAttackSlots[0].enable()
			iAttackSlots[1].enable()
			iAttackSlots[2].enable()
			iAttackSlots[0].spawnRandomAreaItem(area)
			iAttackSlots[1].spawnRandomAreaItem(area)
			iAttackSlots[2].spawnRandomAreaItem(area)
		
		nextButton.disabled = false
		await nextButton.button_up
		# TODO: Exit scene to map
		print("Exit scene to map")
		player.savePlayer()
		get_tree().change_scene_to_file("res://Scenes/map.tscn")

func onItemAttackSlotChange(slotNum: int, itemInSlot: bool) -> void:
	if (battleEnded == BATTLE_ONGOING):
		if (itemInSlot):
			attackItemsExist[slotNum - 1] = true
		else:
			attackItemsExist[slotNum - 1] = false
		
		var shouldDisable = true
		for i in attackItemsExist:
			if (i == true):
				shouldDisable = false
		
		#if (shouldDisable == true):
			#nextButton.disabled = true
		#else:
			#nextButton.disabled = false

func onTextProgressed():
	playerStatsDisplay.updateStats()
