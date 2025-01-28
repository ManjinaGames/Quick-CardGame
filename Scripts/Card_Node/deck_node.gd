extends Node2D
class_name Deck_Node
#region VARIABLES
@export var gameScene: GameScene
@export var collisionShape: CollisionShape2D
@export var sprite: Sprite2D
@export var label: Label
@export var player_deck_resources: Array[Card_Resource]
var player_deck: Array[Card_Class]
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
		print(_name)
		var _card_Class: Card_Class = load(gameScene.cardDatabase_hability_path+"/"+_name+".gd").new() as Card_Class
		_card_Class.cardResource = _cardResource
		player_deck.append(_card_Class)
	player_deck.shuffle()
#-------------------------------------------------------------------------------
func GetResource_Name(_resource: Card_Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func DrawCard():
	if(player_deck.size() <= 0):
		return
	#-------------------------------------------------------------------------------
	var _card_Class: Card_Class = player_deck[0]
	player_deck.erase(_card_Class)
	#-------------------------------------------------------------------------------
	if(player_deck.size() <= 0):
		sprite.visible = false
	#-------------------------------------------------------------------------------
	SetDeckNumber()
	#-------------------------------------------------------------------------------
	var _card_Node: Card_Node = gameScene.player.hand.cardPrefab.instantiate() as Card_Node
	_card_Node.global_position = global_position
	_card_Node.z_index = gameScene.z_index_hand
	gameScene.add_child(_card_Node)
	#-------------------------------------------------------------------------------
	_card_Node.cardBase = _card_Class
	_card_Class.Set_Card_Node(_card_Node)
	_card_Class.gameScene = gameScene
	_card_Node.artwork.texture = _card_Class.cardResource.artwork
	gameScene.player.hand.Add_card_to_hand(_card_Node)
#-------------------------------------------------------------------------------
func SetDeckNumber():
	label.text = str(player_deck.size())+" / "+str(maxDeckNum)
#-------------------------------------------------------------------------------
