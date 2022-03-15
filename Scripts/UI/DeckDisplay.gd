extends Node2D

var deckDisplayData = preload("res://Scenes/UI/DeckDisplayData.tscn")
var cardNode = preload("res://Scenes/CardNode.tscn")
onready var cardWidth = ListOfCards.cardBackground.get_width()
onready var cardHeight = ListOfCards.cardBackground.get_height()

var data := []
var total := -1 setget setTotal, getTotal
export var deckMax = -1

var parent

func setTotal(newTotal : int):
	if newTotal != total:
		total = newTotal
		if deckMax != -1:
			$Label.text = str(newTotal) + " / " + str(deckMax)
		else:
			$Label.text = ""
		if parent != null and parent.has_method("deckModified"):
			parent.deckModified()
		
		if total != deckMax:
			$Label.set("custom_colors/font_color", Color.black)
		else:
			$Label.set("custom_colors/font_color", Color.blueviolet)
	
func getTotal() -> int:
	return total

func _ready():
	setTotal(0)

func _physics_process(delta):
	if hoveringOn != null:
		if onHoverTimer < onHoverMaxTime:
			onHoverTimer += delta
		else:
			if hoverCard == null:
				hoverCard = cardNode.instance()
				hoverCard.card = hoveringOn.card
				add_child(hoverCard)
				hoverCard.global_position = Vector2(global_position.x - cardWidth, hoveringOn.rect_global_position.y)
				hoverCard.modulate = Color(1, 1, 1, hoverAlpha)
			
	for k in disappearing.keys():
		if disappearing[k] > 0:
			disappearing[k] -= delta
			k.modulate = Color(1, 1, 1, lerp(0, hoverAlpha, disappearing[k] / disappearMaxTime))
		else:
			k.queue_free()
			disappearing.erase(k)
			
func clearData():
	while(data.size() > 0):
		removeCard(0)

func addCard(id : int) -> bool:
	for i in range(data.size()):
		if data[i].card.UUID == id:
			data[i].count += 1
			data[i].updateDisplay()
			setTotal(getTotal() + 1)
			return true
	
	var d = deckDisplayData.instance()
	d.card = ListOfCards.getCard(id)
	d.count = 1
	$VBoxContainer.add_child(d)
	data.append(d)
	d.get_node("Button").connect("pressed", self, "onDeckDataClicked", [d])
	d.get_node("Button").connect("mouse_entered", self, "onDeckDataMouseEnter", [d])
	d.get_node("Button").connect("mouse_exited", self, "onDeckDataMouseExit", [d])
	setTotal(getTotal() + 1)
	return true
	
var hoverAlpha = 1
var hoverCard = null
var hoveringOn = null
var onHoverTimer = 0
var onHoverMaxTime = 0.5
var disappearMaxTime = 0.5
var disappearing = {}
	
func onDeckDataMouseEnter(button):
	hoveringOn = button
	onHoverTimer = 0
	
func onDeckDataMouseExit(button):
	if hoveringOn == button:
		hoveringOn = null
		if hoverCard != null:
			disappearing[hoverCard] = disappearMaxTime
			hoverCard = null
	
func removeCard(index : int) -> bool:
	if index >= 0 and index < data.size():
		
		data[index].count -= 1
		parent.removeCard(data[index].card.UUID)
			
		if data[index].count > 0:
			data[index].updateDisplay()
		else:
			if hoveringOn == data[index]:
				onDeckDataMouseExit(data[index])
			data[index].queue_free()
			data.remove(index)
		setTotal(getTotal() - 1)
		
		return true
	return false

func onDeckDataClicked(d) -> bool:
	var index = -1
	for i in range(data.size()):
		if data[i] == d:
			index = i
			break
	if index != -1:
		return removeCard(index)
	else:
		return false

func getDeckData() -> Dictionary:
	var rtn = {}
	for d in data:
		rtn[d.card.UUID] = d.count
	return rtn

func getDeckDataAsJSON() -> Dictionary:
	var rtn = {}
	var data = getDeckData()
	for d in data.keys():
		rtn[str(d)] = float(data[d])
	return rtn
