extends Node

var fontTRES = preload("res://Fonts/FontNormal.tres")

var waitMaxTime = 0.6
var waitTimer = waitMaxTime
var waitNum = -1
var waitNumMax = 4

func _ready():
	MusicManager.playLobbyMusic()
	$IPSet/HBoxContainer/LineEdit.text = str(Server.ip)

func _physics_process(delta):
	if $WaitLabel.visible:
		waitTimer += delta
		if waitTimer >= waitMaxTime:
			waitNum = (waitNum+1) % (waitNumMax + 1)
			waitTimer = 0
			$WaitLabel.text = "Waiting" + ".".repeat(waitNum)

func hostButtonPressed():
	Server.host = true
	$MultiplayerUI.visible = false
	openFileSelector()
	
func joinButtonPressed():
	$MultiplayerUI.visible = false
	openFileSelector()
	
func ipBackButtonPressed():
	$IPSet.visible = false
	openFileSelector()
	
		
func backButtonPressed():
	Server.host = false
	var root = get_node("/root")
	var startup = load("res://Scenes/StartupScreen.tscn").instance()
	
	startup.onPlayPressed()
	root.add_child(startup)
	get_tree().current_scene = startup
	
	root.remove_child(self)
	queue_free()
		
func startGame():
	var error = get_tree().change_scene("res://Scenes/main.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
	
func openFileSelector():
	$DeckSelector.visible = true
		
	var files = []
	var dir = Directory.new()
	dir.open(Settings.path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with("json"):
			files.append(file)
	dir.list_dir_end()
	
	if files.size() > 0:
		for c in $DeckSelector/VBoxContainer.get_children():
			if c is Button and c.name != "BackButton":
				c.queue_free()
				c.get_parent().remove_child(c)
				
		for i in range(files.size()):
			var b = Button.new()
			$DeckSelector/VBoxContainer.add_child(b)
			b.text = str(files[i].get_basename())
			b.set("custom_fonts/font", fontTRES)
			b.connect("pressed", self, "onFileButtonClicked", [files[i]])
			$DeckSelector/VBoxContainer.move_child(b, i+1)
		$DeckSelector/VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		$DeckSelector/Background.rect_size = $DeckSelector/VBoxContainer.rect_size + Vector2(60, 20)
		$DeckSelector/Background.rect_position = $DeckSelector/VBoxContainer.rect_position - Vector2(30, 10)
	else:
		MessageManager.notify("You must create a new deck before playing")
		$DeckSelector.visible = false
		$MultiplayerUI.visible = true
	
	
func onFileButtonClicked(fileName : String):
	$DeckSelector.visible = false
		
	Settings.selectedDeck = fileName
	if Server.host:
		Server.online = true
		Server.startServer()
		$WaitLabel.visible = true
	else:
		$IPSet.visible = true

func ipJoinButtonPressed():
	Server.ip = $IPSet/HBoxContainer/LineEdit.text
	Settings.writeToSettings()
	print(Server.ip)
	Server.online = true
	Server.connectToServer()
	$WaitLabel.visible = true
	$IPSet.visible = false
	

func onBackButtonClicked():
	$DeckSelector.visible = false
	$MultiplayerUI.visible = true
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_ESCAPE:
			if Server.online:
				disconnected()
			elif $MultiplayerUI.visible:
				backButtonPressed()
			elif $IPSet.visible:
				ipBackButtonPressed()
			elif $DeckSelector.visible:
				onBackButtonClicked()

func disconnected():
	Server.closeServer()
	
	$MultiplayerUI.visible = true
	$WaitLabel.visible = false
