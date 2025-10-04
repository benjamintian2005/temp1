extends CharacterBody2D

# Movement speed in pixels per second
@export var speed: float = 150.0

# Reference to the behavior script (can be swapped at runtime)
@export var behavior: EnemyBehavior = null

# Reference to the player (set automatically)
var player: CharacterBody2D = null

func _ready() -> void:
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	
	# Initialize the behavior if it exists
	if behavior:
		behavior.initialize(self)

func _physics_process(delta: float) -> void:
	# Let the behavior decide the movement direction
	if behavior and player:
		var direction = behavior.get_movement_direction(self, player, delta)
		velocity = direction * speed
		move_and_slide()
	else:
		# No behavior = no movement
		velocity = Vector2.ZERO
