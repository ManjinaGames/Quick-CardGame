extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum GAME_STATE{GAMEPLAY, DESCRIPTION_MENU}
enum PHASE_STATE{START_PHASE, MAIN_PHASE1, BATTLE_PHASE, MAIN_PHASE2, END_PHASE}
enum MAINPHASE1_STATE{IDLE, HAND_MENU, SUMMON_MENU}
#region VARIABLES
@export var player1: Player_Node
@export var player2: Player_Node
#-------------------------------------------------------------------------------
@export var descriptionMenu: Control
@export var descriptionMenu_Frame: Frame_Node
#-------------------------------------------------------------------------------
@export var banner_panel: PanelContainer
@export var banner_label: Label
#-------------------------------------------------------------------------------
@export var button1: Button_Node
@export var button2: Button_Node
@export var phase_button: Button_Node
#-------------------------------------------------------------------------------
@export var phase_menu: Phase_Menu
#-------------------------------------------------------------------------------
@export var card_Node_Prefab: PackedScene
#-------------------------------------------------------------------------------
var z_index_field: int = 0
var z_index_hand: int = 1
#-------------------------------------------------------------------------------
var leftMouseCounter: int = 0
var isLeftMousePressed: bool = false
#-------------------------------------------------------------------------------
var mouseLastPosition: Vector2
#-------------------------------------------------------------------------------
@export var debugInfo: Label
#-------------------------------------------------------------------------------
var parameters: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
var myGAME_STATE: GAME_STATE = GAME_STATE.GAMEPLAY
var myPHASE_STATE: PHASE_STATE = PHASE_STATE.START_PHASE
#-------------------------------------------------------------------------------
var object_node: Array[Object_Node]
var highlighted_object_node: Object_Node = null
#-------------------------------------------------------------------------------
var screen_size: Vector2
var highlight_scale: float = 1.1
var selected_scale: float = 1.2
#-------------------------------------------------------------------------------
const cardDatabase_path: String = "res://Cards/Resources"
const cardDatabase_hability_path: String = "res://Cards/Scripts"
@export var cardDatabase: Dictionary = {}
#-------------------------------------------------------------------------------
var card_width: float = 90
#-------------------------------------------------------------------------------
var nothing_pressed: Callable = func(): pass
var nothing_released: Callable = func(): pass
var nothing_cancel: Callable = func(): pass
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready() -> void:
	parameters = PhysicsPointQueryParameters2D.new()
	parameters.collide_with_areas = true
	space_state = get_world_2d().direct_space_state
	#-------------------------------------------------------------------------------
	SetStage()
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
	if(Input.is_action_just_pressed("Right_Click")):
		nothing_cancel.call()
		return
	#-------------------------------------------------------------------------------
	Debug_Info()
	#-------------------------------------------------------------------------------
	if(myGAME_STATE != GAME_STATE.GAMEPLAY):
		return
	#-------------------------------------------------------------------------------
	Organize_Area2Ds()
	#-------------------------------------------------------------------------------
	if(highlighted_object_node):
		if(object_node.has(highlighted_object_node)):
			var _object_node: Object_Node = highlighted_object_node
			#-------------------------------------------------------------------------------
			for _i in object_node.size():
				if(object_node[_i].z_index > _object_node.z_index):
					_object_node = object_node[_i]
			#-------------------------------------------------------------------------------
			if(_object_node != highlighted_object_node):
				highlighted_object_node.lowlighted.call()
				_object_node.highlighted.call()
				highlighted_object_node = _object_node
				#-------------------------------------------------------------------------------
				isLeftMousePressed = false
				leftMouseCounter = 0
				#-------------------------------------------------------------------------------
				return
			#-------------------------------------------------------------------------------
			else:
				#-------------------------------------------------------------------------------
				if(isLeftMousePressed):
					highlighted_object_node.holding.call()
					if(Input.is_action_just_released("Left_Click")):
						highlighted_object_node.released.call()
						#-------------------------------------------------------------------------------
						isLeftMousePressed = false
						leftMouseCounter = 0
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				else:
					if(Input.is_action_just_pressed("Left_Click")):
						highlighted_object_node.pressed.call()
						#-------------------------------------------------------------------------------
						isLeftMousePressed = true
						leftMouseCounter = 0
						return
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		else:
			if(object_node.size() > 0):
				var _object_node: Object_Node = object_node[0]
				#-------------------------------------------------------------------------------
				for _i in object_node.size():
					if(object_node[_i].z_index > _object_node.z_index):
						_object_node = object_node[_i]
				#-------------------------------------------------------------------------------
				highlighted_object_node.lowlighted.call()
				_object_node.highlighted.call()
				highlighted_object_node = _object_node
				#-------------------------------------------------------------------------------
				isLeftMousePressed = false
				leftMouseCounter = 0
				#-------------------------------------------------------------------------------
				return
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			else:
				highlighted_object_node.lowlighted.call()
				highlighted_object_node = null
				#-------------------------------------------------------------------------------
				isLeftMousePressed = false
				leftMouseCounter = 0
				#-------------------------------------------------------------------------------
				return
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		if(object_node.size() > 0):
			var _object_node: Object_Node = object_node[0]
			#-------------------------------------------------------------------------------
			for _i in object_node.size():
				if(object_node[_i].z_index > _object_node.z_index):
					_object_node = object_node[_i]
			#-------------------------------------------------------------------------------
			_object_node.highlighted.call()
			highlighted_object_node = _object_node
			#-------------------------------------------------------------------------------
			isLeftMousePressed = false
			leftMouseCounter = 0
			#-------------------------------------------------------------------------------
			return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		else:
			#-------------------------------------------------------------------------------
			if(isLeftMousePressed):
				if(Input.is_action_just_released("Left_Click")):
					nothing_released.call()
					#-------------------------------------------------------------------------------
					isLeftMousePressed = false
					leftMouseCounter = 0
					return
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			else:
				if(Input.is_action_just_pressed("Left_Click")):
					nothing_pressed.call()
					#-------------------------------------------------------------------------------
					isLeftMousePressed = true
					leftMouseCounter = 0
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
	_s += "GAME_STATE: "+str(GAME_STATE.keys()[myGAME_STATE])+"\n"
	_s += "GAME_STATE: "+str(PHASE_STATE.keys()[myPHASE_STATE])+"\n"
	_s += "--------------------------------------\n"
	_s += "Mouse Counter: "+str(leftMouseCounter)+"\n"
	_s += "Is Mouse Pressed: "+str(isLeftMousePressed)+"\n"
	_s += "--------------------------------------\n"
	_s += str(Engine.get_frames_per_second()) + " fps.\n"
	_s += "--------------------------------------\n"
	_s += "Highlighted Object_Node:\n"
	_s += "---> "+str(highlighted_object_node)+"\n"
	_s += "--------------------------------------\n"
	_s += "Object_Nodes:\n"
	for _i in object_node.size():
		_s += "---> "+str(object_node[_i])+"\n"
	_s += "--------------------------------------\n"
	debugInfo.text = _s
#-------------------------------------------------------------------------------
func Organize_Area2Ds():
	var _x: float = clamp(get_global_mouse_position().x, 0, screen_size.x)
	var _y: float = clamp(get_global_mouse_position().y, 0, screen_size.y)
	parameters.position = Vector2(_x, _y)
	var _result: Array[Dictionary] = space_state.intersect_point(parameters)
	#-------------------------------------------------------------------------------
	object_node = []
	#-------------------------------------------------------------------------------
	for _i in _result.size():
		var _collider: Area2D = _result[_i].collider
		var _var = _collider.get_parent().get_parent()
		#-------------------------------------------------------------------------------
		if(_var is Object_Node):
			var _obj_N: Object_Node = _var
			#-------------------------------------------------------------------------------
			if(_obj_N.canBePressed):
				object_node.append(_obj_N)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region SELECTED FUNCTIONS
func Hide_Button_Node(_button_node: Button_Node):
	_button_node.collisionShape2D.disabled = true
	button1.released = func():pass
	_button_node.hide()
#-------------------------------------------------------------------------------
func Show_Button_Node(_button_node: Button_Node):
	_button_node.collisionShape2D.disabled = false
	_button_node.show()
#-------------------------------------------------------------------------------
func Selected_Card_True(_card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel()
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, _card_node.card_Class.user.card_selected_posY_offset), 0.05)
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
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, _card_node.card_Class.user.card_highlight_posY_offset), 0.05)
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
func LoadDeck(_user: Player_Node):
	#-------------------------------------------------------------------------------
	for _cardResource in _user.mainDeck.card_Resource:
		var _card_Class: Card_Class = _cardResource.card_Class.new() as Card_Class
		_card_Class.card_Resource = _cardResource
		_user.mainDeck.card_Class_Array.append(_card_Class)
	#-------------------------------------------------------------------------------
	_user.mainDeck.card_Class_Array.shuffle()
#-------------------------------------------------------------------------------
func GetResource_Name(_resource: Card_Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func SetDeckNumber1(_deck_node: Deck_Node):
	var _num: int = _deck_node.card_Class_Array.size()
	_deck_node.label.text = str(_num)+" / "+str(_deck_node.maxDeckNum)
	if(_num <= 0):
		_deck_node.card_TextureRect.hide()
#-------------------------------------------------------------------------------
func SetDeckNumber2(_deck_node: Deck_Node):
	var _num: int = _deck_node.card_Class_Array.size()
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
			_frame_node.topLabel.text = Get_Level(_card_Resource)
			_frame_node.bottonLabel.text = Get_Attack_and_Defense(_card_Resource)
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.BLUE:
			_frame_node.frame.self_modulate = Color.LIGHT_BLUE
			_frame_node.topLabel.text = Get_Magic_Card_Type(_card_Resource)
			_frame_node.bottonLabel.text = ""
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.YELLOW:
			_frame_node.frame.self_modulate = Color.LIGHT_GOLDENROD
			_frame_node.topLabel.text = Get_Level(_card_Resource)
			_frame_node.bottonLabel.text = Get_Attack_and_Defense(_card_Resource)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Get_Attack_and_Defense(_card_Resource: Card_Resource) -> String:
	var _s: String = ""
	_s += "["+str(Card_Resource.ELEMENT.keys()[_card_Resource.myELEMENT])+" - "+Card_Resource.CLASS.keys()[_card_Resource.myCLASS]+"]"+"\n"
	_s += "ATK/"+str(_card_Resource.attack)+"      "+"DEF/"+str(_card_Resource.defense)
	return _s
#-------------------------------------------------------------------------------
func Get_Level(_card_Resource: Card_Resource) -> String:
	var _s:String = "Lv."+str(_card_Resource.level)
	return _s
#-------------------------------------------------------------------------------
func Get_Magic_Card_Type(_card_Resource: Card_Resource) -> String:
	var _s: String = ""
	match(_card_Resource.myITEM_TYPE):
		Card_Resource.ITEM_TYPE.NORMAL:
			_s = "(Normal Item Card)"
		#-------------------------------------------------------------------------------
		Card_Resource.ITEM_TYPE.EQUIP:
			_s = "(Equip Item Card)"
		#-------------------------------------------------------------------------------
		Card_Resource.ITEM_TYPE.QUICK:
			_s = "(Quick Item Card)"
		#-------------------------------------------------------------------------------
		Card_Resource.ITEM_TYPE.INFINITE:
			_s = "(Infinite Item Card)"
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	return _s
#endregion
#-------------------------------------------------------------------------------
#region DESCRIPTION MENU
func Open_Description(_card_Resource: Card_Resource):
	Set_Card_Node(descriptionMenu_Frame, _card_Resource)
	descriptionMenu.show()
	myGAME_STATE = GAME_STATE.DESCRIPTION_MENU
	var _cancel: Callable = nothing_cancel
	nothing_cancel = func(): Close_Description(_cancel)
#-------------------------------------------------------------------------------
func Close_Description(_cancel: Callable):
	descriptionMenu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	nothing_cancel = _cancel
#endregion
#-------------------------------------------------------------------------------
#region PRESSHOLD FUNCS
func CardSlot_Node_PressHolding(_cardSlot_Node: CardSlot_Node):
	if(_cardSlot_Node.card_in_slot == null):
		return
	#-------------------------------------------------------------------------------
	Card_Node_PressHolding(_cardSlot_Node.card_in_slot)
#-------------------------------------------------------------------------------
func Card_Node_PressHolding(_card_Node: Card_Node):
	if(_card_Node.card_Class == null):
		return
	#-------------------------------------------------------------------------------
	Card_Class_PressHolding(_card_Node.card_Class)
#-------------------------------------------------------------------------------
func Card_Class_PressHolding(_card_Class: Card_Class):
	if(_card_Class.card_Resource == null):
		return
	#-------------------------------------------------------------------------------
	Card_Resource_PressHolding(_card_Class.card_Resource)
#-------------------------------------------------------------------------------
func Card_Resource_PressHolding(_cardResource: Card_Resource):
	leftMouseCounter += 1
	if(leftMouseCounter > 40):
		Open_Description(_cardResource)
		#-------------------------------------------------------------------------------
		leftMouseCounter = 0
		isLeftMousePressed = false
		#-------------------------------------------------------------------------------
		return
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region SET TABLET
func SetStage():
	screen_size = get_viewport_rect().size
	#-------------------------------------------------------------------------------
	#LoadCardDatabase()
	SetPlayer(player1, player2)
	SetPlayer(player2, player1)
	#-------------------------------------------------------------------------------
	SetButton(button1)
	SetButton(button2)
	SetButton(phase_button)
	#-------------------------------------------------------------------------------
	banner_panel.hide()
	phase_menu.hide()
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	nothing_released = func(): print("Nothing was Pressed.")
	nothing_cancel = func(): print("Cancel was Pressed.")
	#-------------------------------------------------------------------------------
	descriptionMenu.hide()
	#-------------------------------------------------------------------------------
	Draw_Cards(player1, 5)
	await Draw_Cards(player2, 5)
	#-------------------------------------------------------------------------------
	await StartPhase()
#-------------------------------------------------------------------------------
func SetButton(_button: Button_Node):
	_button.highlighted = func(): Highlight_Button_True(_button)
	_button.lowlighted = func(): Highlight_Button_False(_button)
	_button.highlight_TextureRect.hide()
#-------------------------------------------------------------------------------
func SetPlayer(_user:Player_Node, _opponent:Player_Node):
	LoadDeck(_user)
	#-------------------------------------------------------------------------------
	Set_SummonCounter(_user, 1)
	#-------------------------------------------------------------------------------
	_user.mainDeck.maxDeckNum = _user.mainDeck.card_Class_Array.size()
	for _i in _user.mainDeck.card_Class_Array.size():
		_user.mainDeck.card_Class_Array[_i].user = _user
		_user.mainDeck.card_Class_Array[_i].opponent = _opponent
	#-------------------------------------------------------------------------------
	SetDeckNumber1(_user.mainDeck)
	SetDeckNumber1(_user.extraDeck)
	SetDeckNumber2(_user.grave)
	SetDeckNumber2(_user.removed)
	#-------------------------------------------------------------------------------
	_user.mainDeck.highlighted = func(): Highlight_Deck_True(_user.mainDeck)
	_user.mainDeck.lowlighted = func(): Highlight_Deck_False(_user.mainDeck)
	#-------------------------------------------------------------------------------
	_user.extraDeck.highlighted = func(): Highlight_Deck_True(_user.extraDeck)
	_user.extraDeck.lowlighted = func(): Highlight_Deck_False(_user.extraDeck)
	#-------------------------------------------------------------------------------
	_user.grave.highlighted = func(): Highlight_Deck_True(_user.grave)
	_user.grave.lowlighted = func(): Highlight_Deck_False(_user.grave)
	#-------------------------------------------------------------------------------
	_user.removed.highlighted = func(): Highlight_Deck_True(_user.removed)
	_user.removed.lowlighted = func(): Highlight_Deck_False(_user.removed)
	#-------------------------------------------------------------------------------
	for _i in _user.monsterZone.size():
		_user.monsterZone[_i].highlighted = func(): Highlight_Cardslot_True(_user.monsterZone[_i])
		_user.monsterZone[_i].lowlighted = func(): Highlight_Cardslot_False(_user.monsterZone[_i])
		_user.monsterZone[_i].holding = func(): CardSlot_Node_PressHolding(_user.monsterZone[_i])
	#-------------------------------------------------------------------------------
	for _i in _user.magicZone.size():
		_user.magicZone[_i].highlighted = func(): Highlight_Cardslot_True(_user.magicZone[_i])
		_user.magicZone[_i].lowlighted = func(): Highlight_Cardslot_False(_user.magicZone[_i])
		_user.magicZone[_i].holding = func(): CardSlot_Node_PressHolding(_user.magicZone[_i])
#-------------------------------------------------------------------------------
func Draw_Cards(_player:Player_Node, _iMax: int):
	await get_tree().create_timer(0.5).timeout
	for _i in _iMax:
		Draw_1_Card(_player)
		await get_tree().create_timer(0.15).timeout
#-------------------------------------------------------------------------------
func Draw_1_Card(_player:Player_Node) -> void:
	#-------------------------------------------------------------------------------
	if(_player.mainDeck.card_Class_Array.size() <= 0):
		return
	#-------------------------------------------------------------------------------
	var _card_Class: Card_Class = _player.mainDeck.card_Class_Array[0]
	_player.mainDeck.card_Class_Array.erase(_card_Class)
	#-------------------------------------------------------------------------------
	SetDeckNumber1(_player.mainDeck)
	#-------------------------------------------------------------------------------
	var _card_Node: Card_Node = card_Node_Prefab.instantiate() as Card_Node
	_card_Node.offset_Node2D.rotation_degrees = _player.card_rotation
	_card_Node.global_position = _player.mainDeck.global_position
	_card_Node.z_index = z_index_hand
	#-------------------------------------------------------------------------------
	if(_player.isPlayer1):
		_player.hand.card_Node_Array.push_back(_card_Node)
		_card_Node.frame_Node.back.hide()
	else:
		_player.hand.card_Node_Array.push_front(_card_Node)
		#_card_Node.frame_Node.back.show()
	#-------------------------------------------------------------------------------
	add_child(_card_Node)
	#-------------------------------------------------------------------------------
	_card_Node.card_Class = _card_Class
	Set_Card_Node(_card_Node.frame_Node, _card_Node.card_Class.card_Resource)
	#-------------------------------------------------------------------------------
	_card_Node.highlighted = func(): Highlight_Card_True(_card_Node)
	_card_Node.lowlighted = func(): Highlight_Card_False(_card_Node)
	_card_Node.holding = func(): Card_Node_PressHolding(_card_Node)
	#-------------------------------------------------------------------------------
	Update_hand_position(_player.hand)
#-------------------------------------------------------------------------------
func Update_hand_position(_hand:Hand_Node):
	#-------------------------------------------------------------------------------
	for _i:int in _hand.card_Node_Array.size():
		var _newPosition: Vector2 = Vector2(Calculate_card_position(_i), _hand.global_position.y)
		var _card:Card_Node = _hand.card_Node_Array[_i]
		_card.starting_position = _newPosition
		Animate_card_to_position(_card, _newPosition)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Calculate_card_position(_i:int) -> float:
	var _total_width: float = (player1.hand.card_Node_Array.size()-1)*card_width
	var _x_offset: float = player1.hand.global_position.x+float(_i)*card_width-_total_width/2
	return _x_offset
#-------------------------------------------------------------------------------
func Animate_card_to_position(_card:Card_Node, _newPosition:Vector2):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card, "global_position", _newPosition, 0.1)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_card:Card_Node):
	if(_card in player1.hand.card_Node_Array):
		player1.hand.card_Node_Array.erase(_card)
		Update_hand_position(player1.hand)
#endregion
#-------------------------------------------------------------------------------
#Here are the START PHASE funcs.
#-------------------------------------------------------------------------------
#region START PHASE
func StartPhase():
	myPHASE_STATE = PHASE_STATE.START_PHASE
	NullPhase()
	await Show_Banner("Your Turn")
	await Show_Banner("Start Phase")
	Draw_1_Card(player1)
	Set_SummonCounter(player1, 1)
	await get_tree().create_timer(0.15).timeout
	await MainPhase1()
#-------------------------------------------------------------------------------
func Set_SummonCounter(_player:Player_Node, _i:int):
	player1.summonCounter = _i
	Set_SummonCounter_Common(_player, _i)
#-------------------------------------------------------------------------------
func Set_SummonCounter_Minus(_player:Player_Node):
	player1.summonCounter -= 1
	Set_SummonCounter_Common(_player, _player.summonCounter)
#-------------------------------------------------------------------------------
func Set_SummonCounter_Common(_player:Player_Node, _i:int):
	player1.label_Summons.text = str(_i) + "/1 NS"
#-------------------------------------------------------------------------------
func Show_Banner(_s:String):
	banner_label.text = _s
	banner_panel.show()
	await get_tree().create_timer(1).timeout
	banner_panel.hide()
#-------------------------------------------------------------------------------
func NullPhase():
	phase_button.released = func(): pass
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	NullPhase_Player(player1)
	NullPhase_Player(player2)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func NullPhase_Player(_player: Player_Node):
	_player.mainDeck.released = func():pass
	_player.extraDeck.released = func():pass
	_player.grave.released = func():pass
	_player.removed.released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		_player.hand.card_Node_Array[_i].released = func(): pass
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#Here are the MAINs PHASE funcs.
#-------------------------------------------------------------------------------
#region MAIN PHASE 1
func MainPhase1():
	NullPhase()
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.MAIN_PHASE1
	await Show_Banner("Main Phase 1")
	#-------------------------------------------------------------------------------
	MainPhase_Common_Idle()
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE 2
func MainPhase2():
	NullPhase()
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.MAIN_PHASE2
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	await Show_Banner("Main Phase 2")
	#-------------------------------------------------------------------------------
	MainPhase_Common_Idle()
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE COMMON - IDLE
func MainPhase_Common_Idle():
	print("Enter - MainPhase1 - Idle")
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	phase_button.released = func(): MainPhase_Common_Exit_Idle_Enter_PhaseMenu()
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	MainPhase_Common_Idle_Player(player1)
	MainPhase_Common_Idle_Player(player2)
#-------------------------------------------------------------------------------
func MainPhase_Common_Idle_Player(_player: Player_Node):
	_player.mainDeck.released = func():pass
	_player.extraDeck.released = func():pass
	_player.grave.released = func():pass
	_player.removed.released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node.released = func(): MainPhase_Common_Exit_Idle_Enter_HandMenu(_card_Node)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_Idle_Enter_HandMenu(_cardNode: Card_Node):
	MainPhase_Common_HandMenu(_cardNode)
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE COMMON - HAND MENU
func MainPhase_Common_HandMenu(_cardNode: Card_Node):
	print("Enter - MainPhase1 - HandMenu")
	#-------------------------------------------------------------------------------
	MainPhase_Common_HandMenu_Common(_cardNode)
#-------------------------------------------------------------------------------
func MainPhase_Common_HandMenu_Common(_cardNode: Card_Node):
	#-------------------------------------------------------------------------------
	Selected_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	_cardNode.highlighted = func():pass
	_cardNode.lowlighted = func():pass
	_cardNode.released = func():pass
	#-------------------------------------------------------------------------------
	if(_cardNode.card_Class.user.summonCounter > 0 or _cardNode.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		button1.global_position = _cardNode.global_position + Vector2(-35, -150)
		button2.global_position = _cardNode.global_position + Vector2(35, -150)
		#-------------------------------------------------------------------------------
		button1.released = func(): MainPhase_Common_Exit_HandMenu_Enter_SummonMenu(_cardNode, true)
		button2.released = func(): MainPhase_Common_Exit_HandMenu_Enter_SummonMenu(_cardNode, false)
		#-------------------------------------------------------------------------------
		Show_Button_Node(button1)
		Show_Button_Node(button2)
	#-------------------------------------------------------------------------------
	else:
		Hide_Button_Node(button1)
		Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	phase_button.released = func(): MainPhase_Common_Exit_HandMenu_Enter_PhaseMenu(_cardNode)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode)
	nothing_released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	MainPhase_Common_HandMenu_Player(player1, _cardNode)
	MainPhase_Common_HandMenu_Player(player2, _cardNode)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase_Common_HandMenu_Player(_player: Player_Node, _cardNode: Card_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.extraDeck.released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.grave.released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.removed.released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func(): MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		if(_player.hand.card_Node_Array[_i] != _cardNode):
			var _card_Node_InHand: Card_Node = _player.hand.card_Node_Array[_i]
			_card_Node_InHand.released = func(): MainPhase_Common_HandMenu_2(_card_Node_InHand, _cardNode)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase_Common_HandMenu_2(_cardNode1: Card_Node, _cardNode2: Card_Node):
	Restablish_Highlight_of_Card_in_Hand(_cardNode2)
	#-------------------------------------------------------------------------------
	MainPhase_Common_HandMenu_Common(_cardNode1)
#-------------------------------------------------------------------------------
func Restablish_Highlight_of_Card_in_Hand(_card_node: Card_Node):
	Selected_Card_False(_card_node)
	_card_node.highlighted = func(): Highlight_Card_True(_card_node)
	_card_node.lowlighted = func(): Highlight_Card_False(_card_node)
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_HandMenu_Enter_Idle(_cardNode: Card_Node):
	Selected_Card_False(_cardNode)
	HandCard_Canceled_Common(_cardNode)
	MainPhase_Common_Idle()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode: Card_Node):
	if(object_node.has(_cardNode)):
		Highlight_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	else:
		Selected_Card_False(_cardNode)
	#-------------------------------------------------------------------------------
	HandCard_Canceled_Common(_cardNode)
	MainPhase_Common_Idle()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_HandMenu_Enter_SummonMenu(_cardNode: Card_Node, _isInAttackPosition: bool):
	_cardNode.card_Class.isInAttackPosition = _isInAttackPosition
	Selected_Card_False(_cardNode)
	HandCard_Canceled_Common(_cardNode)
	MainPhase_Common_SummonMenu(_cardNode)
#-------------------------------------------------------------------------------
func HandCard_Canceled_Common(_cardNode: Card_Node):
	_cardNode.highlighted = func(): Highlight_Card_True(_cardNode)
	_cardNode.lowlighted = func(): Highlight_Card_False(_cardNode)
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE COMMON - SUMMON MENU
func MainPhase_Common_SummonMenu(_card_Node:Card_Node):
	print("Enter - MainPhase1 - SummonMenu")
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	phase_button.released = func(): MainPhase_Common_Exit_SummonMenu_Enter_PhaseMenu(_card_Node)
	#-------------------------------------------------------------------------------
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		for _i in player1.magicZone.size():
			if(player1.magicZone[_i].card_in_slot == null):
				player1.magicZone[_i].summoning_TextureRect.show()
				player1.magicZone[_i].released = func(): MainPhase_Common_SummonMenu_ActiveteCard(player1.magicZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				player1.magicZone[_i].released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in player1.monsterZone.size():
			player1.monsterZone[_i].released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		for _i in player1.monsterZone.size():
			if(player1.monsterZone[_i].card_in_slot == null):
				player1.monsterZone[_i].summoning_TextureRect.show()
				player1.monsterZone[_i].released = func(): MainPhase_Common_SummonMenu_SummonMonster(player1.monsterZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				player1.monsterZone[_i].released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in player1.magicZone.size():
			player1.magicZone[_i].released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	for _i in player2.monsterZone.size():
		player2.monsterZone[_i].released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	for _i in player2.magicZone.size():
		player2.magicZone[_i].released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	nothing_released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	nothing_cancel = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	MainPhase_Common_SummonMenu_Player(player1, _card_Node)
	MainPhase_Common_SummonMenu_Player(player2, _card_Node)
#-------------------------------------------------------------------------------
func MainPhase_Common_SummonMenu_Player(_player:Player_Node, _card_Node: Card_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.extraDeck.released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.grave.released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.removed.released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node_inHand: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node_inHand.released = func(): MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_2(_card_Node_inHand, _card_Node)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase_Common_SummonMenu_SummonMonster(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	Set_SummonCounter_Minus(_card_Node.card_Class.user)
	MainPhase_Common_Exit_SummonMenu_Enter_Idle(_cardSlot_Node, _card_Node)
	Desactivate_MonsterZone()
#-------------------------------------------------------------------------------
func MainPhase_Common_SummonMenu_ActiveteCard(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MainPhase_Common_Exit_SummonMenu_Enter_Idle(_cardSlot_Node, _card_Node)
	Desactivate_MagicZone()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_SummonMenu_Enter_Idle(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MoveCard_fromHand_toSlot(_card_Node, player1.hand, _cardSlot_Node)
	MainPhase_Common_Idle()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_1(_card_Node: Card_Node):
	MainPhase_Common_HandMenu(_card_Node)
	Deselect_Zones(_card_Node)
	#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_SummonMenu_Enter_HandMenu_2(_card_Node1: Card_Node, _card_Node2: Card_Node):
	MainPhase_Common_HandMenu(_card_Node1)
	Deselect_Zones(_card_Node2)
#-------------------------------------------------------------------------------
func Deselect_Zones(_card_Node: Card_Node):
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		Desactivate_MagicZone()
	#-------------------------------------------------------------------------------
	else:
		Desactivate_MonsterZone()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Desactivate_MagicZone():
	for _i in player1.magicZone.size():
		player1.magicZone[_i].summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Desactivate_MonsterZone():
	for _i in player1.monsterZone.size():
		player1.monsterZone[_i].summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MoveCard_fromHand_toSlot(_card_node: Card_Node, _hand: Hand_Node, _cardSlot_Node:CardSlot_Node):
	_card_node.canBePressed = false
	_cardSlot_Node.card_in_slot = _card_node
	_hand.card_Node_Array.erase(_card_node)
	Update_hand_position(_hand)
	#-------------------------------------------------------------------------------
	var _timer: float = 0.2
	var _size: float = 0.7
	#-------------------------------------------------------------------------------
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, 0), _timer)
	_tween.tween_property(_card_node.offset_Node2D, "scale", Vector2(_size, _size), _timer)
	if(_card_node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		if(_card_node.card_Class.isInAttackPosition):
			pass
		else:
			_card_node.frame_Node.back.show()
			_card_node.frame_Node.back.self_modulate.a = 0.9
	else:
		if(_card_node.card_Class.isInAttackPosition):
			pass
		else:
			_tween.tween_property(_card_node, "rotation_degrees", _card_node.card_Class.user.card_defense_rotation, _timer)
	_tween.tween_property(_card_node, "global_position", _cardSlot_Node.global_position, _timer)
	_tween.set_parallel(false)
	_tween.tween_callback(func():
		_card_node.z_index = 0
	)
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE COMMON - PHASE MENU
func MainPhase_Common_Exit_Idle_Enter_PhaseMenu():
	MainPhase_Common_Enter_PhaseMenu()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_HandMenu_Enter_PhaseMenu(_card_node: Card_Node):
	Restablish_Highlight_of_Card_in_Hand(_card_node)
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	MainPhase_Common_Enter_PhaseMenu()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_SummonMenu_Enter_PhaseMenu(_card_node: Card_Node):
	Deselect_Zones(_card_node)
	MainPhase_Common_Enter_PhaseMenu()
#-------------------------------------------------------------------------------
func MainPhase_Common_Enter_PhaseMenu():
	phase_menu.show()
	myGAME_STATE = GAME_STATE.DESCRIPTION_MENU
	#-------------------------------------------------------------------------------
	if(myPHASE_STATE == PHASE_STATE.MAIN_PHASE1):
		print("Enter - MainPhase1 - PhaseMenu")
		phase_menu.button_startPhase.disabled = true
		Connect_PressedSignal_InButton(phase_menu.button_mainPhase1, func():MainPhase_Common_Exit_PhaseMenu_Enter_Idle())
		Connect_PressedSignal_InButton(phase_menu.button_battlePhase, func():BattlePhase())
		phase_menu.button_mainPhase2.disabled = true
		Connect_PressedSignal_InButton(phase_menu.button_endPhase, func():EndPhase())
		Connect_PressedSignal_InButton(phase_menu.button_cancel, func():MainPhase_Common_Exit_PhaseMenu_Enter_Idle())
	#-------------------------------------------------------------------------------
	elif(myPHASE_STATE == PHASE_STATE.MAIN_PHASE2):
		print("Enter - MainPhase2 - PhaseMenu")
		phase_menu.button_startPhase.disabled = true
		phase_menu.button_mainPhase1.disabled = true
		phase_menu.button_battlePhase.disabled = true
		Connect_PressedSignal_InButton(phase_menu.button_mainPhase2, func():MainPhase_Common_Exit_PhaseMenu_Enter_Idle())
		Connect_PressedSignal_InButton(phase_menu.button_endPhase, func():EndPhase())
		Connect_PressedSignal_InButton(phase_menu.button_cancel, func():MainPhase_Common_Exit_PhaseMenu_Enter_Idle())
	#-------------------------------------------------------------------------------
	nothing_cancel = func():MainPhase_Common_Exit_PhaseMenu_Enter_Idle()
#-------------------------------------------------------------------------------
func MainPhase_Common_Exit_PhaseMenu_Enter_Idle():
	#-------------------------------------------------------------------------------
	if(myPHASE_STATE == PHASE_STATE.MAIN_PHASE1):
		phase_menu.button_startPhase.disabled = false
		phase_menu.button_mainPhase2.disabled = false
		Disconnect_Signal(phase_menu.button_cancel.pressed)
		Disconnect_Signal(phase_menu.button_mainPhase1.pressed)
		Disconnect_Signal(phase_menu.button_battlePhase.pressed)
	#-------------------------------------------------------------------------------
	elif(myPHASE_STATE == PHASE_STATE.MAIN_PHASE2):
		phase_menu.button_startPhase.disabled = false
		phase_menu.button_mainPhase2.disabled = false
		phase_menu.button_battlePhase.disabled = false
		Disconnect_Signal(phase_menu.button_mainPhase2.pressed)
		Disconnect_Signal(phase_menu.button_cancel.pressed)
	#-------------------------------------------------------------------------------
	MainPhase_Common_Idle()
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
#endregion
#-------------------------------------------------------------------------------
#Here are the BATTLE PHASE funcs.
#-------------------------------------------------------------------------------
#region BATTLE PHASE
func BattlePhase():
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	myPHASE_STATE = PHASE_STATE.BATTLE_PHASE
	NullPhase()
	await Show_Banner("Battle Phase")
	BattlePhase_Idle()
#endregion
#-------------------------------------------------------------------------------
#region BATTLE PHASE - IDLE
func BattlePhase_Idle():
	print("Enter - BattlePhase - Idle")
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	phase_button.released = func(): BattlePhase_Exit_Idle_Enter_PhaseMenu()
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	BattlePhase_Idle_Player(player1)
	BattlePhase_Idle_Player(player2)
#-------------------------------------------------------------------------------
func BattlePhase_Idle_Player(_player: Player_Node):
	_player.mainDeck.released = func():pass
	_player.extraDeck.released = func():pass
	_player.grave.released = func():pass
	_player.removed.released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node.released = func(): BattlePhase_HandMenu(_card_Node)
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region BATTLE PHASE - HAND MENU
func BattlePhase_HandMenu(_cardNode: Card_Node):
	print("Enter - BattlePhase - HandMenu")
	#-------------------------------------------------------------------------------
	BattlePhase_HandMenu_Common(_cardNode)
#-------------------------------------------------------------------------------
func BattlePhase_HandMenu_Common(_cardNode: Card_Node):
	#-------------------------------------------------------------------------------
	Selected_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	_cardNode.highlighted = func():pass
	_cardNode.lowlighted = func():pass
	_cardNode.released = func():pass
	#-------------------------------------------------------------------------------
	phase_button.released = func(): BattlePhase_Exit_HandMenu_Enter_PhaseMenu(_cardNode)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): BattlePhase_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode)
	nothing_released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	BattlePhase_HandMenu_Player(player1, _cardNode)
	BattlePhase_HandMenu_Player(player2, _cardNode)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func BattlePhase_HandMenu_Player(_player: Player_Node, _cardNode: Card_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.extraDeck.released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.grave.released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.removed.released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func(): BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		if(_player.hand.card_Node_Array[_i] != _cardNode):
			var _card_Node_InHand: Card_Node = _player.hand.card_Node_Array[_i]
			_card_Node_InHand.released = func(): BattlePhase_HandMenu_2(_card_Node_InHand, _cardNode)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func BattlePhase_HandMenu_2(_cardNode1: Card_Node, _cardNode2: Card_Node):
	Restablish_Highlight_of_Card_in_Hand(_cardNode2)
	#-------------------------------------------------------------------------------
	BattlePhase_HandMenu_Common(_cardNode1)
#-------------------------------------------------------------------------------
func BattlePhase_Exit_HandMenu_Enter_Idle(_cardNode: Card_Node):
	Selected_Card_False(_cardNode)
	HandCard_Canceled_Common(_cardNode)
	BattlePhase_Idle()
#-------------------------------------------------------------------------------
func BattlePhase_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode: Card_Node):
	if(object_node.has(_cardNode)):
		Highlight_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	else:
		Selected_Card_False(_cardNode)
	#-------------------------------------------------------------------------------
	HandCard_Canceled_Common(_cardNode)
	BattlePhase_Idle()
#endregion
#-------------------------------------------------------------------------------
#region BATTLE PHASE - PHASE MENU
func BattlePhase_Exit_Idle_Enter_PhaseMenu():
	BattlePhase_Enter_PhaseMenu()
#-------------------------------------------------------------------------------
func BattlePhase_Exit_HandMenu_Enter_PhaseMenu(_card_node: Card_Node):
	Restablish_Highlight_of_Card_in_Hand(_card_node)
	#-------------------------------------------------------------------------------
	BattlePhase_Enter_PhaseMenu()
#-------------------------------------------------------------------------------
func BattlePhase_Enter_PhaseMenu():
	print("Enter - BattlePhase - PhaseMenu")
	phase_menu.show()
	myGAME_STATE = GAME_STATE.DESCRIPTION_MENU
	#-------------------------------------------------------------------------------
	phase_menu.button_startPhase.disabled = true
	phase_menu.button_mainPhase1.disabled = true
	Connect_PressedSignal_InButton(phase_menu.button_battlePhase, func():BattlePhase_Exit_PhaseMenu_Enter_Idle())
	Connect_PressedSignal_InButton(phase_menu.button_mainPhase2, func():MainPhase2())
	Connect_PressedSignal_InButton(phase_menu.button_endPhase, func():EndPhase())
	Connect_PressedSignal_InButton(phase_menu.button_cancel, func():BattlePhase_Exit_PhaseMenu_Enter_Idle())
	#-------------------------------------------------------------------------------
	nothing_cancel = func():BattlePhase_Exit_PhaseMenu_Enter_Idle()
#-------------------------------------------------------------------------------
func BattlePhase_Exit_PhaseMenu_Enter_Idle():
	#-------------------------------------------------------------------------------
	phase_menu.button_startPhase.disabled = false
	phase_menu.button_mainPhase1.disabled = false
	Disconnect_Signal(phase_menu.button_battlePhase.pressed)
	Disconnect_Signal(phase_menu.button_mainPhase2.pressed)
	Disconnect_Signal(phase_menu.button_cancel.pressed)
	#-------------------------------------------------------------------------------
	BattlePhase_Idle()
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
#endregion
#-------------------------------------------------------------------------------
#Here are the END PHASE funcs.
#-------------------------------------------------------------------------------
#region END PHASE
func EndPhase():
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	myPHASE_STATE = PHASE_STATE.END_PHASE
	EndPhase_Idle()
	await Show_Banner("End Phase")
	await Show_Banner("Opponent Turn")
	StartPhase()
#endregion
#-------------------------------------------------------------------------------
#region END PHASE - IDLE
func EndPhase_Idle():
	print("Enter - EndPhase - Idle")
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	phase_button.released = func(): pass
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	EndPhase_Idle_Player(player1)
	EndPhase_Idle_Player(player2)
#-------------------------------------------------------------------------------
func EndPhase_Idle_Player(_player: Player_Node):
	_player.mainDeck.released = func():pass
	_player.extraDeck.released = func():pass
	_player.grave.released = func():pass
	_player.removed.released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func():pass
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node.released = func(): pass
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#Here are the Misc
#-------------------------------------------------------------------------------
#region MISC
func Connect_PressedSignal_InButton(_button:Button, _callable: Callable):
	_button.disabled = false
	Connect_Signal(_button.pressed, _callable)
#-------------------------------------------------------------------------------
func Connect_Signal(_signal:Signal, _callable: Callable):
	Disconnect_Signal(_signal)
	_signal.connect(_callable)
#-------------------------------------------------------------------------------
func Disconnect_Signal(_signal:Signal):
	var _dictionaryArray : Array = _signal.get_connections()
	for _dictionary in _dictionaryArray:
		_signal.disconnect(_dictionary["callable"])
#endregion
#-------------------------------------------------------------------------------
