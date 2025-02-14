extends Node2D
class_name Button_Node
#region VARIABLES
@export var area2D: Area2D
@export var collisionShape2D: CollisionShape2D
@export var highlight_TextureRect: TextureRect
#-------------------------------------------------------------------------------
var pressed: Callable = func(): pass
#endregion
#-------------------------------------------------------------------------------
