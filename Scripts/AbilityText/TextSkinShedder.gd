extends Ability

class_name TextSkinShedder

var mat = load("res://Scripts/Abilities/AbilityMatryoshka.gd")

func _init(card : Card).("Skin Shedder", card, Color.darkgray, false, Vector2(0, 0)):
	pass

func genDescription(subCount = 0) -> String:
	return .genDescription() + "A 1/1 necro creature with " + str(mat.new(null).setCount(2))
