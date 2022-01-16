extends CardCreature

class_name CardLeviathan

func _init(params).(params if params != null else {"name":"Leviathan", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_LEVIATHAN.png"), "power":1, "toughness":3, "creature_type":CardCreature.CREATURE_TYPE.Beast, "tier":2}):
	pass

func onEnter(board):
	.onEnter(board)
	for p in board.players:
		if p.UUID == playerID:
			p.hand.drawCard()
