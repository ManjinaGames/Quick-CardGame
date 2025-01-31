extends Node2D
class_name Deck_Node
#-------------------------------------------------------------------------------
enum DECK_TYPE{MAIN, EXTRA, GRAVEYARD, REMOVED}
#region VARIABLES
@export var gameScene: GameScene
@export var myDECK_TYPE: DECK_TYPE
@export var collisionShape: CollisionShape2D
@export var highlight_TextureRect: TextureRect
@export var card_TextureRect: TextureRect
@export var label: Label
@export var card_Resource: Array[Card_Resource]
var card_Class: Array[Card_Class]
var maxDeckNum: int
#endregion
#-------------------------------------------------------------------------------
