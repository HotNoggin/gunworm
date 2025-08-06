@tool
class_name Ability
extends Tile

@export var ability_name: StringName
@export var abilities: Abilities
@export var flash_scene: PackedScene
@export var text: Label


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	if ability_name in SaveData.loaded.ability_names:
		queue_free()


func flash() -> void:
	text.show()
	var where: Vector2i = tile_position - Vector2i.ONE
	for x: int in range(0, 3):
		for y: int in range(0, 3):
			var spawn_tile: Vector2i = where + Vector2i(x, y)
			var effect: Node2D = flash_scene.instantiate() as Node2D
			add_sibling(effect)
			effect.global_position = spawn_tile * 8
