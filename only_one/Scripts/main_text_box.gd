extends RichTextLabel

var backupText = "" 

var storedText = false
var dragLocked = false
var tempTextDisabled = false

var textQueue: Array = []
signal clickedThroughText
signal textProgressed

func _ready() -> void:
	text = ""

func showText(Text: String) -> void:
	text = Text
	
func queueText(textToQueue: String) -> void:
	if (textQueue.size() == 0 and text == "" and textToQueue != ""):
		text = textToQueue
	else:
		if (textToQueue != ""):
			textQueue.append(textToQueue)

func queueTextsFromArray(textsToQueue: Array) -> void:
	var needToDisplay
	if (textQueue.size() == 0 and text == ""):
		needToDisplay = true
	for i in textsToQueue.size():
		if (textsToQueue[i] != ""):
			textQueue.append(textsToQueue[i])
	if (needToDisplay == true):
		proceedQueue()

func proceedQueue() -> void:
	if (textQueue.size() != 0):
		if (textQueue[0] == "SIGNAL_CLICKED_THROUGH"):
			textQueue.pop_front()
			clickedThroughText.emit()
			if (textQueue.size() != 0):
				text = textQueue.pop_front()
			else:
				text = ""
		else:
			text = textQueue.pop_front()
			textProgressed.emit()

func showTempText(tempText: String) -> void:
	if (tempTextDisabled == false):
		if (storedText == false and dragLocked == false):
			backupText = text
			storedText = true
		if (dragLocked == false):
			text = tempText

func forceDragText(tempText: String) -> void:
	if (tempTextDisabled == false):
		text = tempText
		dragLocked = true
	
func stopShowingTempText() -> void:
	if (tempTextDisabled == false):
		if (storedText == true and dragLocked == false):
			text = backupText
			storedText = false
			backupText = ""
