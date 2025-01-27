extends CardBase
class_name Card_Blue
#region VARIABLES
var cardResource: CardResource_Blue
#endregion

func SetColor(_sprite:Sprite2D):
	_sprite.self_modulate = Color.BLUE
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card):
	_card.scale = Vector2(gameScene.highlight_scale, gameScene.highlight_scale)
	var _card_slot_found: CardSlot = gameScene.Raycast_Check_for_CardSlot()
	if(_card_slot_found):
		var _field: Field = _card_slot_found.get_parent() as Field
		if(not _card_slot_found.card_in_slot and _field.myFIELD_TYPE == Field.FIELD_TYPE.ITEMS):
			gameScene.playerHand.Remove_card_from_hand(_card)
			_card.global_position = _card_slot_found.global_position
			_card.scale = Vector2(0.7, 0.7)
			_card.collisionShape.disabled = true
			_card_slot_found.card_in_slot = _card
		else:
			Cancel_Drag(_card)
	else:
		Cancel_Drag(_card)
	gameScene.card_being_dragged = null
#-------------------------------------------------------------------------------
func Cancel_Drag(_card:Card):
	gameScene.playerHand.Add_card_to_hand(_card)
#-------------------------------------------------------------------------------
