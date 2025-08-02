@tool
extends Node
class_name Worm

@export var segments_scene: PackedScene
@export var segments: Array[Segment]

var motion_dir: Vector2i


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	adjust_worm()
	if Engine.is_editor_hint():
		return


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	motion_dir = Vector2i.ZERO
	if Input.is_action_just_pressed("up"):
		motion_dir = Vector2i.UP
	if Input.is_action_just_pressed("down"):
		motion_dir = Vector2i.DOWN
	if Input.is_action_just_pressed("left"):
		motion_dir = Vector2i.LEFT
	if Input.is_action_just_pressed("right"):
		motion_dir = Vector2i.RIGHT
	
	if motion_dir != Vector2i.ZERO:
		do_turn()


func do_turn() -> void:
	try_move()
	adjust_worm()


func try_move() -> void:
	var head: Segment = segments.front() as Segment
	var goal_pos: Vector2i = head.tile_position + motion_dir
	if Tile.has(goal_pos):
		var tile: Tile = Tile.at(goal_pos)
		if tile.tasty:
			tile.queue_free()
			grow_worm()
			move_worm()
	else:
		move_worm()


func move_worm() -> void:
	var head: Segment = segments.front() as Segment
	var positions: Array[Vector2i]
	# Move
	for i: int in range(0, segments.size()):
		var segment: Segment = segments[i]
		positions.append(segment.tile_position)
	for i: int in range(1, segments.size()):
		var segment: Segment = segments[i] as Segment
		segment.tile_position = positions[i - 1]
	head.tile_position += motion_dir


func adjust_worm() -> void:
	if segments.size() > 0:
		for i: int in range(0, segments.size()):
			var segment: Segment = segments[i]
			# Previous segment if this is NOT the head
			var prev: Segment = segments[i - 1] if i > 0 else null
			# Next segment if this is NOT the tail
			var next: Segment = segments[i + 1] if i < segments.size() - 1 else null
			segment.adjust(prev, next)


func grow_worm() -> void:
	var segment: Segment = segments_scene.instantiate() as Segment
	var end: Segment = segments.back() as Segment
	add_child(segment)
	move_child(segment, 0)
	segment.tile_position = end.tile_position
	segment.place()
	segments.append(segment)
