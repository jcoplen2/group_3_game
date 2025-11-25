extends CharacterBody2D

@export var move_speed: float = 80.0
@export var shield_speed_factor: float = 0.8  

@export var max_health: int = 3
var health: int
var invincible: bool = false
@export var invincibility_time: float = 0.5  

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_hitbox: Area2D = $SwordHitbox
@onready var sword_shape: CollisionShape2D = $SwordHitbox/CollisionShape2D
@export var hitbox_offset := 10  

var facing_dir: Vector2 = Vector2.DOWN
var attacking: bool = false
var shielding: bool = false

signal health_changed(current: int, max: int)

func _ready() -> void:
	health = max_health
	emit_signal("health_changed", health, max_health)

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
		anim.flip_h = dir.x < 0.0
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
		anim.flip_h = dir.x < 0.0
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
	anim.frame = 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not attacking and not shielding:
		_start_attack()

	if event.is_action_pressed("shield") and not shielding and not attacking:
		_start_shield()

	if event.is_action_released("shield") and shielding:
		_stop_shield()


func _start_attack() -> void:
	attacking = true

	# Position hitbox + enable hitbox
	_update_sword_hitbox_position()
	_set_sword_hitbox_active(true)

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

	# Disable hitbox after attack
	_set_sword_hitbox_active(false)

	attacking = false
	_play_idle_anim()


func _start_shield() -> void:
	shielding = true
	_play_shield_idle_anim()


func _stop_shield() -> void:
	shielding = false
	_play_idle_anim()


func _update_sword_hitbox_position() -> void:
	var dir := Vector2.ZERO

	if abs(facing_dir.x) > abs(facing_dir.y):
		if facing_dir.x > 0.0:
			dir = Vector2.RIGHT
		else:
			dir = Vector2.LEFT
	else:
		if facing_dir.y > 0.0:
			dir = Vector2.DOWN
		else:
			dir = Vector2.UP

	sword_hitbox.position = dir * float(hitbox_offset)

	if dir == Vector2.UP:
		sword_hitbox.rotation_degrees = -90.0
	elif dir == Vector2.DOWN:
		sword_hitbox.rotation_degrees = 90.0
	else:
		sword_hitbox.rotation_degrees = 0.0


func _set_sword_hitbox_active(active: bool) -> void:
	sword_hitbox.monitoring = active
	sword_hitbox.monitorable = active
	sword_shape.disabled = not active

func _on_SwordHitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1, global_position)


func take_damage(amount: int, _from_position: Vector2 = Vector2.ZERO) -> void:
	if invincible:
		return
		
	if shielding:
		return

	health -= amount
	print("Player took ", amount, " damage. Health: ", health)

	emit_signal("health_changed", health, max_health)  

	if health <= 0:
		_die()
	else:
		_start_invincibility()



func _start_invincibility() -> void:
	invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	invincible = false


func _die() -> void:
	get_tree().change_scene_to_file("res://cutscenes/cutscene_fail.tscn")
