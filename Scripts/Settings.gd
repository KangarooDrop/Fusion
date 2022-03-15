extends Node

enum VERSION_COMP {SAME, OLDER, NEWER, BAD_KEYS, UNEVEN_KEYS}
var versionID = "0.0.1.02"

var playAnimations = true
var selectedDeck = ""
var path = "user://decks/"

var dumpPath = "user://dumps/"
var dumpFile = "x_.txt"

enum GAME_MODE {NONE, LOBBY_PLAY, LOBBY_DRAFT, PLAY, REPLAY, DRAFTING}
var gameMode : int = 0

var cardSlotScale = 1.5

var settingsPath = "user:/"
var settingsName = "settings"

func _ready():
	var json = FileIO.readJSON(settingsPath + "/" + settingsName + ".json")
	if json.keys().size() == 0:
		FileIO.writeToJSON(settingsPath, settingsName, getSettingsDict())
		
	var settings = FileIO.readJSON(settingsPath + "/" + settingsName + ".json")
	var ok = verifySettings(settings)
	
	Settings.playAnimations = settings["play_anims"]
	Server.MAX_PEERS = settings["num_draft"] - 1
	Server.username = settings["username"]
	Server.ip = settings["ip_saved"]
	
	if not ok:
		writeToSettings()

func verifySettings(settings : Dictionary) -> bool:
	var ok = true
	if not settings.has("play_anims"):
		settings["play_anims"] = true
		ok = false
	if not settings.has("num_draft"):
		settings["num_draft"] = 8
		ok = false
	if not settings.has("username"):
		settings["username"] = "NO_NAME"
		ok = false
	if not settings.has("ip_saved"):
		settings["ip_saved"] = "127.0.0.1"
		ok = false
		
	return ok
	

func writeToSettings():
	print("Saving user settings")
	print(getSettingsDict())
	FileIO.writeToJSON(settingsPath, settingsName, getSettingsDict())
	
func getSettingsDict() -> Dictionary:
	var rtn := \
	{
		"num_draft":Server.MAX_PEERS + 1,
		"play_anims":playAnimations,
		"username":Server.username,
		"ip_saved":Server.ip
	}
	return rtn
	

static func compareVersion(comp1 : String, comp2 : String) -> int:
	var spl = comp1.split(".")
	var spl2 = comp2.split(".")
	
	if spl.size() != spl2.size():
		return VERSION_COMP.UNEVEN_KEYS
		
	for i in range(spl.size()):
		if spl[i].length() != spl2[i].length():
			return VERSION_COMP.UNEVEN_KEYS
		
	for i in range(spl.size()):
		if not spl[i].is_valid_integer() or not spl2[i].is_valid_integer():
			return VERSION_COMP.BAD_KEYS
			
	for i in range(spl.size()):
		if int(spl[i]) < 0 or int(spl2[i]) < 0:
			return VERSION_COMP.BAD_KEYS
		elif int(spl[i]) > int(spl2[i]):
			return VERSION_COMP.NEWER
		elif int(spl[i]) < int(spl2[i]):
			return VERSION_COMP.OLDER
			
	return VERSION_COMP.SAME
	
static func versionCompUnitTest():
	var string1 = "0.0.0.01"
	var string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.SAME)
	
	string1 = "4.00.20.3"
	string2 = "4.00.20.3"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.SAME)
	
	string1 = "30.123.0"
	string2 = "30.123.0"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.SAME)
	
	##################################################################################################################################################################
	
	string1 = "0.0.0"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.0.0.01"
	string2 = "0.0.0"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.00.0.02"
	string2 = "0.0.0.02"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.0.0.01"
	string2 = "0.0..01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.0..01"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	##################################################################################################################################################################
	
	string1 = "0.0.f.01"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.BAD_KEYS)
	
	string1 = "0.00.0.20"
	string2 = "0.-1.0.20"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.BAD_KEYS)
	
	##################################################################################################################################################################
	
	string1 = "0.0.0.01"
	string2 = "0.0.0.02"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.OLDER)
	
	string1 = "0.00.0.01"
	string2 = "0.20.0.02"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.OLDER)
	
	##################################################################################################################################################################
	
	string1 = "0.20.0.02"
	string2 = "0.00.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.NEWER)
	
	string1 = "0.0.0.02"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.NEWER)
	
	##################################################################################################################################################################
	
