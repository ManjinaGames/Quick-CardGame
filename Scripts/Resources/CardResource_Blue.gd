extends CardResource
class_name CardResource_Blue
#-------------------------------------------------------------------------------
enum ITEM_TYPE{NORMAL, EQUIP, QUICK, INFINITE}
#region VARIABLES
@export var myITEM_TYPE: ITEM_TYPE
#endregion
#-------------------------------------------------------------------------------
func CreateCard() -> Card_Blue:
	return Card_Blue.new()
