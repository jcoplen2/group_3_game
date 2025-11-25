extends CharacterBody2D

@export var speed: float = 30.0
@export var change_dir_time: float = 1.5
@export var max_health: int = 3

@export var knockback_speed: float = 80.0
@export var knockback_duration: float = 0.15

var health: int
var _dir: Vector2 = Vector2.ZERO
var _time_left: float = 0.0

var _knockback_time: float = 0.0
var _knockback_dir: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	health = max_health
	randomize()
	_pick_new_direction()


func _physics_process(delta: float) -> void:
	if _knockback_time > 0.0:
		_knockback_time -= delta
		velocity = _knockback_dir * knockback_speed
		move_and_slide()
		return

	_time_left -= delta
	if _time_left <= 0.0:
		_pick_new_direction()

	velocity = _dir * speed
	move_and_slide()

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

func take_damage(amount: int, from_position: Vector2) -> void:
	health -= amount
	print(name, " took ", amount, " damage. HP: ", health)

	_apply_knockback(from_position)
	_flash_on_hit()

	if health <= 0:
		_die()


func _apply_knockback(from_position: Vector2) -> void:
	var dir := (global_position - from_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.DOWN

	_knockback_dir = dir
	_knockback_time = knockback_duration


func _flash_on_hit() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.4, 0.4), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 0.4, 0.4), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.05)

func _die() -> void:
	# Disable collisions
	$CollisionShape2D.disabled = true
	$hitbox/CollisionShape2D.disabled = true
	$hitbox.monitoring = false
	$hitbox.monitorable = false

	velocity = Vector2.ZERO

	var poof := $Poof.duplicate()
	get_parent().add_child(poof)
	poof.global_position = global_position
	poof.visible = true          
	poof.start()                 

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Sprite2D, "scale", $Sprite2D.scale * 0.4, 0.2)
	tween.parallel().tween_property($Sprite2D, "modulate", Color(1, 0.3, 0.3, 0), 0.2)

	await tween.finished
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_damage(1)
