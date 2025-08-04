@tool
extends Node
class_name Worm

@export_category("Scenes")
@export var segments_scene: PackedScene
@export var turd_scene: PackedScene
@export var snip_scene: PackedScene
@export var flash_scene: PackedScene
@export_category("Worm")
@export var segments: Array[Segment]
@export var dead_texture: Texture2D
@export var reset_timer: Timer

@export_category("Abililties")
@export var growing: bool # Things that you eat make you grow!
@export var hungry: bool # You can eat brittle things, too!
@export var smart: bool # You can back up to reverse the worm!
@export var turd: bool # You can snip off the end of yourself.
@export var gun: bool # Bang bang.

var motion_dir: Vector2i
var shooting: bool
var pooping: bool
var killing: bool
var dead: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	adjust_worm()
	if Engine.is_editor_hint():
		return
	reset_timer.timeout.connect(get_tree().reload_current_scene)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if segments.size() < 3:
		dead = true
	
	if dead:
		if reset_timer.is_stopped(): reset_timer.start()
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
	shooting = gun and Input.is_action_just_pressed("shoot")
	pooping = turd and Input.is_action_just_pressed("poop")
	killing = Input.is_action_just_pressed("reset")
	
	if motion_dir != Vector2i.ZERO or shooting or pooping or killing:
		do_turn()


func do_turn() -> void:
	if killing:
		dead = true
	elif shooting:
		shoot()
	elif pooping:
		drop_turd()
	elif motion_dir != Vector2i.ZERO:
		try_move()
	adjust_worm()


func try_move() -> void:
	var head: Segment = segments.front() as Segment
	var goal_pos: Vector2i = head.tile_position + motion_dir
	if Tile.has(goal_pos):
		var tile: Tile = Tile.at(goal_pos)
		if Tile.at(goal_pos) == segments[1]:
			if smart: reverse_worm()
		elif tile.tasty or (tile.brittle and hungry):
			if tile is Segment:
				cut_worm(tile as Segment)
			else:
				tile.queue_free()
			if growing and tile.tasty: grow_worm()
			move_worm()
	else:
		move_worm()


func move_worm() -> void:
	var head: Segment = segments.front() as Segment
	var positions: Array[Vector2i]
	# Move
	for segment: Segment in segments:
		positions.append(segment.tile_position)
	for i: int in range(1, segments.size()):
		var segment: Segment = segments[i] as Segment
		segment.tile_position = positions[i - 1]
	head.tile_position += motion_dir


func shoot() -> void:
	var head: Segment = segments.front() as Segment
	var second: Segment = segments[1] as Segment
	var dir: Vector2i = head.tile_position - second.tile_position
	var where: Vector2i = head.tile_position
	for i: int in range(0, 16):
		(segments.back() as Segment).queue_free()
		where += dir
		if Tile.has(where):
			# Destroy brittle tiles
			var tile: Tile = Tile.at(where)
			if tile.brittle:
				tile.queue_free()
			else:
				break
		var flash: Node2D = flash_scene.instantiate() as Node2D
		add_sibling(flash)
		flash.global_position = where * 8


func reverse_worm() -> void:
	var tail: Segment = segments.back() as Segment
	var second: Segment = segments[segments.size() - 2] as Segment
	var dir: Vector2i = tail.tile_position - second.tile_position
	var goal: Vector2i = tail.tile_position + dir
	if Tile.has(goal): return
	var positions: Array[Vector2i]
	# Move
	for segment: Segment in segments:
		positions.append(segment.tile_position)
	for i: int in range(0, segments.size() - 1):
		var segment: Segment = segments[i]
		segment.tile_position = positions[i + 1]
	tail.tile_position = goal


func adjust_worm() -> void:
	for i: int in range(segments.size() - 1, 0, -1):
		var segment: Segment = segments[i]
		if not is_instance_valid(segment) or segment.is_queued_for_deletion():
			cut_worm(segment)
	if dead or segments.size() < 3:
		for segment: Segment in segments:
			segment.sprite.texture = dead_texture
	if segments.size() > 0:
		for i: int in range(0, segments.size()):
			var segment: Segment = segments[i]
			# Previous segment if this is NOT the head
			var prev: Segment = segments[i - 1] if i > 0 else null
			# Next segment if this is NOT the tail
			var next: Segment = segments[i + 1] if i < segments.size() - 1 else null
			segment.adjust(prev, next)


func grow_worm(dir: Vector2i = Vector2i.ZERO) -> void:
	var segment: Segment = segments_scene.instantiate() as Segment
	var end: Segment = segments.back() as Segment
	add_child(segment)
	move_child(segment, 0)
	segment.tile_position = end.tile_position + dir
	segment.place()
	segments.append(segment)


func drop_turd() -> void:
	var end: Segment = segments.back() as Segment
	var tile: Tile = turd_scene.instantiate() as Tile
	add_sibling(tile)
	tile.tile_position = end.tile_position
	end.queue_free()
	tile.place()


func cut_worm(tile: Segment, where: int = -1) -> void:
	var cutting: bool = false
	var endsize: int = segments.size()
	for i: int in range(0, segments.size()):
		var segment: Segment = segments[i]
		if segment == tile or i == where:
			cutting = true
			endsize = i
		if cutting:
			if endsize == i:
				segment.queue_free()
			else:
				var snip: Tile = snip_scene.instantiate() as Tile
				add_sibling(snip)
				snip.tile_position = segment.tile_position
				segment.queue_free()
				snip.place()
	segments.resize(endsize)
