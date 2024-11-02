extends Node2D
@export var dualGridTilemap: DualGridTileMap
@onready var grid_line: ColorRect = %GridLine
@onready var cursor: AnimatedSprite2D = $Cursor

var target_pos:Vector2

## 单元格大小
@export var cell_size = Vector2i(256, 256)

func to_cell_pos(screen_pos:Vector2):
	return floor(screen_pos / Vector2(cell_size))

func _input(event):
	if event is InputEventMouseMotion:  # 鼠标移动
		var mouse_pos = get_global_mouse_position() # 鼠标位置
		target_pos = to_cell_pos(mouse_pos) * Vector2(cell_size)         # 获取鼠标所在位置单元格坐标


func _process(delta):
	cursor.global_position = target_pos + Vector2(128, 128)
	grid_line.global_position = get_global_mouse_position() + Vector2(-672, -672)

	var coords = dualGridTilemap.local_to_map(get_global_mouse_position()) - Vector2i(1, 1)
	if Input.is_action_pressed("left_click"):
		dualGridTilemap.set_tile(coords, dualGridTilemap.sand_atlas_coord)
	elif Input.is_action_pressed("right_click"):
		dualGridTilemap.set_tile(coords, dualGridTilemap.grass_atlas_coord)
