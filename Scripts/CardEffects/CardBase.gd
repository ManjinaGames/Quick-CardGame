class_name CardBase

var gameScene: GameScene

func Finish_Drag(_card:Card):
	_card.scale = Vector2(gameScene.highlight_scale, gameScene.highlight_scale)
	var _card_slot_found: CardSlot = gameScene.Raycast_Check_for_CardSlot()
	if(_card_slot_found and not _card_slot_found.card_in_slot):
		gameScene.playerHand.Remove_card_from_hand(_card)
		_card.global_position = _card_slot_found.global_position
		_card.scale = Vector2(0.7, 0.7)
		_card.collisionShape.disabled = true
		_card_slot_found.card_in_slot = _card
	else:
		gameScene.playerHand.Add_card_to_hand(_card)
	_card = null
