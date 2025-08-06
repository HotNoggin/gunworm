@tool
class_name Checkpoint
extends Tile


func act() -> void:
	if Tile.has(tile_position):
		var tile: Tile = Tile.at(tile_position)
		if tile is Segment and tile.get_parent() is Worm:
			var worm: Worm = tile.get_parent() as Worm
			worm.cut_worm(null, 3, false)
