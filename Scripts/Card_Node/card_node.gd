extends Node2D
class_name Card_Node
#region VARIABLES
@export var area2d: Area2D
@export var offset_Node2D: Node2D
@export var collisionShape: CollisionShape2D
@export var frame_Node: Frame_Node
#-------------------------------------------------------------------------------
var starting_position: Vector2
#-------------------------------------------------------------------------------
var card_Class: Card_Class
#-------------------------------------------------------------------------------
var pressed: Callable = func(): pass
#endregion
#-------------------------------------------------------------------------------
