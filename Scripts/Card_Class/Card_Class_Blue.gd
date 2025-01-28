extends Card_Class
class_name Card_Class_Blue
#region VARIABLES
var cardResource: Card_Resource_Blue
#endregion
func SetColor(_texture:TextureRect):
	_texture.self_modulate = Color.BLUE
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card_Node):
	Finish_Drag_Common(_card, CardSlot_Node.FIELD_TYPE.ITEMS, NormalActivation)
#-------------------------------------------------------------------------------
func NormalActivation():
	pass
#-------------------------------------------------------------------------------
