extends Control

const CPGameConfig = preload("res://mods-unpacked/StarPanda-ChallengePack/util/CPGameConfig.gd")

@export var button_class_mode: ButtonClass
@export var button_class_items: ButtonClass
@export var button_class_shuffle: ButtonClass
@export var button_class_turn: ButtonClass

const id = "StarPanda-ChallengePack"

var totalGameModes = len(CPGameConfig.GameMode.keys())
var totalItemModes = len(CPGameConfig.ItemMode.keys())
var totalShuffleModes = len(CPGameConfig.ShuffleMode.keys())
var totalTurnModes = len(CPGameConfig.TurnMode.keys())

var buttons: Array[ButtonClass]

func _ready():
	buttons = [button_class_mode, button_class_items, button_class_shuffle, button_class_turn]
	for button in buttons:
		button.cursor = get_node("/root/menu/standalone managers/cursor manager")
		button.speaker_press = get_node("/root/menu/speaker_press")
		button.speaker_hover = get_node("/root/menu/speaker_hover")
	
	button_class_mode.connect("is_pressed", func(): _on_mode_button_click("mode", totalGameModes))
	button_class_items.connect("is_pressed", func(): _on_mode_button_click("items", totalItemModes))
	button_class_shuffle.connect("is_pressed", func(): _on_mode_button_click("shuffle", totalShuffleModes))
	button_class_turn.connect("is_pressed", func(): _on_mode_button_click("turn", totalTurnModes))
	
	_update_labels()
	
func _on_mode_button_click(setting_name, total_modes) -> void:
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		var mode_id = config.data[setting_name]
		var next_mode = (mode_id + 1) if (mode_id + 1 < total_modes) else 0
		
		config.data[setting_name] = next_mode
		ModLoaderConfig.update_config(config)
		_update_labels()

func _update_labels():
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		var mode_id = config.data.mode
		var item_mode_id = config.data.items
		var shuffle_mode_id = config.data.shuffle
		var turn_mode_id = config.data.turn
		
		buttons[0].ui.text = "shell visibility: " + CPGameConfig.GameMode.keys()[mode_id]
		buttons[1].ui.text = "items visibility: " + CPGameConfig.ItemMode.keys()[item_mode_id]
		buttons[2].ui.text = "shuffle bullets: " + CPGameConfig.ShuffleMode.keys()[shuffle_mode_id]
		buttons[3].ui.text = "first turn: " + CPGameConfig.TurnMode.keys()[turn_mode_id].replace("_", " ")
