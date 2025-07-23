extends TextureRect

enum EType {HEALING, EXPLODING, FIRE, ICE, POISON}
@export var itemID = -1
@export var itemName = ""
@export var itemEffect = -1
@export var itemPower = -1
@export var itemImage: AtlasTexture = null
@export var itemHoverImage: AtlasTexture = null
@export var itemSplash = false

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
	
func unlink() -> void:
	itemID = -1
	itemName = ""
	itemPower = -1
	itemImage = null
	itemHoverImage = null
	itemSplash = false

func _on_mouse_entered() -> void:
	if itemHoverImage != null:
		texture = itemHoverImage
	print("hi")

func _on_mouse_exited() -> void:
	if texture != itemImage:
		texture = itemImage

func _get_drag_data(at_position: Vector2) -> Variant:
	return
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	pass
