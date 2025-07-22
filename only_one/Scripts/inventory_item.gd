extends Control

enum EType {DAMAGING, HEALING, STUNNING, BUFF_ATK, BUFF_DEF, BUFF_SPD}
@export var itemName = ""
@export var effectType = -1
@export var power = -1

func initialize(Name: String, EffectType: int, Power: int):
	itemName = Name
	effectType = EffectType
	power = Power

	
