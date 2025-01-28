extends Node2D
class_name CardSlot_Node
#-------------------------------------------------------------------------------
enum FIELD_TYPE{MONSTERS, ITEMS}
#region VARIABLES
@export var area2D: Area2D
@export var myFIELD_TYPE: FIELD_TYPE
var card_in_slot: Card_Node
#endregion
#-------------------------------------------------------------------------------
