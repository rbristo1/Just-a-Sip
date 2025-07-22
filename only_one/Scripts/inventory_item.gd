extends Control

@onready var itemDisplay:TextureRect = $ItemDisplay

enum EType {DAMAGING, HEALING, STUNNING, BUFF_ATK, BUFF_DEF, BUFF_SPD}
@export var itemID = -1
@export var itemName = ""
@export var itemEffect = -1
@export var itemPower = -1
@export var itemImage = ""
@export var itemSplash = false

func initialize(ID: int, Name: String, Effect: int, Power: int, iImage: String, Splash: bool):
	itemID = ID
	itemName = Name
	itemEffect = Effect
	itemPower = Power
	itemImage = iImage
	itemSplash = Splash
	itemDisplay.texture = itemImage
	

	

	
