extends TextureRect
class_name ItemDisplay

enum EType {HEALING, EXPLODING, FIRE, ICE, POISON}
var pHud
var tBox
@export var itemID = -1
@export var itemName = ""
@export var itemEffect = -1
@export var itemPower = -1
@export var itemImage: AtlasTexture = null
@export var itemHoverImage: AtlasTexture = null
@export var itemSplash = false
@export var INVENTORY: bool = false
@export var INVENTORY_NUM: int = -1
@export var EXTRA_HOVER_MARGIN = 2

func _ready() -> void:
	pHud = get_tree().get_first_node_in_group("Player Hud")
	tBox = get_tree().get_first_node_in_group("Main Text Box")

func link(ID: int, Name: String, Effect: int, Power: int, iImage: AtlasTexture,
					 iHImage: AtlasTexture, Splash: bool):
	itemID = ID
	itemName = Name
	itemEffect = Effect
	itemPower = Power
	itemImage = iImage
	itemHoverImage = iHImage
	itemSplash = Splash
	texture = itemImage
	
func linkDict(info: Dictionary):
	itemID = info["iID"]
	itemName = info["iName"]
	itemEffect = info["iEffect"]
	itemPower = info["iPower"]
	itemImage = info["iImage"]
	itemHoverImage = info["iHImage"]
	itemSplash = info["iSplash"]
	texture = itemImage
	
func unlink() -> void:
	itemID = -1
	itemName = ""
	itemPower = -1
	itemImage = null
	itemHoverImage = null
	itemSplash = false
	texture = null

func _on_mouse_entered() -> void:
	if itemHoverImage != null:
		texture = itemHoverImage
	if (DragManager.isDragging == false):
		displayText()


func _on_mouse_exited() -> void:
	if texture != itemImage:
		texture = itemImage
	if (DragManager.isDragging == false):
		stopDisplayingText()


func _get_drag_data(_at_position: Vector2) -> Variant:
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
			"iSplash": itemSplash,
			"droppedFrom": self,
			"fromInventory": INVENTORY}
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only allow the item to be dropped here if the inventory is empty
	return typeof(data) == TYPE_DICTIONARY and data.has("iID") and itemID == -1
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	linkDict(data)
	data["droppedFrom"].unlink()
	# If the item was dragged from the inventory, clear the inventory slot
	if (data["fromInventory"] == true):
		pHud.findAndRemoveFromInventory(data["droppedFrom"].INVENTORY_NUM)
	
	# If the item was dragged to the inventory, add it to the inventory slot
	if (INVENTORY):
		pHud.findAndAddToInventory(data, INVENTORY_NUM)
	
func _has_point(point: Vector2) -> bool:
	# Expand the hitbox by 10px in all directions
	var expanded_rect = Rect2(Vector2(-EXTRA_HOVER_MARGIN, -EXTRA_HOVER_MARGIN),
				 size + Vector2(EXTRA_HOVER_MARGIN * 2, EXTRA_HOVER_MARGIN * 2))
	return expanded_rect.has_point(point)
	
func _notification(what: int) -> void:
	if (what == NOTIFICATION_DRAG_END):
		DragManager.isDragging = false
		tBox.dragLocked = false
		 

func displayText():
	if tBox != null and itemID != -1:
		tBox.showTempText(itemName)
	
func stopDisplayingText():
	if tBox != null and DragManager.isDragging == false and itemID != -1:
		tBox.stopShowingTempText()
