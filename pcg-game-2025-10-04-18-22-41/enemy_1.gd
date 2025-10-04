extends CharacterBody2D
#GRUNT
const SPEED = 100.0
const DETECTION_RANGE = 250.0
const ATTACK_RANGE = 50.0

var health = 50
var player = null
var state = "idle"  # idle, walk, attack, hit, death

@onready var anim = $AnimatedSprite2D

func _ready():
	add_to_group("enemy")
	
	anim.play("idle")
	$AnimatedSprite2D.scale = Vector2(1.5,1.5) 

func _physics_process(delta):
	if state == "death":
		return
	
	# Find player
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var distance = position.distance_to(player.position)
	
	if distance < ATTACK_RANGE:
		attack()
	elif distance < DETECTION_RANGE:
		chase_player()
	elif distance > DETECTION_RANGE:
		idle()
	else:
		idle()
	
	move_and_slide()

func idle():
	if state != "idle":
		state = "idle"
		anim.play("idle")
	velocity = Vector2.ZERO

func chase_player():
	if state != "walk":
		state = "walk"
		anim.play("walk")
	
	var direction = (player.position - position).normalized()
	velocity = direction * SPEED
	
	# Flip sprite based on direction
	if direction.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

func attack():
	if state != "attack":
		state = "attack"
		anim.play("attack")
		velocity = Vector2.ZERO

func take_damage(amount):
	health -= amount
	
	if health <= 0:
		die()
	else:
		show_hit()

func show_hit():
	state = "hit"
	anim.play("hit")
	await anim.animation_finished
	state = "idle"

func die():
	state = "death"
	anim.play("death")
	await anim.animation_finished
	queue_free()
