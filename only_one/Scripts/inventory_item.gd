extends Control

<<<<<<< Updated upstream
enum EType {DAMAGING, HEALING, STUNNING, BUFF_ATK, BUFF_DEF, BUFF_SPD}
@export var itemName = ""
@export var effectType = -1
@export var power = -1

func initialize(Name: String, EffectType: int, Power: int):
=======
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
>>>>>>> Stashed changes
	itemName = Name
	effectType = EffectType
	power = Power

	
<<<<<<< Updated upstream
=======
func deinitialize() -> void:
	itemID = -1
	inventorySlot = -1
	itemName = ""
	itemPower = -1
	itemImage = null
	itemHoverImage = null
	itemSplash = false
>>>>>>> Stashed changes
