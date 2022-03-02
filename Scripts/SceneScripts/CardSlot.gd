extends Node

class_name CardSlot

var disabled = false

var board
var cardNode
var playerID = -1

enum ZONES {NONE, HAND, ENCHANTMENT, CREATURE, DECK}
var currentZone = ZONES.NONE
var isOpponent = false

func _ready():
	if currentZone == ZONES.HAND:
		$SpotSprite.visible = false
	else:
		$SpotSprite.visible = true
	
func mouseEnter():
	if board != null and not disabled:
		board.onSlotEnter(self)
	
func mouseExit():
	if board != null:
		board.onSlotExit(self)
	
func _input_event(viewport, event, shape_idx):
	if board != null and not disabled:
		if event is InputEventMouseButton and event.pressed:
			board.onSlotBeingClicked(self, event.button_index)

func getNeighbors() -> Array:
	var neighbors = []
	var index = get_index()
	if index > 0:
		var c = get_parent().get_child(index - 1)
		if c is get_script():
			neighbors.append(c)
	if index < get_parent().get_child_count() - 1:
		var c = get_parent().get_child(index + 1)
		if c is get_script():
			neighbors.append(c)
	return neighbors
