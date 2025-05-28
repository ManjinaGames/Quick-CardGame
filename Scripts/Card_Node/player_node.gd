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
#estas son propiedades que tengo que variar a su valor opuesto para que se puedan utilizar las mismas funciones.
@export var isPlayer1: bool = true
@export var opponent: Player_Node
@export var card_pos_y_offset: float = -25
@export var card_rotation: float = 0
#endregion
#-------------------------------------------------------------------------------
