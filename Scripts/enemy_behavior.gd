extends Resource
class_name EnemyBehavior

# Base class for all enemy behaviors
# Override these methods in child classes to create different behaviors

# Called when the enemy is initialized
func initialize(enemy: CharacterBody2D) -> void:
	pass

# Returns the direction the enemy should move
# Return Vector2.ZERO for no movement
# enemy: the enemy this behavior is controlling
# player: the player target
func get_movement_direction(enemy: CharacterBody2D, player: CharacterBody2D, delta: float) -> Vector2:
	return Vector2.ZERO
