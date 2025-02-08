extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum MOUSE_STATE{HIGHLIGHT, HOLD}
enum HIGHLIGHT_STATE{EMPTY, HAND, MONSTER_ZONE, MAGIC_ZONE, MAIN_DECK_ZONE, EXTRA_DECK_ZONE, GRAVE_ZONE, REMOVE_ZONE}
#region VARIABLES
@export var player: Player_Node
#-------------------------------------------------------------------------------
@export var card_Node_Prefab: PackedScene
#-------------------------------------------------------------------------------
@export_flags_2d_physics var collision_mask_card
#-------------------------------------------------------------------------------
var z_index_field: int = 0
var z_index_hand: int = 1
var tweenSpeed: float = 0.1
#-------------------------------------------------------------------------------
@export var debugInfo: Label
#-------------------------------------------------------------------------------
var parameters: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
var myMOUSE_STATE: MOUSE_STATE = MOUSE_STATE.HIGHLIGHT
var myHIGHLIGHT_STATE: HIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
#-------------------------------------------------------------------------------
var card_node: Array[Card_Node]
var monsterSlot_node: Array[CardSlot_Node]
var magicSlot_node: Array[CardSlot_Node]
var mainDeck_node: Array[Deck_Node]
var graveDeck_node: Array[Deck_Node]
var extraDeck_node: Array[Deck_Node]
var removeDeck_node: Array[Deck_Node]
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
func _physics_process(_delta: float) -> void:
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
	Organize_Area2Ds()
	Debug_Info()
	#-------------------------------------------------------------------------------
	match(myMOUSE_STATE):
		MOUSE_STATE.HIGHLIGHT:
			#-------------------------------------------------------------------------------
			match(myHIGHLIGHT_STATE):
				HIGHLIGHT_STATE.EMPTY:
					if(card_node.size()>0):
						Card_Highlight_True(card_node[0])
						current_card_node = card_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						return
					#-------------------------------------------------------------------------------
					if(monsterSlot_node.size()>0):
						Cardslot_Highlight_True(monsterSlot_node[0])
						current_cardslot_node = monsterSlot_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.MONSTER_ZONE
						return
					#-------------------------------------------------------------------------------
					if(magicSlot_node.size()>0):
						Cardslot_Highlight_True(magicSlot_node[0])
						current_cardslot_node = magicSlot_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.MAGIC_ZONE
						return
					#-------------------------------------------------------------------------------
					if(mainDeck_node.size()>0):
						Deck_Highlight_True(mainDeck_node[0])
						current_deck_node = mainDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.MAIN_DECK_ZONE
						return
					#-------------------------------------------------------------------------------
					if(extraDeck_node.size()>0):
						Deck_Highlight_True(extraDeck_node[0])
						current_deck_node = extraDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EXTRA_DECK_ZONE
						return
					#-------------------------------------------------------------------------------
					if(graveDeck_node.size()>0):
						Deck_Highlight_True(graveDeck_node[0])
						current_deck_node = graveDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.GRAVE_ZONE
						return
					#-------------------------------------------------------------------------------
					if(removeDeck_node.size()>0):
						Deck_Highlight_True(removeDeck_node[0])
						current_deck_node = removeDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.REMOVE_ZONE
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.HAND:
					if(!card_node.has(current_card_node)):
						Card_Highlight_False(current_card_node)
						current_card_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
					if(Input.is_action_just_pressed("Left_Click")):
						myMOUSE_STATE = MOUSE_STATE.HOLD
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.MONSTER_ZONE:
					if(card_node.size()>0):
						Cardslot_Highlight_False(current_cardslot_node)
						current_cardslot_node = null
						#-------------------------------------------------------------------------------
						Card_Highlight_True(card_node[0])
						current_card_node = card_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						return
					#-------------------------------------------------------------------------------
					if(!monsterSlot_node.has(current_cardslot_node)):
						Cardslot_Highlight_False(current_cardslot_node)
						current_cardslot_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.MAGIC_ZONE:
					if(card_node.size()>0):
						Cardslot_Highlight_False(current_cardslot_node)
						current_cardslot_node = null
						#-------------------------------------------------------------------------------
						Card_Highlight_True(card_node[0])
						current_card_node = card_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						return
					#-------------------------------------------------------------------------------
					if(!magicSlot_node.has(current_cardslot_node)):
						Cardslot_Highlight_False(current_cardslot_node)
						current_cardslot_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.MAIN_DECK_ZONE:
					#-------------------------------------------------------------------------------
					if(card_node.size()>0):
						Deck_Highlight_False(current_deck_node)
						current_deck_node = null
						#-------------------------------------------------------------------------------
						Card_Highlight_True(card_node[0])
						current_card_node = card_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						return
					#-------------------------------------------------------------------------------
					if(!mainDeck_node.has(current_deck_node)):
						Deck_Highlight_False(current_deck_node)
						current_deck_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
					if(Input.is_action_just_pressed("Left_Click")):
						DrawCard()
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.EXTRA_DECK_ZONE:
					#-------------------------------------------------------------------------------
					if(!extraDeck_node.has(current_deck_node)):
						Deck_Highlight_False(current_deck_node)
						current_deck_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.GRAVE_ZONE:
					#-------------------------------------------------------------------------------
					if(!graveDeck_node.has(current_deck_node)):
						Deck_Highlight_False(current_deck_node)
						current_deck_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.REMOVE_ZONE:
					#-------------------------------------------------------------------------------
					if(!removeDeck_node.has(current_deck_node)):
						Deck_Highlight_False(current_deck_node)
						current_deck_node = null
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		MOUSE_STATE.HOLD:
			#-------------------------------------------------------------------------------
			match(myHIGHLIGHT_STATE):
				HIGHLIGHT_STATE.HAND:
					Set_Card_Mouse_Position()
					#-------------------------------------------------------------------------------
					if(Input.is_action_just_released("Left_Click")):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(1, 1), tweenSpeed)
						Update_hand_position()
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(monsterSlot_node.size()>0):
						current_cardslot_node = monsterSlot_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.MONSTER_ZONE
						#-------------------------------------------------------------------------------
						var _tween: Tween = get_tree().create_tween()
						_tween.set_parallel()
						_tween.tween_property(current_card_node, "global_position", monsterSlot_node[0].global_position, tweenSpeed)
						_tween.tween_property(current_card_node, "scale", Vector2(0.7, 0.7), tweenSpeed)
						return
					#-------------------------------------------------------------------------------
					if(magicSlot_node.size()>0):
						current_cardslot_node = magicSlot_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.MAGIC_ZONE
						#-------------------------------------------------------------------------------
						var _tween: Tween = get_tree().create_tween()
						_tween.set_parallel()
						_tween.tween_property(current_card_node, "global_position", magicSlot_node[0].global_position, tweenSpeed)
						_tween.tween_property(current_card_node, "scale", Vector2(0.7, 0.7), tweenSpeed)
						return
					#-------------------------------------------------------------------------------
					if(graveDeck_node.size()>0):
						current_deck_node = graveDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.GRAVE_ZONE
						#-------------------------------------------------------------------------------
						var _tween: Tween = get_tree().create_tween()
						_tween.set_parallel()
						_tween.tween_property(current_card_node, "global_position", graveDeck_node[0].global_position, tweenSpeed)
						_tween.tween_property(current_card_node, "scale", Vector2(0.7, 0.7), tweenSpeed)
						return
					#-------------------------------------------------------------------------------
					if(mainDeck_node.size()>0):
						current_deck_node = mainDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.MAIN_DECK_ZONE
						#-------------------------------------------------------------------------------
						var _tween: Tween = get_tree().create_tween()
						_tween.set_parallel()
						_tween.tween_property(current_card_node, "global_position", mainDeck_node[0].global_position, tweenSpeed)
						_tween.tween_property(current_card_node, "scale", Vector2(0.7, 0.7), tweenSpeed)
						return
					#-------------------------------------------------------------------------------
					if(extraDeck_node.size()>0):
						current_deck_node = extraDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EXTRA_DECK_ZONE
						#-------------------------------------------------------------------------------
						var _tween: Tween = get_tree().create_tween()
						_tween.set_parallel()
						_tween.tween_property(current_card_node, "global_position", extraDeck_node[0].global_position, tweenSpeed)
						_tween.tween_property(current_card_node, "scale", Vector2(0.7, 0.7), tweenSpeed)
						return
					#-------------------------------------------------------------------------------
					if(removeDeck_node.size()>0):
						current_deck_node = removeDeck_node[0]
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.REMOVE_ZONE
						#-------------------------------------------------------------------------------
						var _tween: Tween = get_tree().create_tween()
						_tween.set_parallel()
						_tween.tween_property(current_card_node, "global_position", removeDeck_node[0].global_position, tweenSpeed)
						_tween.tween_property(current_card_node, "scale", Vector2(0.7, 0.7), tweenSpeed)
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.MONSTER_ZONE:
					if(Input.is_action_just_released("Left_Click")):
						player.hand.card_Node.erase(current_card_node)
						Update_hand_position()
						current_card_node.collisionShape.disabled = true
						current_card_node.z_index = z_index_field
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(!monsterSlot_node.has(current_cardslot_node)):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						current_cardslot_node = null
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.MAGIC_ZONE:
					if(Input.is_action_just_released("Left_Click")):
						player.hand.card_Node.erase(current_card_node)
						Update_hand_position()
						current_card_node.collisionShape.disabled = true
						current_card_node.z_index = z_index_field
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(!magicSlot_node.has(current_cardslot_node)):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						current_cardslot_node = null
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.GRAVE_ZONE:
					if(Input.is_action_just_released("Left_Click")):
						player.hand.card_Node.erase(current_card_node)
						Update_hand_position()
						current_card_node.collisionShape.disabled = true
						current_card_node.z_index = z_index_field
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(!graveDeck_node.has(current_deck_node)):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						current_cardslot_node = null
						return
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.MAIN_DECK_ZONE:
					if(Input.is_action_just_released("Left_Click")):
						player.hand.card_Node.erase(current_card_node)
						Update_hand_position()
						current_card_node.collisionShape.disabled = true
						current_card_node.z_index = z_index_field
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(!mainDeck_node.has(current_deck_node)):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						current_cardslot_node = null
						return
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.EXTRA_DECK_ZONE:
					if(Input.is_action_just_released("Left_Click")):
						player.hand.card_Node.erase(current_card_node)
						Update_hand_position()
						current_card_node.collisionShape.disabled = true
						current_card_node.z_index = z_index_field
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(!extraDeck_node.has(current_deck_node)):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						current_cardslot_node = null
						return
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.REMOVE_ZONE:
					if(Input.is_action_just_released("Left_Click")):
						player.hand.card_Node.erase(current_card_node)
						Update_hand_position()
						current_card_node.collisionShape.disabled = true
						current_card_node.z_index = z_index_field
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.EMPTY
						myMOUSE_STATE = MOUSE_STATE.HIGHLIGHT
						return
					#-------------------------------------------------------------------------------
					if(!removeDeck_node.has(current_deck_node)):
						var _tween: Tween = get_tree().create_tween()
						_tween.tween_property(current_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.HAND
						current_cardslot_node = null
						return
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE FUNCTIONS
#-------------------------------------------------------------------------------
func Debug_Info():
	var _s: String = ""
	_s += "MOUSE_STATE: "+str(MOUSE_STATE.keys()[myMOUSE_STATE])+"\n"
	_s += "HIGHLIGHT_STATE: "+str(HIGHLIGHT_STATE.keys()[myHIGHLIGHT_STATE])+"\n"
	_s += "Current Card_Node: "+str(current_card_node)+"\n"
	_s += "Current CardSlot_Node: "+str(current_cardslot_node)+"\n"
	_s += "Current Deck_Node: "+str(current_deck_node)+"\n"
	_s += "______________________________________\n"
	_s += "Areas2D_Node Being Detected:\n"
	for _i in card_node.size():
		_s += "---> Card: "+str(card_node[_i])+"\n"
	for _i in monsterSlot_node.size():
		_s += "---> Monster Slot: "+str(monsterSlot_node[_i])+"\n"
	for _i in magicSlot_node.size():
		_s += "---> Magic Slot: "+str(magicSlot_node[_i])+"\n"
	for _i in mainDeck_node.size():
		_s += "---> MainDeck: "+str(mainDeck_node[_i])+"\n"
	for _i in extraDeck_node.size():
		_s += "---> MainDeck: "+str(extraDeck_node[_i])+"\n"
	for _i in graveDeck_node.size():
		_s += "---> MainDeck: "+str(graveDeck_node[_i])+"\n"
	for _i in removeDeck_node.size():
		_s += "---> MainDeck: "+str(removeDeck_node[_i])+"\n"
	debugInfo.text = _s
#-------------------------------------------------------------------------------
func Organize_Area2Ds():
	parameters.position = get_global_mouse_position()
	var _result: Array[Dictionary] = space_state.intersect_point(parameters)
	#-------------------------------------------------------------------------------
	card_node = []
	monsterSlot_node = []
	magicSlot_node = []
	mainDeck_node = []
	graveDeck_node = []
	extraDeck_node = []
	removeDeck_node = []
	#-------------------------------------------------------------------------------
	for _i in _result.size():
		var _object_node: Object_Node = _result[_i].collider.get_parent() as Object_Node
		match(_object_node.myZONE_TYPE):
			Object_Node.ZONE_TYPE.HAND_ZONE:
				card_node.append(_object_node as Card_Node)
			#-------------------------------------------------------------------------------
			Object_Node.ZONE_TYPE.MONSTER_ZONE:
				monsterSlot_node.append(_object_node as CardSlot_Node)
			#-------------------------------------------------------------------------------
			Object_Node.ZONE_TYPE.MAGIC_ZONE:
				magicSlot_node.append(_object_node as CardSlot_Node)
			#-------------------------------------------------------------------------------
			Object_Node.ZONE_TYPE.DECK_ZONE:
				mainDeck_node.append(_object_node as Deck_Node)
			#-------------------------------------------------------------------------------
			Object_Node.ZONE_TYPE.EXTRA_DECK_ZONE:
				extraDeck_node.append(_object_node as Deck_Node)
			#-------------------------------------------------------------------------------
			Object_Node.ZONE_TYPE.GRAVE_ZONE:
				graveDeck_node.append(_object_node as Deck_Node)
			#-------------------------------------------------------------------------------
			Object_Node.ZONE_TYPE.REMOVE_ZONE:
				removeDeck_node.append(_object_node as Deck_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Card_Highlight_True(_card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card_node, "scale", Vector2(highlight_scale, highlight_scale), tweenSpeed)
	_card_node.z_index = 2
#-------------------------------------------------------------------------------
func Card_Highlight_False(_card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card_node, "scale", Vector2(1, 1), tweenSpeed)
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
	_tween.tween_property(_card, "global_position", _newPosition, tweenSpeed)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_card:Card_Node):
	if(_card in player.hand.card_Node):
		player.hand.card_Node.erase(_card)
		Update_hand_position()
#-------------------------------------------------------------------------------
func Set_Card_Mouse_Position():
	var mouse_pos: Vector2 = get_global_mouse_position()
	var _x: float = lerp(current_card_node.global_position.x, mouse_pos.x, 0.75)
	_x = clamp(_x, 0, screen_size.x)
	var _y: float  = lerp(current_card_node.global_position.y, mouse_pos.y, 0.75)
	_y = clamp(_y, 0, screen_size.y)
	current_card_node.global_position = Vector2(_x, _y)
#endregion
#-------------------------------------------------------------------------------
