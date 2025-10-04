extends Node2D


func _ready():
	spawn_player()
	spawn_enemies()

func spawn_player():
	var player = preload("res://player.tscn").instantiate()
	player.position = Vector2(100, 400)  # Starting position
	add_child(player)

func spawn_enemies():
	for i in range(10):
		var enemy = preload("res://enemy1.tscn").instantiate()
		enemy.position = Vector2(
			randf_range(0, 500),  # Random x
			randf_range(100, 500)   # Random y
		)
		add_child(enemy)
