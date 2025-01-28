extends Node2D
class_name Card_Node
#region VARIABLES
@export var area2d: Area2D
@export var collisionShape: CollisionShape2D
@export var frame: TextureRect
@export var artwork: TextureRect
var starting_position: Vector2
#-------------------------------------------------------------------------------
var cardBase: Card_Class
#endregion
#-------------------------------------------------------------------------------
