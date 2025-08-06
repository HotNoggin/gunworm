@tool
extends Node
class_name Worm

signal worm_changed(worm: Worm)

@export_category("Scenes")
@export var segments_scene: PackedScene
@export var turd_scene: PackedScene
@export var snip_scene: PackedScene
@export var flash_scene: PackedScene
@export_category("Worm")
@export var worm_data: WormData
@export var segments: Array[Segment]
@export var dead_texture: Texture2D
@export var reset_timer: Timer

@export var able: Abilities

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


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		adjust_worm()
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
	shooting = able.gun and Input.is_action_just_pressed("shoot")
	pooping = able.turd and Input.is_action_just_pressed("poop")
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
	Tile.do_turns()
	adjust_worm()
	worm_changed.emit(self)
	move_rooms()


func try_move() -> void:
	var head: Segment = segments.front() as Segment
	var goal_pos: Vector2i = head.tile_position + motion_dir
	if Tile.has(goal_pos):
		var tile: Tile = Tile.at(goal_pos)
		if Tile.at(goal_pos) == segments[1]:
			if able.smart: reverse_worm()
		elif tile.tasty or (tile.brittle and able.hungry):
			if tile is Segment:
				cut_worm(tile as Segment)
			else:
				if tile is Ability:
					collect(tile as Ability)
				tile.queue_free()
			if able.growing and tile.tasty: grow_worm()
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


func move_rooms() -> void:
	var head: Segment = segments.front() as Segment
	var pos: Vector2i = head.tile_position
	var move_dir: Vector2i = Vector2i.ZERO
	if pos.x > 15: move_dir.x = 1
	if pos.x < 0: move_dir.x = -1
	if pos.y > 15: move_dir.y = 1
	if pos.y < 0: move_dir.y = -1
	if move_dir != Vector2i.ZERO:
		RoomManager.manager.move_room(move_dir)


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
	if segments.size() < 0: return
	
	for i: int in range(segments.size() - 1, 0, -1):
		var segment: Segment = segments[i]
		if not is_instance_valid(segment) or segment.is_queued_for_deletion():
			cut_worm(segment)
	
	if dead or segments.size() < 3:
		for segment: Segment in segments:
			segment.sprite.texture = dead_texture
	
	for i: int in range(0, segments.size()):
		var segment: Segment = segments[i]
		# Previous segment if this is NOT the head
		var prev: Segment = segments[i - 1] if i > 0 else null
		# Next segment if this is NOT the tail
		var next: Segment = segments[i + 1] if i < segments.size() - 1 else null
		segment.adjust(prev, next)


func grow_worm(offset: Vector2i = Vector2i.ZERO) -> void:
	var segment: Segment = segments_scene.instantiate() as Segment
	var end: Segment = null
	if not segments.is_empty(): end = segments.back() as Segment
	add_child(segment)
	move_child(segment, 0)
	var end_position: Vector2i
	if is_instance_valid(end): end_position = end.tile_position
	segment.tile_position = end_position + offset
	segment.place()
	segments.append(segment)


func drop_turd() -> void:
	var end: Segment = segments.back() as Segment
	var tile: Tile = turd_scene.instantiate() as Tile
	add_sibling(tile)
	tile.tile_position = end.tile_position
	end.queue_free()
	tile.place()


func cut_worm(tile: Segment, where: int = -1, drop_snips: bool = true) -> void:
	var cutting: bool = false
	var endsize: int = segments.size()
	for i: int in range(0, segments.size()):
		var segment: Segment = segments[i]
		if segment == tile or i == where:
			cutting = true
			endsize = i
		if cutting:
			if endsize == i or (not drop_snips):
				segment.queue_free()
			else:
				var snip: Tile = snip_scene.instantiate() as Tile
				add_sibling(snip)
				snip.tile_position = segment.tile_position
				segment.queue_free()
				snip.place()
	segments.resize(endsize)


func collect(ability: Ability) -> void:
	ability.flash()
	SaveData.loaded.ability_names.append(ability.ability_name)
	var has: Abilities = ability.abilities
	if has.growing: able.growing = true
	if has.hungry: able.hungry = true
	if has.turd: able.turd = true
	if has.smart: able.smart = true
	if has.gun: able.gun = true
