extends CharacterBody2D

@export var follow_speed: float = 60.0
@export var follow_distance: float = 12.0  

var following: bool = false
var player: Node2D = null

@onready var trigger: Area2D = $Trigger
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	trigger.body_entered.connect(_on_trigger_body_entered)
	_set_idle()


func _on_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		following = true
		player = body
		print("NPC is now following the player")


func _physics_process(_delta: float) -> void:
	if following and player:
		var to_player := player.global_position - global_position
		var distance := to_player.length()

		if distance > follow_distance:
			var dir := to_player.normalized()
			velocity = dir * follow_speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_update_animation()


func _update_animation() -> void:
	if following and velocity.length() > 0.1:
		# Just play the walk animation in a loop
		if anim.animation != "walk" or not anim.is_playing():
			anim.play("walk")
	else:
		_set_idle()


func _set_idle() -> void:
	# Fake idle: first frame of the walk animation
	anim.animation = "walk"
	anim.stop()
	anim.frame = 0
