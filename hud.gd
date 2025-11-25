extends CanvasLayer

@export var max_hearts: int = 3
@export var full_heart: Texture2D
@export var empty_heart: Texture2D

var hearts_container: HBoxContainer


func _ready() -> void:
	# Now the node tree is ready, so this path is valid
	hearts_container = $Root/MarginContainer/HBoxContainer
	# Initialize to full hearts (in case we missed an early signal)
	update_hearts(max_hearts, max_hearts)


func update_hearts(current: int, max_health_value: int) -> void:
	# If called too early (before _ready), just ignore
	if hearts_container == null:
		return

	current = clamp(current, 0, max_health_value)

	for i in range(hearts_container.get_child_count()):
		var heart := hearts_container.get_child(i) as TextureRect

		if i < current:
			# FULL HEART
			heart.texture = full_heart
			heart.modulate = Color(1, 1, 1, 1)
		else:
			# EMPTY HEART
			if empty_heart:
				heart.texture = empty_heart
				heart.modulate = Color(1, 1, 1, 1)
			else:
				# fallback: dark full-heart
				heart.texture = full_heart
				heart.modulate = Color(0.25, 0.25, 0.25, 1)


func _on_player_health_changed(current: int, max_health_value: int) -> void:
	update_hearts(current, max_health_value)
