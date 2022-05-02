extends Ability

class_name AbilitySacrifice

func _init(card : Card).("Sacrifice", card, Color.darkgray, true, Vector2(0, 96)):
	pass

func onDeath():
	.onDeath()
	addToStack("onEffect", [card, count])

static func onEffect(params):
	for slot in NodeLoc.getBoard().creatures[params[0].playerID]:
		if is_instance_valid(slot.cardNode):
			slot.cardNode.card.power += params[1]
			slot.cardNode.card.toughness += params[1]

func genDescription(subCount = 0) -> String:
	return .genDescription() + "When this creature dies, it gives other creatures you control +" + str(count) + "/+" + str(count)
