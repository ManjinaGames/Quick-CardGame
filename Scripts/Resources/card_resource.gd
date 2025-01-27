extends Resource
class_name CardResource
#-------------------------------------------------------------------------------
enum ARCHTYPE{DRAGON_MAID}
enum RESTRICTION{UNLIMITED, SOFT_ONCE_PER_TURN, HARD_ONCE_PER_TURN}
#region VARIABLES
@export var artwork: Texture2D
@export var myARCHTYPE: Array[ARCHTYPE]
@export var myRESTRICTION: RESTRICTION = RESTRICTION.UNLIMITED
#-------------------------------------------------------------------------------
@export_range (1, 3) var limit: int = 3
#endregion
#-------------------------------------------------------------------------------
