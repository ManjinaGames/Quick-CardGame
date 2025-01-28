extends Card_Class
class_name Card_Class_Red
#region VARIABLES
var cardResource: Card_Resource_Red
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS FROM PARENT
func Set_Card_Node(_card_node:Card_Node):
	_card_node.frame.self_modulate = Color.SALMON
	_card_node.topLavel.text = "(Lv "+str(cardResource.level)+")"
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card_Node, _cardSlot:CardSlot_Node):
	Finish_Drag_Common(_card, _cardSlot, CardSlot_Node.FIELD_TYPE.MONSTERS, NormalSummon)
#endregion
#-------------------------------------------------------------------------------
func NormalSummon():
	pass
#-------------------------------------------------------------------------------
