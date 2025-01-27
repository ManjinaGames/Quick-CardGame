class_name CardBase
#region VARIABLES
@export var cardResource: CardResource
#endregion
func SetColor(_sprite:Sprite2D):
	_sprite.self_modulate = Color.RED
