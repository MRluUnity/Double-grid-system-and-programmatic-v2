extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	var tile_map_layer : TileMapLayer = get_parent()
	var generate_creater : GenerateCreater = tile_map_layer.get_parent()
	generate_creater.delete_prop(tile_map_layer.local_to_map(position))
	queue_free()
