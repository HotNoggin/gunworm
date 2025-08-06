@tool
class_name MapEditor
extends Node2D

@export var generate: bool:
	set(val):
		generate_world()
@export var world_map: WorldMap


func generate_world() -> void:
	world_map.rooms.clear()
	for child: Node2D in get_children():
		var where: Vector2i = child.position / 128
		world_map.rooms[where] = child.scene_file_path
	notify_property_list_changed()
	ResourceSaver.save(world_map)
