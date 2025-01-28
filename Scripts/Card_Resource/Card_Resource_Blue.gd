extends Card_Resource
class_name Card_Resource_Blue
#-------------------------------------------------------------------------------
enum ITEM_TYPE{NORMAL, EQUIP, QUICK, INFINITE}
#region VARIABLES
@export var myITEM_TYPE: ITEM_TYPE
#-------------------------------------------------------------------------------
@export var cardClass: Card_Class_Blue
#endregion
#-------------------------------------------------------------------------------
func CreateCard() -> Card_Class_Blue:
	return Card_Class_Blue.new()
