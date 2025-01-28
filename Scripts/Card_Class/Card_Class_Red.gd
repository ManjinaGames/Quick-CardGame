extends Card_Class
class_name Card_Class_Red
#region VARIABLES
var cardResource: Card_Resource_Red
#endregion
func SetColor(_texture:TextureRect):
	_texture.self_modulate = Color.RED
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card_Node):
	Finish_Drag_Common(_card, CardSlot_Node.FIELD_TYPE.MONSTERS, NormalSummon)
#-------------------------------------------------------------------------------
func NormalSummon():
	pass
#-------------------------------------------------------------------------------
