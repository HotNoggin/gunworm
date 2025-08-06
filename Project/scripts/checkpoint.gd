@tool
class_name Checkpoint
extends Tile


func act() -> void:
	if Tile.has(tile_position):
		var tile: Tile = Tile.at(tile_position)
		if tile is Segment and tile.get_parent() is Worm:
			var worm: Worm = tile.get_parent() as Worm
			if worm.segments.front() == tile:
				worm.cut_worm(null, 3, false)
				var room: Room = RoomManager.manager.room
				room.worm_data.save_worm(worm)
				room.start_data = room.worm_data.duplicate()
				SaveData.save()
