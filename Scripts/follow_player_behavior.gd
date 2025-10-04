extends EnemyBehavior
class_name FollowPlayerBehavior

# Minimum distance to maintain from player (to avoid jittering)
@export var stop_distance: float = 10.0

func get_movement_direction(enemy: CharacterBody2D, player: CharacterBody2D, delta: float) -> Vector2:
	if not player or not enemy:
		return Vector2.ZERO
	
	# Calculate direction to player
	var direction = player.global_position - enemy.global_position
	var distance = direction.length()
	
	# Stop if close enough to avoid jittering
	if distance < stop_distance:
		return Vector2.ZERO
	
	# Normalize to get unit direction
	return direction.normalized()
