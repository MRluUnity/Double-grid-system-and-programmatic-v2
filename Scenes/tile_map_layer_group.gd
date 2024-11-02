class_name GenerateCreater extends Node2D

@onready var world_tile_map_layer: DualGridTileMap = $WorldTileMapLayer
@onready var prop_tile_map_layer: TileMapLayer = $PropTileMapLayer
@onready var player: CharacterBody2D = $"../Player"
@onready var fps_label: Label = $"../CanvasLayer/FPSLabel"

@export var block_size : int = 24
@export var load_range_radius : int = 1

var noise : FastNoiseLite

var blocks : Array[Vector2] = []

var target_pos : Vector2
var current_block_coords : Vector2

var generate : Dictionary = {}
var props : Dictionary = {}
var waters : Dictionary = {}
var sands : Dictionary = {}

func _ready() -> void:

	randomize()
	noise = FastNoiseLite.new()
	noise.seed = randi()

	generate_block()

func _process(delta: float) -> void:
	fps_label.text = "FPS:"+str(Engine.get_frames_per_second())
	target_pos = player.global_position
	update_block_coords()

func update_block_coords() -> void:
	var block_coords : Vector2 = to_block_pos(target_pos)

	if current_block_coords != block_coords:
		print("========>新的区块：%s，当前区块：%s" % [block_coords, current_block_coords])
		current_block_coords = block_coords
		generate_block()


func generate_block() -> void:
	var start_coords := current_block_coords - Vector2(load_range_radius,load_range_radius)
	var end_coords := current_block_coords + Vector2(load_range_radius,load_range_radius) + Vector2.ONE

	var temp_blocks : Array[Vector2] = []
	for x:int in range(start_coords.x,end_coords.x):
		for y:int in range(start_coords.y,end_coords.y):
			temp_blocks.append(Vector2(x,y))

	var remove_blocks : Array[Vector2] = []
	for coords:Vector2 in blocks:
		if not temp_blocks.has(coords):
			remove_blocks.append(coords)
			remove_block(coords)
			await get_tree().process_frame

	for coords:Vector2 in remove_blocks:
		blocks.erase(coords)

	# 加载
	for coords:Vector2 in temp_blocks:
		if not blocks.has(coords):
			blocks.append(coords)
			add_block(coords)
			await get_tree().process_frame
			await get_tree().process_frame


func remove_block(coords : Vector2) -> void:
	#print("-------->删除区块：%s" % coords)

	for x in range(coords.x * block_size, coords.x * block_size + block_size):
		for y in range(coords.y * block_size, coords.y * block_size + block_size):
			delete_tile(Vector2(x, y))
			delete_prop(Vector2(x, y))

func add_block(coords : Vector2) -> void:
	print("-------->加载区块：%s" % coords)

	for x in range(coords.x * block_size, coords.x * block_size + block_size):
		for y in range(coords.y * block_size, coords.y * block_size + block_size):
			create_tile(Vector2(x, y))




func create_tile(coords : Vector2i) -> void:
	var main_value :float
	# 读取已保存的地图
	if generate.has(coords):
		main_value = generate[coords]

		if main_value == .1:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.grass_atlas_coord)

		if main_value == .2:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.sand_atlas_coord)

		if main_value == .3:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.water_atlas_coord)

	# 按照不同的噪声值绘制不同的地形
	else :
		main_value = noise.get_noise_2d(coords.x, coords.y)

		# 草地
		if main_value<0.1:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.grass_atlas_coord)

		# 泥土
		if main_value >= 0.1:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.drit_atlas_coord)

		# 沙子
		if main_value >= 0.16:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.sand_atlas_coord)

		# 海洋
		if main_value >= 0.24:
			world_tile_map_layer.set_cell(coords, world_tile_map_layer.char_id, world_tile_map_layer.water_atlas_coord)

	world_tile_map_layer.set_display_tile(coords)

	# 读取已保存的物品
	if props.has(coords):
		main_value = props[coords]
		if main_value == -.2:
			prop_tile_map_layer.set_cell(coords, world_tile_map_layer.prop_id, Vector2i.ZERO, 3)

		if main_value == -.1:
			prop_tile_map_layer.set_cell(coords, world_tile_map_layer.prop_id, Vector2i.ZERO, 1)

		if main_value == -.15:
			prop_tile_map_layer.set_cell(coords, world_tile_map_layer.prop_id, Vector2i.ZERO, 2)

	# 按照不同的噪声值绘制不同的物品
	else :
		if main_value > -0.3 and main_value < -0:
			var index : int = randi() % 100
			if index < 8:
				prop_tile_map_layer.set_cell(coords, world_tile_map_layer.prop_id, Vector2i.ZERO, randi_range(0, 2))

		if main_value > -0.3 and main_value < -0:
			var index : int = randi() % 100
			if index < 5:
				prop_tile_map_layer.set_cell(coords, world_tile_map_layer.prop_id, Vector2i.ZERO, 3)

func delete_tile(coords : Vector2i) -> void:
	if world_tile_map_layer.get_cell_atlas_coords(coords) == world_tile_map_layer.grass_atlas_coord:
		generate[coords] = 0.1
	elif world_tile_map_layer.get_cell_atlas_coords(coords) == world_tile_map_layer.sand_atlas_coord:
		generate[coords] = 0.2
	elif world_tile_map_layer.get_cell_atlas_coords(coords) == world_tile_map_layer.water_atlas_coord:
		generate[coords] = 0.3
	elif world_tile_map_layer.get_cell_atlas_coords(coords) == -Vector2i.ONE:
		generate[coords] = 0.1

	world_tile_map_layer.erase_cell(coords)

	world_tile_map_layer.set_display_tile(coords)

func delete_prop(coords : Vector2i) -> void:
	if props.has(coords):
		if props[coords] != prop_tile_map_layer.get_cell_alternative_tile(coords):
			if prop_tile_map_layer.get_cell_alternative_tile(coords) == -1:
				props.erase(coords)
			if prop_tile_map_layer.get_cell_alternative_tile(coords) == 1:
				props[coords] = -0.10
			elif prop_tile_map_layer.get_cell_alternative_tile(coords) == 2:
				props[coords] = -0.15
			elif prop_tile_map_layer.get_cell_alternative_tile(coords) == 3:
				props[coords] = -0.20

	if prop_tile_map_layer.get_cell_alternative_tile(coords) != -1 and prop_tile_map_layer.get_cell_alternative_tile(coords) != 0:
		if prop_tile_map_layer.get_cell_alternative_tile(coords) == 1:
			props[coords] = -0.10
		elif prop_tile_map_layer.get_cell_alternative_tile(coords) == 2:
			props[coords] = -0.15
		elif prop_tile_map_layer.get_cell_alternative_tile(coords) == 3:
			props[coords] = -0.20

	prop_tile_map_layer.erase_cell(coords)


func to_block_pos(screen_pos:Vector2):
	return floor(screen_pos / (Vector2(block_size, block_size) * Vector2(world_tile_map_layer.tile_set.tile_size)))
