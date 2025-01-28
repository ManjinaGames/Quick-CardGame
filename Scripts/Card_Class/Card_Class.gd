class_name Card_Class
#region VARIABLES
var gameScene: GameScene
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS THAT CHILDS INHERITS
func Finish_Drag(_card:Card_Node):
	pass
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS THAT CHILDS USES
func Finish_Drag_Common(_card:Card_Node, _myFIELD_TYPE:CardSlot_Node.FIELD_TYPE, _callable:Callable):
	_card.scale = Vector2(gameScene.highlight_scale, gameScene.highlight_scale)
	var _card_slot_found: CardSlot_Node = gameScene.Raycast_Check_for_CardSlot()
	if(_card_slot_found):
		if(not _card_slot_found.card_in_slot and _card_slot_found.myFIELD_TYPE == _myFIELD_TYPE):
			gameScene.player.hand.Remove_card_from_hand(_card)
			_card.global_position = _card_slot_found.global_position
			_card.scale = Vector2(0.7, 0.7)
			_card.collisionShape.disabled = true
			_card_slot_found.card_in_slot = _card
			_callable.call()
		else:
			Cancel_Drag(_card)
	else:
		Cancel_Drag(_card)
	gameScene.card_being_dragged = null
#-------------------------------------------------------------------------------
func Cancel_Drag(_card:Card_Node):
	gameScene.player.hand.Add_card_to_hand(_card)
#endregion
#-------------------------------------------------------------------------------
