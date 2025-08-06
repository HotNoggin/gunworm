class_name SaveData
extends Resource

static var loaded: SaveData
static var worm_abilities: Abilities
static var worm_data: WormData

@export var ability_names: Array[StringName]
@export var abilites: Abilities
@export var worm_offset: Vector2i
@export var worm_positions: Array[Vector2i]
@export var start_room: Vector2i


static func initialize() -> void:
	worm_abilities = load("res://resources/worm_abilities.tres") as Abilities
	worm_data = load("res://resources/worm_data.tres") as WormData
	loaded = SaveData.new()
	loaded.abilites = Abilities.new()


static func load_save() -> void:
	var data: SaveData = null
	if ResourceLoader.exists("user://save.tres"):
		data = SafeResourceLoader.load("user://save.tres") as SaveData
	if data != null and data is SaveData:
		loaded = data
	
	worm_data.positions = loaded.worm_positions
	worm_data.offset = loaded.worm_offset
	RoomManager.manager.room.start_data = worm_data.duplicate()
	worm_abilities.growing = loaded.abilites.growing
	worm_abilities.hungry = loaded.abilites.hungry
	worm_abilities.smart = loaded.abilites.smart
	worm_abilities.turd = loaded.abilites.turd
	worm_abilities.gun = loaded.abilites.gun


static func save() -> void:
	if loaded == null:
		loaded = SaveData.new()
	var start_data: WormData = RoomManager.manager.room.start_data
	loaded.abilites = worm_abilities.duplicate()
	loaded.worm_offset = start_data.offset
	loaded.worm_positions = start_data.positions.duplicate()
	ResourceSaver.save(loaded, "user://save.tres")
