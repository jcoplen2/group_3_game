extends Area2D
signal picked_up
var textures = {"health": "res://images/health_pickup.png"}
@onready var target = $"res://player.gd"


func init(type, _position):
	$Sprite2D.texture = load(textures[type])
	position = _position

func _on_body_entered():
	picked_up.emit()
	queue_free()


func _on_picked_up():
	target.health += 1
