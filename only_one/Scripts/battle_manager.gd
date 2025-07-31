extends Node2D

# This is the battle manager, which is the sort of 'link' between the player,
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
var runButton

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
@export var mapFile = "res://JSONS/map.JSON"
@export var ITEM_POWER_MULT: int = 5


@export var enemiesFile = "res://JSONS/enemies.JSON"

# TODO - remove this. This is for testing only
func _ready() -> void:
	loadEnemyAreaList()
	
	for i in enemies.size():
		var scene = load("res://Scenes/enemy.tscn").instantiate()
		enemies[i] = scene # We need to ensure that the enemy scenes have loaded
							# everything off of their JSON files before moving on
	
	# Link up nodes from groups to trees, then sort them if need be
	eDisplays = GeneralFunctions.sortGroup(get_tree().get_nodes_in_group("Enemy Displays"))
	iAttackSlots = GeneralFunctions.sortGroup(get_tree().get_nodes_in_group("Attack Item Displays"))
	eHealthBars = GeneralFunctions.sortGroup(get_tree().get_nodes_in_group("Enemy Health Bars"))
	player = get_tree().get_first_node_in_group("Player Hud")
	tBox = get_tree().get_first_node_in_group("Main Text Box")
	nextButton = get_tree().get_first_node_in_group("Next Button")
	playerStatsDisplay = get_tree().get_first_node_in_group("Player Stats Display")
	runButton = get_tree().get_first_node_in_group("Run Button")
	runButton.run.connect(onRunComplete)
	
	tBox.textProgressed.connect(onTextProgressed)
	for i in iAttackSlots.size():
		iAttackSlots[i].itemInAttackSlot.connect(onItemAttackSlotChange)
		
	
	for i in eDisplays.size(): # enemies MUST be added to the scene tree, as that is when _ready() calls
		eDisplays[i].add_child(enemies[i])
	
	beginBattle()

func getEnemySlot(find: Control, arrName: String) -> int:
	var arr = get(arrName)
	return arr.find(find)

func loadEnemyAreaList() -> void:
	if not FileAccess.file_exists(enemiesFile):
		print("JSON Error: file does not exist")
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
				if(i == "enemyAreas" or i == "enemyBosses"):
					set(i, node_data[i])


func beginBattle() -> void:
	# First thing that needs to happen is the number of enemies and type of enemies
	# needs to be decided, created, and linked up to the eDisplays
	generateEnemies()
	
	# After that, we need to calculate the speed threshold using the player's speed
	speedThreshold = int(sqrt(player.speed * 10))
	
	# Display text in the text box to show that the battle has begun
	tBox.queueText("Battle begin!")
	
	# Now we give the player a free turn
	await playerTurn()
	# Now we start the alternating rounds, beginning by setting the enemies starting
	# speed counter randomly
	for i in enemyIDs.size():
		if (enemyIDs[i] != -1):
			speedCounters[i] = randi_range(0, speedThreshold)
			
	# Now we can start the battle turns
	while (battleEnded == BATTLE_ONGOING):
		# Calculate enemy speed stuff and see if enemies can attack
		for i in enemyIDs.size():
			if (enemyIDs[i] != -1):
				speedCounters[i] += enemies[i].speed * enemySpeedModifiers[i]
			if (speedCounters[i] >= speedThreshold):
				enemiesAttacking[i] = true
				eDisplays[i].changeActiveTexture(1)
				if (speedCounters[i] >= speedThreshold * 2 and enemies[i].canMultiattack == false):
					speedCounters[i] = (speedThreshold * 2) - 1 # Prevent multiattack
		# Now the player can take their turn
		tBox.queueText(player.playerName + "'s turn!")
		await playerTurn()
		# Check here to see if the player has killed all the enemies
		if (battleEnded != BATTLE_ONGOING):
			break
		# Activate enemy statuses here, since it isn't guarenteed every enemy
		# will take a turn every turn:
		for i in enemyIDs.size():
			if (enemyIDs[i] != -1):
				if (enemyAttackModifiers[i] != 1):
					enemyAttackModifierTurns[i] -= 1
					if (enemyAttackModifierTurns[i] <= 0):
						enemyAttackModifiers[i] = 1
						enemyAttackModifierTurns[i] = 0
				if (enemyDefenseModifiers[i] != 1):
					enemyDefenseModifierTurns[i] -= 1
					if (enemyDefenseModifierTurns[i] <= 0):
						enemyDefenseModifiers[i] = 1
						enemyDefenseModifierTurns[i] = 0
				if (enemySpeedModifiers[i] != 1):
					enemySpeedModifierTurns[i] -= 1
					if (enemySpeedModifierTurns[i] <= 0):
						enemySpeedModifiers[i] = 1
						enemySpeedModifierTurns[i] = 0
				if (enemyStatuses[i] != -1):
					activateEnemyStatuses(enemies[i], i)
					enemies[i].buildStatusText(enemyStatuses[i], enemyStatusTurns[i])
				tBox.queueTextsFromArray(deathCheck())
				
		for i in enemyIDs.size():
			if (enemyIDs[i] != -1 and enemiesAttacking[i] == true):
				while (speedCounters[i] >= speedThreshold):
					await enemyTurn(i)
	# At this point here, the battle should be over, so we can award stats and
	# items to the player for them to take. Once the player hits the next button,
	# the battle will be over and the scene will be closed.
	endBattle()

func generateEnemies():
	# The first thing that we need to determine how many enemies we will
	# have. The later the area, the higher chance of more enemies
	numEnemies = getRandomEnemyNum()
	
	# Next we need to determine the pool of enemies we can pick from based 
	# on the area
	var enemyPool: Array
	if !bossBattle:
		for i in enemyAreas.size():
			for j in enemyAreas[i].size():
				if (enemyAreas[i][j] == area and enemyBosses[i] != true):
					enemyPool.append(i)
		
		# Now we need to figure out where enemies are displayed based on the
		# number of enemies
		if (numEnemies == 1): # Center
			disableUnusedEnemyObjects(0)
			createEnemy(1, randi_range(0, enemyPool.size() - 1))
			disableUnusedEnemyObjects(2)
		if (numEnemies == 2): # Left and Right
			createEnemy(0, randi_range(0, enemyPool.size() - 1))
			disableUnusedEnemyObjects(1)
			createEnemy(2, randi_range(0, enemyPool.size() - 1))
		if (numEnemies == 3): # All three
			createEnemy(0, randi_range(0, enemyPool.size() - 1))
			createEnemy(1, randi_range(0, enemyPool.size() - 1))
			createEnemy(2, randi_range(0, enemyPool.size() - 1))
	
	if (bossBattle):
		if (area == 0):
			disableUnusedEnemyObjects(0)
			createEnemy(1, 4)
			disableUnusedEnemyObjects(2)
		if (area == 1):
			disableUnusedEnemyObjects(0)
			createEnemy(1, 8)
			disableUnusedEnemyObjects(2)
		if (area == 2):
			disableUnusedEnemyObjects(0)
			createEnemy(1, 13)
			disableUnusedEnemyObjects(2)
		if (area == 3):
			createEnemy(0, 17)
			createEnemy(0, 16)
			createEnemy(0, 18)


func getRandomEnemyNum() -> int:
	# I may try to implement a more complex system depending on the are
	# you are in, but that will happen later. For now, it is purely random
	return randi_range(1, 3)

func createEnemy(enemySlot: int, enemyID: int) -> void:
	# To create an enemy, we must do the following:
	# 1. Instantiate and initalize an enemy with an ID from the ID pool
	enemies[enemySlot].initialize(enemyID, enemySlot)
	eHealthBars[enemySlot].max_value = enemies[enemySlot].maxHP
	eHealthBars[enemySlot].value = enemies[enemySlot].maxHP
	enemyTextureModes[enemySlot] = 0
	eDisplays[enemySlot].changeActiveTexture(0)
	enemyIDs[enemySlot] = enemyID
	
func disableUnusedEnemyObjects(enemySlot: int):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	eHealthBars[enemySlot].add_theme_stylebox_override("background", style)
	eHealthBars[enemySlot].add_theme_stylebox_override("fill", style)
	iAttackSlots[enemySlot].disable()
	eDisplays[enemySlot].disable(false)
	
func playerTurn():
	nextButton.disabled = true
	
	# Resolve status effects from player
	playerAttackModifierTurns -= 1
	playerDefenseModifierTurns -= 1
	playerSpeedModifierTurns -= 1
	if (playerAttackModifierTurns == 0):
		playerAttackModifier = 1
	if (playerDefenseModifierTurns == 0):
		playerDefenseModifier = 1
	if (playerSpeedModifierTurns == 0):
		playerSpeedModifier = 1
	
	playerStatsDisplay.updateStats()
	
	await nextButton.button_up
	
	tBox.showText("")
	
	# Items are in their slots, so resolve them
	for i in attackItemsExist.size():
		if (attackItemsExist[i] == true):
			# Resolve item effects
			resolveItemEffects(iAttackSlots[i], enemies[i], i)
			iAttackSlots[i].unlink()
			tBox.queueTextsFromArray(deathCheck())
	
	playerStatsDisplay.updateStats()
	# Now we need to wait for the text to be clicked through before starting
	# the enemy turn
	tBox.queueText("SIGNAL_CLICKED_THROUGH")
	tBox.tempTextDisabled = true
	await tBox.clickedThroughText
	tBox.tempTextDisabled = false
	
func deathCheck() -> Array:
	var toReturn: Array = []
	for i in enemies.size():
		if (enemyIDs[i] != -1):
			if (enemies[i].HP <= 0):
				toReturn.append(enemies[i].enemyName + " died!")
				killEnemy(enemies[i], i)
	if (enemyIDs == [-1, -1, -1]):
		battleEnded = BATTLE_WON
	if (player.HP <= 0):
		battleEnded = BATTLE_LOST
		toReturn.append(player.playerName + " died!")
	return toReturn

func enemyTurn(enemySlot: int):
	# Set speed counters
	eDisplays[enemySlot].changeActiveTexture(2)
	var enemy = enemies[enemySlot]
	speedCounters[enemySlot] -= speedThreshold
	if (speedCounters[enemySlot] < 0):
		speedCounters[enemySlot] = 0
	
	var attackAndTarget = chooseEnemyMove(enemy, enemySlot)
	var damage
	var statusPower
	
	if (enemy.attackPowers[attackAndTarget[0]] <= 5):
		statusPower = 1
	elif (enemy.attackPowers[attackAndTarget[0]] <= 10):
		statusPower = 2
	else:
		statusPower = 3
	
	if (attackAndTarget[1] == 3):
		# This is an attack on the player, so deal damage and give text
		if (enemy.attackTypes[attackAndTarget[0]] == ATK_DROP):
			playerAttackModifier = 0.5
			playerAttackModifierTurns = 2 * statusPower
			tBox.queueText(enemy.enemyName + " used " + enemy.attackTexts[attackAndTarget[0]] + " on " + player.playerName + "!")
			tBox.queueText(player.playerName + "'s attack was lowered!")
		elif (enemy.attackTypes[attackAndTarget[0]] == DEF_DROP):
			playerDefenseModifier = 0.5
			playerDefenseModifierTurns = 2 * statusPower
			tBox.queueText(enemy.enemyName + " used " + enemy.attackTexts[attackAndTarget[0]] + " on " + player.playerName + "!")
			tBox.queueText(player.playerName + "'s defense was lowered!")
		elif (enemy.attackTypes[attackAndTarget[0]] == SPD_DROP):
			playerSpeedModifier = 0.5
			playerSpeedModifierTurns = 2 * statusPower
			tBox.queueText(enemy.enemyName + " used " + enemy.attackTexts[attackAndTarget[0]] + " on " + player.playerName + "!")
			tBox.queueText(player.playerName + "'s speed was lowered!")
		damage = damageCalc(enemy.attack, player.defense, enemyAttackModifiers[enemySlot],
					playerDefenseModifier, 1, enemy.attackPowers[attackAndTarget[0]])
		player.takeDamage(damage)
		tBox.queueText(enemy.enemyName + " used " + enemy.attackTexts[attackAndTarget[0]] + " on " + player.playerName + "!")
		tBox.queueText(player.playerName + " took " + str(damage) + " damage!")
	else:

		tBox.queueText(enemy.enemyName + " used " + enemy.attackTexts[attackAndTarget[0]] + " on " + enemies[attackAndTarget[1]].enemyName + "!")
		
		if (enemy.attackTypes[attackAndTarget[0]] == ATK_BUFF): # Attack buff
			enemyAttackModifiers[attackAndTarget[1]] = 2
			enemyAttackModifierTurns[attackAndTarget[1]] = 2 * statusPower
			tBox.queueText(enemies[attackAndTarget[1]].enemyName + "'s attack increased!")
		elif (enemy.attackTypes[attackAndTarget[0]] == DEF_BUFF): # Defense buff
			enemyDefenseModifiers[attackAndTarget[1]] = 2
			enemyDefenseModifierTurns[attackAndTarget[1]] = 2 * statusPower
			tBox.queueText(enemies[attackAndTarget[1]].enemyName + "'s defense increased!")
		else: # Speed buff (default)
			enemySpeedModifiers[attackAndTarget[1]] = 2
			enemySpeedModifierTurns[attackAndTarget[1]] = 2 * statusPower
			tBox.queueText(enemies[attackAndTarget[1]].enemyName + "'s speed increased!")
		
	tBox.queueTextsFromArray(deathCheck())
	
	playerStatsDisplay.updateStats()
	# Now we need to wait for text to be clicked through before moving on
	tBox.queueText("SIGNAL_CLICKED_THROUGH")
	tBox.tempTextDisabled = true
	await tBox.clickedThroughText
	eDisplays[enemySlot].changeActiveTexture(0)
	tBox.tempTextDisabled = false

# Returns the attack index and target of the attack (3 means attack player)
func chooseEnemyMove(enemy: Control, enemySlot: int) -> Array:
	# Logic for choosing a move:
	# First see if any enemies stats are lowered
	var loweredATK = false
	var loweredDEF = false
	var loweredSPD = false
	var loweredEnemySlot = -1
	for i in enemyIDs.size():
		# Check for lowered stats
		if (enemyAttackModifiers[i] < 1):
			loweredATK = true
			loweredEnemySlot = i
		if (enemyDefenseModifiers[i] < 1):
			loweredDEF = true
			loweredEnemySlot = i
		if (enemySpeedModifiers[i] < 1):
			loweredSPD = true
			loweredEnemySlot = i
	
	# If any enemy has a stat that is lowered, and the user has a stat raising move
	# of the same type, use it on that enemy
	var raisingMove
	for i in enemy.attackTypes.size():
		if ((enemy.attackTypes[i] == ATK_BUFF and loweredATK) or
				(enemy.attackTypes[i] == DEF_BUFF and loweredDEF) or 
				(enemy.attackTypes[i] == SPD_BUFF and loweredSPD)):
			return [i, loweredEnemySlot]
	
	# If none of that is true, choose a random attack
	var chosenMove = randi_range(0, enemy.attackTypes.size() - 1)
	# If it is a buffing move, choose a random enemy that exists to target it with
	# if they don't already have that buff
	if ((enemy.attackTypes[chosenMove] == ATK_BUFF) or (enemy.attackTypes[chosenMove] == DEF_BUFF)
		or (enemy.attackTypes[chosenMove] == SPD_BUFF)):
			var validEnemyTargets: Array = [enemySlot] # Double chance to choose self, and makes sure enemy can always use at least one move
			for i in enemyIDs.size():
				if (enemyIDs[i] != -1 and
					(enemy.attackTypes[chosenMove] == ATK_BUFF and not
					enemyAttackModifiers[i] > 1) and
					(enemy.attackTypes[chosenMove] == DEF_BUFF and not
					enemyDefenseModifiers[i] > 1) and
					(enemy.attackTypes[chosenMove] == SPD_BUFF and not
					enemySpeedModifiers[i] > 1)):
					validEnemyTargets.append(i)
			return[chosenMove, validEnemyTargets[randi_range(0, validEnemyTargets.size() - 1)]]
	else:
		return [chosenMove, 3] # It must be a damaging move, so target player

func endBattle():
	if not FileAccess.file_exists(mapFile):
		area = 0
	else:
		var save_file = FileAccess.open(mapFile, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			var node_data = json.data
			for i in node_data.keys():
				if (i == "area"):
					set(i, int(node_data[i]))
	if (battleEnded == BATTLE_LOST):
		tBox.queueText("You lost!")
		tBox.queueText("Game Over!")
		tBox.queueText("SIGNAL_CLICKED_THROUGH")
		tBox.tempTextDisabled = true
		await tBox.clickedThroughText
		tBox.tempTextDisabled = false
		# TODO: Go back to main menu here
		print("Go back to main menu here")
	else:
		tBox.queueText("You won!")
		
		var HPGained = 0
		var ATKGained = 0
		var DEFGained = 0
		var SPDGained = 0
		# Player gains stats here
		if (bossBattle):
			HPGained = 10
			ATKGained = 3
			DEFGained = 3
			SPDGained = 3
		else:
			for i in numEnemies:
				HPGained += 1
				var gainingStat = randi_range(0, 2)
				if (gainingStat == 0):
					ATKGained += 1
				elif (gainingStat == 1):
					DEFGained += 1
				else:
					SPDGained += 1
		player.HP += HPGained
		player.maxHP += HPGained
		player.attack += ATKGained
		player.defense += DEFGained
		player.speed += SPDGained
		var statGainedText: Array = []
		if (HPGained > 0):
			statGainedText.append(player.playerName + " gained " + str(HPGained) + " HP!")
		if (ATKGained > 0):
			statGainedText.append(player.playerName + " gained " + str(ATKGained) + " ATK!")
		if (DEFGained > 0):
			statGainedText.append(player.playerName + " gained " + str(DEFGained) + " DEF!")
		if (SPDGained > 0):
			statGainedText.append(player.playerName + " gained " + str(SPDGained) + " SPD!")
		
		playerStatsDisplay.updateStats()
		
		tBox.queueTextsFromArray(statGainedText)
		tBox.queueText("SIGNAL_CLICKED_THROUGH")
		tBox.tempTextDisabled = true
		await tBox.clickedThroughText
		tBox.tempTextDisabled = false
		
		# Now we need to give the players the ability to get items after battle
		if (numEnemies == 1):
			iAttackSlots[1].enable()
			iAttackSlots[1].spawnRandomAreaItem(area)
		elif (numEnemies == 2):
			iAttackSlots[0].enable()
			iAttackSlots[2].enable()
			iAttackSlots[0].spawnRandomAreaItem(area)
			iAttackSlots[2].spawnRandomAreaItem(area)
		elif (numEnemies == 3):
			iAttackSlots[0].enable()
			iAttackSlots[1].enable()
			iAttackSlots[2].enable()
			iAttackSlots[0].spawnRandomAreaItem(area)
			iAttackSlots[1].spawnRandomAreaItem(area)
			iAttackSlots[2].spawnRandomAreaItem(area)
		
		nextButton.disabled = false
		await nextButton.button_up
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
		
		if (shouldDisable == true):
			nextButton.disabled = true
		else:
			nextButton.disabled = false

func resolveItemEffects(item: Control, enemy: Control, enemySlot: int):
	# Calculate minimal item bonus
	var maxItemsUsed = 0
	var actualItemsUsed = 0
	var minimalItemBonus
	for i in enemyIDs.size():
		if (enemyIDs[i] != -1):
			maxItemsUsed += 1
		if (attackItemsExist[i]):
			actualItemsUsed += 1
	
	minimalItemBonus = (0.25 * (maxItemsUsed - actualItemsUsed)) + 1
	var actualItemPower = (int) (item.itemPower * minimalItemBonus)
	
	# Deal damage to the enemy
	var effect = item.itemEffect
	var effectModifier = calculateEnemyTypeModifiers(enemy, effect)
	if (not (effect >= HEAL)):
		var damage = damageCalc(player.attack, enemy.defense, playerAttackModifier, 
						enemyDefenseModifiers[enemySlot], effectModifier, actualItemPower)
		enemy.takeDamage(damage)
		tBox.queueText(enemy.enemyName + " took " + str(damage) + " damage!")
	
	# Activate item effects
	var statusDisplayString = applyItemStatus(item, enemy, enemySlot, minimalItemBonus)
	tBox.queueText(statusDisplayString)
	
func damageCalc(ATK: int, DEF: int, ATKModifier: float, DEFModifier: float,
				attackEffectModifier: float, attackPower:int) -> int:
	var damage = (((ATK * ATKModifier) * attackPower * ITEM_POWER_MULT) / ((DEF * DEFModifier * 2) + 1)) * attackEffectModifier
	damage = max(1, floori(damage))
	return damage

func applyItemStatus(item: Control, enemy: Control, enemySlot: int, minimalItemBonus: float) -> String:
	var chance = chanceToApply(item.itemPower)
	var statusPower
	var length = 0
	var MID: int
	if (minimalItemBonus == 1.5):
		MID = 2
	elif (minimalItemBonus == 1.25):
		MID = 1
	elif (minimalItemBonus == 1):
		MID = 0
	
	if (item.itemPower == 1):
		statusPower = 1
	elif (item.itemPower == 2):
		statusPower = 2
	else:
		statusPower = 3
	
	if (item.itemEffect == NORMAL):
		# Nothing
		return ""
	elif (item.itemEffect == EXPLOSION):
		# Nothing
		return ""
	elif (item.itemEffect == FIRE):
		# Chance to burn
		if (chance):
			enemyStatuses[enemySlot] = BURN
			length = (statusPower * 2) + MID
			enemyStatusTurns[enemySlot] = length
			enemy.buildStatusText(BURN, length)
			return enemy.enemyName + " was burned for " + str(length) + " turns!"
	elif (item.itemEffect == ICE):
		# Chance to freeze
		if (chance):
			enemyStatuses[enemySlot] = FREEZE
			length = (statusPower * 2) + MID
			enemyStatusTurns[enemySlot] = length
			enemy.buildStatusText(FREEZE, length)
			return enemy.enemyName + " was frozen for " + str(length) + " turns!"
	elif (item.itemEffect == ELECTRIC):
		# Chance to static
		if (chance):
			enemyStatuses[enemySlot] = STATIC
			length = (statusPower * 2) + MID
			enemyStatusTurns[enemySlot] = length
			enemy.buildStatusText(STATIC, length)
			return enemy.enemyName + " was shocked for " + str(length) + " turns!"
	elif (item.itemEffect == AIR):
		# Chance to knockback
		if (chance):
			speedCounters[enemySlot] -= (int)((0.20 * statusPower * speedThreshold) + (0.20 * MID))
			return enemy.enemyName + " was knocked back!"
	elif (item.itemEffect == POISON):
		# Chance to poison
		if (chance):
			enemyStatuses[enemySlot] = POISONED
			length = (statusPower * 2) + MID
			enemyStatusTurns[enemySlot] = length
			enemy.buildStatusText(POISONED, length)
			return enemy.enemyName + " was poisoned for " + str(length) + " turns!"
	elif (item.itemEffect == ACID):
		# Chance to corrode
		if (chance):
			enemyStatuses[enemySlot] = CORRODED
			length = (statusPower * 2) + MID
			enemyStatusTurns[enemySlot] = length
			enemy.buildStatusText(CORRODED, length)
			return enemy.enemyName + " was corroded for " + str((length)) + " turns!"
	elif (item.itemEffect == HEAL):
		# Heal for 1/3 maxHp
		var healAmount = min(player.maxHP - player.HP, (int) ((0.20 * player.maxHP * statusPower)) * (1 + (0.25 * MID)))
		player.heal(healAmount)
		return player.playerName + " was healed for " + str(healAmount) + " health!"
	elif (item.itemEffect == ATK_BUFF):
		# Attack buff player
		playerAttackModifier = 2
		length = (statusPower * 2) + MID
		playerAttackModifierTurns = length
		return player.playerName + "'s attack was increased for " + str(length) + " turns!"
	elif (item.itemEffect == DEF_BUFF):
		# Defense buff player
		playerDefenseModifier = 2
		length = (statusPower * 2) + MID
		playerDefenseModifierTurns = length
		return player.playerName + "'s defense was increased for " + str(length) + " turns!"
	elif (item.itemEffect == SPD_BUFF):
		# Speed buff player
		playerSpeedModifier = 2
		length = (statusPower * 2) + MID
		playerSpeedModifierTurns = length
		return player.playerName + "'s speed was increased for " + str(length) + " turns!"
	elif (item.itemEffect == ATK_DROP):
		# Attack drop enemy
		enemyAttackModifiers[enemySlot] = 0.5
		length = (statusPower * 2) + MID
		enemyAttackModifierTurns[enemySlot] = length
		return enemy.enemyName + "'s attack was lowered for " + str(length) + " turns!"
	elif (item.itemEffect == DEF_DROP):
		# Defense drop enemy
		enemyDefenseModifiers[enemySlot] = 0.5
		length = (statusPower * 2) + MID
		enemyDefenseModifierTurns[enemySlot] = length
		return enemy.enemyName + "'s defense was lowered for " + str(length) + " turns!"
	elif (item.itemEffect == SPD_DROP):
		# Speed drop enemy
		enemySpeedModifiers[enemySlot] = 0.5
		length = (statusPower * 2) + MID
		enemySpeedModifierTurns[enemySlot] = length
		return enemy.enemyName + "'s speed was lowered for " + str(length) + " turns!"
	elif (item.itemEffect == BURN):
		# Burn
		enemyStatuses[enemySlot] = BURN
		length = (statusPower * 2) + MID
		enemyStatusTurns[enemySlot] = length
		enemy.buildStatusText(BURN, length)
		return enemy.enemyName + " was burned for " + str(length) + " turns!"
	elif (item.itemEffect == FREEZE):
		# Freeze
		enemyStatuses[enemySlot] = FREEZE
		length = (statusPower * 2) + MID
		enemyStatusTurns[enemySlot] = length
		enemy.buildStatusText(FREEZE, length)
		return enemy.enemyName + " was frozen for " + str(length) + " turns!"
	elif (item.itemEffect == STATIC):
		# Static
		enemyStatuses[enemySlot] = STATIC
		length = (statusPower * 2) + MID
		enemyStatusTurns[enemySlot] = length
		enemy.buildStatusText(STATIC, length)
		return enemy.enemyName + " was shocked for " + str(length) + " turns!"
	elif (item.itemEffect == KNOCKBACK):
		# Knockback
		speedCounters[enemySlot] -= (int)((0.20 * statusPower * speedThreshold) + (0.20 * MID))
		return enemy.enemyName + " was knocked back!"
	elif (item.itemEffect == POISONED):
		# Poison
		enemyStatuses[enemySlot] = POISONED
		length = (statusPower * 2) + MID
		enemyStatusTurns[enemySlot] = length
		enemy.buildStatusText(POISONED, length)
		return enemy.enemyName + " was poisoned for " + str(length) + " turns!"
	elif (item.itemEffect == CORRODED):
		# Corrode
		enemyStatuses[enemySlot] = CORRODED
		length = (statusPower * 2) + MID
		enemyStatusTurns[enemySlot] = length
		enemy.buildStatusText(CORRODED, length)
		return enemy.enemyName + " was corroded for " + str(length) + " turns!"
	
	return ""

func chanceToApply(pow: int) -> bool:
	var chance
	if (pow <= 5):
		chance = 0.10
	elif (pow <= 10 and pow > 5):
		chance = 0.20
	else:
		chance = 0.30
	if (randf() <= chance):
		return true
	else:
		return false

func killEnemy(enemy: Control, enemySlot: int) -> void:
	# This sets all of the array values for the enemy back to their default
	enemies[enemySlot] = null
	enemyIDs[enemySlot] = -1
	speedCounters[enemySlot] = 0
	enemiesAttacking[enemySlot] = false
	enemyTextureModes[enemySlot] = -1
	enemyStatuses[enemySlot] = -1
	enemyStatusTurns[enemySlot] = 0
	enemyAttackModifiers[enemySlot] = 1
	enemyAttackModifierTurns[enemySlot] = 0
	enemyDefenseModifiers[enemySlot] = 1
	enemyDefenseModifierTurns[enemySlot] = 0
	enemySpeedModifiers[enemySlot] = 1
	enemySpeedModifierTurns[enemySlot] = 0
	await eDisplays[enemySlot].disable(true)
	enemy.queue_free()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	eHealthBars[enemySlot].add_theme_stylebox_override("background", style)
	eHealthBars[enemySlot].add_theme_stylebox_override("fill", style)
	iAttackSlots[enemySlot].disable()

func activateEnemyStatuses(enemy:Control, enemySlot: int) -> String:
	var damage
	if (enemyStatuses[enemySlot] == BURN):
		# Burn deals 1/10th of an enemies health, and lowers their attack
		damage = (int) (enemy.HP / 10.0) * calculateEnemyTypeModifiers(enemy, FIRE)
		enemy.HP -= damage
		if (!(enemyAttackModifiers[enemySlot] > 1)):
			enemyAttackModifiers[enemySlot] = min(enemyAttackModifiers[enemySlot], 0.75)
		return enemy.enemyName + " is burned!\n" + enemy.enemyName + " took " + str(damage) + " damage!"
	if (enemyStatuses[enemySlot] == FREEZE):
		# Freeze sets the enemies speed counter to 0, preventing them from moving
		speedCounters[enemySlot] = 0
		enemiesAttacking[enemySlot] = false
		eDisplays[enemySlot].changeActiveTexture(0)
		return enemy.enemyName + " is frozen!\n" + enemy.enemyName + " can't move!"
	if (enemyStatuses[enemySlot] == STATIC):
		# Static deals 1/10th of an enemies health, and lowers their speed
		damage = (int) (enemy.HP / 10.0) * calculateEnemyTypeModifiers(enemy, ELECTRIC)
		enemy.HP -= damage
		if (!(enemySpeedModifiers[enemySlot] > 1)):
			enemySpeedModifiers[enemySlot] = min(enemySpeedModifiers[enemySlot], 0.75)
		return enemy.enemyName + " is shocked!\n" + enemy.enemyName + " took " + str(damage) + " damage!"
	if (enemyStatuses[enemySlot] == POISONED):
		# Poison deals 1/8th of an enemies health
		damage = (int) (enemy.HP / 8.0) * calculateEnemyTypeModifiers(enemy, POISON)
		enemy.HP -= damage
		return enemy.enemyName + " is poisoned!\n" + enemy.enemyName + " took " + str(damage) + " damage!"
	if (enemyStatuses[enemySlot] == CORRODED):
		# Corroded deals 1/10th of an enemies health, and lowers their defense
		damage = (int) (enemy.HP / 10.0) * calculateEnemyTypeModifiers(enemy, ACID)
		enemy.HP -= damage
		if (!(enemyDefenseModifiers[enemySlot] > 1)):
			enemyDefenseModifiers[enemySlot] = min(enemyDefenseModifiers[enemySlot], 0.75)
		return enemy.enemyName + " is corroded!\n" + enemy.enemyName + " took " + str(damage) + " damage!"
	enemyStatusTurns[enemySlot] -= 1
	if (enemyStatusTurns[enemySlot] <= 0):
		enemyStatuses[enemySlot] == -1
		enemyStatusTurns[enemySlot] = 0
	return ""

func calculateEnemyTypeModifiers(enemy: Control, type: int) -> float:
	for i in enemy.damageTypeWeaknesses.size():
		if (type == enemy.damageTypeWeaknesses[i]):
			return 2.0
	for i in enemy.damageTypeResistances.size():
		if (type == enemy.damageTypeResistances[i]):
			return 0.5
	return 1

func onTextProgressed():
	playerStatsDisplay.updateStats()

func onRunComplete():
	if (player.itemInventoryNum > 2 and not bossBattle):
		tBox.queueText(player.playerName + " ran away!")
		# Remove two random items from the inventory
		var item1 = randi_range(0, player.itemInventoryNum - 1)
		var item1Name = player.itemInventory[item1].itemName
		var item2 = randi_range(0, player.itemInventoryNum - 1)
		var item2Name = player.itemInventory[item2].itemName
		player.removeItemFromInventory(item1, 0)
		player.removeItemFromInventory(item2, 0)
		tBox.queueText(player.playerName + " dropped " + item1Name + " and " + item2Name + "!")
		tBox.queueText("SIGNAL_CLICKED_THROUGH")
		tBox.tempTextDisabled = true
		await tBox.clickedThroughText
		tBox.tempTextDisabled = false
		player.savePlayer()
		get_tree().change_scene_to_file("res://Scenes/map.tscn")
	else:
		if (bossBattle):
			tBox.showTempText(player.playerName + " can't run away!\n(Can't run during a boss fight!)")
			await tBox.textProgressed
			tBox.stopShowingTempText()
		else:
			tBox.showTempText(player.playerName + " can't run away!\n(Need more items to run away!)")
			await tBox.textProgressed
			tBox.stopShowingTempText()
		
