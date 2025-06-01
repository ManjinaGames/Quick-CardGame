extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum GAME_STATE{GAMEPLAY, DESCRIPTION_MENU}
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
var myMAINPHASE1_STATE: MAINPHASE1_STATE = MAINPHASE1_STATE.IDLE
#-------------------------------------------------------------------------------
var object_node: Array[Object_Node]
var highlighted_object_node: Object_Node = null
var selected_object_node: Object_Node = null
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
	_s += "MAINPHASE1_STATE: "+str(MAINPHASE1_STATE.keys()[myMAINPHASE1_STATE])+"\n"
	_s += "______________________________________\n"
	_s += "Mouse Counter: "+str(leftMouseCounter)+"\n"
	_s += "Is Mouse Pressed: "+str(isLeftMousePressed)+"\n"
	_s += "______________________________________\n"
	_s += "Selected Object_Node:\n"
	_s += "---> "+str(selected_object_node)+"\n"
	_s += "Highlighted Object_Node:\n"
	_s += "---> "+str(highlighted_object_node)+"\n"
	_s += "Object_Nodes:\n"
	for _i in object_node.size():
		_s += "---> "+str(object_node[_i])+"\n"
	_s += "______________________________________\n"
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
	#-------------------------------------------------------------------------------
	banner_panel.hide()
	#-------------------------------------------------------------------------------
	button1.highlight_TextureRect.hide()
	button2.highlight_TextureRect.hide()
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
	await MainPhase1()
#-------------------------------------------------------------------------------
func SetButton(_button: Button_Node):
	_button.highlighted = func(): Highlight_Button_True(_button)
	_button.lowlighted = func(): Highlight_Button_False(_button)
#-------------------------------------------------------------------------------
func SetPlayer(_user:Player_Node, _opponent:Player_Node):
	LoadDeck(_user)
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
		var _card_Node: Card_Node = Draw_1_Card(_player)
		Update_hand_position(_player.hand)
		await get_tree().create_timer(0.15).timeout
#-------------------------------------------------------------------------------
func Draw_1_Card(_player:Player_Node) -> Card_Node:
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
	return _card_Node
#-------------------------------------------------------------------------------
func Add_card_to_hand(_card_Node:Card_Node):
	if(_card_Node not in player1.hand.card_Node_Array):
		player1.hand.card_Node_Array.push_back(_card_Node)
		Update_hand_position(player1.hand)
	else:
		Animate_card_to_position(_card_Node, _card_Node.starting_position)
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
#region START PHASE
func StartPhase():
	await Show_Banner("Start Phase")
	var _card_Node: Card_Node = Draw_1_Card(player1)
	Update_hand_position(player1.hand)
	await get_tree().create_timer(0.15).timeout
#-------------------------------------------------------------------------------
func Show_Banner(_s:String):
	banner_label.text = _s
	banner_panel.show()
	await get_tree().create_timer(1).timeout
	banner_panel.hide()
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE 1
func MainPhase1():
	await Show_Banner("Main Phase 1")
	MainPhase1_Idle()
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
#region MAIN PHASE 1 - IDLE
func MainPhase1_Idle():
	myMAINPHASE1_STATE = MAINPHASE1_STATE.IDLE
	print("Enter 'MAINPHASE1_STATE.IDLE'")
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	nothing_released = func():pass
	nothing_cancel = func():pass
	#-------------------------------------------------------------------------------
	MainPhase1_Idle_Player(player1)
	MainPhase1_Idle_Player(player2)
#-------------------------------------------------------------------------------
func MainPhase1_Idle_Player(_player: Player_Node):
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
		_card_Node.released = func(): MainPhase1_Exit_Idle_Enter_HandMenu(_card_Node)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase1_Exit_Idle_Enter_HandMenu(_cardNode: Card_Node):
	MainPhase1_HandMenu(_cardNode)
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE 1 - HAND MENU
func MainPhase1_HandMenu(_cardNode: Card_Node):
	myMAINPHASE1_STATE = MAINPHASE1_STATE.HAND_MENU
	print("Enter 'MAINPHASE1_STATE.HAND_MENU'")
	#-------------------------------------------------------------------------------
	MainPhase1_HandMenu_Common(_cardNode)
#-------------------------------------------------------------------------------
func MainPhase1_HandMenu_Common(_cardNode: Card_Node):
	selected_object_node = _cardNode
	#-------------------------------------------------------------------------------
	Selected_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	_cardNode.highlighted = func():pass
	_cardNode.lowlighted = func():pass
	_cardNode.released = func():pass
	#-------------------------------------------------------------------------------
	button1.global_position = _cardNode.global_position + Vector2(-35, -150)
	button2.global_position = _cardNode.global_position + Vector2(35, -150)
	#-------------------------------------------------------------------------------
	button1.released = func(): MainPhase1_Exit_HandMenu_Enter_SummonMenu(_cardNode)
	button2.released = func(): MainPhase1_Exit_HandMenu_Enter_SummonMenu(_cardNode)
	#-------------------------------------------------------------------------------
	Show_Button_Node(button1)
	Show_Button_Node(button2)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): MainPhase1_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode)
	nothing_released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	HandCard_Selected_Player(player1, _cardNode)
	HandCard_Selected_Player(player2, _cardNode)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func HandCard_Selected_Player(_player: Player_Node, _cardNode: Card_Node):
	_player.mainDeck.released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.extraDeck.released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.grave.released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	_player.removed.released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].released = func(): MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		if(_player.hand.card_Node_Array[_i] != _cardNode):
			var _card_Node_InHand: Card_Node = _player.hand.card_Node_Array[_i]
			_card_Node_InHand.released = func(): MainPhase1_HandMenu_2(_card_Node_InHand, _cardNode)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase1_HandMenu_2(_cardNode1: Card_Node, _cardNode2: Card_Node):
	Selected_Card_False(_cardNode2)
	_cardNode2.highlighted = func(): Highlight_Card_True(_cardNode2)
	_cardNode2.lowlighted = func(): Highlight_Card_False(_cardNode2)
	#-------------------------------------------------------------------------------
	MainPhase1_HandMenu_Common(_cardNode1)
#-------------------------------------------------------------------------------
func MainPhase1_Exit_HandMenu_Enter_Idle(_cardNode: Card_Node):
	Selected_Card_False(_cardNode)
	HandCard_Canceled_Common(_cardNode)
	MainPhase1_Idle()
#-------------------------------------------------------------------------------
func MainPhase1_Exit_HandMenu_Enter_Idle_by_Cancel(_cardNode: Card_Node):
	if(object_node.has(_cardNode)):
		Highlight_Card_True(_cardNode)
	#-------------------------------------------------------------------------------
	else:
		Selected_Card_False(_cardNode)
	#-------------------------------------------------------------------------------
	HandCard_Canceled_Common(_cardNode)
	MainPhase1_Idle()
#-------------------------------------------------------------------------------
func MainPhase1_Exit_HandMenu_Enter_SummonMenu(_cardNode: Card_Node):
	Selected_Card_False(_cardNode)
	HandCard_Canceled_Common(_cardNode)
	MainPhase1_SummonMenu(_cardNode)
#-------------------------------------------------------------------------------
func HandCard_Canceled_Common(_cardNode: Card_Node):
	selected_object_node = null
	#-------------------------------------------------------------------------------
	_cardNode.highlighted = func(): Highlight_Card_True(_cardNode)
	_cardNode.lowlighted = func(): Highlight_Card_False(_cardNode)
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE 1 - SUMMON MENU
func MainPhase1_SummonMenu(_card_Node:Card_Node):
	myMAINPHASE1_STATE = MAINPHASE1_STATE.SUMMON_MENU
	print("Enter 'MAINPHASE1_STATE.SUMMON_MENU'")
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		for _i in player1.magicZone.size():
			if(player1.magicZone[_i].card_in_slot == null):
				player1.magicZone[_i].summoning_TextureRect.show()
				player1.magicZone[_i].released = func(): MainPhase1_SummonMenu_ActiveteCard(player1.magicZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				player1.magicZone[_i].released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in player1.monsterZone.size():
			player1.monsterZone[_i].released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	else:
		for _i in player1.monsterZone.size():
			if(player1.monsterZone[_i].card_in_slot == null):
				player1.monsterZone[_i].summoning_TextureRect.show()
				player1.monsterZone[_i].released = func(): MainPhase1_SummonMenu_SummonMonster(player1.monsterZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				player1.monsterZone[_i].released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in player1.magicZone.size():
			player1.magicZone[_i].released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	for _i in player2.monsterZone.size():
		player2.monsterZone[_i].released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	for _i in player2.magicZone.size():
		player2.magicZone[_i].released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	nothing_released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	nothing_cancel = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	MainPhase1_SummonMenu_Player(player1, _card_Node)
	MainPhase1_SummonMenu_Player(player2, _card_Node)
#-------------------------------------------------------------------------------
func MainPhase1_SummonMenu_Player(_player:Player_Node, _card_Node: Card_Node):
	#-------------------------------------------------------------------------------
	_player.mainDeck.released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.extraDeck.released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.grave.released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	_player.removed.released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node)
	#-------------------------------------------------------------------------------
	for _i in _player.hand.card_Node_Array.size():
		var _card_Node_inHand: Card_Node = _player.hand.card_Node_Array[_i]
		_card_Node_inHand.released = func(): MainPhase1_Exit_SummonMenu_Enter_HandMenu_2(_card_Node_inHand, _card_Node)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase1_SummonMenu_SummonMonster(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MainPhase1_Exit_SummonMenu_Enter_Idle(_cardSlot_Node, _card_Node)
	Desactivate_MonsterZone()
#-------------------------------------------------------------------------------
func MainPhase1_SummonMenu_ActiveteCard(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MainPhase1_Exit_SummonMenu_Enter_Idle(_cardSlot_Node, _card_Node)
	Desactivate_MagicZone()
#-------------------------------------------------------------------------------
func MainPhase1_Exit_SummonMenu_Enter_Idle(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MoveCard_fromHand_toSlot(_card_Node, player1.hand, _cardSlot_Node)
	MainPhase1_Idle()
#-------------------------------------------------------------------------------
func MainPhase1_Exit_SummonMenu_Enter_HandMenu_1(_card_Node: Card_Node):
	MainPhase1_HandMenu(_card_Node)
	Deselect_Zones(_card_Node)
	#-------------------------------------------------------------------------------
func MainPhase1_Exit_SummonMenu_Enter_HandMenu_2(_card_Node1: Card_Node, _card_Node2: Card_Node):
	MainPhase1_HandMenu(_card_Node1)
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
	_tween.tween_property(_card_node, "global_position", _cardSlot_Node.global_position, _timer)
	_tween.set_parallel(false)
	_tween.tween_callback(func():
		_card_node.z_index = 0
	)
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
