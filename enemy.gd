extends CharacterBody2D

@export var speed: float = 30.0
@export var change_dir_time: float = 1.5
@export var max_health: int = 3

var health: int
var _dir: Vector2 = Vector2.ZERO
var _time_left: float = 0.0

func _ready() -> void:
	health = max_health
	randomize()
	_pick_new_direction()

func _physics_process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		_pick_new_direction()

	velocity = _dir * speed
	move_and_slide()

	# If we hit a wall, pick a new direction
	if get_slide_collision_count() > 0:
		_pick_new_direction()

func _pick_new_direction() -> void:
	var dirs := [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN
	]
	_dir = dirs[randi() % dirs.size()]
	_time_left = change_dir_time

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_damage()
