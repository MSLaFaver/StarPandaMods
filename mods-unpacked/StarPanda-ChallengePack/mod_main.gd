extends Node

const id = "StarPanda-ChallengePack"
const STPND_CHALLENGEPACK_LOG := "StarPanda-ChallengePack:Main"
const CPGameConfig = preload("res://mods-unpacked/StarPanda-ChallengePack/util/CPGameConfig.gd")

const hooks = [
	"scripts/DeathManager.gd",
	"scripts/ItemManager.gd",
	"scripts/ShellSpawner.gd",
	"scripts/ShellLoader.gd"
]

var patches := {}
var last_scene := ""
var config_data

signal cp_death
signal cp_steal_start
signal cp_steal_end

var config_defaults = {
	"mode": CPGameConfig.GameMode.DEFAULT,
	"items": CPGameConfig.ItemMode.DEFAULT,
	"shuffle": CPGameConfig.ShuffleMode.YES,
	"turn": CPGameConfig.TurnMode.ALWAYS_FIRST
}

func _init() -> void:
	ModLoaderLog.debug("Init phase started", STPND_CHALLENGEPACK_LOG)
	randomize()
	
	for hook in hooks:
		ModLoaderMod.install_script_hooks("res://%s" % hook,
			"res://mods-unpacked/%s/%s" % [id, hook])
	
	add_patches()
	ModLoaderLog.debug("Init phase finished", STPND_CHALLENGEPACK_LOG)
	
func add_patches() -> void:
	var patches_dir_path = "res://mods-unpacked/%s/patches" % id
	
	var dir = DirAccess.open(patches_dir_path)
	for file in dir.get_files():
		if (file == "patch.gd"):
			continue
		var cl = load(patches_dir_path + "/" + file)
		var obj = cl.new()
		ModLoaderLog.debug("Found patch for scene '" + obj.getSceneName() + "': " + file, STPND_CHALLENGEPACK_LOG)
		
		if !(patches.has(obj.getSceneName())):
			patches[obj.getSceneName()] = []
		patches[obj.getSceneName()].append(obj)

func _ready() -> void:
	ModLoader.get_node("MSLaFaver-ModMenu").config_init(id, config_defaults)
	
	ModLoaderLog.info("Mod Ready!", STPND_CHALLENGEPACK_LOG)
	
func apply_patches():
	var scene := get_scene_name()
	if scene and patches.has(scene.name):
		var repeated = (last_scene == scene.name)
		last_scene = scene.name
		
		if (!repeated):
			ModLoaderLog.debug("Scene loaded: " + last_scene, STPND_CHALLENGEPACK_LOG)
		
		var config = ModLoaderConfig.get_config(id, "user")
		if config != null:
			config_data = config.data
		
		var patchArr = patches[scene.name]
		for patch in patchArr:
			patch.mod_main = self
			patch.apply(scene, repeated)
		
func get_scene_name() -> Node:
	return get_tree().current_scene;
