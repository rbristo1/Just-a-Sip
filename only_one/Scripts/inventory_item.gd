extends Control

enum EType {HEALING, EXPLODING, FIRE, ICE, POISON}
@export var itemID = -1
@export var inventorySlot = -1
@export var itemName = ""
@export var itemEffect = -1
@export var itemPower = -1
@export var itemImage: AtlasTexture = null
@export var itemHoverImage: AtlasTexture = null
@export var itemSplash = false
@export var inventoryDisplaySpotNumber = 0

func initialize(ID: int, InvSlot: int, Name: String, Effect: int, Power: int, iImage: AtlasTexture,
					 iHImage: AtlasTexture, Splash: bool):
	itemID = ID
	inventorySlot = InvSlot
func initialize(ID: int, Name: String, Effect: int, Power: int, iImage: AtlasTexture,
					 iHImage: AtlasTexture, Splash: bool):
	itemID = ID
	itemName = Name
	itemEffect = Effect
	itemPower = Power
	itemImage = iImage
	itemHoverImage = iHImage
	itemSplash = Splash
	
func deinitialize() -> void:
	itemID = -1
	itemName = ""
	itemPower = -1
	itemImage = null
	itemHoverImage = null
	itemSplash = false
