extends Control

var map : Array
@export var mapWidth = 5
@export var mapHeight = 5
@export var numeratorChance = 6
@export var reduceSizeModifier = 5
@export var denominatorChance = 10

@export var mapLength = 8
#make odd ideally
@export var widthPeak = 5

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

func generateMap2():
	for i in widthPeak:
		var mapRow: Array
		for j in mapLength:
			mapRow.append(0)
		map.append(mapRow)
	var midpoint = (widthPeak/2)+widthPeak%2-1
	print(midpoint)
	map[midpoint][0] = 1
	var width = 1
	var widths: Array
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
				
	
	
	for i in map.size():
		print(map[i])

func displayMap() -> void:
	var x = 30
	var y = 40
	var incrX = 630/mapLength
	var incrY = 350/widthPeak
	
	for i in widthPeak:
		for j in mapLength:
			if (map[i][j] == 1):
				#down
				var location = TextureButton.new()
				var script = load("res://Scripts/locationButton.gd")
				location.set_script(script)
				var text = load("res://Art/Atlas Textures/UI/pause_button/pause_button_normal.tres")
				location.texture_normal = text
				var position: Vector2
				position.x = x
				position.y = y
				location.set_position(position, false)
				#if i != mapHeight-1 and map[i+1][j] == 1: 
					#var line = Line2D.new()
					#var pos1 = position
					#pos1.x+=8
					#line.add_point(pos1)
					#line.width = 1
					#var pos2 = pos1
					#pos2.y += incrY
					#line.add_point(pos2)
					#add_child(line)
				if j != mapLength-1 and map[i][j+1] == 1: 
					var line = Line2D.new()
					var pos1 = position
					pos1.y+=8
					line.add_point(pos1)
					line.width = 1
					var pos2 = pos1
					pos2.x += incrX
					line.add_point(pos2)
					add_child(line)
				x+=incrX
				
				add_child(location)
			else:
				x+=incrX
		y+=incrY
		x=30


func _ready() ->void:
	generateMap2()
	displayMap()
	
	
