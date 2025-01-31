extends Node2D
class_name Player_Node
#region VARIABLES
@export var mainDeck: Deck_Node
@export var extraDeck: Deck_Node
@export var grave: Deck_Node
@export var removed: Deck_Node
@export var hand: Hand_Node
@export var magicZone: Array[CardSlot_Node]
@export var monsterZone: Array[CardSlot_Node]
#endregion
#-------------------------------------------------------------------------------
