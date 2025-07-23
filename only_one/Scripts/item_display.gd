extends TextureRect

enum EType {HEALING, EXPLODING, FIRE, ICE, POISON}
@export var itemID = -1
@export var itemName = ""
@export var itemEffect = -1
@export var itemPower = -1
@export var itemImage: AtlasTexture = null
@export var itemHoverImage: AtlasTexture = null
@export var itemSplash = false
@export var INVENTORY: bool = false
signal item_dropped(data)

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

func _on_mouse_exited() -> void:
	if texture != itemImage:
		texture = itemImage

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = self.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
	preview.modulate = Color(1, 1, 1, 0.5) # Half opacity
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE # Just in case
	set_drag_preview(preview)
	
	return {"iID": itemID,
			"iName": itemName,
			"iEffect": itemEffect,
			"iPower": itemPower,
			"iImage": itemImage,
			"iHImage": itemHoverImage,
			"iSplash": itemSplash,
			"droppedFrom": self}
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only allow the item to be dropped here if the inventory is empty
	return typeof(data) == TYPE_DICTIONARY and data.has("iID") and itemID == -1
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	linkDict(data)
	data["droppedFrom"].unlink()
	
	# If the item was dragged from the inventory, clear the inventory slot
	
	
	# If the item was dragged to the inventory, add it to the inventory slot
	
	
	
