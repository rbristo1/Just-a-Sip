extends Control

enum {NORMAL, EXPLOSION, FIRE, ICE, ELECTRIC, AIR, POISON, ACID, HEAL, ATK_BUFF,
		DEF_BUFF, SPD_BUFF, ATK_DROP, DEF_DROP, SPD_DROP, BURN, FREEZE, STATIC, KNOCKBACK}
@export var itemID = -1
@export var inventorySlot = -1
@export var itemName = ""
@export var itemEffect = -1
@export var itemPower = -1
@export var itemImage: AtlasTexture = null
@export var itemHoverImage: AtlasTexture = null
@export var itemArea: Array = []
@export var inventoryDisplaySpotNumber = 0

func initialize(ID: int, InvSlot: int, Name: String, Effect: int, Power: int, iImage: AtlasTexture,
					 iHImage: AtlasTexture, iArea: Array):
	itemID = ID
	inventorySlot = InvSlot
	itemName = Name
	itemEffect = Effect
	itemPower = Power
	itemImage = iImage
	itemHoverImage = iHImage
	itemArea = iArea
	
func initializeDict(info: Dictionary):
	itemID = info["iID"]
	inventorySlot = info["iSlot"]
	itemName = info["iName"]
	itemEffect = info["iEffect"]
	itemPower = info["iPower"]
	itemImage = info["iImage"]
	itemHoverImage = info["iHImage"]
	itemArea = info["iArea"]
	
func deinitialize() -> void:
	itemID = -1
	itemName = ""
	itemPower = -1
	itemImage = null
	itemHoverImage = null
	itemArea = []
