extends Node2D
class_name Object_Node
#region VARIABLES
var pressed: Callable = func(): pass
var released: Callable = func(): pass
#-------------------------------------------------------------------------------
var holding: Callable = func(): pass
#-------------------------------------------------------------------------------
var deselected: Callable = func(): pass
#-------------------------------------------------------------------------------
var highlighted: Callable = func(): pass
var lowlighted: Callable = func(): pass
#endregion
