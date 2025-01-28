extends Card_Class
class_name Card_Class_Yellow
#region VARIABLES
var cardResource: Card_Resource_Yellow
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS FROM PARENT
func Set_Card_Node(_card_node:Card_Node):
	_card_node.frame.self_modulate = Color.YELLOW
#endregion
#-------------------------------------------------------------------------------
