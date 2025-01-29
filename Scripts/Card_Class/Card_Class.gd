extends GDScript
class_name Card_Class
#region VARIABLES
var gameScene: GameScene
var cardResource: Card_Resource
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS THAT CHILDS INHERITS
func Set_Card_Node(_card_node:Card_Node):
	match(_card_node.card_Class.cardResource.myCARD_TYPE):
		Card_Resource.CARD_TYPE.RED:
			_card_node.frame.self_modulate = Color.LIGHT_PINK
			_card_node.topLabel.text = Get_Stars()
			_card_node.bottonLabel.text = Get_Attack_and_Defense()
		Card_Resource.CARD_TYPE.BLUE:
			_card_node.frame.self_modulate = Color.LIGHT_BLUE
			_card_node.topLabel.text = "(Magic Card)"
			_card_node.bottonLabel.text = ""
		Card_Resource.CARD_TYPE.YELLOW:
			_card_node.frame.self_modulate = Color.LIGHT_GOLDENROD
			_card_node.topLabel.text = Get_Stars()
			_card_node.bottonLabel.text = Get_Attack_and_Defense()
#-------------------------------------------------------------------------------
func Get_Attack_and_Defense() -> String:
	return "ATK/"+str(cardResource.attack)+"      "+"DEF/"+str(cardResource.defense)
#-------------------------------------------------------------------------------
func Get_Stars() -> String:
	var _s:String = ""
	for _i in cardResource.level:
		_s += "* "
	return _s
#-------------------------------------------------------------------------------
func Finish_Drag(_card:Card_Node, _cardSlot:CardSlot_Node):
	match(_card.card_Class.cardResource.myCARD_TYPE):
		Card_Resource.CARD_TYPE.RED:
			Finish_Drag_Common(_card, _cardSlot, CardSlot_Node.FIELD_TYPE.MONSTERS, NormalSummon)
		Card_Resource.CARD_TYPE.BLUE:
			Finish_Drag_Common(_card, _cardSlot, CardSlot_Node.FIELD_TYPE.ITEMS, NormalActivation)
		Card_Resource.CARD_TYPE.YELLOW:
			pass
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
func NormalActivation():
	pass
#-------------------------------------------------------------------------------
func NormalSummon():
	pass
