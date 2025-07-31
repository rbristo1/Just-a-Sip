extends Control

var map : Array
@export var mapWidth = 5
@export var mapHeight = 5
@export var numeratorChance = 6
@export var reduceSizeModifier = 5
@export var denominatorChance = 10
@export var mapFile = "res://JSONS/map.JSON"
var area = 0
@export var mapLength = 8
#make odd ideally
@export var widthPeak = 5
var adjList: Array = []
var widths: Array
var events: Array = []
var midpoint
var playerPosX
var playerPosY
#for old generation
func hasSiblings(map: Array, x: int, y: int) -> bool:
	var sum = 0
	if (x > 0 and map[x-1][y] == 1):
		sum += 1
	if (x < mapWidth-1 and map[x+1][y] == 1):
		sum += 1
	if (y > 0 and map[x][y-1] == 1):
		sum += 1
	if (y < mapHeight-1 and map[x][y+1] == 1):
		sum += 1
	
	if (sum >= 2):
		return true
	else:
		return false

#for old generation
func hasFewSiblings(map: Array, x: int, y: int) -> int:
	var sum = 0
	if (x > 0 and map[x-1][y] == 1):
		sum += 1
	if (x < mapWidth-1 and map[x+1][y] == 1):
		sum += 1
	if (y > 0 and map[x][y-1] == 1):
		sum += 1
	if (y < mapHeight-1 and map[x][y+1] == 1):
		sum += 1
	
	return sum


#old dungeon generation technique
func generateMap():
	for i in mapHeight:
		var mapRow: Array
		for j in mapWidth:
			mapRow.append(1)
		map.append(mapRow)
	
	
	for i in mapHeight:
		for j in mapWidth:
			if (randi()%denominatorChance < numeratorChance and (j-1 < 0 or hasSiblings(map, j-1, i)) and (j+1 >= mapWidth or hasSiblings(map, j+1, i)) and (i+1 >= mapHeight or hasSiblings(map, j, i+1)) and (i-1 < 0 or hasSiblings(map, j, i-1)) and (hasFewSiblings(map, j, i) > 3 or hasFewSiblings(map, j, i) < 2)):
				map[j][i] = 0
	for i in mapHeight:
		for j in mapWidth:
			if (randi()%denominatorChance < numeratorChance and (j-1 < 0 or hasSiblings(map, j-1, i)) and (j+1 >= mapWidth or hasSiblings(map, j+1, i)) and (i+1 >= mapHeight or hasSiblings(map, j, i+1)) and (i-1 < 0 or hasSiblings(map, j, i-1)) and (hasFewSiblings(map, j, i) > 3 or hasFewSiblings(map, j, i) < 2)):
				map[j][i] = 0
				
	#for i in mapHeight:
		#if (randi()%denominatorChance < numeratorChance and hasFewSiblings(map, 0, i) >2):
			#map[0][i] = 0
		#if (randi()%denominatorChance < numeratorChance and hasFewSiblings(map, mapWidth-1, i) >2):
			#map[mapWidth-1][i] = 0
	#for i in mapWidth:
		#if (randi()%denominatorChance < numeratorChance and hasFewSiblings(map, 0, i) >2):
			#map[i][0] = 0
		#if (randi()%denominatorChance < numeratorChance and hasFewSiblings(map, mapHeight-1, i) >2):
			#map[i][mapHeight-1] = 0
	for i in map.size():
		print(map[i])


#Diagonal generation technique
func generateMap2():
	for i in widthPeak:
		var mapRow: Array
		for j in mapLength:
			mapRow.append(0)
		map.append(mapRow)
	midpoint = (widthPeak/2)+widthPeak%2-1
	playerPosX = 0
	playerPosY = midpoint
	print(midpoint)
	map[midpoint][0] = 1
	var width = 1
	for i in mapLength:
		
		var alternator = -1
		if (width != widthPeak and randi()%denominatorChance < numeratorChance and mapLength-width > i and i > 0):
			width += 1
		elif (mapLength-width < i):
			width -= 1
		elif (width > 1 and randi()%denominatorChance < numeratorChance/reduceSizeModifier):
			width -= 1
		for j in width:
			map[midpoint-((j+1)/(2*alternator))][i] = 1
			alternator *= -1
		widths.append(width)
	for i in map.size():
		print(map[i])
	print("\n")
	for i in mapLength:
		var ran = 0
		for j in widthPeak:
			
			if map[j][i] == 1 and randi()%10 < 4-abs(j-midpoint) and widths[i] > 2 and i > 1 and i < mapLength-1 and ran != widths[i]-1: 
				map[j][i] = 0
				ran += 1
				
	adjListGen()
	eventGen()
	for i in map.size():
		print(map[i])


func eventGen():
	
	for i in widthPeak:
		var eventRow: Array
		for j in mapLength:
			if (map[i][j] == 1):
				eventRow.append(1)
			else:
				eventRow.append(0)
		events.append(eventRow)
	for i in mapLength:
		for j in widthPeak:
			if (map[j][i] == 1):
				events[j][i] = randi()%3+1
				
	events[midpoint][mapLength-1] = 4
	events[midpoint][0] = -1
	for i in events.size():
		print(events[i])

#generates 3d array for storing an adjacency list at each point on the map
func adjListGen():
	
	for i in mapLength:
		var sum = 0
		for j in widthPeak:
			if (map[j][i] == 1):
				sum += 1
		widths[i] = sum
	
	
	
	for i in widthPeak:
		var adjListRow: Array = []
		for j in mapLength:
			var adjListRowVecs: Array = []
			adjListRow.append(adjListRowVecs)
		adjList.append(adjListRow)
		print("ran")
	for i in mapLength-1:
		var usedIndexes: Array = []
		for j in widthPeak:
			if (map[j][i] == 1):
				var connections = randi()%widths[i+1] + 1
				var tempVec: Array = []
				var tempVec2: Array = []
				for k in widthPeak:
						if (map[k][i+1] == 1):
							tempVec.append(k)
							tempVec2.append(k)
				for k in connections:
					if widths[i] == 1:
						adjList[j][i] = tempVec
					else:
						if (tempVec.size() != 0):
							var index = randi()%tempVec.size()
							var val = tempVec[index]
							adjList[j][i].append(val)
							if (usedIndexes.find(val) == -1):
								usedIndexes.append(val)
							tempVec.remove_at(index)
					if j == widths[i] and usedIndexes.size() != tempVec2.size():
						adjList[j][i] = tempVec2
						usedIndexes = tempVec2
				if j > widths[i] and usedIndexes.size() != tempVec2.size():
					adjList[j][i] = tempVec2
					for k in tempVec2.size():
						if usedIndexes.find(tempVec2[k]) == -1:
							adjList[j][i].append(tempVec2[k])
							usedIndexes.append(tempVec2[k])
					
					
					
					
			

	
	for i in adjList.size():
		print(adjList[i])
 
#creates lines and buttons and places them on the screen
func displayMap() -> void:
	var x = 30
	var y = 40
	var incrX = 630/mapLength
	var incrY = 350/widthPeak
	var colorIncre = 0
	print (adjList)
	print (playerPosX)
	print (playerPosY)
	for i in widthPeak:
		for j in mapLength:
			if (map[i][j] == 1):
				#down
				var location = TextureButton.new()
				location.pressed.connect(_on_texture_button_pressed.bind(i))
				var text1
				var text2
				var text3
				if (events[i][j] == -1):
					if playerPosX == 0:
						text1 = load("res://Art/Atlas Textures/UI/map_buttons/playerStart-1.png.png")
						text2 = load("res://Art/Atlas Textures/UI/map_buttons/playerStart-1.png.png")
						text3 = load("res://Art/Atlas Textures/UI/map_buttons/playerStart-1.png.png")
					else:
						text1 = load("res://Art/Atlas Textures/UI/map_buttons/playerStart-1.png.png")
						text2 = load("res://Art/Atlas Textures/UI/map_buttons/playerStart-2.png.png")
						text3 = load("res://Art/Atlas Textures/UI/map_buttons/playerStart-3.png.png")
				if (events[i][j] == 1):
					text1 = load("res://Art/Atlas Textures/UI/map_buttons/Battle-1.png.png")
					text2 = load("res://Art/Atlas Textures/UI/map_buttons/Battle-2.png.png")
					text3 = load("res://Art/Atlas Textures/UI/map_buttons/Battle-3.png.png")
				if (events[i][j] == 2):
					text1 = load("res://Art/Atlas Textures/UI/map_buttons/Encounter-1.png.png")
					text2 = load("res://Art/Atlas Textures/UI/map_buttons/Encounter-2.png.png")
					text3 = load("res://Art/Atlas Textures/UI/map_buttons/Encounter-3.png.png")
				if (events[i][j] == 3):
					text1 = load("res://Art/Atlas Textures/UI/map_buttons/Random-1.png.png")
					text2 = load("res://Art/Atlas Textures/UI/map_buttons/Random-2.png.png")
					text3 = load("res://Art/Atlas Textures/UI/map_buttons/Random-3.png.png")
				if (events[i][j] == 4):
					text1 = load("res://Art/Atlas Textures/UI/map_buttons/Final Battle-1.png.png")
					text2 = load("res://Art/Atlas Textures/UI/map_buttons/Final Battle-2.png.png")
					text3 = load("res://Art/Atlas Textures/UI/map_buttons/Final Battle-3.png.png")
				location.texture_hover = text1
				location.texture_normal = text2
				location.texture_disabled = text3
				var dis1
				var dis2
				if adjList[playerPosY][playerPosX].find(i) == -1 or j != playerPosX + 1:
					dis1 = true
				if adjList[playerPosY][playerPosX].find(float(i)) == -1 or j != playerPosX + 1:
					dis2 = true
				if dis1 and dis2:
					location.disabled = true
				
				var position: Vector2
				position.x = x
				position.y = y
				colorIncre = colorIncre % 3
				location.set_position(position, false)
				for k in adjList[i][j].size():
					var line = Line2D.new()
					var pos1 = position
					pos1.x+=16
					pos1.y+=8
					line.add_point(pos1)
					
					line.width = 1
					if colorIncre == 0:
						line.modulate = Color(255, 0, 255)
					elif colorIncre == 1:
						line.modulate = Color(0, 255, 255)
					elif colorIncre == 2:
						line.modulate = Color(255, 255, 0)
					
					var pos2 = pos1
					pos2.x += incrX-16
					pos2.y = 40+incrY*adjList[i][j][k]+8
					line.add_point(pos2)
					add_child(line)
				x+=incrX
				add_child(location)
				colorIncre += 1
				colorIncre = colorIncre % 3
			else:
				x+=incrX
		y+=incrY
		x=30

func _on_texture_button_pressed(i: int) -> void:
	
	playerPosX += 1
	playerPosY = i
	
	print(i)
	mapSave()
	#battle
	if (events[playerPosY][playerPosX] == 1):
		get_tree().change_scene_to_file("res://Scenes/Battle.tscn")
	#encounter
	elif (events[playerPosY][playerPosX] == 2):
		get_tree().change_scene_to_file("res://Scenes/encounter.tscn")
	#random
	elif (events[playerPosY][playerPosX] == 3):
		if (randi()%2 == 0):
			get_tree().change_scene_to_file("res://Scenes/Battle.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/encounter.tscn")
	#boss
	elif (events[playerPosY][playerPosX] == 4):
		get_tree().change_scene_to_file("res://Scenes/Battle.tscn")

func mapSave():
	var save_dict = {
		"map" : map,
		"events" : events,
		"adjList" : adjList,
		"midpoint": midpoint,
		"playerPosX": playerPosX,
		"playerPosY": playerPosY,
		"area": area
	}
	var saveFile = FileAccess.open(mapFile, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	saveFile.store_line(json_string)

func mapLoad():
	if not FileAccess.file_exists(mapFile):
		return
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
				#if (i == "")
				set(i, node_data[i])

func _ready() ->void:
	#TODO remove 1 == 0 later once battles can return to map, delete the map JSON after game is won/finished to generate new
	if FileAccess.file_exists(mapFile):
		mapLoad()
		#if playerPosX == 0:
			#generateMap2()
	else:
		area = 0
		generateMap2()
	
	if playerPosX == float(mapLength)-1.0:
		area += 1
		if area == 3:
			#TODO add correct path
			get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
		adjList = []
		widths = []
		events = []
		generateMap2()
	
	displayMap()
	mapSave()
	
	
