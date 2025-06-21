extends Resource
class_name Card_Resource
#-------------------------------------------------------------------------------
enum CARD_TYPE{MONSTER_CARD, MAGIC_CARD}
#-------------------------------------------------------------------------------
enum MONSTER_ELEMENT{WATER, FIRE, EARTH, WIND, LIGHT, DARK}
enum MONSTER_TYPE{WARRIOR, MAGICIAN, MACHINE, PANT, BEAST, DRAGON}
#-------------------------------------------------------------------------------
enum MAGIC_TYPE{NORMAL, EQUIP, QUICK, INFINITE}
#region VARIABLES
@export_category("Common Parameters")
@export var artwork: Texture2D
@export var myCARD_TYPE: CARD_TYPE
@export_range (1, 3) var limit: int = 3
#-------------------------------------------------------------------------------
@export_category("Monster Card Paramenters")
@export var isFusionMonster: bool = false
@export var attack: int = 0
@export var defense: int = 0
@export var myMONSTER_ELEMENT: MONSTER_ELEMENT
@export var myMONSTER_TYPE: MONSTER_TYPE
@export_range (1, 10) var level: int = 1
#-------------------------------------------------------------------------------
@export_category("Magic Card Parameters")
@export var isTrapCard: bool = false
@export var myMAGIC_TYPE: MAGIC_TYPE
#endregion
#-------------------------------------------------------------------------------
