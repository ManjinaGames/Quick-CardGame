extends Resource
class_name Card_Resource
#-------------------------------------------------------------------------------
enum CARD_TYPE{RED, BLUE, YELLOW}
enum ARCHTYPE{DRAGON_MAID}
enum RESTRICTION{UNLIMITED, SOFT_ONCE_PER_TURN, HARD_ONCE_PER_TURN}
#-------------------------------------------------------------------------------
enum ELEMENT{WATER, FIRE, EARTH, WIND, THUNDER}
enum CLASS{WARRIOR, MAGICIAN, MACHINE, PANT, BEAST, DRAGON}
#-------------------------------------------------------------------------------
enum ITEM_TYPE{NORMAL, EQUIP, QUICK, INFINITE}
#region VARIABLES
@export_category("Common Parameters")
@export var artwork: Texture2D
@export var myCARD_TYPE: CARD_TYPE
@export var myRESTRICTION: RESTRICTION = RESTRICTION.UNLIMITED
#-------------------------------------------------------------------------------
@export_range (1, 3) var limit: int = 3
@export var myARCHTYPE: Array[ARCHTYPE]
@export var card_Class: GDScript
#-------------------------------------------------------------------------------
@export_category("RED and YELLOW")
@export var attack: int = 0
@export var defense: int = 0
#-------------------------------------------------------------------------------
@export var myELEMENT: ELEMENT
@export var myCLASS: CLASS
#-------------------------------------------------------------------------------
@export_range (1, 10) var level: int = 1
#-------------------------------------------------------------------------------
@export_category("BLUE")
@export var myITEM_TYPE: ITEM_TYPE
#endregion
#-------------------------------------------------------------------------------
