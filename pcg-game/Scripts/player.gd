
extends CharacterBody2D

const SPEED = 200.0
var health = 100
var texture

func _ready():
	add_to_group("player")
	
	texture = preload("res://Tiles/tile_0099.png")
	scale = Vector2(2.0, 2.0)

func _physics_process(_delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()  # This handles wall collision!
