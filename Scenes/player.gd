extends CharacterBody2D


@export var speed = 4500.0
var dir : Vector2

#func _process(delta: float) -> void:
	#dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")


func _physics_process(delta: float) -> void:
	velocity = speed * Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	move_and_slide()
	#move_and_collide()
