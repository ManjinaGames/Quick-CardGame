extends Object_Node
class_name CardSlot_Node
#-------------------------------------------------------------------------------
enum ZONE_TYPE{MONSTER_ZONE, MAGIC_ZONE}
#region VARIABLES
@export var myZONE_TYPE: ZONE_TYPE
@export var area2D: Area2D
@export var highlight_TextureRect: TextureRect
@export var summoning_TextureRect: TextureRect
#-------------------------------------------------------------------------------
var card_in_slot: Card_Node = null
#endregion
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
