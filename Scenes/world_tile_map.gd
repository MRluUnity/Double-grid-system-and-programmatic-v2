class_name DualGridTileMap extends TileMapLayer

#region 变量
@onready var display_tile_map_layer: TileMapLayer = $"../DisplayTileMapLayer"
@onready var display_tile_map_layer_2: TileMapLayer = $"../DisplayTileMapLayer2"
@onready var display_tile_map_layer_3: TileMapLayer = $"../DisplayTileMapLayer3"
@onready var display_tile_map_layer_4: TileMapLayer = $"../DisplayTileMapLayer4"

@export var grass_atlas_coord: Vector2i
@export var drit_atlas_coord : Vector2i
@export var water_atlas_coord: Vector2i
@export var sand_atlas_coord: Vector2i
@export_group("图块资源ID")
@export var char_id : int
@export var prop_id : int
@export var grass_id : int
@export var drit_id : int
@export var sand_id : int
@export var water_id : int

var can_set_tile : bool = true
#endregion

#region 常量
const FOUR_CELLS : Array[Vector2i] = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]

const TILE = {
	Vector2i(2, 1) : [TileType.NotNull, TileType.NotNull, TileType.NotNull, TileType.NotNull], # 草
	Vector2i(1, 3) : [TileType.Null, TileType.Null, TileType.Null, TileType.NotNull], # 右下角草
	Vector2i(0, 0) : [TileType.Null, TileType.Null, TileType.NotNull, TileType.Null], # 左下角草
	Vector2i(0, 2) : [TileType.Null, TileType.NotNull, TileType.Null, TileType.Null], # 右上角草
	Vector2i(3, 3) : [TileType.NotNull, TileType.Null, TileType.Null, TileType.Null], # 左上角草
	Vector2i(1, 0) : [TileType.Null, TileType.NotNull, TileType.Null, TileType.NotNull], # 右半边草
	Vector2i(3, 2) : [TileType.NotNull, TileType.Null, TileType.NotNull, TileType.Null], # 左半边草
	Vector2i(3, 0) : [TileType.Null, TileType.Null, TileType.NotNull, TileType.NotNull], # 下半边草
	Vector2i(1, 2) : [TileType.NotNull, TileType.NotNull, TileType.Null, TileType.Null], # 上半边草
	Vector2i(1, 1) : [TileType.Null, TileType.NotNull, TileType.NotNull, TileType.NotNull], # 左上角泥
	Vector2i(2, 0) : [TileType.NotNull, TileType.Null, TileType.NotNull, TileType.NotNull], # 右上角泥
	Vector2i(2, 2) : [TileType.NotNull, TileType.NotNull, TileType.Null, TileType.NotNull], # 左下角泥
	Vector2i(3, 1) : [TileType.NotNull, TileType.NotNull, TileType.NotNull, TileType.Null], # 右下角泥
	Vector2i(2, 3) : [TileType.Null, TileType.NotNull, TileType.NotNull, TileType.Null], # 左上与右下泥
	Vector2i(0, 1) : [TileType.NotNull, TileType.Null, TileType.Null, TileType.NotNull], # 左上与右下草
	Vector2i(0, 3) : [TileType.Null, TileType.Null, TileType.Null, TileType.Null]  # 泥
}
enum TileType {
	Null,
	NotNull,
	Grass,
	Drit,
	Water,
	Sand,
}
#endregion


func _ready() -> void:

	for coord : Vector2i in get_used_cells():
		set_display_tile(coord)

func set_tile(coords : Vector2i, atlas_coords : Vector2i) -> void:
	if not can_set_tile : return
	set_cell(coords, 0, atlas_coords)
	set_display_tile(coords)

func set_display_tile(pos : Vector2i) -> void:
	for i in FOUR_CELLS.size():
		var new_position : Vector2i = pos + FOUR_CELLS[i]
		calculate_display_tile(new_position)

func calculate_display_tile(new_position : Vector2i) -> void:
		var four_tile_type : Array[TileType]

		var up_left : TileType = get_world_tile(new_position - FOUR_CELLS[3])
		var up_right : TileType = get_world_tile(new_position - FOUR_CELLS[2])
		var down_left : TileType = get_world_tile(new_position - FOUR_CELLS[1])
		var down_right : TileType = get_world_tile(new_position - FOUR_CELLS[0])

		four_tile_type.append_array([up_left, up_right, down_left, down_right])

		create_tile_layer(new_position, four_tile_type, TileType.Grass)
		create_tile_layer(new_position, four_tile_type, TileType.Drit)
		create_tile_layer(new_position, four_tile_type, TileType.Sand)
		create_tile_layer(new_position, four_tile_type, TileType.Water)

func create_tile_layer(new_position : Vector2, four_tile_type : Array[TileType], tile_index : TileType) -> void:
	var current_four_tile_type : Array[TileType]
	var tile_layer : TileMapLayer
	var source_id : int

	if tile_index == TileType.Grass:
		tile_layer = display_tile_map_layer
		source_id = grass_id
	elif tile_index == TileType.Sand:
		tile_layer = display_tile_map_layer_2
		source_id = sand_id
	elif tile_index == TileType.Water:
		tile_layer = display_tile_map_layer_3
		source_id = water_id
	elif tile_index == TileType.Drit:
		tile_layer = display_tile_map_layer_4
		source_id = drit_id

	for i in four_tile_type:
		if i == tile_index:
			current_four_tile_type.append(TileType.NotNull)
			continue
		current_four_tile_type.append(TileType.Null)

	var tile_pos : Vector2i

	tile_pos = TILE.find_key(current_four_tile_type)

	tile_layer.set_cell(new_position, source_id, tile_pos)

func get_world_tile(coords : Vector2i) -> TileType:
		var atlas_coord : Vector2i = get_cell_atlas_coords(coords);
		if atlas_coord == grass_atlas_coord:
			return TileType.Grass
		elif atlas_coord == drit_atlas_coord:
			return TileType.Drit
		elif atlas_coord == sand_atlas_coord:
			return TileType.Sand
		elif atlas_coord == water_atlas_coord:
			return TileType.Water
		else :
			return TileType.Null
