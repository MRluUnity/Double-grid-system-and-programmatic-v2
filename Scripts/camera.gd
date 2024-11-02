extends Camera2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP  and zoom.x < .7 and zoom.y < .7:
			zoom.x += event.factor * .01
			zoom.y += event.factor * .01
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x > .1 and zoom.y > .1:
			zoom.x -= event.factor * .01
			zoom.y -= event.factor * .01

		if is_zero_approx(zoom.x) || is_zero_approx(zoom.y):
			zoom.x = .01
			zoom.y = .01
