extends Card_Class
class_name Card_Class_Yellow
#region VARIABLES
var cardResource: Card_Resource_Yellow
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS
func SetColor(_texture:TextureRect):
	_texture.self_modulate = Color.YELLOW
#endregion
#-------------------------------------------------------------------------------
