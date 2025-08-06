class_name RoomManager
extends Node

@export var world: WorldMap
@export var room: Room

static var manager: RoomManager

var location: Vector2i


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manager = self
	SaveData.initialize()
	SaveData.load_save()


func reload() -> void:
	print("Reloading current room")
	move_room(Vector2i.ZERO)


func move_room(dir: Vector2i) -> void:
	location += dir
	room.queue_free()
	print("Changing rooms to " + str(location))
	var new_room_scene: PackedScene = load(world.rooms[location])
	var new_room: Node2D = new_room_scene.instantiate() as Node2D
	add_child(new_room)
	room = new_room
