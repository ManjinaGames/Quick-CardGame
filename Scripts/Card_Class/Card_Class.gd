extends GDScript
class_name Card_Class
#region VARIABLES
var gameScene: GameScene
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS THAT CHILDS INHERITS
func Set_Card_Node(_card_node:Card_Node):
	pass
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card_Node, _cardSlot:CardSlot_Node):
	print("This card has no Code to Drag and Drop")
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS THAT CHILDS USES
func Finish_Drag_Common(_card:Card_Node, _cardSlot:CardSlot_Node, _myFIELD_TYPE: CardSlot_Node.FIELD_TYPE, _callable:Callable):
	if(not _cardSlot.card_in_slot and _cardSlot.myFIELD_TYPE == _myFIELD_TYPE):
		gameScene.player.hand.Remove_card_from_hand(_card)
		_card.global_position = _cardSlot.global_position
		_card.scale = Vector2(0.7, 0.7)
		_card.z_index = gameScene.z_index_field
		_card.collisionShape.disabled = true
		_cardSlot.card_in_slot = _card
		gameScene.card_being_hightlighted = null
		_callable.call()
	else:
		gameScene.player.hand.Add_card_to_hand(_card)
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
