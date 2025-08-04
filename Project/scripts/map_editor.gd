@tool
class_name MapEditor
extends Node2D

@export var generate: bool:
	set(val):
		generate_world()
@export var world_map: WorldMap


func generate_world() -> void:
	for child: Node2D in get_children():
		var where: Vector2i = child.position / 128
		var scene: PackedScene = load(child.scene_file_path)
		world_map.rooms[where] = scene
