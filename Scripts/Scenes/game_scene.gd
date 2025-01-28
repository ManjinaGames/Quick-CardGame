extends Node2D
class_name GameScene
#region VARIABLES
@export var player: Player_Node
@export_flags_2d_physics var collision_mask_card
@export_flags_2d_physics var collision_mask_cardslot
@export_flags_2d_physics var collision_mask_deck
var card_being_dragged: Card_Node
var screen_size: Vector2
var is_hovering_on_card: bool
var _space_state: PhysicsDirectSpaceState2D
var highlight_scale: float = 1.2
#-------------------------------------------------------------------------------
const cardDatabase_path: String = "res://Cards/Resources"
const cardDatabase_hability_path: String = "res://Cards/Scripts"
@export var cardDatabase: Dictionary = {}
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready() -> void:
	screen_size = get_viewport_rect().size
	_space_state = get_world_2d().direct_space_state
	LoadCardDatabase()
	print(cardDatabase)
#-------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	if(card_being_dragged):
		var mouse_pos: Vector2 = get_global_mouse_position()
		var _x: float = clamp(mouse_pos.x, 0, screen_size.x)
		var _y: float  = clamp(mouse_pos.y, 0, screen_size.y)
		card_being_dragged.global_position = Vector2(_x, _y)
#-------------------------------------------------------------------------------
func _input(_event: InputEvent) -> void:
	if(_event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT):
		if(_event.is_pressed()):
			Raycast_at_Cursor()
		else:
			if(card_being_dragged):
				Finish_Drag()
#endregion
#-------------------------------------------------------------------------------
#region CARD DATABASE
func LoadCardDatabase():
	var dir_array = DirAccess.get_files_at(cardDatabase_hability_path)
	if(dir_array):
		for _i in dir_array.size():
			var _base_name: String = dir_array[_i].get_slice(".",0)
			print(_base_name)
			var _cardBase: Card_Class = load(cardDatabase_hability_path+"/"+_base_name+".gd").new() as Card_Class
			var _cardResource: Card_Resource = load(cardDatabase_path+"/"+_base_name+".tres") as Card_Resource
			_cardBase.cardResource = _cardResource
			cardDatabase[_base_name] = _cardBase
#endregion
#-------------------------------------------------------------------------------
#region RAYCAST FUNTIONS
func Raycast_at_Cursor():
	var _parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	_parameters.position = get_global_mouse_position()
	_parameters.collide_with_areas = true
	var _result: Array[Dictionary] = _space_state.intersect_point(_parameters)
	#-------------------------------------------------------------------------------
	if(_result.size()>0):
		var _result_collision_mask: int = _result[0].collider.collision_mask
		match(_result_collision_mask):
			collision_mask_card:
				var _card_found: Card_Node = _result[0].collider.get_parent()
				if(_card_found):
					Star_Drag(_card_found)
			#-------------------------------------------------------------------------------
			collision_mask_deck:
				print("Mouse Presed")
				player.deck.DrawCard()
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Raycast_Check_for_Card() -> Card_Node:
	var _parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	_parameters.position = get_global_mouse_position()
	_parameters.collide_with_areas = true
	_parameters.collision_mask = collision_mask_card
	var _result: Array[Dictionary] = _space_state.intersect_point(_parameters)
	#-------------------------------------------------------------------------------
	var _cards: Array[Card_Node]
	for _i:int in _result.size():
		_cards.push_back(_result[0].collider.get_parent())
	#-------------------------------------------------------------------------------
	if(_cards.size()>0):
		return Get_Card_with_Highest_z_Index(_cards)
	return null
#-------------------------------------------------------------------------------
func Raycast_Check_for_CardSlot() -> CardSlot_Node:
	var _parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	_parameters.position = get_global_mouse_position()
	_parameters.collide_with_areas = true
	_parameters.collision_mask = collision_mask_cardslot
	var _result: Array[Dictionary] = _space_state.intersect_point(_parameters)
	#-------------------------------------------------------------------------------
	if(_result.size() > 0):
		return _result[0].collider.get_parent()
	return null
#-------------------------------------------------------------------------------
func Get_Card_with_Highest_z_Index(_card_node:Array[Card_Node]) -> Card_Node:
	var _highest_z_card: Card_Node = _card_node[0]
	var _highest_z_index: int = _highest_z_card.z_index
	for _i in range(1, _card_node.size()):
		var _current_card: Card_Node = _card_node[_i]
		if(_current_card.z_index > _highest_z_index):
			_highest_z_card = _current_card
			_highest_z_index = _current_card.z_index
	return _highest_z_card
#--------------------------------------------------------------------------
func Star_Drag(_card_node:Card_Node):
	card_being_dragged = _card_node
	#_card_node.scale = Vector2(1, 1)
#--------------------------------------------------------------------------
func Finish_Drag():
	card_being_dragged.cardBase.Finish_Drag(card_being_dragged)
#endregion
#-------------------------------------------------------------------------------
#region CREATING CARD FUNC
func SetCard(_card_node:Card_Node):
	_card_node.area2d.mouse_entered.connect(func():Card_Mouse_Entered(_card_node))
	_card_node.area2d.mouse_exited.connect(func():Card_Mouse_Exited(_card_node))
#-------------------------------------------------------------------------------
func Card_Mouse_Entered(_card_node: Card_Node):
	if(!is_hovering_on_card):
		is_hovering_on_card = true
		Highlight_Card_True(_card_node)
#-------------------------------------------------------------------------------
func Card_Mouse_Exited(_card_node: Card_Node):
	if(!card_being_dragged):
		Highlight_Card_False(_card_node)
		var _new_cad_hovered: Card_Node = Raycast_Check_for_Card()
		if(_new_cad_hovered):
			Highlight_Card_True(_card_node)
		else:
			is_hovering_on_card = false
#-------------------------------------------------------------------------------
func Highlight_Card_True(_card_node: Card_Node):
	pass
	#_card_node.scale = Vector2(highlight_scale, highlight_scale)
	#_card_node.z_index = 2
#-------------------------------------------------------------------------------
func Highlight_Card_False(_card_node: Card_Node):
	pass
	#_card_node.scale = Vector2(1, 1)
	#_card_node.z_index = 1
#endregion
#-------------------------------------------------------------------------------
