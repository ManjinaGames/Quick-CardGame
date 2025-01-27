extends CardResource
class_name CardResource_Red
#-------------------------------------------------------------------------------
enum ELEMENT{WATER, FIRE, EARTH, WIND, THUNDER}
enum CLASS{WARRIOR, MAGICIAN, MACHINE, PANT, BEAST, DRAGON}
#region VARIABLES
#-------------------------------------------------------------------------------
@export var attack: int = 0
@export var defense: int = 0
#-------------------------------------------------------------------------------
@export var myELEMENT: ELEMENT
@export var myCLASS: CLASS
#-------------------------------------------------------------------------------
@export_range (1, 10) var level: int = 1
#endregion
#-------------------------------------------------------------------------------
func CreateCard() -> Card_Red:
	return Card_Red.new()
