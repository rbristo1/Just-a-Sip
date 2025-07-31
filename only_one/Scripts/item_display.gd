extends TextureRect
class_name ItemDisplay

enum {NORMAL, EXPLOSION, FIRE, ICE, ELECTRIC, AIR, POISON, ACID, HEAL, ATK_BUFF,
		DEF_BUFF, SPD_BUFF, ATK_DROP, DEF_DROP, SPD_DROP, BURN, FREEZE, STATIC, KNOCKBACK}
var pHud
var tBox
var statsDisplay
var itemID = -1
var itemName = ""
var itemEffect = -1
var itemPower = -1
@export var itemImage: AtlasTexture = null
@export var itemHoverImage: AtlasTexture = null
var itemArea: Array = []
@export var INVENTORY: bool = false
@export var INVENTORY_NUM: int = -1
@export var ATTACK_SLOT_NUM: int = -1
@export var EXTRA_HOVER_MARGIN = 2
var hovering = false
var disabled = false

signal itemInAttackSlot(slotNum: int, isInSlot: bool)


func _ready() -> void:
	pHud = get_tree().get_first_node_in_group("Player Hud")
	tBox = get_tree().get_first_node_in_group("Main Text Box")
	statsDisplay = get_tree().get_first_node_in_group("Player Stats Display")

func link(ID: int, Name: String, Effect: int, Power: int, iImage: AtlasTexture,
					 iHImage: AtlasTexture, iArea: Array):
	if (disabled == false):
		itemID = ID
		itemName = Name
		itemEffect = Effect
		itemPower = Power
		itemImage = iImage
		itemHoverImage = iHImage
		itemArea = iArea
		texture = itemImage
	
func linkDict(info: Dictionary):
	if (disabled == false):
		itemID = info["iID"]
		itemName = info["iName"]
		itemEffect = info["iEffect"]
		itemPower = info["iPower"]
		itemImage = info["iImage"]
		itemHoverImage = info["iHImage"]
		itemArea = info["iArea"]
		texture = itemImage
		
		if (self.is_in_group("Attack Item Displays")):
			itemInAttackSlot.emit(ATTACK_SLOT_NUM, true)
	
func unlink() -> void:
	if (disabled == false):
		itemID = -1
		itemName = ""
		itemPower = -1
		itemImage = null
		itemHoverImage = null
		itemArea = []
		texture = null
		
		if (self.is_in_group("Attack Item Displays")):
			itemInAttackSlot.emit(ATTACK_SLOT_NUM, false)

func _on_mouse_entered() -> void:
	if (disabled == false):
		if itemHoverImage != null:
			texture = itemHoverImage
		if (DragManager.isDragging == false):
			displayText()
		hovering = true

func _on_mouse_exited() -> void:
	if (disabled == false):
		if texture != itemImage:
			texture = itemImage
		if (DragManager.isDragging == false):
			stopDisplayingText()
		hovering = false

func _gui_input(event: InputEvent) -> void:
	if (disabled == false):
		if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
			DragManager.isDragging = event.pressed

func _get_drag_data(_at_position: Vector2) -> Variant:
	if (disabled == false):
		var preview = self.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
		preview.modulate = Color(1, 1, 1, 0.5) # Half opacity
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE # Just in case
		set_drag_preview(preview)
		DragManager.isDragging = true
	
		return {"iID": itemID,
				"iName": itemName,
				"iEffect": itemEffect,
				"iPower": itemPower,
				"iImage": itemImage,
				"iHImage": itemHoverImage,
				"iArea": itemArea,
				"droppedFrom": self,
				"fromInventory": INVENTORY}
	else:
		return {}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only allow the item to be dropped here if the inventory is empty
	return typeof(data) == TYPE_DICTIONARY and !disabled and not tBox.tempTextDisabled and data.has("droppedFrom") and data["droppedFrom"] != self

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if (data.has("iID") and itemID != -1):
		var oldItemData: Dictionary = {}
		oldItemData = {"iID": itemID,
						"iName": itemName,
						"iEffect": itemEffect,
						"iPower": itemPower,
						"iImage": itemImage,
						"iHImage": itemHoverImage,
						"iArea": itemArea,
						"droppedFrom": self,
						"fromInventory": INVENTORY}
		linkDict(data)
		data["droppedFrom"].unlink()
		data["droppedFrom"].linkDict(oldItemData)
		
		# If the new item is from the inventory, remove it and add the old item data
		if (data["fromInventory"] == true):
			pHud.findAndRemoveFromInventory(data["droppedFrom"].INVENTORY_NUM, true)
			pHud.findAndAddToInventory(oldItemData, data["droppedFrom"].INVENTORY_NUM, true)
		
		
		# If the old item is from the inventory, remove it and add the new item data
		if (INVENTORY):
			pHud.findAndRemoveFromInventory(INVENTORY_NUM, true)
			pHud.findAndAddToInventory(data, INVENTORY_NUM, true)
		#if INVENTORY_NUM <= 16:
		pHud.shiftInventoryLeft(-1)
	else:
		linkDict(data)
		data["droppedFrom"].unlink()
		# If the item was dragged from the inventory, clear the inventory slot
		if (data["fromInventory"] == true):
			pHud.findAndRemoveFromInventory(data["droppedFrom"].INVENTORY_NUM, false)
		
		# If the item was dragged to the inventory, add it to the inventory slot
		if (INVENTORY):
			pHud.findAndAddToInventory(data, INVENTORY_NUM, false)
	statsDisplay.updateStats()
	pHud.shiftInventoryLeft(-1)
	for i in pHud.itemInventory:
		print(i.itemID)

func _has_point(point: Vector2) -> bool:
	if (disabled == false):
		# Expand the hitbox by 10px in all directions
		var expanded_rect = Rect2(Vector2(-EXTRA_HOVER_MARGIN, -EXTRA_HOVER_MARGIN),
					 size + Vector2(EXTRA_HOVER_MARGIN * 2, EXTRA_HOVER_MARGIN * 2))
		return expanded_rect.has_point(point)
	else:
		return false

func _notification(what: int) -> void:
	if (disabled == false):
		if (what == NOTIFICATION_DRAG_END):
			DragManager.isDragging = false
			tBox.dragLocked = false
 
func displayText():
	if (disabled == false):
		if (tBox != null and itemID != -1):
			tBox.showTempText(itemName)

func stopDisplayingText():
	if (disabled == false):
		if (tBox != null and DragManager.isDragging == false and itemID != -1):
			tBox.stopShowingTempText()

func disable() -> void:
	disabled = true
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	get_parent().add_theme_stylebox_override("panel", style)

func enable() -> void:
	disabled = false
	var style = StyleBoxTexture.new()
	style.texture = load("res://Art/Atlas Textures/UI/item_slot/item_slot_normal.tres")
	style.region_rect = Rect2(0, 0, 16, 16)
	get_parent().add_theme_stylebox_override("panel", style)

func spawnRandomAreaItem(area: int) -> void:
	pHud.spawnRandomAreaItem(area, self)
