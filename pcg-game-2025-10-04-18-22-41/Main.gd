extends Node2D


func _ready():
	spawn_player()
	spawn_enemies()

func spawn_player():
	var player = preload("res://player.tscn").instantiate()
	player.position = Vector2(100, 400)  # Starting position
	add_child(player)

func spawn_enemies():
		var enemy1 = preload("res://enemy1.tscn").instantiate()
		enemy1.position = Vector2(300,500)
		add_child(enemy1)
		var enemy2 = preload("res://enemy_2.tscn").instantiate()
		enemy2.position = Vector2(200, 400)
		add_child(enemy2)
		var enemy3 = preload("res://enemy_3.tscn").instantiate()
		enemy3.position = Vector2(250,100)
		add_child(enemy3)
