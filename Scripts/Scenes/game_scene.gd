extends Node2D
class_name GameScene
#region VARIABLES
@export var playerHand: PlayerHand
@export var playerDeck: Deck
@export_flags_2d_physics var collision_mask_card
@export_flags_2d_physics var collision_mask_cardslot
@export_flags_2d_physics var collision_mask_deck
var card_being_dragged: Card
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
		card_being_dragged.position = Vector2(_x, _y)
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
			var _cardBase: CardBase = load(cardDatabase_hability_path+"/"+_base_name+".gd").new() as CardBase
			var _cardResource: CardResource = load(cardDatabase_path+"/"+_base_name+".tres") as CardResource
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
				var _card_found: Card = _result[0].collider.get_parent()
				if(_card_found):
					Star_Drag(_card_found)
			#-------------------------------------------------------------------------------
			collision_mask_deck:
				print("Mouse Presed")
				playerDeck.DrawCard()
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Raycast_Check_for_Card() -> Card:
	var _parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	_parameters.position = get_global_mouse_position()
	_parameters.collide_with_areas = true
	_parameters.collision_mask = collision_mask_card
	var _result: Array[Dictionary] = _space_state.intersect_point(_parameters)
	#-------------------------------------------------------------------------------
	var _cards: Array[Card]
	for _i:int in _result.size():
		_cards.push_back(_result[0].collider.get_parent())
	#-------------------------------------------------------------------------------
	if(_cards.size()>0):
		return Get_Card_with_Highest_z_Index(_cards)
	return null
#-------------------------------------------------------------------------------
func Raycast_Check_for_CardSlot() -> CardSlot:
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
func Get_Card_with_Highest_z_Index(_cards:Array[Card]) -> Card:
	var _highest_z_card: Card = _cards[0]
	var _highest_z_index: int = _highest_z_card.z_index
	for _i in range(1, _cards.size()):
		var _current_card: Card = _cards[_i]
		if(_current_card.z_index > _highest_z_index):
			_highest_z_card = _current_card
			_highest_z_index = _current_card.z_index
	return _highest_z_card
#--------------------------------------------------------------------------
func Star_Drag(_card:Card):
	card_being_dragged = _card
	_card.scale = Vector2(1, 1)
#--------------------------------------------------------------------------
func Finish_Drag():
	card_being_dragged.cardBase.Finish_Drag(card_being_dragged)
#endregion
#-------------------------------------------------------------------------------
#region CREATING CARD FUNC
func SetCard(_card:Card):
	_card.area2d.mouse_entered.connect(func():Card_Mouse_Entered(_card))
	_card.area2d.mouse_exited.connect(func():Card_Mouse_Exited(_card))
#-------------------------------------------------------------------------------
func Card_Mouse_Entered(_card: Card):
	if(!is_hovering_on_card):
		is_hovering_on_card = true
		Highlight_Card_True(_card)
#-------------------------------------------------------------------------------
func Card_Mouse_Exited(_card: Card):
	if(!card_being_dragged):
		Highlight_Card_False(_card)
		var _new_cad_hovered: Card = Raycast_Check_for_Card()
		if(_new_cad_hovered):
			Highlight_Card_True(_card)
		else:
			is_hovering_on_card = false
#-------------------------------------------------------------------------------
func Highlight_Card_True(_card: Card):
	_card.scale = Vector2(highlight_scale, highlight_scale)
	_card.z_index = 2
#-------------------------------------------------------------------------------
func Highlight_Card_False(_card: Card):
	_card.scale = Vector2(1, 1)
	_card.z_index = 1
#endregion
#-------------------------------------------------------------------------------
