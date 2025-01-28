extends Card_Class
class_name Card_Class_Blue
#region VARIABLES
var cardResource: Card_Resource_Blue
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS FROM PARENT
func Set_Card_Node(_card_node:Card_Node):
	_card_node.frame.self_modulate = Color.AQUAMARINE
	_card_node.topLavel.text = "(Magic Card)"
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card_Node, _cardSlot:CardSlot_Node):
	Finish_Drag_Common(_card, _cardSlot, CardSlot_Node.FIELD_TYPE.ITEMS, NormalActivation)
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS THAT CHILDS INHERITS
func NormalActivation():
	pass
#endregion
#-------------------------------------------------------------------------------
