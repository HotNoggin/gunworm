class_name Room
extends Node2D

@export var worm_data: WormData = preload("res://resources/worm_data.tres")
@export var worm_scene: PackedScene = preload("res://scenes/entities/worm.tscn")

var worm: Worm
var start_data: WormData


func _ready() -> void:
	worm = worm_scene.instantiate() as Worm
	add_child(worm)
	worm.worm_changed.connect(worm_data.save_worm)
	worm_data.load_worm(worm)
	start_data = worm_data.duplicate()
	worm.reset_timer.timeout.connect(_reset)
	worm_data.save_worm(worm)


func _reset() -> void:
	worm_data.positions = start_data.positions
	worm_data.offset = start_data.offset
	RoomManager.manager.reload()
