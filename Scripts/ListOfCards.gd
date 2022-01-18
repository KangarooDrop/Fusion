extends Node

var cardList := []

var cardBackground = preload("res://Art/backgrounds/card_blank.png")
var cardBackgroundActive = preload("res://Art/backgrounds/card_active.png")
var unknownCardTex = preload("res://Art/portraits/card_unknown.png")
var noneCardTex = preload("res://Art/portraits/card_NONE.png")

var creatureTypeImageList = [null, 
		preload("res://Art/types/type_null.png"), 
		preload("res://Art/types/type_fire.png"), 
		preload("res://Art/types/type_water.png"), 
		preload("res://Art/types/type_rock.png"), 
		preload("res://Art/types/type_beast.png"), 
		preload("res://Art/types/type_mech.png"),
		preload("res://Art/types/type_necro.png")]
#{None, Null, Fire, Water, Earth, Beast, Mech, Necro}

var fusionList := \
[
	[
		[-1,   -1,   -1,   -1,   -1,    -1,  -1,   -1],
		[-1,   0,    1,    2,    3,     4,   5,    21],
		[-1,   0,    6,    null, null, null, null, null],
		[-1,   0,    7,    8,    null, null, null, null],
		[-1,   0,    9,    10,   11,   null, null, null],
		[-1,   0,   12,    13,   14,   15,   null, null],
		[-1,   0,   16,    17,   18,   19,   20,   null],
		[-1,   0,   22,    23,   24,   25,   26,   27]
	]
#	[
#		[-1, 	-1, 	-1, 	-1, 	-1, 	-1, 	-1, 	-1],
#		[-1, 	0, 		null, 	null, 	null, 	null, 	null, 	null],
#		[-1, 	0, 		0, 		null, 	null, 	null, 	null, 	null],
#		[-1, 	0, 		0, 		0, 		null, 	null, 	null, 	null],
#		[-1, 	0, 		0, 		0, 		0, 		null, 	null, 	null],
#		[-1, 	0, 		0, 		0, 		0, 		0, 		null, 	null],
#		[-1, 	0, 		0, 		0, 		0, 		0, 		0,	 	null],
#		[-1, 	0, 		0, 		0, 		0, 		0, 		0, 		0]
#	]
]

func _ready():
	cardList.append(CardCreature.new({"name":"Null", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_NULL.png", "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Null], "tier":1}))
	cardList.append(CardCreature.new({"name":"Fire Elemental", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_FIRE.png", "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire], "tier":1, "abilities":[AbilityDash]}))
	cardList.append(CardCreature.new({"name":"Water Elemental", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_WATER.png", "power":0, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Water], "tier":1, "abilities":[AbilityWisdom]}))
	cardList.append(CardCreature.new({"name":"Earth Elemental", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_ROCK.png", "power":0, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Earth], "tier":1, "abilities":[AbilityTough]}))
	cardList.append(CardCreature.new({"name":"Wolf", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_WOLF.png", "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Beast], "tier":1}))
	cardList.append(CardCreature.new({"name":"Automaton", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_ROBOT.png", "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Mech], "tier":1, "abilities":[AbilityProduction]}))
	
	cardList.append(CardCreature.new({"name":"Fiend", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_FIEND.png", "power":3, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire], "tier":2, "abilities":[AbilityDash]}))
	cardList.append(CardCreature.new({"name":"Djinn", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_DJINN.png", "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Water], "tier":2, "abilities":[AbilityDash, AbilityWisdom]}))
	cardList.append(CardCreature.new({"name":"Torrent", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_TORRENT.png", "power":1, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Water], "tier":2, "abilities":[AbilityWisdom, AbilityWisdom]}))
	cardList.append(CardCreature.new({"name":"Volcan", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_VOLCAN.png", "power":2, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Earth], "tier":2, "abilities":[AbilityDash, AbilityTough]}))
	cardList.append(CardCreature.new({"name":"Sludge", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_SLUDGE.png", "power":0, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Earth, CardCreature.CREATURE_TYPE.Water], "tier":2, "abilities":[AbilityWisdom, AbilityTough]}))
	cardList.append(CardCreature.new({"name":"Golem", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_GOLEM.png", "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Earth], "tier":2, "abilities":[AbilityTough, AbilityTough]}))
	
	cardList.append(CardCreature.new({"name":"Cerberus", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_CERBERUS.png", "power":3, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Fire], "tier":2, "abilities":[AbilityDash]}))
	cardList.append(CardCreature.new({"name":"Leviathan", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_LEVIATHAN.png", "power":1, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Water], "tier":2, "abilities":[AbilityWisdom]}))
	cardList.append(CardCreature.new({"name":"Stone Serpant", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_STONE_SERPANT.png", "power":2, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Earth], "tier":2, "abilities":[AbilityTough]}))
	cardList.append(CardCreature.new({"name":"Gargantua", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_GARGANTUA.png", "power":3, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Beast], "tier":2}))
	cardList.append(CardCreature.new({"name":"Flame Cannon", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_FLAME_CANNON.png", "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Mech], "tier":2, "abilities":[AbilityDash, AbilityProduction]}))
	cardList.append(CardCreature.new({"name":"Steamer", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_STEAMER.png", "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Mech, CardCreature.CREATURE_TYPE.Water], "tier":2, "abilities":[AbilityProduction, AbilityWisdom]}))
	cardList.append(CardCreature.new({"name":"Miner", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_Miner.png", "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Mech, CardCreature.CREATURE_TYPE.Earth], "tier":2, "abilities":[AbilityTough, AbilityProduction]}))
	cardList.append(CardCreature.new({"name":"Cyber wolf", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_CYBER_WOLF.png", "power":2, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Mech], "tier":2, "abilities":[AbilityProduction]}))
	cardList.append(CardCreature.new({"name":"Factory", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_FACTORY.png", "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Mech], "tier":2, "abilities":[AbilityProduction, AbilityProduction]}))
	
	
	cardList.append(CardCreature.new( {"name":"Necro", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_NECRO.png", "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Necro], "tier":1, "abilities":[AbilitySacrifice]}))
	cardList.append(CardCreature.new({"name":"Combust", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_COMBUST.png", "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Fire, CardCreature.CREATURE_TYPE.Necro], "tier":2, "abilities":[AbilityDash, AbilitySacrifice]}))
	cardList.append(CardCreature.new({"name":"Drifter", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_DRIFTER.png", "power":1, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Water, CardCreature.CREATURE_TYPE.Necro], "tier":2, "abilities":[AbilityWisdom, AbilitySacrifice]}))
	cardList.append(CardCreature.new({"name":"Grave Robber", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_DRIFTER.png", "power":1, "toughness":3, "creature_type":[CardCreature.CREATURE_TYPE.Earth, CardCreature.CREATURE_TYPE.Necro], "tier":2, "abilities":[AbilityTough, AbilitySacrifice]}))
	cardList.append(CardCreature.new({"name":"Necro-Wolf", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_NECRO_WOLF.png", "power":3, "toughness":2, "creature_type":[CardCreature.CREATURE_TYPE.Beast, CardCreature.CREATURE_TYPE.Necro], "tier":2, "abilities":[AbilitySacrifice]}))
	cardList.append(CardCreature.new({"name":"Abomination", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_ABOMINATION.png", "power":1, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Necro, CardCreature.CREATURE_TYPE.Mech], "tier":2, "abilities":[AbilityProduction, AbilitySacrifice]}))
	cardList.append(CardCreature.new({"name":"Lichomancer", "card_type":Card.CARD_TYPE.Creature, "tex":"res://Art/portraits/card_LICHOMANCER.png", "power":2, "toughness":1, "creature_type":[CardCreature.CREATURE_TYPE.Necro], "tier":2, "abilities":[AbilitySacrifice, AbilitySacrifice]}))
	
	
	for i in range(cardList.size()):
		cardList[i].UUID = i
		
	var path = "user:/"
	var fileName = "card_list"
	var dict = {}
	for i in range(cardList.size()):
		dict[i] = cardList[i].params
	
	var error = FileIO.writeToJSON(path, fileName, dict)
	if error != 0:
		print("Error: Writing card list to JSON : ", error)
	else:
		print("Card list written to JSON at path: ", path, "/", fileName + ".json")

func getCard(index : int) -> Card:
	if index < 0 or index >= cardList.size():
		return null
	var card = cardList[index].get_script().new(cardList[index].params)
	card.UUID = index
	return card

static func deserialize(data : Dictionary) -> Card:
	var card : Card = ListOfCards.getCard(data["id"])
	card.playerID = data["player_id"]
	return card
	
