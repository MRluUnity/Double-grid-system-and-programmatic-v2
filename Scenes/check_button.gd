extends CheckButton
@onready var world_tile_map_layer: DualGridTileMap = $"../../TileMapLayerGroup/WorldTileMapLayer"
@onready var grid_line: ColorRect = %GridLine

func _on_toggled(toggled_on: bool) -> void:
	grid_line.visible = toggled_on
	world_tile_map_layer.can_set_tile = toggled_on
