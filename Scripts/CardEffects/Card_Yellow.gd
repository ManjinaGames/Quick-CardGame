extends CardBase
class_name Card_Yellow
#region VARIABLES
var cardResource: CardResource_Red
#endregion

func SetColor(_sprite:Sprite2D):
	_sprite.self_modulate = Color.YELLOW
