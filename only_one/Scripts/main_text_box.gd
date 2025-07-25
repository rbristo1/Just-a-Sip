extends RichTextLabel

var backupText = "" 

var storedText = false
var dragLocked = false


func showText(Text: String) -> void:
	text = Text

func showTempText(tempText: String) -> void:
	if (storedText == false and dragLocked == false):
		backupText = text
		storedText = true
		text = tempText

func forceDragText(tempText: String) -> void:
	text = tempText
	dragLocked = true
	
func stopShowingTempText() -> void:
	if (storedText == true and dragLocked == false):
		print("bye")
		text = backupText
		storedText = false
		backupText = ""
