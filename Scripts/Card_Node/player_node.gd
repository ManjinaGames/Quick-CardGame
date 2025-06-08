extends Node2D
class_name Player_Node
#region VARIABLES
@export var mainDeck: Deck_Node
@export var extraDeck: Deck_Node
@export var grave: Deck_Node
@export var removed: Deck_Node
@export var hand: Hand_Node
#-------------------------------------------------------------------------------
@export var magicZone: Array[CardSlot_Node]
@export var monsterZone: Array[CardSlot_Node]
#-------------------------------------------------------------------------------
var lifePoints: int = 8000
var turnCounter: int = 0
#-------------------------------------------------------------------------------
#estas son propiedades que tengo que variar a su valor opuesto para que se puedan utilizar las mismas funciones.
@export var isPlayer1: bool = true
@export var opponent: Player_Node
@export var card_highlight_posY_offset: float = -25
@export var card_selected_posY_offset: float = -53
@export var card_rotation: float = 0
@export var card_defense_rotation: float = -90
#endregion
#-------------------------------------------------------------------------------
