extends Card_Resource
class_name Card_Resource_Red
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
func CreateCard() -> Card_Class_Red:
	return Card_Class_Red.new()
