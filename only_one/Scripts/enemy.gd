extends VBoxContainer
var enemyMaxHP
var enemyDEF
var enemyImage
var enemyHP
var enemyATK
var enemyIDs
var enemyNames
var enemySPD
var enemySplash
var enemyUndead
var area
@export var enemiesFile = "res://JSONS/enemies.JSON"


var enemies
var enemiesHP: Array

func _ready() -> void:
	
	loadEnemyCache()
	generateEnemies()
	enemiesHP.append(enemyHP[enemies[0]])
	enemiesHP.append(enemyHP[enemies[1]])
	enemiesHP.append(enemyHP[enemies[2]])
	initEnemies()
	


func initEnemies():
	if (enemies[0] != -1):
		$EnemyImageRow/EnemyImage1.texture = load(enemyImage[enemies[0]])
		$EnemyInfoRow/HealthBar1.max_value = enemyHP[enemies[0]]
		$EnemyInfoRow/HealthBar1.value = enemiesHP[0]
	else:
		$EnemyImageRow/EnemyImage1.texture = null
		$EnemyInfoRow/HealthBar1.z_index = -100
		$ItemSlotRow/BattleItemSlot1/BattleItemDisplay1.queue_free()
		$ItemSlotRow/BattleItemSlot1.z_index = -100
		
	if (enemies[1] != -1):
		$EnemyImageRow/EnemyImage2.texture = load(enemyImage[enemies[1]])
		$EnemyInfoRow/HealthBar2.max_value = enemyHP[enemies[1]]
		$EnemyInfoRow/HealthBar2.value = enemiesHP[1]
		
	else:
		$EnemyImageRow/EnemyImage2.texture = null
		$EnemyInfoRow/HealthBar2.z_index = -100
		$ItemSlotRow/BattleItemSlot2/BattleItemDisplay2.queue_free()
		$ItemSlotRow/BattleItemSlot2.z_index = -100
	if (enemies[2] != -1):
		$EnemyImageRow/EnemyImage3.texture = load(enemyImage[enemies[2]])
		$EnemyInfoRow/HealthBar3.max_value = enemyHP[enemies[2]]
		$EnemyInfoRow/HealthBar3.value = enemiesHP[2]
	else:
		$EnemyImageRow/EnemyImage3.texture = null
		$EnemyInfoRow/HealthBar3.z_index = -100
		$ItemSlotRow/BattleItemSlot3/BattleItemDisplay3.queue_free()
		$ItemSlotRow/BattleItemSlot3.z_index = -100

func generateEnemies():
	
	enemies = [-1,0,0]

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
				print(i)
				print(node_data[i])
