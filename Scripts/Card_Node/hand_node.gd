extends Node2D
class_name Hand_Node
#region VARIABLES
@export var gameScene: GameScene
@export var cardPrefab: PackedScene
var playerHand: Array[Card_Node] = []
var height: float
var width: float
var card_width: float = 70
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready() -> void:
	width = get_viewport_rect().size.x
	height = get_viewport_rect().size.y
#endregion
#-------------------------------------------------------------------------------
#region HAND FUNCTIONS
func Add_card_to_hand(_card:Card_Node):
	if(_card not in playerHand):
		playerHand.push_back(_card)
		Update_hand_position()
	else:
		Animate_card_to_position(_card, _card.starting_position)
#-------------------------------------------------------------------------------
func Update_hand_position():
	for _i:int in playerHand.size():
		var _newPosition: Vector2 = Vector2(Calculate_card_position(_i), global_position.y)
		var _card:Card_Node = playerHand[_i]
		_card.starting_position = _newPosition
		Animate_card_to_position(_card, _newPosition)
#-------------------------------------------------------------------------------
func Calculate_card_position(_i:int) -> float:
	var _total_width: float = (playerHand.size()-1)*card_width
	var _x_offset: float = global_position.x+float(_i)*card_width-_total_width/2
	return _x_offset
#-------------------------------------------------------------------------------
func Animate_card_to_position(_card:Card_Node, _newPosition:Vector2):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card, "global_position", _newPosition, 0.1)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_card:Card_Node):
	if(_card in playerHand):
		playerHand.erase(_card)
		Update_hand_position()
#endregion
#-------------------------------------------------------------------------------
