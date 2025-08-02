@tool
extends Node2D
class_name Tile

signal moved

static var grid: Dictionary[Vector2i, Tile]
static var ground: Dictionary[Vector2i, Tile]
static var all_tiles: Array 

@export var solid: bool = false
@export var tasty: bool = false
@export var brittle: bool = false
@export var tile_position: Vector2i:
	set(val):
		tile_position = val
		Tile.update()
		moved.emit()
@export var auto_position: bool = true

static func update() -> void:
	grid.clear()
	ground.clear()
	for tile: Tile in Tile.all_tiles:
		if tile.solid:
			grid[tile.tile_position] = tile
		else:
			ground[tile.tile_position] = tile
		tile.place()

static func has(where: Vector2i, gnd: bool = false) -> bool:
	return Tile.ground.has(where) if gnd else Tile.grid.has(where)

static func at(where: Vector2i, gnd: bool = false) -> Tile:
	return Tile.ground.get(where) as Tile if gnd else Tile.grid.get(where)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if auto_position:
		tile_position = global_position / 8
	place()


func place() -> void:
	if Engine.is_editor_hint():
		return
	global_position = Vector2(tile_position * 8) + Vector2(4, 4)


func _enter_tree() -> void:
	Tile.all_tiles.append(self)

func _exit_tree() -> void:
	Tile.all_tiles.erase(self)
