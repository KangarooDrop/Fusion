extends Ability

class_name AbilityPronged

func _init(card : Card).("Pronged", card, Color.red, false, Vector2(0, 16)):
	pass

func genDescription() -> String:
	return "Damages the two spaces adjacent to the target space when attacking"
