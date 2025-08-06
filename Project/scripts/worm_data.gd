class_name WormData
extends Resource

@export var positions: Array[Vector2i]
@export var offset: Vector2i


func save_worm(worm: Worm) -> void:
	positions.clear()
	for segment: Segment in worm.segments:
		var position: Vector2i = segment.tile_position
		positions.append(position)
	var head: Vector2i = positions[0]
	var goal_pos: Vector2i = Vector2i(-1, -1)
	if head.x > 15: goal_pos = Vector2i(0, head.y)
	if head.x < 0: goal_pos = Vector2i(15, head.y)
	if head.y > 15: goal_pos = Vector2i(head.x, 0)
	if head.y < 0: goal_pos = Vector2i(head.x, 15)
	if goal_pos.x > 0: offset = goal_pos - head


func load_worm(worm: Worm) -> void:
	print("loading worm")
	worm.grow_worm(positions[0] + offset)
	for i: int in range(1, positions.size()):
		var grow_dir: Vector2i = positions[i] - positions[i - 1]
		worm.grow_worm(grow_dir)
	worm.adjust_worm()
