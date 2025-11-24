extends CharacterBody2D

@export var move_speed: float = 80.0
@export var shield_speed_factor: float = 0.8  

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var facing_dir: Vector2 = Vector2.DOWN
var attacking: bool = false
var shielding: bool = false


func _physics_process(_delta: float) -> void:
	if attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vec := Vector2(
		Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left"),
		Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")
	)

	var moving := false

	if input_vec.length() > 0.0:
		input_vec = input_vec.normalized()
		moving = true
		facing_dir = input_vec

		var speed := move_speed
		if shielding:
			speed *= shield_speed_factor

		velocity = input_vec * speed
	else:
		velocity = Vector2.ZERO

	if shielding:
		if moving:
			_play_shield_walk_anim(input_vec)
		else:
			_play_shield_idle_anim()
	else:
		if moving:
			_play_walk_anim(input_vec)
		else:
			_play_idle_anim()

	move_and_slide()


func _play_walk_anim(dir: Vector2) -> void:
	var anim_name := ""

	if abs(dir.x) > abs(dir.y):
		anim_name = "walk_side"
		anim.flip_h = dir.x < 0.0  # left/right
	else:
		anim.flip_h = false
		if dir.y > 0.0:
			anim_name = "walk_down"
		else:
			anim_name = "walk_up"

	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)


func _play_idle_anim() -> void:
	var anim_name := ""

	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_name = "walk_side"
		anim.flip_h = facing_dir.x < 0.0
	else:
		anim.flip_h = false
		if facing_dir.y > 0.0:
			anim_name = "walk_down"
		else:
			anim_name = "walk_up"

	if anim.animation != anim_name:
		anim.animation = anim_name

	anim.stop()
	anim.frame = 0


func _play_shield_walk_anim(dir: Vector2) -> void:
	var anim_name := ""

	if abs(dir.x) > abs(dir.y):
		anim_name = "shield_side"
		anim.flip_h = dir.x < 0.0  # left/right
	else:
		anim.flip_h = false
		if dir.y > 0.0:
			anim_name = "shield_down"
		else:
			anim_name = "shield_up"

	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)


func _play_shield_idle_anim() -> void:
	var anim_name := ""

	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_name = "shield_side"
		anim.flip_h = facing_dir.x < 0.0
	else:
		anim.flip_h = false
		if facing_dir.y > 0.0:
			anim_name = "shield_down"
		else:
			anim_name = "shield_up"

	if anim.animation != anim_name:
		anim.animation = anim_name

	anim.stop()
	anim.frame = 0  # still shield pose


func _unhandled_input(event: InputEvent) -> void:
	# Attack (only if not shielding/attacking)
	if event.is_action_pressed("attack") and not attacking and not shielding:
		_start_attack()

	# Start shield
	if event.is_action_pressed("shield") and not shielding and not attacking:
		_start_shield()

	# Stop shield when button released
	if event.is_action_released("shield") and shielding:
		_stop_shield()


func _start_attack() -> void:
	attacking = true
	var anim_name := ""

	if abs(facing_dir.x) > abs(facing_dir.y):
		anim_name = "attack_side"
		anim.flip_h = facing_dir.x < 0.0
	else:
		anim.flip_h = false
		if facing_dir.y > 0.0:
			anim_name = "attack_down"
		else:
			anim_name = "attack_up"

	anim.play(anim_name)

	await anim.animation_finished

	attacking = false
	_play_idle_anim()


func _start_shield() -> void:
	shielding = true
	_play_shield_idle_anim()


func _stop_shield() -> void:
	shielding = false
	_play_idle_anim()
