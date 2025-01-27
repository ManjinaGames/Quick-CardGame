extends Node2D
class_name Deck
#region VARIABLES
@export var gameScene: GameScene
@export var collisionShape: CollisionShape2D
@export var sprite: Sprite2D
@export var label: Label
var player_deck: Array[String] = ["a1_c1", "a1_c2", "a1_c3", "a1_c1", "a1_c2", "a1_c3", "a1_c1"]
var maxDeckNum: int
#endregion
#-------------------------------------------------------------------------------
#region MONOBEHAVIOUR
func _ready() -> void:
	maxDeckNum = player_deck.size()
	SetDeckNumber()
#endregion
#-------------------------------------------------------------------------------
func DrawCard():
	var _card_draw: String = player_deck[0]
	player_deck.erase(_card_draw)
	#-------------------------------------------------------------------------------
	if(player_deck.size() == 0):
		collisionShape.disabled = true
		sprite.visible = false
	#-------------------------------------------------------------------------------
	SetDeckNumber()
	var _new_card: Card = gameScene.playerHand.cardPrefab.instantiate()
	_new_card.global_position = global_position
	gameScene.SetCard(_new_card)
	gameScene.playerHand.add_child(_new_card)
	_new_card.name = "Card"
	var _cardBase: CardBase = gameScene.cardDatabase.get(_card_draw)
	_cardBase.SetColor(_new_card.frame)
	_new_card.artwork.texture = _cardBase.cardResource.artwork
	gameScene.playerHand.Add_card_to_hand(_new_card)
#-------------------------------------------------------------------------------
func SetDeckNumber():
	label.text = str(player_deck.size())+" / "+str(maxDeckNum)
#-------------------------------------------------------------------------------
