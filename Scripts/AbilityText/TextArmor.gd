extends Ability

class_name TextArmor

func _init(card : Card).("Armor", card, Color.brown, false, Vector2(0, 0)):
	pass

func genDescription(subCount = 0) -> String:
	return .genDescription() + "Damage is dealt to armor before life"
