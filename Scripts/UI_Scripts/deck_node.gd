extends Object_Node
class_name Deck_Node
#-------------------------------------------------------------------------------
enum DECK_TYPE{MAIN_DECK, EXTRA_DECK, GRAVE_DECK, REMOVE_DECK}
#region VARIABLES
@export var myDECK_TYPE: DECK_TYPE
@export var collisionShape: CollisionShape2D
@export var highlight_TextureRect: TextureRect
@export var card_TextureRect: TextureRect
@export var label: Label
#-------------------------------------------------------------------------------
var card_Class_Array: Array[Card_Class]
var maxDeckNum: int
#endregion
#-------------------------------------------------------------------------------
