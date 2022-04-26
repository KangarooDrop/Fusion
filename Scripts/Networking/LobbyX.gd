extends Node

export(bool) var bypassPunchthrough = false

var inLobby = false

var numOfPlayers := 0

var popupUI = preload("res://Scenes/UI/PopupUI.tscn")
var kickTex = preload("res://Art/UI/kick.png")

onready var lobbySettings = $LobbySettings

var messageTimer = 0

onready var holepuncher = $RabidHolePuncher

func _ready():
	Settings.gameMode = Settings.GAME_MODE.LOBBY
	BackgroundFusion.stop()
	MusicManager.playLobbyMusic()
	
	holepuncher.connect("holepunch_progress_update", self, "holepunch_progress_update")
	holepuncher.connect("holepunch_failure", self, "holepunch_failure")
	holepuncher.connect("holepunch_success", self, "holepunch_success")
	holepuncher.connect("holepunch_chat", self, "holepunch_chat")
	holepuncher.connect("set_host", self, "set_host")
	
	$Lobby/LineEdit3.text = Server.username

func _process(delta):
	$LoadingWindow/Sprite.rotation -= delta * PI
	
	if messageTimer > 0:
		messageTimer -= delta

func setInLobby():
	if not inLobby:
		$Lobby/LeaveButton.text = "Leave Lobby"
		$Lobby/LineEdit.editable = false
		$Lobby/LineEdit2.editable = false
		$Lobby/LineEdit3.editable = false
		$Lobby/JoinButton.disabled = true
		$Lobby/HostButton.disabled = true
		$Lobby/SendChatButton.disabled = false
		
		inLobby = true

func holepunch_progress_update(type, session_name, player_names):
	print(type, "  ", session_name, "  ", player_names)
	
	if type == holepuncher.STATUS_SESSION_CREATED:
		if holepuncher.is_host():
			$Lobby/StartButton.disabled = false
		$LoadingWindow.visible = false
			
	if type == holepuncher.STATUS_SESSION_CREATED or type == holepuncher.STATUS_SESSION_UPDATED:
		clearPlayers()
		numOfPlayers = player_names.size()
		
		var vbox = $Lobby/ScrollContainer/VBoxContainer
		for name in player_names:
			var label = Label.new()
			label.text = name
			NodeLoc.setLabelParams(label)
			vbox.add_child(label)
			
			if holepuncher.is_host():
				if name != Server.username:
					var tb = TextureButton.new()
					tb.texture_normal = kickTex
					tb.texture_pressed = kickTex
					tb.texture_hover = kickTex
					label.add_child(tb)
					tb.rect_position = Vector2($Lobby/ScrollContainer.rect_size.x - kickTex.get_width() - 8, 2)
					tb.connect("pressed", self, "kickPlayer", [name])
	
	if type == holepuncher.STATUS_STARTING_SESSION:
		$Lobby/StartButton.disabled = true
	
	if type == holepuncher.STATUS_STARTING_SESSION or type == holepuncher.STATUS_SENDING_GREETINGS or type == holepuncher.STATUS_SENDING_CONFIRMATIONS:
		$LoadingWindow.visible = true
		$LoadingWindow/Label.text = type.capitalize()

func kickPlayer(name):
	holepuncher.kick_player(name)

func clearPlayers():
	var vbox = $Lobby/ScrollContainer/VBoxContainer
	for c in vbox.get_children():
		c.queue_free()
	numOfPlayers = 0

func holepunch_failure(error):
	print("Failure: ", error)
	
	if error == holepuncher.ERR_UNREACHABLE_SELF and bypassPunchthrough:
		if holepuncher.is_host():
			holepunch_success(25565, null, null)
		else:
			holepunch_success(0, "127.0.0.1", 25565)
		return
	
	if error == holepuncher.ERR_UNREACHABLE_SELF or error == "error:incompatible_game_version":
		numOfPlayers -= 1
		if numOfPlayers == 1:
			createPopup("Error Creating Lobby", "Failure: " + str(error))
			
			$LoadingWindow.visible = false
			$Lobby/LobbySettingsButton.disabled = false
			
			if inLobby:
				clearPlayers()
				_on_LeaveButton_pressed()
			
		return
	
	if inLobby:
		clearPlayers()
		_on_LeaveButton_pressed()
	
	if error != holepuncher.ERR_SESSION_PLAYER_EXIT:
		createPopup("Error Creating Lobby", "Failure: " + str(error))
		
		$LoadingWindow.visible = false
		$Lobby/LobbySettingsButton.disabled = false

func holepunch_success(self_port, host_ip, host_port):
	print("Success: ", self_port, "  ", host_ip, "  ", host_port)
	
	$LoadingWindow/Label.text = "Establishing connections"
	
	Server.online = true
	if host_ip == null:
		Server.host = true
		var numPeers = $Lobby/LineEdit2.get_value() - 1
		Server.startServer(self_port, numPeers)
		var ready = false
		while not ready:
			ready = Server.playerIDs.size() == numOfPlayers - 1
			
			if numOfPlayers == 0:
				return
			
			yield(get_tree().create_timer(1), "timeout")
			print("not ready  ", Server.playerIDs.size(), "  ", numOfPlayers - 1)
		
		Server.receiveConfirmJoin()
	else:
		Server.connectToServer(host_ip, host_port, self_port)

func holepunch_chat(chat):
	var label = Label.new()
	NodeLoc.setLabelParams(label)
	var s_split = chat.split(':', 2)
	label.text = s_split[1] + ": " + s_split[2]
	$Lobby/ScrollContainer2/VBoxContainer.add_child(label)
	var scrollToBottom = ($Lobby/ScrollContainer2.get_v_scrollbar().max_value - $Lobby/ScrollContainer2.rect_size.y) - $Lobby/ScrollContainer2.scroll_vertical < 3
	if scrollToBottom:
		yield(get_tree(), "idle_frame")
		$Lobby/ScrollContainer2.scroll_vertical = $Lobby/ScrollContainer2.get_v_scrollbar().max_value

func set_host():
	if holepuncher.is_host():
		$Lobby/StartButton.disabled = false

func playerConnected(player_id : int):
	print("player connected: ", player_id)
	
func playerDisconnected(player_id : int):
	print("player dc'd: ", player_id)
	
func _OnConnectFailed():
	print("failed to connect to server")

func _OnConnectSucceeded():
	print("connected to server")

func _Server_Disconnected():
	print("Server diconnected")

func _exit_tree():
	holepuncher.exit_session()
#	Server.closeServer()

func _on_HostButton_pressed():
	checkUsernameChange()
	var numPlayers = $Lobby/LineEdit2.get_value()
	if numPlayers <= 1 or numPlayers > 16:
		print("Failure: Bad player count")
		createPopup("Error Creating Lobby", "Failure: Number of players must be at least 2 and fewer than 17")
		return
	else:
		$LoadingWindow.visible = true
		setInLobby()
		holepuncher.create_session($Lobby/LineEdit.text, Server.username, numPlayers)
		
		$LoadingWindow/Label.text = "Connecting to Server"
		
		clearMessages()

func _on_JoinButton_pressed():
	checkUsernameChange()
	$LoadingWindow.visible = true
	setInLobby()
	holepuncher.join_session($Lobby/LineEdit.text, Server.username)
	
	$LoadingWindow/Label.text = "Connecting to Server"
	$Lobby/LobbySettingsButton.disabled = true
	
	clearMessages()

func _on_StartButton_pressed():
	if numOfPlayers > 1:
		var params = getGameParams()
		if params["game_type"] == Settings.GAME_TYPES.DRAFT and params["draft_type"] == Settings.DRAFT_TYPES.SOLOMON:
			if numOfPlayers != 2:
				print("Failure: Wrong player numbers")
				createPopup("Error Creating Lobby", "Failure: This game mode can only be played with exactly 2 players")
				return
		
		if params.has("games_per_match") and (params["games_per_match"] < 1 or params["games_per_match"] % 2 == 0):
			print("Failure: Bad games per match")
			createPopup("Error Creating Lobby", "Failure: The number of games per match must be greater than 0 and odd")
			return
		
		if params.has("num_boosters") and params["num_boosters"] < 3:
			print("Failure: Bad num boosters")
			createPopup("Error Creating Lobby", "Failure: Must draft with at least 3 booster packs")
			return
		
		holepuncher.start_session()
	else:
		print("Failure: Not enough players")
		createPopup("Error Creating Lobby", "Failure: " + holepuncher.ERR_SESSION_SINGLE_PLAYER)

func _on_LeaveButton_pressed():
	if inLobby:
		clearPlayers()
		_exit_tree()
		if Server.online:
			Server.closeServer()
		$Lobby/StartButton.disabled = true
		$Lobby/JoinButton.disabled = false
		$Lobby/HostButton.disabled = false
		$Lobby/SendChatButton.disabled = true
		$Lobby/LineEdit.editable = true
		$Lobby/LineEdit2.editable = true
		$Lobby/LineEdit3.editable = true
		$Lobby/LeaveButton.text = "Main Menu"
		inLobby = false
	else:
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))
		checkUsernameChange()

func startGame():
	$LoadingWindow.visible = false
	openFileSelector()

func openFileSelector():
	$DeckSelector.visible = true
	$Lobby.visible = false
		
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
			NodeLoc.setButtonParams(b)
			b.connect("pressed", self, "onFileButtonClicked", [files[i]])
			$DeckSelector/VBoxContainer.move_child(b, i+1)
		$DeckSelector/VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		$DeckSelector/Background.rect_size = $DeckSelector/VBoxContainer.rect_size + Vector2(60, 20)
		$DeckSelector/Background.rect_position = $DeckSelector/VBoxContainer.rect_position - Vector2(30, 10)
	else:
		MessageManager.notify("You must create a new deck before playing")
		
		var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
		if error != 0:
			print("Error loading test1.tscn. Error Code = " + str(error))

	
func onFileButtonClicked(fileName : String):
	var path = Settings.path
	
	var dataRead = FileIO.readJSON(path + fileName)
	var dError = Deck.verifyDeck(dataRead)
	
	if dError != OK:
		createPopup("Error Loading Deck", "Error loading " + fileName + "\nop_code=" + str(dError) + " : " + Deck.DECK_VALIDITY_TYPE.keys()[dError])
		return
	
	$DeckSelector.visible = false
	
	Settings.selectedDeck = fileName
	
	if Settings.matchType == Settings.MATCH_TYPE.TOURNAMENT:
		Server.setReady(true)
		$LoadingWindow.visible = true
		$LoadingWindow/Label.text = "Waiting for opponents"
	
	elif Settings.matchType == Settings.MATCH_TYPE.FREE_PLAY:
		$OpponentList.show()

func _on_LobbySettingsButton_pressed():
	lobbySettings.show()

func setOwnGameParams(gameParams : Dictionary):
	lobbySettings.setOwnGameParams(gameParams)

func getGameParams() -> Dictionary:
	return lobbySettings.getGameParams()

func onUsernameLineEditChange(new_text):
	Server.username = new_text

func checkUsernameChange():
	var new_text = $Lobby/LineEdit3.text
	if new_text != Server.username:
		Server.username = new_text
		Settings.writeToSettings()

func createPopup(title : String, desc : String):
	var pop = popupUI.instance()
	pop.init(title, desc, [["Close", pop, "close", []]])
	$PopupHolder.add_child(pop)
	pop.options[0].grab_focus()

func clearMessages():
	for c in $Lobby/ScrollContainer2/VBoxContainer.get_children():
		c.queue_free()

func sendMessage(text = null):
	if text == null:
		text = $Lobby/LineEdit4.text
		
	if messageTimer >= 3:
		createPopup("Warning", "Slow down there, buckaroo! You're sending messages way too fast")
		return
	
	if text == "" or $Lobby/SendChatButton.disabled:
		return
	
	messageTimer += 1
	holepuncher.send_chat(Server.username + ":" + text)
	$Lobby/LineEdit4.text = ""


func _on_OpponentLeaveButton_pressed():
	var pop = popupUI.instance()
	pop.init("Main Menu", "Are you sure you want to quit and return to the main menu?", [["Yes", self, "toMainMenu", []], ["Back", pop, "close", []]])
	$PopupHolder.add_child(pop)
	pop.options[1].grab_focus()
	
func toMainMenu():
	if Server.online:
		Server.closeServer()
	var error = get_tree().change_scene("res://Scenes/StartupScreen.tscn")
	if error != 0:
		print("Error loading test1.tscn. Error Code = " + str(error))
