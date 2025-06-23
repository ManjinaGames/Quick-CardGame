extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum GAME_STATE{GAMEPLAY, DESCRIPTION_MENU}
enum GAMEMENU_STATE{IDLE_STATE, HAND_MENU, FIELD_MENU, DECK_MENU, PHASE_MENU, SUMMON_MENU}
enum PHASE_STATE{START_PHASE, MAIN_PHASE1, BATTLE_PHASE, MAIN_PHASE2, END_PHASE}
enum MAINPHASE1_STATE{IDLE, HAND_MENU, SUMMON_MENU}
#region VARIABLES
@export var player1: Player_Node
@export var player2: Player_Node
#-------------------------------------------------------------------------------
@export var cardLayer_pink: Texture2D
@export var cardLayer_green: Texture2D
@export var cardLayer_orange: Texture2D
@export var cardLayer_purple: Texture2D
var turnCounter: int = 0
#-------------------------------------------------------------------------------
var player1_color: Color = Color.LIGHT_SKY_BLUE
var player2_color: Color = Color.LIGHT_PINK
#-------------------------------------------------------------------------------
const _cardClass_path: String = "res://Cards/Class/"
const _cardResource_path: String = "res://Cards/Resource/"
#-------------------------------------------------------------------------------
@export var descriptionMenu: Control
@export var descriptionMenu_Frame: Frame_Node
#-------------------------------------------------------------------------------
@export var banner_panel: PanelContainer
@export var banner_label: Label
#-------------------------------------------------------------------------------
@export var button_Array: Array[Button_Node]
@export var button_phase: Button_Node
#-------------------------------------------------------------------------------
@export var button_Icon_Summon: Texture2D
@export var button_Icon_Set: Texture2D
@export var button_Icon_attack: Texture2D
@export var button_Icon_position: Texture2D
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
var myGAMEMENU_STATE: GAMEMENU_STATE = GAMEMENU_STATE.IDLE_STATE
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
var card_width: float = 120
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
	_s += "GAMEMENU_STATE: "+str(GAMEMENU_STATE.keys()[myGAMEMENU_STATE])+"\n"
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
#Here are the Selected/Highlighted Funcs.
#-------------------------------------------------------------------------------
#region SELECTED FUNCTIONS
func Hide_Buton_Node_Array(_button_node_array: Array[Button_Node]):
	for _b in _button_node_array:
		Hide_Button_Node(_b)
#-------------------------------------------------------------------------------
func Hide_Button_Node(_button_node: Button_Node):
	_button_node.collisionShape2D.disabled = true
	_button_node.released = func():pass
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
func LoadDeck(_user: Player_Node):			#IMPORTANTE: El Nombre del Card_Class debe coincidir con el nombre del Card_Resource en los archivos.
	#-------------------------------------------------------------------------------
	for _cardResource in _user.mainDeck_Card_Resource_Array:
		var _cardClass: Card_Class = Create_CardClass(_cardResource)
		_cardClass.card_Resource = _cardResource
		_user.mainDeck.card_Class_Array.append(_cardClass)
	#-------------------------------------------------------------------------------
	_user.mainDeck.card_Class_Array.shuffle()
#-------------------------------------------------------------------------------
func Create_CardClass(_cardResource: Card_Resource) -> Card_Class:			#IMPORTANTE: El Nombre del Card_Class debe coincidir con el nombre del Card_Resource en los archivos.
	var _path: String = _cardClass_path + GetResource_Name(_cardResource) + ".gd"
	var _cardClass: Card_Class = load(_path).new() as Card_Class
	return _cardClass
#-------------------------------------------------------------------------------
func GetResource_Name(_resource: Card_Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
#-------------------------------------------------------------------------------
func SetDeckNumber1(_deck_node: Deck_Node):
	var _num: int = _deck_node.card_Class_Array.size()
	_deck_node.label.text = str(_num)+"/"+str(_deck_node.maxDeckNum)
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
		Card_Resource.CARD_TYPE.MONSTER_CARD:
			if(_card_Resource.isFusionMonster):
				_frame_node.frame.texture = cardLayer_purple
			#-------------------------------------------------------------------------------
			else:
				_frame_node.frame.texture = cardLayer_orange
			#-------------------------------------------------------------------------------
			_frame_node.label_CardType.text = Get_Monster_Element_Type_Level(_card_Resource)
			_frame_node.label_Attack.text = "ATK/"+str(_card_Resource.attack)
			_frame_node.label_Defense.text = "DEF/"+str(_card_Resource.defense)
			_frame_node.label_Name.text = "Name of the Monster Card"
			_frame_node.label_Description.text = "Description of the Monster Card"
		#-------------------------------------------------------------------------------
		Card_Resource.CARD_TYPE.MAGIC_CARD:
			if(_card_Resource.isTrapCard):
				_frame_node.frame.texture = cardLayer_pink
			#-------------------------------------------------------------------------------
			else:
				_frame_node.frame.texture = cardLayer_green
			#-------------------------------------------------------------------------------
			_frame_node.label_CardType.text = Get_Magic_Card_Type(_card_Resource)
			_frame_node.label_Attack.text = ""
			_frame_node.label_Defense.text = ""
			_frame_node.label_Name.text = "Name of the Magic/Trap Card"
			_frame_node.label_Description.text = "Description of the Magic/Trap Card"
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Get_Monster_Element_Type_Level(_card_Resource: Card_Resource) -> String:
	var _element: String = str(Card_Resource.MONSTER_ELEMENT.keys()[_card_Resource.myMONSTER_ELEMENT])
	var _type: String = Card_Resource.MONSTER_TYPE.keys()[_card_Resource.myMONSTER_TYPE]
	var _level: String = str(_card_Resource.level)
	#-------------------------------------------------------------------------------
	var _s:String = "["+_element+" - "+_type+" - "+"Lv."+_level+"]"
	return _s
#-------------------------------------------------------------------------------
func Get_Magic_Card_Type(_card_Resource: Card_Resource) -> String:
	var _cardType1: String = ""
	var _cardType2: String = ""
	#-------------------------------------------------------------------------------
	if(_card_Resource.isTrapCard):
		_cardType2 = "Trap Card)"
	#-------------------------------------------------------------------------------
	else:
		_cardType2 = "Magic Card)"
	#-------------------------------------------------------------------------------
	match(_card_Resource.myMAGIC_TYPE):
		Card_Resource.MAGIC_TYPE.NORMAL:
			_cardType1 = "(Normal "
		#-------------------------------------------------------------------------------
		Card_Resource.MAGIC_TYPE.EQUIP:
			_cardType1 = "(Equip "
		#-------------------------------------------------------------------------------
		Card_Resource.MAGIC_TYPE.QUICK:
			_cardType1 = "(Quick "
		#-------------------------------------------------------------------------------
		Card_Resource.MAGIC_TYPE.INFINITE:
			_cardType1 = "(Infinite "
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	return _cardType1+_cardType2
#endregion
#-------------------------------------------------------------------------------
#Here are the Description Funcs.
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
#Here are the _READY Funcs.
#-------------------------------------------------------------------------------
#region SET TABLET
func SetStage():
	screen_size = get_viewport_rect().size
	#-------------------------------------------------------------------------------
	#LoadCardDatabase()
	SetPlayer(player1, player2)
	SetPlayer(player2, player1)
	#-------------------------------------------------------------------------------
	SetButton_Array(button_Array)
	SetButton(button_phase)
	#-------------------------------------------------------------------------------
	banner_panel.hide()
	phase_menu.hide()
	#-------------------------------------------------------------------------------
	Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
	nothing_released = func(): pass
	nothing_cancel = func(): pass
	#-------------------------------------------------------------------------------
	descriptionMenu.hide()
	#-------------------------------------------------------------------------------
	Draw_Cards(player1, 5)
	await Draw_Cards(player2, 5)
	#-------------------------------------------------------------------------------
	await StartPhase()
#-------------------------------------------------------------------------------
func SetButton_Array(_button_Array: Array[Button_Node]):
	for _b in _button_Array:
		SetButton(_b)
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
	_user.mainDeck.label.hide()
	_user.mainDeck.highlight_TextureRect.hide()
	#-------------------------------------------------------------------------------
	_user.extraDeck.highlighted = func(): Highlight_Deck_True(_user.extraDeck)
	_user.extraDeck.lowlighted = func(): Highlight_Deck_False(_user.extraDeck)
	_user.extraDeck.label.hide()
	_user.extraDeck.highlight_TextureRect.hide()
	#-------------------------------------------------------------------------------
	_user.grave.highlighted = func(): Highlight_Deck_True(_user.grave)
	_user.grave.lowlighted = func(): Highlight_Deck_False(_user.grave)
	_user.grave.label.hide()
	_user.grave.highlight_TextureRect.hide()
	#-------------------------------------------------------------------------------
	_user.removed.highlighted = func(): Highlight_Deck_True(_user.removed)
	_user.removed.lowlighted = func(): Highlight_Deck_False(_user.removed)
	_user.removed.label.hide()
	_user.removed.highlight_TextureRect.hide()
	#-------------------------------------------------------------------------------
	for _i in _user.monsterZone.size():
		var _monsterZone: CardSlot_Node = _user.monsterZone[_i]
		_monsterZone.highlighted = func(): Highlight_Cardslot_True(_monsterZone)
		_monsterZone.lowlighted = func(): Highlight_Cardslot_False(_monsterZone)
		_monsterZone.holding = func(): CardSlot_Node_PressHolding(_monsterZone)
		_monsterZone.highlight_TextureRect.hide()
		_monsterZone.summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
	for _i in _user.magicZone.size():
		var _magicZone: CardSlot_Node = _user.magicZone[_i]
		_magicZone.highlighted = func(): Highlight_Cardslot_True(_magicZone)
		_magicZone.lowlighted = func(): Highlight_Cardslot_False(_magicZone)
		_magicZone.holding = func(): CardSlot_Node_PressHolding(_magicZone)
		_magicZone.highlight_TextureRect.hide()
		_magicZone.summoning_TextureRect.hide()
#-------------------------------------------------------------------------------
func Draw_Cards(_player:Player_Node, _iMax: int):
	await get_tree().create_timer(0.5).timeout
	for _i in _iMax:
		await Draw_1_Card(_player)
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
	await get_tree().create_timer(0.15).timeout
#-------------------------------------------------------------------------------
func Update_hand_position(_hand:Hand_Node):
	#-------------------------------------------------------------------------------
	for _i:int in _hand.card_Node_Array.size():
		var _newPosition: Vector2 = Vector2(Calculate_card_position(_hand, _i), _hand.global_position.y)
		var _card:Card_Node = _hand.card_Node_Array[_i]
		_card.starting_position = _newPosition
		Animate_card_to_position(_card, _newPosition)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Calculate_card_position(_hand: Hand_Node, _i:int) -> float:
	var _total_width: float = (_hand.card_Node_Array.size()-1)*card_width
	var _x_offset: float = _hand.global_position.x+float(_i)*card_width-_total_width/2
	return _x_offset
#-------------------------------------------------------------------------------
func Animate_card_to_position(_card:Card_Node, _newPosition:Vector2):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card, "global_position", _newPosition, 0.1)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_hand:Hand_Node, _card:Card_Node):
	if(_card in _hand.card_Node_Array):
		_hand.card_Node_Array.erase(_card)
		Update_hand_position(_hand)
#endregion
#-------------------------------------------------------------------------------
#Here are the PHASE Funcs.
#-------------------------------------------------------------------------------
#region START_PHASE
func StartPhase():
	CommonPhase_Null()
	turnCounter += 1
	player1.turnCounter += 1
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.START_PHASE
	await Show_Banner("Your Turn")
	await Show_Banner("Start Phase")
	Set_SummonCounter(player1, 1)
	await Draw_1_Card(player1)
	#-------------------------------------------------------------------------------
	await MainPhase1()
#endregion
#-------------------------------------------------------------------------------
#region MAIN_PHASE_1
func MainPhase1():
	CommonPhase_Null()
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.MAIN_PHASE1
	await Show_Banner("Main Phase 1")
	#-------------------------------------------------------------------------------
	CommonPhase_Idle()
#endregion
#-------------------------------------------------------------------------------
#region BATTLE_PHASE
func BattlePhase():
	CommonPhase_Null()
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.BATTLE_PHASE
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	await Show_Banner("Battle Phase")
	#-------------------------------------------------------------------------------
	CommonPhase_Idle()
#endregion
#-------------------------------------------------------------------------------
#region MAIN_PHASE_2
func MainPhase2():
	CommonPhase_Null()
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.MAIN_PHASE2
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	await Show_Banner("Main Phase 2")
	#-------------------------------------------------------------------------------
	CommonPhase_Idle()
#endregion
#-------------------------------------------------------------------------------
#region END_PHASE
func EndPhase():
	CommonPhase_Null()
	#-------------------------------------------------------------------------------
	myPHASE_STATE = PHASE_STATE.END_PHASE
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
	await Show_Banner("End Phase")
	#-------------------------------------------------------------------------------
	await Turn_Opponent()
#-------------------------------------------------------------------------------
func Turn_Opponent():
	await Show_Banner("Opponent Turn", false)
	await Show_Banner("Start Phase", false)
	turnCounter += 1
	player2.turnCounter += 1
	Set_SummonCounter(player2, 1)
	await Draw_1_Card(player2)
	await Show_Banner("Main Phase 1", false)
	await Show_Banner("End Phase", false)
	StartPhase()
#endregion
#-------------------------------------------------------------------------------
#Here are the PHASE STATEMACHINE Funcs.
#-------------------------------------------------------------------------------
#region COMMON_PHASE - IDLE
func CommonPhase_Idle():
	myGAMEMENU_STATE = GAMEMENU_STATE.IDLE_STATE
	#-------------------------------------------------------------------------------
	Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
	button_phase.released = func(): CommonPhase_Exit_Idle_Enter_PhaseMenu()
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	CommonPhase_Idle_Player(player1)
	CommonPhase_Idle_Player(player2)
#-------------------------------------------------------------------------------
func CommonPhase_Idle_Player(_player: Player_Node):
	_player.mainDeck.released = func(): CommonPhase_Exit_Idle_Enter_DeckMenu(_player.mainDeck)
	_player.extraDeck.released = func():CommonPhase_Exit_Idle_Enter_DeckMenu(_player.extraDeck)
	_player.grave.released = func():CommonPhase_Exit_Idle_Enter_DeckMenu(_player.grave)
	_player.removed.released = func():CommonPhase_Exit_Idle_Enter_DeckMenu(_player.removed)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		var _monsterZone: CardSlot_Node = _player.monsterZone[_i]
		_monsterZone.released = func():CommonPhase_Exit_Idle_Enter_FieldMenu(_monsterZone)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		var _magicZone: CardSlot_Node = _player.magicZone[_i]
		_magicZone.released = func():CommonPhase_Exit_Idle_Enter_FieldMenu(_magicZone)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node.released = func(): CommonPhase_Exit_Idle_Enter_HandMenu(_card_Node)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_Exit_Idle_Enter_HandMenu(_cardNode: Card_Node):
	CommonPhase_HandMenu(_cardNode)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_Idle_Enter_FieldMenu(_cardSlot_Node: CardSlot_Node):
	CommonPhase_FieldMenu(_cardSlot_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_Idle_Enter_DeckMenu(_deck_Node: Deck_Node):
	CommonPhase_DeckMenu(_deck_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_Idle_Enter_PhaseMenu():
	CommonPhase_PhaseMenu()
#endregion
#-------------------------------------------------------------------------------
#region COMMON_PHASE - HAND MENU
func CommonPhase_HandMenu(_cardNode: Card_Node):
	myGAMEMENU_STATE = GAMEMENU_STATE.HAND_MENU
	#-------------------------------------------------------------------------------
	CommonPhase_HandMenu_Common(_cardNode)
#-------------------------------------------------------------------------------
func CommonPhase_HandMenu_Common(_cardNode: Card_Node):
	#-------------------------------------------------------------------------------
	Selected_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	CommonPhase_HandMenu_Player(player1, _cardNode)
	CommonPhase_HandMenu_Player(player2, _cardNode)
	#-------------------------------------------------------------------------------
	_cardNode.highlighted = func():pass
	_cardNode.lowlighted = func():pass
	_cardNode.released = func():pass
	#-------------------------------------------------------------------------------
	button_phase.released = func(): CommonPhase_Exit_HandMenu_Enter_PhaseMenu(_cardNode)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): CommonPhase_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode)
	nothing_released = func(): CommonPhase_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	if(myPHASE_STATE == PHASE_STATE.MAIN_PHASE1 or myPHASE_STATE == PHASE_STATE.MAIN_PHASE2):
		if(_cardNode.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.MAGIC_CARD):
			button_Array[0].global_position = _cardNode.global_position + Vector2(-50, -180)
			button_Array[0].icon.texture = button_Icon_Summon
			button_Array[0].label.text = "Activar"
			button_Array[0].released = func(): CommonPhase_Exit_HandMenu_Enter_SummonMenu(_cardNode, true)
			Show_Button_Node(button_Array[0])
			#-------------------------------------------------------------------------------
			button_Array[1].global_position = _cardNode.global_position + Vector2(50, -180)
			button_Array[1].icon.texture = button_Icon_Set
			button_Array[1].label.text = "Colocar"
			button_Array[1].released = func(): CommonPhase_Exit_HandMenu_Enter_SummonMenu(_cardNode, false)
			Show_Button_Node(button_Array[1])
		else:
			if(_cardNode.card_Class.user.summonCounter > 0):
				button_Array[0].global_position = _cardNode.global_position + Vector2(-50, -180)
				button_Array[0].icon.texture = button_Icon_Summon
				button_Array[0].label.text = "Convocar"
				button_Array[0].released = func(): CommonPhase_Exit_HandMenu_Enter_SummonMenu(_cardNode, true)
				Show_Button_Node(button_Array[0])
				#-------------------------------------------------------------------------------
				button_Array[1].global_position = _cardNode.global_position + Vector2(50, -180)
				button_Array[1].icon.texture = button_Icon_Set
				button_Array[1].label.text = "Colocar"
				button_Array[1].released = func(): CommonPhase_Exit_HandMenu_Enter_SummonMenu(_cardNode, false)
				Show_Button_Node(button_Array[1])
			#-------------------------------------------------------------------------------
			else:
				Hide_Buton_Node_Array(button_Array)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_HandMenu_Player(_player: Player_Node, _cardNode: Card_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): CommonPhase_Exit_HandMenu_Enter_DeckMenu(_cardNode, _player.mainDeck)
	_player.extraDeck.released = func(): CommonPhase_Exit_HandMenu_Enter_DeckMenu(_cardNode, _player.extraDeck)
	_player.grave.released = func(): CommonPhase_Exit_HandMenu_Enter_DeckMenu(_cardNode, _player.grave)
	_player.removed.released = func(): CommonPhase_Exit_HandMenu_Enter_DeckMenu(_cardNode, _player.removed)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		var _monsterZone: CardSlot_Node = _player.monsterZone[_i]
		_monsterZone.released = func(): CommonPhase_Exit_HandMenu_Enter_FieldMenu(_cardNode, _monsterZone)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		var _magicZone: CardSlot_Node = _player.magicZone[_i]
		_magicZone.released = func(): CommonPhase_Exit_HandMenu_Enter_FieldMenu(_cardNode, _magicZone)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node_InHand: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node_InHand.released = func(): CommonPhase_Exit_HandMenu_Enter_HandMenu(_cardNode, _card_Node_InHand)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_Idle(_cardNode: Card_Node):
	CommonPhase_Exit_HandMenu(_cardNode)
	CommonPhase_Idle()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_HandMenu(_last_cardNode: Card_Node, _new_cardNode: Card_Node):
	Restablish_Highlight_of_Card_in_Hand(_last_cardNode)
	#-------------------------------------------------------------------------------
	CommonPhase_HandMenu_Common(_new_cardNode)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_FieldMenu(_card_Node: Card_Node, _cardSlot_Node:CardSlot_Node):
	CommonPhase_Exit_HandMenu(_card_Node)
	CommonPhase_FieldMenu(_cardSlot_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_DeckMenu(_card_Node: Card_Node, deck_Node:Deck_Node):
	CommonPhase_Exit_HandMenu(_card_Node)
	CommonPhase_DeckMenu(deck_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_SummonMenu(_card_Node: Card_Node, _isInAttackPosition: bool):
	_card_Node.card_Class.isInAttackPosition = _isInAttackPosition
	CommonPhase_Exit_HandMenu(_card_Node)
	CommonPhase_SummonMenu(_card_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu(_card_Node: Card_Node):
	Selected_Card_False(_card_Node)
	HandCard_Canceled_Common(_card_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode: Card_Node):
	if(object_node.has(_cardNode)):
		Highlight_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	else:
		Selected_Card_False(_cardNode)
	#-------------------------------------------------------------------------------
	HandCard_Canceled_Common(_cardNode)
	CommonPhase_Idle()
#-------------------------------------------------------------------------------
func HandCard_Canceled_Common(_cardNode: Card_Node):
	_cardNode.highlighted = func(): Highlight_Card_True(_cardNode)
	_cardNode.lowlighted = func(): Highlight_Card_False(_cardNode)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_HandMenu_Enter_PhaseMenu(_card_node: Card_Node):
	Restablish_Highlight_of_Card_in_Hand(_card_node)
	Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
	CommonPhase_PhaseMenu()
#-------------------------------------------------------------------------------
func Restablish_Highlight_of_Card_in_Hand(_card_node: Card_Node):
	Selected_Card_False(_card_node)
	_card_node.highlighted = func(): Highlight_Card_True(_card_node)
	_card_node.lowlighted = func(): Highlight_Card_False(_card_node)
#endregion
#-------------------------------------------------------------------------------
#region COMMON_PHASE - FIELD MENU
func CommonPhase_FieldMenu(_cardSlot_node: CardSlot_Node):
	myGAMEMENU_STATE = GAMEMENU_STATE.FIELD_MENU
	CommonPhase_FieldMenu_Common(_cardSlot_node)
#-------------------------------------------------------------------------------
func CommonPhase_FieldMenu_Common(_cardSlot_node: CardSlot_Node):
	#-------------------------------------------------------------------------------
	CommonPhase_FieldMenu_Player(player1, _cardSlot_node)
	CommonPhase_FieldMenu_Player(player2, _cardSlot_node)
	_cardSlot_node.released = func():pass
	#-------------------------------------------------------------------------------
	button_phase.released = func(): CommonPhase_Exit_FieldMenu_Enter_PhaseMenu(_cardSlot_node)
	#-------------------------------------------------------------------------------
	Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node)
	nothing_released = func(): CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node)
	#-------------------------------------------------------------------------------
	match(myPHASE_STATE):
		#-------------------------------------------------------------------------------
		PHASE_STATE.MAIN_PHASE1:
			match(_cardSlot_node.myZONE_TYPE):
				CardSlot_Node.ZONE_TYPE.MONSTER_ZONE:
					if(_cardSlot_node.card_in_slot != null):
						button_Array[0].global_position = _cardSlot_node.global_position + Vector2(0, -90)
						button_Array[0].icon.texture = button_Icon_position
						button_Array[0].label.text = "Change\nPosition"
						button_Array[0].released = func(): pass
						Show_Button_Node(button_Array[0])
						#-------------------------------------------------------------------------------
						nothing_cancel = func(): CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node)
						nothing_released = func(): CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node)
					#-------------------------------------------------------------------------------
					else:
						Hide_Buton_Node_Array(button_Array)
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				CardSlot_Node.ZONE_TYPE.MAGIC_ZONE:
					Hide_Buton_Node_Array(button_Array)
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		PHASE_STATE.BATTLE_PHASE:
			#-------------------------------------------------------------------------------
			match(_cardSlot_node.myZONE_TYPE):
				CardSlot_Node.ZONE_TYPE.MONSTER_ZONE:
					if(_cardSlot_node.card_in_slot != null):
						button_Array[0].global_position = _cardSlot_node.global_position + Vector2(0, -90)
						button_Array[0].icon.texture = button_Icon_attack
						button_Array[0].label.text = "Atacar"
						button_Array[0].released = func(): pass
						Show_Button_Node(button_Array[0])
						#-------------------------------------------------------------------------------
						nothing_cancel = func(): CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node)
						nothing_released = func(): CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node)
					#-------------------------------------------------------------------------------
					else:
						Hide_Buton_Node_Array(button_Array)
					#-------------------------------------------------------------------------------
				#-------------------------------------------------------------------------------
				CardSlot_Node.ZONE_TYPE.MAGIC_ZONE:
					Hide_Buton_Node_Array(button_Array)
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_FieldMenu_Player(_player: Player_Node, _cardSlot_node: CardSlot_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): CommonPhase_Exit_FieldMenu_Enter_DeckMenu(_cardSlot_node, _player.mainDeck)
	_player.extraDeck.released = func(): CommonPhase_Exit_FieldMenu_Enter_DeckMenu(_cardSlot_node, _player.extraDeck)
	_player.grave.released = func(): CommonPhase_Exit_FieldMenu_Enter_DeckMenu(_cardSlot_node, _player.grave)
	_player.removed.released = func(): CommonPhase_Exit_FieldMenu_Enter_DeckMenu(_cardSlot_node, _player.removed)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		var _monsterZone: CardSlot_Node = _player.monsterZone[_i]
		_monsterZone.released = func(): CommonPhase_Exit_FieldMenu_Enter_FieldMenu(_cardSlot_node, _monsterZone)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		var _magicZone: CardSlot_Node = _player.magicZone[_i]
		_magicZone.released = func(): CommonPhase_Exit_FieldMenu_Enter_FieldMenu(_cardSlot_node, _magicZone)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node_InHand: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node_InHand.released = func(): CommonPhase_Exit_FieldMenu_Enter_Hand(_cardSlot_node, _card_Node_InHand)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_Exit_FieldMenu_Enter_Idle(_cardSlot_node: CardSlot_Node):
	CommonPhase_Exit_FieldMenu(_cardSlot_node)
	CommonPhase_Idle()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_FieldMenu_Enter_Hand(_cardSlot_node: CardSlot_Node, _card_in_hand: Card_Node):
	CommonPhase_Exit_FieldMenu(_cardSlot_node)
	CommonPhase_HandMenu(_card_in_hand)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_FieldMenu_Enter_DeckMenu(_cardSlot_node: CardSlot_Node, _deck_Node: Deck_Node):
	CommonPhase_Exit_FieldMenu(_cardSlot_node)
	CommonPhase_DeckMenu(_deck_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_FieldMenu_Enter_FieldMenu(_last_cardSlot_node: CardSlot_Node, _new_cardSlot_node: CardSlot_Node):
	CommonPhase_FieldMenu_Common(_new_cardSlot_node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_FieldMenu_Enter_PhaseMenu(_cardSlot_node: CardSlot_Node):
	CommonPhase_Exit_FieldMenu(_cardSlot_node)
	CommonPhase_PhaseMenu()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_FieldMenu(_cardSlot_node: CardSlot_Node):
	Hide_Buton_Node_Array(button_Array)
#endregion
#-------------------------------------------------------------------------------
#region COMMON_PHASE - DECK MENU
func CommonPhase_DeckMenu(_deck_node: Deck_Node):
	myGAMEMENU_STATE = GAMEMENU_STATE.DECK_MENU
	CommonPhase_DeckMenu_Common(_deck_node)
#-------------------------------------------------------------------------------
func CommonPhase_DeckMenu_Common(_deck_node: Deck_Node):
	#-------------------------------------------------------------------------------
	CommonPhase_DeckMenu_Player(player1, _deck_node)
	CommonPhase_DeckMenu_Player(player2, _deck_node)
	_deck_node.released = func():pass
	#-------------------------------------------------------------------------------
	button_phase.released = func(): CommonPhase_Exit_DeckMenu_Enter_PhaseMenu(_deck_node)
	#-------------------------------------------------------------------------------
	Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): CommonPhase_Exit_DeckMenu_Enter_Idle(_deck_node)
	nothing_released = func(): CommonPhase_Exit_DeckMenu_Enter_Idle(_deck_node)
	#-------------------------------------------------------------------------------
	match(myPHASE_STATE):
		#-------------------------------------------------------------------------------
		PHASE_STATE.BATTLE_PHASE:
			#-------------------------------------------------------------------------------
			match(_deck_node.myDECK_TYPE):
				Deck_Node.DECK_TYPE.MAIN_DECK:
					pass
				#-------------------------------------------------------------------------------
				Deck_Node.DECK_TYPE.EXTRA_DECK:
					pass
				#-------------------------------------------------------------------------------
				Deck_Node.DECK_TYPE.GRAVE_DECK:
					pass
				#-------------------------------------------------------------------------------
				Deck_Node.DECK_TYPE.REMOVE_DECK:
					pass
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_DeckMenu_Player(_player: Player_Node, _deck_node: Deck_Node):
	_player.mainDeck.released = func(): CommonPhase_Exit_DeckMenu_Enter_DeckMenu(_deck_node, _player.mainDeck)
	_player.extraDeck.released = func(): CommonPhase_Exit_DeckMenu_Enter_DeckMenu(_deck_node, _player.mainDeck)
	_player.grave.released = func(): CommonPhase_Exit_DeckMenu_Enter_DeckMenu(_deck_node, _player.mainDeck)
	_player.removed.released = func(): CommonPhase_Exit_DeckMenu_Enter_DeckMenu(_deck_node, _player.mainDeck)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		var _monsterZone: CardSlot_Node = _player.monsterZone[_i]
		_monsterZone.released = func(): CommonPhase_Exit_DeckMenu_Enter_FieldMenu(_deck_node, _monsterZone)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		var _magicZone: CardSlot_Node = _player.magicZone[_i]
		_magicZone.released = func(): CommonPhase_Exit_DeckMenu_Enter_FieldMenu(_deck_node, _magicZone)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node_InHand: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node_InHand.released = func(): CommonPhase_Exit_DeckMenu_Enter_Hand(_deck_node, _card_Node_InHand)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_Exit_DeckMenu_Enter_Idle(_deck_node: Deck_Node):
	CommonPhase_Exit_DeckMenu(_deck_node)
	CommonPhase_Idle()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_DeckMenu_Enter_Hand(_deck_node: Deck_Node, _card_in_hand: Card_Node):
	CommonPhase_Exit_DeckMenu(_deck_node)
	CommonPhase_HandMenu(_card_in_hand)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_DeckMenu_Enter_FieldMenu(_deck_node: Deck_Node, _cardSlot_Node: CardSlot_Node):
	CommonPhase_Exit_DeckMenu(_deck_node)
	CommonPhase_FieldMenu(_cardSlot_Node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_DeckMenu_Enter_DeckMenu(_last_deck_node: Deck_Node, _new_deck_node: Deck_Node):
	CommonPhase_Exit_DeckMenu(_last_deck_node)
	CommonPhase_DeckMenu_Common(_new_deck_node)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_DeckMenu_Enter_PhaseMenu(_deck_node: Deck_Node):
	CommonPhase_Exit_DeckMenu(_deck_node)
	CommonPhase_PhaseMenu()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_DeckMenu(_deck_node: Deck_Node):
	Hide_Buton_Node_Array(button_Array)
#endregion
#-------------------------------------------------------------------------------
#region COMMON_PHASE - SUMMON MENU
func CommonPhase_SummonMenu(_card_Node:Card_Node):
	myGAMEMENU_STATE = GAMEMENU_STATE.SUMMON_MENU
	#-------------------------------------------------------------------------------
	Hide_Buton_Node_Array(button_Array)
	#-------------------------------------------------------------------------------
	button_phase.released = func(): CommonPhase_Exit_SummonMenu_Enter_PhaseMenu(_card_Node)
	#-------------------------------------------------------------------------------
	var _user_magicZone: Array[CardSlot_Node] = _card_Node.card_Class.user.magicZone
	var _user_monsterZone: Array[CardSlot_Node] = _card_Node.card_Class.user.monsterZone
	#-------------------------------------------------------------------------------
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.MAGIC_CARD):
		for _i in _user_magicZone.size():
			if(_user_magicZone[_i].card_in_slot == null):
				_user_magicZone[_i].summoning_TextureRect.show()
				_user_magicZone[_i].released = func(): CommonPhase_SummonMenu_ActiveteCard(_user_magicZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				_user_magicZone[_i].released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in _user_monsterZone.size():
			_user_monsterZone[_i].released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		for _i in _user_monsterZone.size():
			if(_user_monsterZone[_i].card_in_slot == null):
				_user_monsterZone[_i].summoning_TextureRect.show()
				_user_monsterZone[_i].released = func(): CommonPhase_SummonMenu_SummonMonster(_user_monsterZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				_user_monsterZone[_i].released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in _user_magicZone.size():
			_user_magicZone[_i].released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	var _oponent_magicZone: Array[CardSlot_Node] = _card_Node.card_Class.opponent.magicZone
	var _oponent_monsterZone: Array[CardSlot_Node] = _card_Node.card_Class.opponent.monsterZone
	#-------------------------------------------------------------------------------
	for _i in _oponent_monsterZone.size():
		_oponent_monsterZone[_i].released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	for _i in _oponent_magicZone.size():
		_oponent_magicZone[_i].released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	nothing_released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	nothing_cancel = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	CommonPhase_SummonMenu_Player(player1, _card_Node)
	CommonPhase_SummonMenu_Player(player2, _card_Node)
#-------------------------------------------------------------------------------
func CommonPhase_SummonMenu_Player(_player:Player_Node, _card_Node: Card_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.extraDeck.released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.grave.released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.removed.released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node_inHand: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node_inHand.released = func(): CommonPhase_Exit_SummonMenu_Enter_HandMenu_2(_card_Node_inHand, _card_Node)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_SummonMenu_SummonMonster(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	_card_Node.card_Class.NormalSummon()
	#-------------------------------------------------------------------------------
	Set_SummonCounter_Minus(_card_Node.card_Class.user)
	CommonPhase_Exit_SummonMenu_Enter_Idle(_cardSlot_Node, _card_Node)
	Desactivate_MonsterZone(_card_Node.card_Class.user)
#-------------------------------------------------------------------------------
func CommonPhase_SummonMenu_ActiveteCard(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	_card_Node.card_Class.NormalActivation()
	#-------------------------------------------------------------------------------
	CommonPhase_Exit_SummonMenu_Enter_Idle(_cardSlot_Node, _card_Node)
	Desactivate_MagicZone(_card_Node.card_Class.user)
#-------------------------------------------------------------------------------
func CommonPhase_Exit_SummonMenu_Enter_Idle(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MoveCard_fromHand_toSlot(_card_Node, _card_Node.card_Class.user.hand, _cardSlot_Node)
	CommonPhase_Idle()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_SummonMenu_Enter_HandMenu_1(_card_Node: Card_Node):
	CommonPhase_HandMenu(_card_Node)
	Deselect_Zones(_card_Node)
	#-------------------------------------------------------------------------------
func CommonPhase_Exit_SummonMenu_Enter_HandMenu_2(_card_Node1: Card_Node, _card_Node2: Card_Node):
	CommonPhase_HandMenu(_card_Node1)
	Deselect_Zones(_card_Node2)
#-------------------------------------------------------------------------------
func Deselect_Zones(_card_Node: Card_Node):
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.MAGIC_CARD):
		Desactivate_MagicZone(_card_Node.card_Class.user)
	#-------------------------------------------------------------------------------
	else:
		Desactivate_MonsterZone(_card_Node.card_Class.user)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Desactivate_MagicZone(_player: Player_Node):
	for _i in _player.magicZone.size():
		_player.magicZone[_i].summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Desactivate_MonsterZone(_player: Player_Node):
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MoveCard_fromHand_toSlot(_card_node: Card_Node, _hand: Hand_Node, _cardSlot_Node:CardSlot_Node):
	_card_node.canBePressed = false
	_cardSlot_Node.card_in_slot = _card_node
	_hand.card_Node_Array.erase(_card_node)
	Update_hand_position(_hand)
	#-------------------------------------------------------------------------------
	var _timer: float = 0.2
	var _size: float = 0.75
	#-------------------------------------------------------------------------------
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, 0), _timer)
	_tween.tween_property(_card_node.offset_Node2D, "scale", Vector2(_size, _size), _timer)
	if(_card_node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.MAGIC_CARD):
		if(_card_node.card_Class.isInAttackPosition):
			pass
		else:
			_card_node.frame_Node.back.show()
			_card_node.frame_Node.back.self_modulate.a = 0.7
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
#region COMMON_PHASE - PHASE MENU
func CommonPhase_Exit_SummonMenu_Enter_PhaseMenu(_card_node: Card_Node):
	Deselect_Zones(_card_node)
	CommonPhase_PhaseMenu()
#-------------------------------------------------------------------------------
func CommonPhase_PhaseMenu():
	myGAMEMENU_STATE = GAMEMENU_STATE.PHASE_MENU
	#-------------------------------------------------------------------------------
	phase_menu.show()
	myGAME_STATE = GAME_STATE.DESCRIPTION_MENU
	#-------------------------------------------------------------------------------
	match(myPHASE_STATE):
		PHASE_STATE.MAIN_PHASE1:
			#-------------------------------------------------------------------------------
			phase_menu.button_startPhase.remove_theme_color_override("font_color")
			phase_menu.button_mainPhase1.add_theme_color_override("font_color", player1_color)
			phase_menu.button_battlePhase.remove_theme_color_override("font_color")
			phase_menu.button_mainPhase2.remove_theme_color_override("font_color")
			phase_menu.button_endPhase.remove_theme_color_override("font_color")
			#-------------------------------------------------------------------------------
			phase_menu.button_startPhase.disabled = true
			Connect_PressedSignal_InButton(phase_menu.button_mainPhase1, func():CommonPhase_Exit_PhaseMenu_Enter_Idle())
			if(turnCounter > 1):
				Connect_PressedSignal_InButton(phase_menu.button_battlePhase, func():BattlePhase())
			#-------------------------------------------------------------------------------
			else:
				phase_menu.button_battlePhase.disabled = true
			#-------------------------------------------------------------------------------
			phase_menu.button_mainPhase2.disabled = true
			Connect_PressedSignal_InButton(phase_menu.button_endPhase, func():EndPhase())
			Connect_PressedSignal_InButton(phase_menu.button_cancel, func():CommonPhase_Exit_PhaseMenu_Enter_Idle())
		#-------------------------------------------------------------------------------
		PHASE_STATE.BATTLE_PHASE:
			#-------------------------------------------------------------------------------
			phase_menu.button_startPhase.remove_theme_color_override("font_color")
			phase_menu.button_mainPhase1.remove_theme_color_override("font_color")
			phase_menu.button_battlePhase.add_theme_color_override("font_color", player1_color)
			phase_menu.button_mainPhase2.remove_theme_color_override("font_color")
			phase_menu.button_endPhase.remove_theme_color_override("font_color")
			#-------------------------------------------------------------------------------
			phase_menu.button_startPhase.disabled = true
			phase_menu.button_mainPhase1.disabled = true
			Connect_PressedSignal_InButton(phase_menu.button_battlePhase, func():CommonPhase_Exit_PhaseMenu_Enter_Idle())
			Connect_PressedSignal_InButton(phase_menu.button_mainPhase2, func():MainPhase2())
			Connect_PressedSignal_InButton(phase_menu.button_endPhase, func():EndPhase())
			Connect_PressedSignal_InButton(phase_menu.button_cancel, func():CommonPhase_Exit_PhaseMenu_Enter_Idle())
		#-------------------------------------------------------------------------------
		PHASE_STATE.MAIN_PHASE2:
			#-------------------------------------------------------------------------------
			phase_menu.button_startPhase.remove_theme_color_override("font_color")
			phase_menu.button_mainPhase1.remove_theme_color_override("font_color")
			phase_menu.button_battlePhase.remove_theme_color_override("font_color")
			phase_menu.button_mainPhase2.add_theme_color_override("font_color", player1_color)
			phase_menu.button_endPhase.remove_theme_color_override("font_color")
			#-------------------------------------------------------------------------------
			phase_menu.button_startPhase.disabled = true
			phase_menu.button_mainPhase1.disabled = true
			phase_menu.button_battlePhase.disabled = true
			Connect_PressedSignal_InButton(phase_menu.button_mainPhase2, func():CommonPhase_Exit_PhaseMenu_Enter_Idle())
			Connect_PressedSignal_InButton(phase_menu.button_endPhase, func():EndPhase())
			Connect_PressedSignal_InButton(phase_menu.button_cancel, func():CommonPhase_Exit_PhaseMenu_Enter_Idle())
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	nothing_cancel = func():CommonPhase_Exit_PhaseMenu_Enter_Idle()
#-------------------------------------------------------------------------------
func CommonPhase_Exit_PhaseMenu_Enter_Idle():
	#-------------------------------------------------------------------------------
	match(myPHASE_STATE):
		PHASE_STATE.MAIN_PHASE1:
			phase_menu.button_startPhase.disabled = false
			Disconnect_Signal(phase_menu.button_mainPhase1.pressed)
			phase_menu.button_battlePhase.disabled = false
			Disconnect_Signal(phase_menu.button_battlePhase.pressed)
			phase_menu.button_mainPhase2.disabled = false
			Disconnect_Signal(phase_menu.button_cancel.pressed)
		#-------------------------------------------------------------------------------
		PHASE_STATE.BATTLE_PHASE:
			phase_menu.button_startPhase.disabled = false
			phase_menu.button_mainPhase1.disabled = false
			Disconnect_Signal(phase_menu.button_battlePhase.pressed)
			Disconnect_Signal(phase_menu.button_mainPhase2.pressed)
			Disconnect_Signal(phase_menu.button_cancel.pressed)
		#-------------------------------------------------------------------------------
		PHASE_STATE.MAIN_PHASE2:
			phase_menu.button_startPhase.disabled = false
			phase_menu.button_battlePhase.disabled = false
			phase_menu.button_mainPhase2.disabled = false
			Disconnect_Signal(phase_menu.button_mainPhase2.pressed)
			Disconnect_Signal(phase_menu.button_cancel.pressed)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	CommonPhase_Idle()
	phase_menu.hide()
	myGAME_STATE = GAME_STATE.GAMEPLAY
#endregion
#-------------------------------------------------------------------------------
#region COMMON_PHASE - NULL (When I need the cards to do nothing between Phases)
func CommonPhase_Null():
	button_phase.released = func(): pass
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	CommonPhase_Null_Player(player1)
	CommonPhase_Null_Player(player2)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func CommonPhase_Null_Player(_player: Player_Node):
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
	#-------------------------------------------------------------------------------
	for _dictionary in _dictionaryArray:
		_signal.disconnect(_dictionary["callable"])
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Set_SummonCounter(_player:Player_Node, _i:int):
	_player.summonCounter = _i
	Set_SummonCounter_Common(_player, _i)
#-------------------------------------------------------------------------------
func Set_SummonCounter_Minus(_player:Player_Node):
	_player.summonCounter -= 1
	Set_SummonCounter_Common(_player, _player.summonCounter)
#-------------------------------------------------------------------------------
func Set_SummonCounter_Common(_player:Player_Node, _i:int):
	_player.label_Summons.text = str(_i) + "/1 NS"
#-------------------------------------------------------------------------------
func Show_Banner(_s:String, _isPlayer1:bool = true):
	if(_isPlayer1):
		banner_label.add_theme_color_override("font_color", player1_color)
	else:
		banner_label.add_theme_color_override("font_color", player2_color)
	banner_label.text = _s
	banner_panel.show()
	await get_tree().create_timer(1).timeout
	banner_panel.hide()
#endregion
