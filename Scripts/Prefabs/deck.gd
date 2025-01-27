extends Node2D
class_name Deck
#region VARIABLES
@export var gameScene: GameScene
@export var collisionShape: CollisionShape2D
@export var sprite: Sprite2D
@export var label: Label
@export var player_deck_resources: Array[CardResource]
var player_deck: Array[CardBase]
var maxDeckNum: int
#endregion
#-------------------------------------------------------------------------------
#region MONOBEHAVIOUR
func _ready() -> void:
	LoadDeck()
	maxDeckNum = player_deck.size()
	SetDeckNumber()
#endregion
#-------------------------------------------------------------------------------
func LoadDeck():
	for _cardResource in player_deck_resources:
		var _name: String = GetResource_Name(_cardResource)
		var _cardBase: CardBase = load(gameScene.cardDatabase_hability_path+"/"+_name+".gd").new() as CardBase
		_cardBase.cardResource = _cardResource
		player_deck.append(_cardBase)
	player_deck.shuffle()
#-------------------------------------------------------------------------------
func GetResource_Name(_resource: CardResource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func DrawCard():
	var _cardBase: CardBase = player_deck[0]
	player_deck.erase(_cardBase)
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
	#-------------------------------------------------------------------------------
	_new_card.cardBase = _cardBase
	_cardBase.SetColor(_new_card.frame)
	_cardBase.gameScene = gameScene
	_new_card.artwork.texture = _cardBase.cardResource.artwork
	gameScene.playerHand.Add_card_to_hand(_new_card)
#-------------------------------------------------------------------------------
func SetDeckNumber():
	label.text = str(player_deck.size())+" / "+str(maxDeckNum)
#-------------------------------------------------------------------------------
