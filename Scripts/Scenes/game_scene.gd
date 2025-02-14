extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum GAME_STATE{GAMEPLAY, DESCRIPTION_MENU}
enum HIGHLIGHT_STATE{NOTHING, ON_CARD, ON_CARDSLOT, ON_DECK, ON_BUTTON}
enum SELECTED_STATE{NOTHING, ON_CARD, ON_CARDSLOT, ON_DECK}
enum GAMEPLAY_STATE{ON_IDLE, ON_SUMMON}
#region VARIABLES
@export var player: Player_Node
@export var descriptionMenu: Control
@export var descriptionMenu_Frame: Frame_Node
@export var button1: Button_Node
@export var button2: Button_Node
#-------------------------------------------------------------------------------
@export var card_Node_Prefab: PackedScene
#-------------------------------------------------------------------------------
@export_flags_2d_physics var collision_mask_card
@export_flags_2d_physics var collision_mask_cardslot
@export_flags_2d_physics var collision_mask_deck
@export_flags_2d_physics var collision_mask_button
#-------------------------------------------------------------------------------
var z_index_field: int = 0
var z_index_hand: int = 1
var mouseCounter: int = 0
var isMousePressed: bool = false
var mouseLastPosition: Vector2
#-------------------------------------------------------------------------------
@export var debugInfo: Label
#-------------------------------------------------------------------------------
var parameters: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
var myGAME_STATE: GAME_STATE = GAME_STATE.GAMEPLAY
var myGAMEPLAY_STATE: GAMEPLAY_STATE = GAMEPLAY_STATE.ON_IDLE
#-------------------------------------------------------------------------------
var card_node: Array[Card_Node]
var cardSlot_node: Array[CardSlot_Node]
var deck_node: Array[Deck_Node]
var button_node: Array[Button_Node]
#-------------------------------------------------------------------------------
var mySELECTED_STATE: SELECTED_STATE = SELECTED_STATE.NOTHING
var selected_button_node: Button_Node = null
var selected_card_node: Card_Node = null
var selected_cardslot_node: CardSlot_Node = null
var selected_deck_node: Deck_Node = null
#-------------------------------------------------------------------------------
var myHIGHLIGHT_STATE: HIGHLIGHT_STATE = HIGHLIGHT_STATE.NOTHING
var highlighted_button_node: Button_Node = null
var highlighted_card_node: Card_Node = null
var highlighted_cardslot_node: CardSlot_Node = null
var highlighted_deck_node: Deck_Node = null
#-------------------------------------------------------------------------------
var screen_size: Vector2
var highlight_scale: float = 1.1
var selected_scale: float = 1.2
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
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	button1.highlight_TextureRect.hide()
	button2.highlight_TextureRect.hide()
	#-------------------------------------------------------------------------------
	descriptionMenu.hide()
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
	match(myGAME_STATE):
		GAME_STATE.GAMEPLAY:
			#-------------------------------------------------------------------------------
			if(Input.is_action_just_pressed("Right_Click")):
				match(myGAMEPLAY_STATE):
					GAMEPLAY_STATE.ON_IDLE:
						#-------------------------------------------------------------------------------
						match(mySELECTED_STATE):
							SELECTED_STATE.ON_CARD:
								if(selected_card_node == highlighted_card_node):
									Highlight_Card_True(selected_card_node)
								else:
									Selected_Card_False(selected_card_node)
								selected_card_node = null
								Hide_Button_Node(button1)
								Hide_Button_Node(button2)
								mySELECTED_STATE = SELECTED_STATE.NOTHING
							#-------------------------------------------------------------------------------
							SELECTED_STATE.ON_CARDSLOT:
								pass
							#-------------------------------------------------------------------------------
							SELECTED_STATE.ON_DECK:
								pass
							#-------------------------------------------------------------------------------
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
					GAMEPLAY_STATE.ON_SUMMON:
						myGAMEPLAY_STATE = GAMEPLAY_STATE.ON_IDLE
						Show_Button_Node(button1)
						Show_Button_Node(button2)
						Selected_Card_True(selected_card_node)
						for _i in player.monsterZone.size():
								player.monsterZone[_i].summoning_TextureRect.hide()
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			match(myHIGHLIGHT_STATE):
				HIGHLIGHT_STATE.NOTHING:
					if(button_node.size() > 0):
						highlighted_button_node = button_node[0]
						Highlight_Button_True(button_node[0])
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_BUTTON
						return
					#-------------------------------------------------------------------------------
					if(card_node.size() > 0):
						highlighted_card_node = card_node[0]
						if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
							if(Is_Current_Selected()):
								pass
							else:
								Highlight_Card_True(card_node[0])
						else:
							Highlight_Card_True(card_node[0])
						#-------------------------------------------------------------------------------
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_CARD
						return
					#-------------------------------------------------------------------------------
					if(cardSlot_node.size() > 0):
						highlighted_cardslot_node = cardSlot_node[0]
						Highlight_Cardslot_True(cardSlot_node[0])
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_CARDSLOT
						return
					#-------------------------------------------------------------------------------
					if(deck_node.size() > 0):
						highlighted_deck_node = deck_node[0]
						Highlight_Deck_True(deck_node[0])
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_DECK
						return
					#-------------------------------------------------------------------------------
					if(isMousePressed):
						if(Input.is_action_just_released("Left_Click")):
							if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
								mySELECTED_STATE = SELECTED_STATE.NOTHING
								Selected_Card_False(selected_card_node)
								selected_card_node = null
								Hide_Button_Node(button1)
								Hide_Button_Node(button2)
							#-------------------------------------------------------------------------------
							mouseCounter = 0
							isMousePressed = false
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
					else:
						if(Input.is_action_just_pressed("Left_Click")):
							isMousePressed = true
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.ON_CARD:
					#-------------------------------------------------------------------------------
					if(button_node.size() > 0):
						if(!Is_Current_Selected()):
							Highlight_Card_False(highlighted_card_node)
						highlighted_card_node = null
						#-------------------------------------------------------------------------------
						Highlight_Button_True(button_node[0])
						highlighted_button_node = button_node[0]
						#-------------------------------------------------------------------------------
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_BUTTON
						return
					#-------------------------------------------------------------------------------
					if(card_node.has(selected_card_node) and highlighted_card_node != selected_card_node and myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
						Highlight_Card_False(highlighted_card_node)
						highlighted_card_node = selected_card_node
						mouseCounter = 0
						isMousePressed = false
						return
					#-------------------------------------------------------------------------------
					if(!card_node.has(highlighted_card_node)):
						if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
							if(Is_Current_Selected()):
								pass
							else:
								Highlight_Card_False(highlighted_card_node)
						else:
							Highlight_Card_False(highlighted_card_node)
						highlighted_card_node = null
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.NOTHING
						return
					#-------------------------------------------------------------------------------
					if(isMousePressed):
						mouseCounter += 1
						#-------------------------------------------------------------------------------
						if(mouseCounter > 40):
							Set_Card_Node(descriptionMenu_Frame, highlighted_card_node.card_Class.card_Resource)
							descriptionMenu.show()
							myGAME_STATE = GAME_STATE.DESCRIPTION_MENU
							mouseCounter = 0
							return
						#-------------------------------------------------------------------------------
						else:
							if(Input.is_action_just_released("Left_Click")):
								highlighted_card_node.pressed.call()
								return
							#-------------------------------------------------------------------------------
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
					else:
						if(Input.is_action_just_pressed("Left_Click")):
							isMousePressed = true
							mouseCounter = 0
							mouseLastPosition = get_global_mouse_position()
							return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.ON_CARDSLOT:
					#-------------------------------------------------------------------------------
					if(button_node.size() > 0):
						Highlight_Cardslot_False(highlighted_cardslot_node)
						highlighted_cardslot_node = null
						#-------------------------------------------------------------------------------
						Highlight_Button_True(button_node[0])
						highlighted_button_node = button_node[0]
						#-------------------------------------------------------------------------------
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_BUTTON
						return
					#-------------------------------------------------------------------------------
					if(card_node.size() > 0):
						Highlight_Cardslot_False(highlighted_cardslot_node)
						highlighted_cardslot_node = null
						highlighted_card_node = card_node[0]
						#-------------------------------------------------------------------------------
						if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
							if(Is_Current_Selected()):
								pass
							else:
								Highlight_Card_True(card_node[0])
						else:
							Highlight_Card_True(card_node[0])
						#-------------------------------------------------------------------------------
						#-------------------------------------------------------------------------------
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.ON_CARD
						return
					#-------------------------------------------------------------------------------
					if(!cardSlot_node.has(highlighted_cardslot_node)):
						Highlight_Cardslot_False(highlighted_cardslot_node)
						highlighted_cardslot_node = null
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.NOTHING
						return
					#-------------------------------------------------------------------------------
					if(isMousePressed):
						if(Input.is_action_just_released("Left_Click")):
							if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
								if(mySELECTED_STATE == SELECTED_STATE.ON_CARD):
									Selected_Card_False(selected_card_node)
								#-------------------------------------------------------------------------------
								Hide_Button_Node(button1)
								Hide_Button_Node(button2)
								mySELECTED_STATE = SELECTED_STATE.NOTHING
							#-------------------------------------------------------------------------------
							mouseCounter = 0
							isMousePressed = false
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
					else:
						if(Input.is_action_just_pressed("Left_Click")):
							isMousePressed = true
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.ON_DECK:
					#-------------------------------------------------------------------------------
					if(!deck_node.has(highlighted_deck_node)):
						Highlight_Deck_False(highlighted_deck_node)
						highlighted_deck_node = null
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.NOTHING
						return
					#-------------------------------------------------------------------------------
					if(isMousePressed):
						if(Input.is_action_just_released("Left_Click")):
							if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
								highlighted_deck_node.pressed.call()
								#-------------------------------------------------------------------------------
								if(mySELECTED_STATE == SELECTED_STATE.ON_CARD):
									Selected_Card_False(selected_card_node)
								#-------------------------------------------------------------------------------
								Hide_Button_Node(button1)
								Hide_Button_Node(button2)
								mySELECTED_STATE = SELECTED_STATE.NOTHING
							#-------------------------------------------------------------------------------
							mouseCounter = 0
							isMousePressed = false
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
					else:
						if(Input.is_action_just_pressed("Left_Click")):
							isMousePressed = true
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				HIGHLIGHT_STATE.ON_BUTTON:
					#-------------------------------------------------------------------------------
					if(!button_node.has(highlighted_button_node)):
						Highlight_Button_False(highlighted_button_node)
						highlighted_button_node = null
						mouseCounter = 0
						isMousePressed = false
						myHIGHLIGHT_STATE = HIGHLIGHT_STATE.NOTHING
						return
					#-------------------------------------------------------------------------------
					if(isMousePressed):
						if(Input.is_action_just_released("Left_Click")):
							highlighted_button_node.pressed.call()
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
					else:
						if(Input.is_action_just_pressed("Left_Click")):
							isMousePressed = true
							return
						#-------------------------------------------------------------------------------
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		GAME_STATE.DESCRIPTION_MENU:
			if(Input.is_action_just_pressed("Right_Click")):
				descriptionMenu.hide()
				myGAME_STATE = GAME_STATE.GAMEPLAY
				isMousePressed = false
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE FUNCTIONS
#-------------------------------------------------------------------------------
func Debug_Info():
	var _s: String = ""
	_s += "GAME_STATE: "+str(GAME_STATE.keys()[myGAME_STATE])+"\n"
	_s += "GAMEPLAY_STATE: "+str(GAMEPLAY_STATE.keys()[myGAMEPLAY_STATE])+"\n"
	_s += "______________________________________\n"
	_s += "Mouse Counter: "+str(mouseCounter)+"\n"
	_s += "Is Mouse Pressed: "+str(isMousePressed)+"\n"
	_s += "______________________________________\n"
	_s += "HIGHLIGHT_STATE: "+str(HIGHLIGHT_STATE.keys()[myHIGHLIGHT_STATE])+"\n"
	_s += "Highlighted Card_Node: "+str(highlighted_card_node)+"\n"
	_s += "Highlighted CardSlot_Node: "+str(highlighted_cardslot_node)+"\n"
	_s += "Highlighted Deck_Node: "+str(highlighted_deck_node)+"\n"
	_s += "Highlighted Button_Node: "+str(highlighted_button_node)+"\n"
	_s += "______________________________________\n"
	_s += "SELECTED_STATE: "+str(SELECTED_STATE.keys()[mySELECTED_STATE])+"\n"
	_s += "Selected Card_Node: "+str(selected_card_node)+"\n"
	_s += "Selected CardSlot_Node: "+str(selected_cardslot_node)+"\n"
	_s += "Selected Deck_Node: "+str(selected_deck_node)+"\n"
	_s += "Selected Button_Node: "+str(selected_button_node)+"\n"
	_s += "______________________________________\n"
	_s += "Areas2D_Node Being Detected:\n"
	for _i in card_node.size():
		_s += "---> Card Node: "+str(card_node[_i])+"\n"
	for _i in cardSlot_node.size():
		_s += "---> CardSlot Node: "+str(cardSlot_node[_i])+"\n"
	for _i in deck_node.size():
		_s += "---> Deck Node: "+str(deck_node[_i])+"\n"
	for _i in button_node.size():
		_s += "---> Button Node: "+str(button_node[_i])+"\n"
	_s += "______________________________________\n"
	debugInfo.text = _s
#-------------------------------------------------------------------------------
func Is_Current_Selected() -> bool:
	var _b: bool = false
	match(mySELECTED_STATE):
		SELECTED_STATE.ON_CARD:
			if(highlighted_card_node == selected_card_node):
				_b = true
		#-------------------------------------------------------------------------------
		SELECTED_STATE.ON_CARDSLOT:
			if(highlighted_cardslot_node == selected_cardslot_node):
				_b = true
		#-------------------------------------------------------------------------------
		SELECTED_STATE.ON_DECK:
			if(highlighted_deck_node == selected_deck_node):
				_b = true
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	return _b
#-------------------------------------------------------------------------------
func Organize_Area2Ds():
	var _x: float = clamp(get_global_mouse_position().x, 0, width)
	var _y: float = clamp(get_global_mouse_position().y, 0, height)
	parameters.position = Vector2(_x, _y)
	var _result: Array[Dictionary] = space_state.intersect_point(parameters)
	#-------------------------------------------------------------------------------
	card_node = []
	cardSlot_node = []
	deck_node = []
	button_node = []
	#-------------------------------------------------------------------------------
	for _i in _result.size():
		var _collider: Area2D = _result[_i].collider
		var _collision_mask: int = _collider.collision_mask as int
		var _object_Node: Node2D = _collider.get_parent().get_parent()
		match(_collision_mask):
			collision_mask_card:
				card_node.append(_object_Node as Card_Node)
			#-------------------------------------------------------------------------------
			collision_mask_cardslot:
				cardSlot_node.append(_object_Node as CardSlot_Node)
			#-------------------------------------------------------------------------------
			collision_mask_deck:
				deck_node.append(_object_Node as Deck_Node)
			#-------------------------------------------------------------------------------
			collision_mask_button:
				button_node.append(_object_Node as Button_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region SELECTED FUNCTIONS
func Hide_Button_Node(_button_node: Button_Node):
	_button_node.collisionShape2D.disabled = true
	_button_node.hide()
#-------------------------------------------------------------------------------
func Show_Button_Node(_button_node: Button_Node):
	_button_node.collisionShape2D.disabled = false
	_button_node.show()
#-------------------------------------------------------------------------------
func Selected_Card_True(_card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel()
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, -53), 0.05)
	_tween.tween_property(_card_node.offset_Node2D, "scale", Vector2(selected_scale, selected_scale), 0.05)
	_card_node.z_index = 3
#-------------------------------------------------------------------------------
func Selected_Card_False(_card_node: Card_Node):
	if(_card_node != null):
		Highlight_Card_False(_card_node)
#endregion
#-------------------------------------------------------------------------------
#region HIGHLIGHTED FUNCTIONS
func Highlight_Button_True(_button_node: Button_Node):
	_button_node.highlight_TextureRect.show()
#-------------------------------------------------------------------------------
func Highlight_Button_False(_button_node: Button_Node):
	_button_node.highlight_TextureRect.hide()
#-------------------------------------------------------------------------------
func Highlight_Card_True(_card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel()
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, -25), 0.05)
	_tween.tween_property(_card_node.offset_Node2D, "scale", Vector2(highlight_scale, highlight_scale), 0.05)
	_card_node.z_index = 2
#-------------------------------------------------------------------------------
func Highlight_Card_False(_card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel()
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, 0), 0.05)
	_tween.tween_property(_card_node.offset_Node2D, "scale", Vector2(1, 1), 0.05)
	_card_node.z_index = 1
#-------------------------------------------------------------------------------
func Highlight_Cardslot_True(_cardslot_node: CardSlot_Node):
	_cardslot_node.highlight_TextureRect.show()
#-------------------------------------------------------------------------------
func Highlight_Cardslot_False(_cardslot_node: CardSlot_Node):
	_cardslot_node.highlight_TextureRect.hide()
#-------------------------------------------------------------------------------
func Highlight_Deck_True(_deck_node: Deck_Node):
	_deck_node.highlight_TextureRect.show()
	_deck_node.label.show()
#-------------------------------------------------------------------------------
func Highlight_Deck_False(_deck_node: Deck_Node):
	_deck_node.highlight_TextureRect.hide()
	_deck_node.label.hide()
#endregion
#-------------------------------------------------------------------------------
#region DECK_HIGHLIGHTED FUNCTIONS
func LoadDeck():
	for _cardResource in player.mainDeck.card_Resource:
		var _card_Class: Card_Class = _cardResource.card_Class.new() as Card_Class
		_card_Class.card_Resource = _cardResource
		player.mainDeck.card_Class.append(_card_Class)
	player.mainDeck.card_Class.shuffle()
	player.mainDeck.pressed = func(): DrawCard()
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
	_card_Node.pressed = func(): Card_Hand_Pressed()
	add_child(_card_Node)
	#-------------------------------------------------------------------------------
	_card_Node.card_Class = _card_Class
	Set_Card_Node(_card_Node.frame_Node, _card_Node.card_Class.card_Resource)
	_card_Class.gameScene = self
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
func Set_Card_Node(_frame_node: Frame_Node, _card_Resource:Card_Resource):
	_frame_node.artwork.texture = _card_Resource.artwork
	#-------------------------------------------------------------------------------
	match(_card_Resource.myCARD_TYPE):
		Card_Resource.CARD_TYPE.RED:
			_frame_node.frame.self_modulate = Color.LIGHT_PINK
			_frame_node.topLabel.text = Get_Stars(_card_Resource)
			_frame_node.bottonLabel.text = Get_Attack_and_Defense(_card_Resource)
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.BLUE:
			_frame_node.frame.self_modulate = Color.LIGHT_BLUE
			_frame_node.topLabel.text = "(Magic Card)"
			_frame_node.bottonLabel.text = ""
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.YELLOW:
			_frame_node.frame.self_modulate = Color.LIGHT_GOLDENROD
			_frame_node.topLabel.text = Get_Stars(_card_Resource)
			_frame_node.bottonLabel.text = Get_Attack_and_Defense(_card_Resource)
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
	_tween.tween_property(_card, "global_position", _newPosition, 0.1)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_card:Card_Node):
	if(_card in player.hand.card_Node):
		player.hand.card_Node.erase(_card)
		Update_hand_position()
#-------------------------------------------------------------------------------
func Set_Card_Mouse_Position():
	var mouse_pos: Vector2 = get_global_mouse_position()
	var _x: float = lerp(highlighted_card_node.global_position.x, mouse_pos.x, 0.75)
	_x = clamp(_x, 0, screen_size.x)
	var _y: float  = lerp(highlighted_card_node.global_position.y, mouse_pos.y, 0.75)
	_y = clamp(_y, 0, screen_size.y)
	highlighted_card_node.global_position = Vector2(_x, _y)
#endregion
#-------------------------------------------------------------------------------
func Button_Summon_Pressed():
	myGAMEPLAY_STATE = GAMEPLAY_STATE.ON_SUMMON
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	Selected_Card_False(selected_card_node)
	for _i in player.monsterZone.size():
		player.monsterZone[_i].summoning_TextureRect.show()
	mouseCounter = 0
	isMousePressed = false
#-------------------------------------------------------------------------------
func Card_Hand_Pressed():
	if(myGAMEPLAY_STATE == GAMEPLAY_STATE.ON_IDLE):
		if(!Is_Current_Selected()):
			Selected_Card_False(selected_card_node)
			selected_card_node = highlighted_card_node
			Selected_Card_True(highlighted_card_node)
			#-------------------------------------------------------------------------------
			button1.global_position = selected_card_node.offset_Node2D.global_position + Vector2(-50, -130)
			button2.global_position = selected_card_node.offset_Node2D.global_position + Vector2(50, -130)
			button1.pressed = func(): Button_Summon_Pressed()
			button2.pressed = func(): Button_Summon_Pressed()
			Show_Button_Node(button1)
			Show_Button_Node(button2)
		#-------------------------------------------------------------------------------
		mySELECTED_STATE = SELECTED_STATE.ON_CARD
	#-------------------------------------------------------------------------------
	mouseCounter = 0
	isMousePressed = false
#-------------------------------------------------------------------------------
