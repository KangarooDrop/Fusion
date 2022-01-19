
class_name Card

var cardNodeScene = load("res://Scenes/CardNode.tscn")

enum CREATURE_TYPE {None, Null, Fire, Water, Earth, Beast, Mech, Necro}

var UUID = -1

var name : String
var texture : Texture
var tier : int
var abilities := []
var creatureType := []
var power : int
var toughness : int

var hasAttacked = true

var params

var cardNode
var playerID = -1


func _init(params):
	self.params = params
	if params.has("UUID"):
		UUID = params["UUID"]
	name = params["name"]
	texture = load(params["tex"])
	tier = params["tier"]
	if params.has("player_id"):
		playerID = params["player_id"]
	if params.has("abilities"):
		for abl in params["abilities"]:
			abilities.append(abl.new(self))
			
	creatureType = params["creature_type"]
	power = params["power"]
	toughness = params["toughness"]
	if params.has("has_attacked"):
		hasAttacked = params["has_attacked"]
	
func onEnter(board, slot):
	cardNode = slot.cardNode
	for abl in abilities:
		abl.onEnter(board, slot)
	
func onOtherEnter(board, slot):
	for abl in abilities:
		abl.onOtherEnter(board, slot)
	
func onOtherDeath(board, slot):
	for abl in abilities:
		abl.onOtherDeath(board, slot)
	
func onDeath(board):
	for abl in abilities:
		abl.onDeath(board)
	
func onStartOfTurn(board):
	if board.players[board.activePlayer].UUID == playerID:
		hasAttacked = false
	for abl in abilities:
		abl.onStartOfTurn(board)

func onEndOfTurn(board):
	for abl in abilities:
		abl.onEndOfTurn(board)
				
func onFusion(card):
	for abl in abilities:
		abl.onFusion(card)
	
	
func onAttack(blocker, board):
	hasAttacked = true
	for abl in abilities:
		abl.onAttack(blocker, board)
	
func onBeingAttacked(attacker, board):
	for abl in abilities:
		abl.onBeingAttacked(attacker, board)
	
func addCreatureToBoard(card, board):
	if board.players[board.activePlayer].UUID == playerID:
		for slot in board.creatures[playerID]:
			if not is_instance_valid(slot.cardNode):
				card.playerID = playerID
				
				var cardPlacing = cardNodeScene.instance()
				cardPlacing.card = card
				board.add_child(cardPlacing)
				cardPlacing.global_position = slot.global_position
				slot.cardNode = cardPlacing
				cardPlacing.slot = slot
				
				card.onEnter(board, slot)
				
				return

func _to_string() -> String:
	return name + " - " + str(power) + "/" + str(toughness)

func clone() -> Card:
	var c : Card = ListOfCards.deserialize(serialize())
	return c
	
func copyBase() -> Card:
	return get_script().new(null)
	
func serialize() -> Dictionary:
	var rtn = {"id":UUID, "player_id":playerID}
	rtn["power"] = power
	rtn["toughness"] = toughness
	rtn["has_attacked"] = hasAttacked
	return rtn

func getHoverData() -> String:
	var string = name + "\n"
	
	string += "Types: "
	for i in range(creatureType.size()):
		string += CREATURE_TYPE.keys()[creatureType[i]].to_lower().capitalize()
		if i < creatureType.size() - 1:
			string += "/"
			
	for abl in abilities:
		string += "\n" + str(abl)
		
	return string
