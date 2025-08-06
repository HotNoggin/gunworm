@tool
extends Tile
class_name Segment

@export var sprite: Sprite2D
@export var tail: int = 0
@export var mid: int = 1
@export var head: int = 2
@export var bend: int = 3

const DIR_UP: Vector2i = Vector2i.UP
const DIR_DOWN: Vector2i = Vector2i.DOWN
const DIR_LEFT: Vector2i = Vector2i.LEFT
const DIR_RIGHT: Vector2i = Vector2i.RIGHT

# A dictionary to map direction pairs to rotations for bent segments.
const BENT_ROTATIONS: Dictionary[Array, int] = {
	[DIR_UP, DIR_RIGHT]: 90,
	[DIR_RIGHT, DIR_UP]: 90,
	[DIR_UP, DIR_LEFT]: 0,
	[DIR_LEFT, DIR_UP]: 0,
	[DIR_DOWN, DIR_RIGHT]: 180,
	[DIR_RIGHT, DIR_DOWN]: 180,
	[DIR_DOWN, DIR_LEFT]: -90,
	[DIR_LEFT, DIR_DOWN]: -90,
}


func _process(_delta: float) -> void:
	if auto_position and Engine.is_editor_hint():
		tile_position = global_position / 8


# Make the segment look like the proper part of the snake
# Prev is the segment closer to the HEAD, as the head is first
# Next is the segment closer to the TAIL, as the tail is last
func adjust(prev_segment: Segment, next_segment: Segment) -> void:
	# Get the grid positions
	var spot: Vector2i = tile_position
	var prev: Vector2i = prev_segment.tile_position if is_instance_valid(prev_segment) else Vector2i.ZERO
	var next: Vector2i = next_segment.tile_position if is_instance_valid(next_segment) else Vector2i.ZERO

	var prev_dir: Vector2i
	if is_instance_valid(prev_segment):
		prev_dir = prev - spot

	var next_dir: Vector2i
	if is_instance_valid(next_segment):
		next_dir = next - spot

	# Head
	if not is_instance_valid(prev_segment):
		sprite.frame = head
		match next_dir:
			DIR_UP: sprite.rotation_degrees = 180
			DIR_DOWN: sprite.rotation_degrees = 0
			DIR_LEFT: sprite.rotation_degrees = 90
			DIR_RIGHT: sprite.rotation_degrees = -90

	# Tail
	elif not is_instance_valid(next_segment):
		sprite.frame = tail
		match prev_dir:
			DIR_UP: sprite.rotation_degrees = 0
			DIR_DOWN: sprite.rotation_degrees = 180
			DIR_LEFT: sprite.rotation_degrees = -90
			DIR_RIGHT: sprite.rotation_degrees = 90

	# Middle
	else:
		# Straight
		if prev_dir == -next_dir:
			sprite.frame = mid
			# Vertical or horizontal
			if prev_dir == DIR_UP or prev_dir == DIR_DOWN:
				sprite.rotation_degrees = 0
			else:
				sprite.rotation_degrees = 90
		# bent
		else:
			sprite.frame = bend
			var dirs: Array = [prev_dir, next_dir]
			dirs.sort()
			sprite.rotation_degrees = BENT_ROTATIONS.get(dirs, 0)
