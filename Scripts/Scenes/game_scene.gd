extends Node2D
class_name GameScene
#-------------------------------------------------------------------------------
enum GAME_STATE{GAMEPLAY, DESCRIPTION_MENU}
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
	if(myGAME_STATE != GAME_STATE.GAMEPLAY):
		return
	#-------------------------------------------------------------------------------
	Organize_Area2Ds()
	Debug_Info()
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
func Highlight_Card_True(_player:Player_Node, _card_node: Card_Node):
	var _tween: Tween = get_tree().create_tween()
	_tween.set_parallel()
	_tween.tween_property(_card_node.offset_Node2D, "position", Vector2(0, _player.card_pos_y_offset), 0.05)
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
func LoadDeck(_player: Player_Node):
	#-------------------------------------------------------------------------------
	for _cardResource in _player.mainDeck.card_Resource:
		var _card_Class: Card_Class = _cardResource.card_Class.new() as Card_Class
		_card_Class.card_Resource = _cardResource
		_player.mainDeck.card_Class.append(_card_Class)
	#-------------------------------------------------------------------------------
	_player.mainDeck.card_Class.shuffle()
	var _null: Callable = func():pass
	_player.mainDeck.released = func():pass
#-------------------------------------------------------------------------------
func GetResource_Name(_resource: Card_Resource) -> String:
	return _resource.resource_path.get_file().trim_suffix('.tres')
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
	SetPlayer(player1)
	SetPlayer(player2)
	#-------------------------------------------------------------------------------
	SetButton(button1)
	SetButton(button2)
	#-------------------------------------------------------------------------------
	banner_panel.hide()
	#-------------------------------------------------------------------------------
	button1.highlight_TextureRect.hide()
	button2.highlight_TextureRect.hide()
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
func SetPlayer(_player:Player_Node):
	LoadDeck(_player)
	#-------------------------------------------------------------------------------
	_player.mainDeck.maxDeckNum = _player.mainDeck.card_Class.size()
	#-------------------------------------------------------------------------------
	SetDeckNumber1(_player.mainDeck)
	SetDeckNumber1(_player.extraDeck)
	SetDeckNumber2(_player.grave)
	SetDeckNumber2(_player.removed)
	#-------------------------------------------------------------------------------
	_player.mainDeck.highlighted = func(): Highlight_Deck_True(_player.mainDeck)
	_player.mainDeck.lowlighted = func(): Highlight_Deck_False(_player.mainDeck)
	#-------------------------------------------------------------------------------
	_player.extraDeck.highlighted = func(): Highlight_Deck_True(_player.extraDeck)
	_player.extraDeck.lowlighted = func(): Highlight_Deck_False(_player.extraDeck)
	#-------------------------------------------------------------------------------
	_player.grave.highlighted = func(): Highlight_Deck_True(_player.grave)
	_player.grave.lowlighted = func(): Highlight_Deck_False(_player.grave)
	#-------------------------------------------------------------------------------
	_player.removed.highlighted = func(): Highlight_Deck_True(_player.removed)
	_player.removed.lowlighted = func(): Highlight_Deck_False(_player.removed)
	#-------------------------------------------------------------------------------
	for _i in _player.monsterZone.size():
		_player.monsterZone[_i].highlighted = func(): Highlight_Cardslot_True(_player.monsterZone[_i])
		_player.monsterZone[_i].lowlighted = func(): Highlight_Cardslot_False(_player.monsterZone[_i])
	#-------------------------------------------------------------------------------
	for _i in _player.magicZone.size():
		_player.magicZone[_i].highlighted = func(): Highlight_Cardslot_True(_player.magicZone[_i])
		_player.magicZone[_i].lowlighted = func(): Highlight_Cardslot_False(_player.magicZone[_i])
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Draw_Cards(_player:Player_Node, _iMax: int):
	await get_tree().create_timer(0.5).timeout
	for _i in _iMax:
		var _card_Node: Card_Node = Draw_1_Card(_player, func():pass)
		Update_hand_position(_player)
		await get_tree().create_timer(0.15).timeout
#-------------------------------------------------------------------------------
func Draw_1_Card(_player:Player_Node, _callable: Callable) -> Card_Node:
	_callable.call()
	#-------------------------------------------------------------------------------
	if(_player.mainDeck.card_Class.size() <= 0):
		return
	#-------------------------------------------------------------------------------
	var _card_Class: Card_Class = _player.mainDeck.card_Class[0]
	_player.mainDeck.card_Class.erase(_card_Class)
	#-------------------------------------------------------------------------------
	SetDeckNumber1(_player.mainDeck)
	#-------------------------------------------------------------------------------
	var _card_Node: Card_Node = card_Node_Prefab.instantiate() as Card_Node
	_card_Node.offset_Node2D.rotation_degrees = _player.card_rotation
	_card_Node.global_position = _player.mainDeck.global_position
	_card_Node.z_index = z_index_hand
	#-------------------------------------------------------------------------------
	if(_player.isPlayer1):
		_player.hand.card_Node.push_back(_card_Node)
	else:
		_player.hand.card_Node.push_front(_card_Node)
	#-------------------------------------------------------------------------------
	add_child(_card_Node)
	#-------------------------------------------------------------------------------
	_card_Node.card_Class = _card_Class
	Set_Card_Node(_card_Node.frame_Node, _card_Node.card_Class.card_Resource)
	_card_Class.gameScene = self
	#-------------------------------------------------------------------------------
	_card_Node.highlighted = func(): Highlight_Card_True(_player, _card_Node)
	_card_Node.lowlighted = func(): Highlight_Card_False(_card_Node)
	#-------------------------------------------------------------------------------
	return _card_Node
#-------------------------------------------------------------------------------
func Add_card_to_hand(_card_Node:Card_Node):
	if(_card_Node not in player1.hand.card_Node):
		player1.hand.card_Node.push_back(_card_Node)
		Update_hand_position(player1)
	else:
		Animate_card_to_position(_card_Node, _card_Node.starting_position)
#-------------------------------------------------------------------------------
func Update_hand_position(_player:Player_Node):
	#-------------------------------------------------------------------------------
	for _i:int in _player.hand.card_Node.size():
		var _newPosition: Vector2 = Vector2(Calculate_card_position(_i), _player.hand.global_position.y)
		var _card:Card_Node = _player.hand.card_Node[_i]
		_card.starting_position = _newPosition
		Animate_card_to_position(_card, _newPosition)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Calculate_card_position(_i:int) -> float:
	var _total_width: float = (player1.hand.card_Node.size()-1)*card_width
	var _x_offset: float = player1.hand.global_position.x+float(_i)*card_width-_total_width/2
	return _x_offset
#-------------------------------------------------------------------------------
func Animate_card_to_position(_card:Card_Node, _newPosition:Vector2):
	var _tween: Tween = get_tree().create_tween()
	_tween.tween_property(_card, "global_position", _newPosition, 0.1)
#-------------------------------------------------------------------------------
func Remove_card_from_hand(_card:Card_Node):
	if(_card in player1.hand.card_Node):
		player1.hand.card_Node.erase(_card)
		Update_hand_position(player1)
#endregion
#-------------------------------------------------------------------------------
#region START PHASE
func StartPhase():
	await Show_Banner("Start Phase")
	var _card_Node: Card_Node = Draw_1_Card(player1, func():pass)
	Update_hand_position(player1)
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
#region MAIN PHASE 1 - IDLE
func MainPhase1_Idle():
	#-------------------------------------------------------------------------------
	var _null: Callable = func():pass
	#-------------------------------------------------------------------------------
	player1.mainDeck.released = _null
	player1.extraDeck.released = _null
	player1.grave.released = _null
	player1.removed.released = _null
	#-------------------------------------------------------------------------------
	button1.released = _null
	button2.released = _null
	#-------------------------------------------------------------------------------
	nothing_released = _null
	nothing_cancel = _null
	#-------------------------------------------------------------------------------
	for _i in player1.monsterZone.size():
		player1.monsterZone[_i].released = _null
	#-------------------------------------------------------------------------------
	for _i in player1.magicZone.size():

		player1.magicZone[_i].released = _null
	#-------------------------------------------------------------------------------
	for _i in player1.hand.card_Node.size():
		var _card_Node: Card_Node = player1.hand.card_Node[_i]
		_card_Node.released = func(): HandCard_Selected(player1, _card_Node, _null)
		_card_Node.holding = func(): Card_PressHolding(_card_Node.card_Class.card_Resource)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Card_PressHolding(_cardResource: Card_Resource):
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
#region MAIN PHASE 1 - HAND MENU
func HandCard_Selected(_player:Player_Node, _cardNode: Card_Node, _callable:Callable):
	var _null: Callable = func():pass
	#-------------------------------------------------------------------------------
	_callable.call()
	#-------------------------------------------------------------------------------
	selected_object_node = _cardNode
	Selected_Card_True(_cardNode)
	_cardNode.highlighted = func():pass
	_cardNode.lowlighted = func():pass
	_cardNode.released = func():pass
	#-------------------------------------------------------------------------------
	button1.global_position = _cardNode.global_position + Vector2(-35, -150)
	button2.global_position = _cardNode.global_position + Vector2(35, -150)
	#-------------------------------------------------------------------------------
	button1.released = func(): Button1_Pressed(_player, _cardNode, func():HandCard_Deselected(_player, _cardNode))
	button2.released = func(): Button1_Pressed(_player, _cardNode, func():HandCard_Deselected(_player, _cardNode))
	#-------------------------------------------------------------------------------
	Show_Button_Node(button1)
	Show_Button_Node(button2)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): HandCard_Canceled(_player, _cardNode)
	nothing_released = func(): HandCard_Deselected(_player, _cardNode)
	#-------------------------------------------------------------------------------
	player1.mainDeck.released = func(): HandCard_Deselected(_player, _cardNode)
	player1.extraDeck.released = func(): HandCard_Deselected(_player, _cardNode)
	player1.grave.released = func(): HandCard_Deselected(_player, _cardNode)
	player1.removed.released = func(): HandCard_Deselected(_player, _cardNode)
	#-------------------------------------------------------------------------------
	for _i in player1.monsterZone.size():
		player1.monsterZone[_i].released = func(): HandCard_Deselected(_player, _cardNode)
	#-------------------------------------------------------------------------------
	for _i in player1.magicZone.size():
		player1.magicZone[_i].released = func(): HandCard_Deselected(_player, _cardNode)
	#-------------------------------------------------------------------------------
	for _i in player1.hand.card_Node.size():
		if(player1.hand.card_Node[_i] != _cardNode):
			player1.hand.card_Node[_i].released = func(): HandCard_Selected(_player, player1.hand.card_Node[_i], func(): HandCard_Deselected(_player, _cardNode))
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func HandCard_Deselected(_player:Player_Node,_cardNode: Card_Node):
	Selected_Card_False(_cardNode)
	_cardNode.highlighted = func(): Highlight_Card_True(_player, _cardNode)
	_cardNode.lowlighted = func(): Highlight_Card_False(_cardNode)
	var _null: Callable = func():pass
	_cardNode.released = func(): HandCard_Selected(_player, _cardNode, _null)
	#-------------------------------------------------------------------------------
	selected_object_node = null
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): pass
	nothing_released = func(): pass
	#-------------------------------------------------------------------------------
	player1.mainDeck.released = func():pass
	player1.extraDeck.released = func():pass
	player1.grave.released = func():pass
	player1.removed.released = func():pass
	for _i in player1.monsterZone.size():
		player1.monsterZone[_i].released = func():pass
	for _i in player1.magicZone.size():
		player1.magicZone[_i].released = func():pass
#-------------------------------------------------------------------------------
func HandCard_Canceled(_player:Player_Node, _cardNode: Card_Node):
	var _selected_card_node: Card_Node = _cardNode as Card_Node
	#-------------------------------------------------------------------------------
	if(object_node.has(_cardNode)):
		Highlight_Card_True(_player, _selected_card_node)
	else:
		Highlight_Card_False(_selected_card_node)
	#-------------------------------------------------------------------------------
	_selected_card_node.highlighted = func(): Highlight_Card_True(_player, _selected_card_node)
	_selected_card_node.lowlighted = func(): Highlight_Card_False(_selected_card_node)
	var _null: Callable = func():pass
	_selected_card_node.released = func(): HandCard_Selected(_player, _selected_card_node, _null)
	#-------------------------------------------------------------------------------
	selected_object_node = null
	#-------------------------------------------------------------------------------
	Hide_Button_Node(button1)
	Hide_Button_Node(button2)
	#-------------------------------------------------------------------------------
	nothing_cancel = func(): pass
	nothing_released = func(): pass
#endregion
#-------------------------------------------------------------------------------
#region MAIN PHASE 1 - SUMMON MENU
func Button1_Pressed(_player:Player_Node, _card_Node: Card_Node, _callable:Callable):
	_callable.call()
	#-------------------------------------------------------------------------------
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		for _i in player1.magicZone.size():
			if(player1.magicZone[_i].card_in_slot == null):
				player1.magicZone[_i].summoning_TextureRect.show()
				player1.magicZone[_i].released = func(): MainPhase1_SummonMenu_ActiveteCard(player1.magicZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				player1.magicZone[_i].released = func(): Button1_Canceled(_player, _card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in player1.monsterZone.size():
			player1.monsterZone[_i].released = func(): Button1_Canceled(_player, _card_Node)
		#-------------------------------------------------------------------------------
	else:
		for _i in player1.monsterZone.size():
			if(player1.monsterZone[_i].card_in_slot == null):
				player1.monsterZone[_i].summoning_TextureRect.show()
				player1.monsterZone[_i].released = func(): MainPhase1_SummonMenu_SummonMonster(player1.monsterZone[_i], _card_Node)
			#-------------------------------------------------------------------------------
			else:
				player1.monsterZone[_i].released = func(): Button1_Canceled(_player, _card_Node)
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		for _i in player1.magicZone.size():
			player1.magicZone[_i].released = func(): Button1_Canceled(_player, _card_Node)
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
	player1.mainDeck.released = func(): Button1_Canceled(_player, _card_Node)
	player1.extraDeck.released = func(): Button1_Canceled(_player, _card_Node)
	player1.grave.released = func(): Button1_Canceled(_player, _card_Node)
	player1.removed.released = func(): Button1_Canceled(_player, _card_Node)
	nothing_released = func(): Button1_Canceled(_player, _card_Node)
	nothing_cancel = func(): Button1_Canceled(_player, _card_Node)
	#-------------------------------------------------------------------------------
	for _i in player1.hand.card_Node.size():
		player1.hand.card_Node[_i].released = func(): HandCard_Selected(_player, player1.hand.card_Node[_i], func(): Button1_Canceled2(_player, _card_Node, player1.hand.card_Node[_i]))
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase1_SummonMenu_SummonMonster(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MainPhase1_Idle()
	Desactivate_MonsterZone()
	MoveCard_fromHand_toSlot(_card_Node, _cardSlot_Node)
#-------------------------------------------------------------------------------
func MoveCard_fromHand_toSlot(_card_node: Card_Node, _cardSlot_Node:CardSlot_Node):
	_card_node.canBePressed = false
	_cardSlot_Node.card_in_slot = _card_node
	player1.hand.card_Node.erase(_card_node)
	Update_hand_position(player1)
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
func Desactivate_MonsterZone():
	for _i in player1.monsterZone.size():
		player1.monsterZone[_i].summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func MainPhase1_SummonMenu_ActiveteCard(_cardSlot_Node: CardSlot_Node, _card_Node: Card_Node):
	MainPhase1_Idle()
	Desactivate_MagicZone()
	MoveCard_fromHand_toSlot(_card_Node, _cardSlot_Node)
#-------------------------------------------------------------------------------
func Desactivate_MagicZone():
	for _i in player1.magicZone.size():
		player1.magicZone[_i].summoning_TextureRect.hide()
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Button1_Canceled(_player:Player_Node, _card_Node: Card_Node):
	var _null: Callable = func():pass
	HandCard_Selected(_player, _card_Node, _null)
	Deselect_Zones(_card_Node)
	nothing_cancel = func(): HandCard_Canceled(_player, _card_Node)
#-------------------------------------------------------------------------------
func Button1_Canceled2(_player:Player_Node, _card_Node1: Card_Node, _card_Node2: Card_Node):
	var _null: Callable = func():pass
	HandCard_Selected(_player, _card_Node2, _null)
	Deselect_Zones(_card_Node1)
	nothing_cancel = func(): HandCard_Canceled(_player, _card_Node1)
#-------------------------------------------------------------------------------
func Deselect_Zones(_card_Node: Card_Node):
	if(_card_Node.card_Class.card_Resource.myCARD_TYPE == Card_Resource.CARD_TYPE.BLUE):
		Desactivate_MagicZone()
	else:
		Desactivate_MonsterZone()
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
