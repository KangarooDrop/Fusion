extends CardCreature

class_name CardSludge

func _init(params).(params if params != null else {"name":"Sludge", "card_type":Card.CARD_TYPE.Creature, "tex":load("res://Art/portraits/card_SLUDGE.png"), "power":0, "toughness":3, "creature_type":CardCreature.CREATURE_TYPE.Earth, "tier":2}):
	abilities.append(AbilityTough.new(self))
	abilities.append(AbilitySacrifice.new(self))
