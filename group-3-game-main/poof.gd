extends Node2D

var life_time := 0.2     # how long the poof lasts
var radius := 0.0        # how far the pixels spread
var alpha := 1.0         # fade out

const PIXEL_SIZE := 1    # size of each "spark" square
const RAYS := 6          # how many pixel rays around the center


func start():
	var tween := create_tween()

	# Expand outwards
	tween.tween_property(self, "radius", 10.0, life_time)

	# Fade out
	tween.parallel().tween_property(self, "alpha", 0.0, life_time)

	await tween.finished
	queue_free()


func _draw():
	# Pixel-style starburst
	for i in RAYS:
		var angle := TAU * float(i) / float(RAYS)
		var dir := Vector2.RIGHT.rotated(angle)
		var pos := dir * radius

		# small square "spark"
		var size := Vector2(PIXEL_SIZE, PIXEL_SIZE)
		var rect := Rect2(pos - size * 0.5, size)

		draw_rect(rect, Color(1, 1, 1, alpha))


func _process(_delta):
	queue_redraw()
