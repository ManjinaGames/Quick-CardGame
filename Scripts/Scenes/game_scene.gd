extends Node2D
class_name GameScene
#region VARIABLES
@export var player: Player_Node
#-------------------------------------------------------------------------------
@export_flags_2d_physics var collision_mask_card
@export_flags_2d_physics var collision_mask_cardslot
@export_flags_2d_physics var collision_mask_deck
#-------------------------------------------------------------------------------
var z_index_field: int = 0
var z_index_hand: int = 1
#-------------------------------------------------------------------------------
@export var debugInfo: Label
#-------------------------------------------------------------------------------
var parameters: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
var card_being_dragged: Card_Node
var card_being_hightlighted: Card_Node
#-------------------------------------------------------------------------------
var screen_size: Vector2
var highlight_scale: float = 1.3
#-------------------------------------------------------------------------------
const cardDatabase_path: String = "res://Cards/Resources"
const cardDatabase_hability_path: String = "res://Cards/Scripts"
@export var cardDatabase: Dictionary = {}
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready() -> void:
	parameters = PhysicsPointQueryParameters2D.new()
	parameters.collide_with_areas = true
	space_state = get_world_2d().direct_space_state
	#-------------------------------------------------------------------------------
	screen_size = get_viewport_rect().size
	LoadCardDatabase()
#-------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	StateMachine()
#endregion
#-------------------------------------------------------------------------------
#region CARD DATABASE
func LoadCardDatabase():
	var dir_array = DirAccess.get_files_at(cardDatabase_hability_path)
	if(dir_array):
		for _i in dir_array.size():
			var _base_name: String = dir_array[_i].get_slice(".",0)
			var _cardBase: Card_Class = load(cardDatabase_hability_path+"/"+_base_name+".gd").new() as Card_Class
			var _cardResource: Card_Resource = load(cardDatabase_path+"/"+_base_name+".tres") as Card_Resource
			_cardBase.cardResource = _cardResource
			cardDatabase[_base_name] = _cardBase
#endregion
#-------------------------------------------------------------------------------
#region RAYCAST FUNTIONS
func StateMachine():
	#-------------------------------------------------------------------------------
	parameters.position = get_global_mouse_position()
	var _result: Array[Dictionary] = space_state.intersect_point(parameters)
	#-------------------------------------------------------------------------------
	var _card_found: Array[Card_Node] = []
	var _cardslot_found: Array[CardSlot_Node] = []
	var _deck_found: Array[Deck_Node] = []
	#-------------------------------------------------------------------------------
	for _i in _result.size():
		var _result_collision_mask: int = _result[_i].collider.collision_mask as int
		match(_result_collision_mask):
			collision_mask_card:
				_card_found.append(_result[_i].collider.get_parent() as Card_Node)
			#-------------------------------------------------------------------------------
			collision_mask_cardslot:
				_cardslot_found.append(_result[_i].collider.get_parent() as CardSlot_Node)
			#-------------------------------------------------------------------------------
			collision_mask_deck:
				_deck_found.append(_result[_i].collider.get_parent() as Deck_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	var _s: String = ""
	for _i in _card_found:
		_s += "Card: "+str(_i)+"\n"
	for _i in _cardslot_found:
		_s += "Card Slot: "+str(_i)+"\n"
	for _i in _deck_found:
		_s += "Deck: "+str(_i)+"\n"
	debugInfo.text = _s
	#-------------------------------------------------------------------------------
	if(_deck_found.size() > 0):
		if(Input.is_action_just_pressed("Left_Click")):
			player.deck.DrawCard()
	#-------------------------------------------------------------------------------
	if(card_being_dragged):
		var mouse_pos: Vector2 = get_global_mouse_position()
		var _x: float = clamp(mouse_pos.x, 0, screen_size.x)
		var _y: float  = clamp(mouse_pos.y, 0, screen_size.y)
		card_being_dragged.global_position = Vector2(_x, _y)
		#-------------------------------------------------------------------------------
		if(Input.is_action_just_released("Left_Click")):
			if(_cardslot_found.size()>0):
				card_being_dragged.cardBase.Finish_Drag(card_being_dragged, _cardslot_found[0])
			else:
				player.hand.Add_card_to_hand(card_being_dragged)
			card_being_dragged = null
		#-------------------------------------------------------------------------------
	else:
		if(card_being_hightlighted):
			if(Input.is_action_just_pressed("Left_Click")):
				card_being_dragged = card_being_hightlighted
				return
			if(_card_found.size()>0):
				var _bool: bool = false
				for _card in _card_found:
					if(card_being_hightlighted == _card):
						_bool = true
						break
				if(!_bool):
					card_being_hightlighted.scale = Vector2(1, 1)
					card_being_hightlighted.z_index = 1
					card_being_hightlighted = null
			else:
				card_being_hightlighted.scale = Vector2(1, 1)
				card_being_hightlighted.z_index = 1
				card_being_hightlighted = null
		else:
			if(_card_found.size()>0):
				#var _card_found_first: Card_Node = Get_Card_with_Highest_z_Index(_card_found)
				var _card_found_first: Card_Node = _card_found[0]
				_card_found_first.scale = Vector2(highlight_scale, highlight_scale)
				_card_found_first.z_index = 2
				card_being_hightlighted = _card_found_first
#endregion
#-------------------------------------------------------------------------------
