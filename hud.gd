extends CanvasLayer

@export var max_hearts: int = 3
@export var full_heart: Texture2D
@export var empty_heart: Texture2D

@onready var hearts_container: HBoxContainer = $Root/MarginContainer/HBoxContainer


func _ready() -> void:
	# DO NOT CALL update_hearts() HERE
	pass


func update_hearts(current: int, max_health_value: int) -> void:
	current = clamp(current, 0, max_health_value)

	for i in range(hearts_container.get_child_count()):
		var heart := hearts_container.get_child(i) as TextureRect
		if i < current:
			heart.texture = full_heart
		else:
			heart.texture = empty_heart


func _on_Player_health_changed(current: int, max_health_value: int) -> void:
	update_hearts(current, max_health_value)
