extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum MOUSE_STATE{EMPTY_STATE, CARD_HIGHLIGHTED, CARDSLOT_HIGHLIGHTED, DECK_HIGHLIGHTED, CARD_DRAGGED, CARD_DRAGGED_OVER_SLOT}
#region VARIABLES
@export var player: Player_Node
#-------------------------------------------------------------------------------
@export var card_Node_Prefab: PackedScene
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
var myMOUSE_STATE: MOUSE_STATE = MOUSE_STATE.EMPTY_STATE
#-------------------------------------------------------------------------------
var card_node: Array[Card_Node]
var cardslot_node: Array[CardSlot_Node]
var deck_node: Array[Deck_Node]
#-------------------------------------------------------------------------------
var current_card_node: Card_Node = null
var current_cardslot_node: CardSlot_Node = null
var current_deck_node: Deck_Node = null
#-------------------------------------------------------------------------------
var screen_size: Vector2
var highlight_scale: float = 1.3
#-------------------------------------------------------------------------------
const cardDatabase_path: String = "res://Cards/Resources"
const cardDatabase_hability_path: String = "res://Cards/Scripts"
@export var cardDatabase: Dictionary = {}
#-------------------------------------------------------------------------------
var height: float
var width: float
var card_width: float = 90
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready() -> void:
	parameters = PhysicsPointQueryParameters2D.new()
	parameters.collide_with_areas = true
	space_state = get_world_2d().direct_space_state
	#-------------------------------------------------------------------------------
	width = get_viewport_rect().size.x
	height = get_viewport_rect().size.y
	#-------------------------------------------------------------------------------
	screen_size = get_viewport_rect().size
	#LoadCardDatabase()
	LoadDeck()
	player.mainDeck.maxDeckNum = player.mainDeck.card_Class.size()
	SetDeckNumber1(player.mainDeck)
	SetDeckNumber1(player.extraDeck)
	SetDeckNumber2(player.grave)
	SetDeckNumber2(player.removed)
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
			_cardBase.card_Resource = _cardResource
			cardDatabase[_base_name] = _cardBase
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func StateMachine():
	#-------------------------------------------------------------------------------
	parameters.position = get_global_mouse_position()
	var _result: Array[Dictionary] = space_state.intersect_point(parameters)
	#-------------------------------------------------------------------------------
	card_node = []
	cardslot_node = []
	deck_node = []
	#-------------------------------------------------------------------------------
	for _i in _result.size():
		var _result_collision_mask: int = _result[_i].collider.collision_mask as int
		match(_result_collision_mask):
			collision_mask_card:
				card_node.append(_result[_i].collider.get_parent() as Card_Node)
			#-------------------------------------------------------------------------------
			collision_mask_cardslot:
				cardslot_node.append(_result[_i].collider.get_parent() as CardSlot_Node)
			#-------------------------------------------------------------------------------
			collision_mask_deck:
				deck_node.append(_result[_i].collider.get_parent() as Deck_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	var _s: String = ""
	_s += "MOUSE_STATE: "+str(MOUSE_STATE.keys()[myMOUSE_STATE])+"\n"
	_s += "Current Card_Node: "+str(current_card_node)+"\n"
	_s += "Current CardSlot_Node: "+str(current_cardslot_node)+"\n"
	_s += "Current Deck_Node: "+str(current_deck_node)+"\n"
	_s += "______________________________________\n"
	_s += "Areas2D_Node Being Detected:\n"
	for _i in card_node.size():
		_s += "---> Card: "+str(card_node[_i])+"\n"
	for _i in cardslot_node.size():
		_s += "---> Card Slot: "+str(cardslot_node[_i])+"\n"
	for _i in deck_node.size():
		_s += "---> Deck: "+str(deck_node[_i])+"\n"
	debugInfo.text = _s
	#-------------------------------------------------------------------------------
	match(myMOUSE_STATE):
		MOUSE_STATE.EMPTY_STATE:
			if(card_node.size() > 0):
				Card_Highlight_True(card_node[0])
				current_card_node = card_node[0]
				myMOUSE_STATE = MOUSE_STATE.CARD_HIGHLIGHTED
				return
			if(cardslot_node.size() > 0):
				Cardslot_Highlight_True(cardslot_node[0])
				current_cardslot_node = cardslot_node[0]
				myMOUSE_STATE = MOUSE_STATE.CARDSLOT_HIGHLIGHTED
				return
			if(deck_node.size() > 0):
				Deck_Highlight_True(deck_node[0])
				current_deck_node = deck_node[0]
				myMOUSE_STATE = MOUSE_STATE.DECK_HIGHLIGHTED
				return
		#-------------------------------------------------------------------------------
		MOUSE_STATE.CARD_HIGHLIGHTED:
			if(!card_node.has(current_card_node)):
				Card_Highlight_False(current_card_node)
				if(card_node.size() > 0):
					current_card_node = card_node[0]
					Card_Highlight_True(current_card_node)
				else:
					current_card_node = null
					myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
				return
			#-------------------------------------------------------------------------------
			if(Input.is_action_just_pressed("Left_Click")):
				myMOUSE_STATE = MOUSE_STATE.CARD_DRAGGED
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		MOUSE_STATE.CARDSLOT_HIGHLIGHTED:
			if(card_node.size() > 0):
				Cardslot_Highlight_False(current_cardslot_node)
				current_cardslot_node = null
				myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
				return
			#-------------------------------------------------------------------------------
			if(!cardslot_node.has(current_cardslot_node)):
				Cardslot_Highlight_False(current_cardslot_node)
				if(cardslot_node.size() > 0):
					current_cardslot_node = cardslot_node[0]
					Cardslot_Highlight_True(current_cardslot_node)
				else:
					current_cardslot_node = null
					myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
				return
		#-------------------------------------------------------------------------------
		MOUSE_STATE.DECK_HIGHLIGHTED:
			if(card_node.size() > 0):
				Deck_Highlight_False(current_deck_node)
				current_deck_node = null
				myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
				return
			#-------------------------------------------------------------------------------
			if(!deck_node.has(current_deck_node)):
				Deck_Highlight_False(current_deck_node)
				if(deck_node.size() > 0):
					current_deck_node = deck_node[0]
					Deck_Highlight_True(current_deck_node)
				else:
					current_deck_node = null
					myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
				return
			#-------------------------------------------------------------------------------
			if(Input.is_action_just_pressed("Left_Click")):
				if(current_deck_node.myDECK_TYPE == Deck_Node.DECK_TYPE.MAIN):
					DrawCard()
				return
		#-------------------------------------------------------------------------------
		MOUSE_STATE.CARD_DRAGGED:
			var mouse_pos: Vector2 = get_global_mouse_position()
			var _x: float = clamp(mouse_pos.x, 0, screen_size.x)
			var _y: float  = clamp(mouse_pos.y, 0, screen_size.y)
			current_card_node.global_position = Vector2(_x, _y)
			#-------------------------------------------------------------------------------
			if(cardslot_node.size()>0):
				var _card_Resource: Card_Resource = current_card_node.card_Class.card_Resource
				#-------------------------------------------------------------------------------
				match(cardslot_node[0].myFIELD_TYPE):
					CardSlot_Node.FIELD_TYPE.MONSTERS:
						if(_card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.RED or _card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.YELLOW):
							if(!cardslot_node[0].card_in_slot):
								current_card_node.global_position = cardslot_node[0].global_position
								current_card_node.scale = Vector2(0.7, 0.7)
								current_card_node.z_index = z_index_field
								current_cardslot_node = cardslot_node[0]
								myMOUSE_STATE = MOUSE_STATE.CARD_DRAGGED_OVER_SLOT
					#-------------------------------------------------------------------------------
					CardSlot_Node.FIELD_TYPE.ITEMS:
						if(_card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
							if(!cardslot_node[0].card_in_slot):
								current_card_node.global_position = cardslot_node[0].global_position
								current_card_node.scale = Vector2(0.7, 0.7)
								current_card_node.z_index = z_index_field
								current_cardslot_node = cardslot_node[0]
								myMOUSE_STATE = MOUSE_STATE.CARD_DRAGGED_OVER_SLOT
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			if(Input.is_action_just_released("Left_Click")):
				Card_Found_CardSlot_False()
				return
		#-------------------------------------------------------------------------------
		MOUSE_STATE.CARD_DRAGGED_OVER_SLOT:
			#-------------------------------------------------------------------------------
			if(cardslot_node.size() > 0):
				if(!cardslot_node.has(current_cardslot_node)):
					var _card_Resource: Card_Resource = current_card_node.card_Class.card_Resource
					#-------------------------------------------------------------------------------
					match(cardslot_node[0].myFIELD_TYPE):
						CardSlot_Node.FIELD_TYPE.MONSTERS:
							if(_card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.RED or _card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.YELLOW):
								if(!cardslot_node[0].card_in_slot):
									current_card_node.global_position = cardslot_node[0].global_position
									current_cardslot_node = cardslot_node[0]
									return
								else:
									Exit_Card_Dragged()
									return
							else:
								Exit_Card_Dragged()
								return
						#-------------------------------------------------------------------------------
						CardSlot_Node.FIELD_TYPE.ITEMS:
							if(_card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
								if(!cardslot_node[0].card_in_slot):
									current_card_node.global_position = cardslot_node[0].global_position
									current_cardslot_node = cardslot_node[0]
									return
								else:
									Exit_Card_Dragged()
									return
							else:
								Exit_Card_Dragged()
								return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			else:
				Exit_Card_Dragged()
				return
			#-------------------------------------------------------------------------------
			if(Input.is_action_just_released("Left_Click")):
				Card_Found_CardSlot_True(current_card_node, cardslot_node[0])
				return
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
func Set_Card_Mouse_Position():
	var mouse_pos: Vector2 = get_global_mouse_position()
	var _x: float = clamp(mouse_pos.x, 0, screen_size.x)
	var _y: float  = clamp(mouse_pos.y, 0, screen_size.y)
	current_card_node.global_position = Vector2(_x, _y)
#-------------------------------------------------------------------------------
func Exit_Card_Dragged():
	Set_Card_Mouse_Position()
	Card_Highlight_False(current_card_node)
	myMOUSE_STATE = MOUSE_STATE.CARD_DRAGGED
#-------------------------------------------------------------------------------
#region STATE MACHINE FUNCTIONS
func Card_Found_CardSlot_False():
	Add_card_to_hand(current_card_node)
	if(card_node.has(current_card_node)):
		myMOUSE_STATE = MOUSE_STATE.CARD_HIGHLIGHTED
	else:
		Card_Highlight_False(current_card_node)
		current_card_node = null
		myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
#-------------------------------------------------------------------------------
func Card_Highlight_True(_card_node: Card_Node):
	_card_node.scale = Vector2(highlight_scale, highlight_scale)
	_card_node.z_index = 2
#-------------------------------------------------------------------------------
func Card_Highlight_False(_card_node: Card_Node):
	_card_node.scale = Vector2(1, 1)
	_card_node.z_index = 1
#-------------------------------------------------------------------------------
func Cardslot_Highlight_True(_cardslot_node: CardSlot_Node):
	_cardslot_node.highlight_TextureRect.show()
#-------------------------------------------------------------------------------
func Cardslot_Highlight_False(_cardslot_node: CardSlot_Node):
	_cardslot_node.highlight_TextureRect.hide()
#-------------------------------------------------------------------------------
func Deck_Highlight_True(_deck_node: Deck_Node):
	_deck_node.highlight_TextureRect.show()
#-------------------------------------------------------------------------------
func Deck_Highlight_False(_deck_node: Deck_Node):
	_deck_node.highlight_TextureRect.hide()
#endregion
#-------------------------------------------------------------------------------
#region DECK_HIGHLIGHTED FUNCTIONS
func LoadDeck():
	for _cardResource in player.mainDeck.card_Resource:
		var _card_Class: Card_Class = _cardResource.card_Class.new() as Card_Class
		_card_Class.card_Resource = _cardResource
		player.mainDeck.card_Class.append(_card_Class)
	player.mainDeck.card_Class.shuffle()
#-------------------------------------------------------------------------------
func GetResource_Name(_resource: Card_Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func DrawCard():
	if(player.mainDeck.card_Class.size() <= 0):
		return
	#-------------------------------------------------------------------------------
	var _card_Class: Card_Class = player.mainDeck.card_Class[0]
	player.mainDeck.card_Class.erase(_card_Class)
	#-------------------------------------------------------------------------------
	SetDeckNumber1(player.mainDeck)
	#-------------------------------------------------------------------------------
	var _card_Node: Card_Node = card_Node_Prefab.instantiate() as Card_Node
	_card_Node.global_position = player.mainDeck.global_position
	_card_Node.z_index = z_index_hand
	add_child(_card_Node)
	#-------------------------------------------------------------------------------
	_card_Node.card_Class = _card_Class
	Set_Card_Node(_card_Node)
	_card_Class.gameScene = self
	_card_Node.artwork.texture = _card_Class.card_Resource.artwork
	Add_card_to_hand(_card_Node)
#-------------------------------------------------------------------------------
func SetDeckNumber1(_deck_node: Deck_Node):
	var _num: int = _deck_node.card_Class.size()
	_deck_node.label.text = str(_num)+" / "+str(_deck_node.maxDeckNum)
	if(_num <= 0):
		_deck_node.card_TextureRect.hide()
#-------------------------------------------------------------------------------
func SetDeckNumber2(_deck_node: Deck_Node):
	var _num: int = _deck_node.card_Class.size()
	_deck_node.label.text = str(_num)
	if(_num <= 0):
		_deck_node.card_TextureRect.hide()
#endregion
#-------------------------------------------------------------------------------
#region CARD_HIGHLIGHTED FUNCTIONS
func Set_Card_Node(_card_node:Card_Node):
	var _card_Resource: Card_Resource = _card_node.card_Class.card_Resource
	match(_card_Resource.myCARD_TYPE):
		Card_Resource.CARD_TYPE.RED:
			_card_node.frame.self_modulate = Color.LIGHT_PINK
			_card_node.topLabel.text = Get_Stars(_card_Resource)
			_card_node.bottonLabel.text = Get_Attack_and_Defense(_card_Resource)
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.BLUE:
			_card_node.frame.self_modulate = Color.LIGHT_BLUE
			_card_node.topLabel.text = "(Magic Card)"
			_card_node.bottonLabel.text = ""
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.YELLOW:
			_card_node.frame.self_modulate = Color.LIGHT_GOLDENROD
			_card_node.topLabel.text = Get_Stars(_card_Resource)
			_card_node.bottonLabel.text = Get_Attack_and_Defense(_card_Resource)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Get_Attack_and_Defense(_card_Resource: Card_Resource) -> String:
	return "ATK/"+str(_card_Resource.attack)+"      "+"DEF/"+str(_card_Resource.defense)
#-------------------------------------------------------------------------------
func Get_Stars(_card_Resource: Card_Resource) -> String:
	var _s:String = ""
	for _i in _card_Resource.level:
		_s += "* "
	return _s
#-------------------------------------------------------------------------------
func Card_Found_CardSlot_True(_card_node:Card_Node, _cardSlot:CardSlot_Node):
	var _card_Class: Card_Class = _card_node.card_Class
	var _card_Resource: Card_Resource = _card_Class.card_Resource
	match(_card_Resource.myCARD_TYPE):
		Card_Resource.CARD_TYPE.RED:
			Finish_Drag_Common(_card_node, _cardSlot, CardSlot_Node.FIELD_TYPE.MONSTERS, _card_Class.NormalSummon)
		Card_Resource.CARD_TYPE.BLUE:
			Finish_Drag_Common(_card_node, _cardSlot, CardSlot_Node.FIELD_TYPE.ITEMS, _card_Class.NormalActivation)
		Card_Resource.CARD_TYPE.YELLOW:
			pass
#-------------------------------------------------------------------------------
func Finish_Drag_Common(_card_node:Card_Node, _cardSlot:CardSlot_Node, _myFIELD_TYPE: CardSlot_Node.FIELD_TYPE, _callable:Callable):
	if(not _cardSlot.card_in_slot and _cardSlot.myFIELD_TYPE == _myFIELD_TYPE):
		Remove_card_from_hand(_card_node)
		_card_node.global_position = _cardSlot.global_position
		_card_node.scale = Vector2(0.7, 0.7)
		_card_node.z_index = z_index_field
		_card_node.collisionShape.disabled = true
		_cardSlot.card_in_slot = _card_node
		myMOUSE_STATE = MOUSE_STATE.EMPTY_STATE
		current_card_node = null
		_callable.call()
	else:
		Card_Found_CardSlot_False()
#endregion
#-------------------------------------------------------------------------------
#region HAND_NODE FUNCTIONS
func Add_card_to_hand(_card_Node:Card_Node):
	if(_card_Node not in player.hand.card_Node):
		player.hand.card_Node.push_back(_card_Node)
		Update_hand_position()
	else:
		Animate_card_to_position(_card_Node, _card_Node.starting_position)
#-------------------------------------------------------------------------------
func Update_hand_position():
	for _i:int in player.hand.card_Node.size():
		var _newPosition: Vector2 = Vector2(Calculate_card_position(_i), player.hand.global_position.y)
		var _card:Card_Node = player.hand.card_Node[_i]
		_card.starting_position = _newPosition
		Animate_card_to_position(_card, _newPosition)
#-------------------------------------------------------------------------------
func Calculate_card_position(_i:int) -> float:
	var _total_width: float = (player.hand.card_Node.size()-1)*card_width
	var _x_offset: float = player.hand.global_position.x+float(_i)*card_width-_total_width/2
	return _x_offset
#-------------------------------------------------------------------------------
func Animate_card_to_position(_card:Card_Node, _newPosition:Vector2):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card, "global_position", _newPosition, 0.1)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_card:Card_Node):
	if(_card in player.hand.card_Node):
		player.hand.card_Node.erase(_card)
		Update_hand_position()
#endregion
#-------------------------------------------------------------------------------
