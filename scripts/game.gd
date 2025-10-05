extends Node2D
const W := 96
const H := 64
enum { WALL, FLOOR }
const WALL_ATLAS := Vector2i(0, 0)
const FLOOR_ATLAS := Vector2i(0, 4)

var grid: Array
var rooms := []
var rng := RandomNumberGenerator.new()

@onready var tile_map_floor: TileMapLayer = $TileMapLayer/TileMapFloor
@onready var tile_map_wall: TileMapLayer = $TileMapLayer/TileMapWall
@onready var tile_map_decor: TileMapLayer = $TileMapLayer/TileMapDecor

func _ready():
	rng.randomize()
	generate_level()
	bake_tiles()
	#sprinkle_decor(0.015)
	spawn_enemies(12)

func generate_level():
	# initialize with walls
	_fill_walls()
	# create rooms
	_sample_rooms(rng.randi_range(8,14))
	# create corriders
	var edges = _mst_edges()
	_carve_corridors(edges, 1)
	# add disturbance
	_break_edges(0.08, 2)
	# pick spawn/exit
	var s = _pick_spawn()
	var e = _pick_exit_far_from(s)
	# test for reachable
	if not _reachable(s, e):
		_force_carve_L(s, e, 1)

func _fill_walls():
	grid = []
	for y in H:
		var row := []
		row.resize(W)
		for x in W: row[x] = WALL
		grid.append(row)
	rooms.clear()

func _sample_rooms(n:int):
	var tries := 0
	while rooms.size() < n and tries < n*30:
		tries += 1
		var rw = rng.randi_range(6,14)
		var rh = rng.randi_range(5,12)
		var rx = rng.randi_range(1, W-rw-2)
		var ry = rng.randi_range(1, H-rh-2)
		var rect = Rect2i(rx, ry, rw, rh)
		if _overlap_ratio(rect) > 0.10: continue 
		# carve
		for y in rh:
			for x in rw:
				grid[ry+y][rx+x] = FLOOR
		rooms.append({ "rect": rect, "center": rect.position + rect.size/2 })

func _overlap_ratio(r:Rect2i) -> float:
	var overlap_area = 0
	for R in rooms:
		var inter = r.intersection(R.rect)
		if inter: overlap_area += inter.size.x * inter.size.y
	return float(overlap_area) / float(r.size.x * r.size.y)

func _mst_edges() -> Array:
	var pts := []
	for i in rooms.size(): pts.append(rooms[i].center)
	var edges := []
	for i in pts.size():
		var j = _nearest_idx(pts, i)
		if j >= 0: edges.append([min(i,j), max(i,j), pts[i].distance_to(pts[j])])
	# Kruskal
	edges.sort_custom(func(a,b): return a[2] < b[2])
	var uf := {}
	var find := func(x:int) -> int:
		if not uf.has(x):
			uf[x] = x
			return x
		var r := x
		while uf[r] != r:
			uf[r] = uf[uf[r]]
			r = uf[r]
		return r
	var unite := func(a, b):
		var pa = find.call(a)
		var pb = find.call(b)
		if pa == pb:
			return false
		uf[pa] = pb
		return true
	var mst := []
	for e in edges:
		if unite.call(e[0], e[1]): mst.append([e[0], e[1]])
	for k in range(0, int(rooms.size()/3)):
		var a = rng.randi_range(0, rooms.size()-1)
		var b = rng.randi_range(0, rooms.size()-1)
		if a!=b: mst.append([min(a,b), max(a,b)])
	return mst

func _nearest_idx(pts:Array, i:int) -> int:
	var best := -1; var bd := 1e9
	for j in pts.size():
		if j==i: continue
		var d = pts[i].distance_to(pts[j])
		if d < bd: bd = d; best = j
	return best

func _carve_corridors(edges:Array, half_w:int):
	for e in edges:
		var A:Vector2i = rooms[e[0]].center
		var B:Vector2i = rooms[e[1]].center
		if rng.randf() < 0.5:
			_carve_hline(A.x, B.x, A.y, half_w)
			_carve_vline(A.y, B.y, B.x, half_w)
		else:
			_carve_vline(A.y, B.y, A.x, half_w)
			_carve_hline(A.x, B.x, B.y, half_w)

func _carve_hline(x0:int, x1:int, y:int, half_w:int):
	for x in range(min(x0,x1), max(x0,x1)+1):
		for k in range(-half_w, half_w + 1):
			if y+k>=0 and y+k<H and x>=0 and x<W:
				grid[y+k][x] = FLOOR

func _carve_vline(y0:int, y1:int, x:int, half_w:int):
	for y in range(min(y0,y1), max(y0,y1)+1):
		for k in range(-half_w, half_w + 1):
			if x+k>=0 and x+k<W and y>=0 and y<H:
				grid[y][x+k] = FLOOR

func _break_edges(p:float, rounds:int):
	for _i in rounds:
		var flips := []
		for y in range(1, H-1):
			for x in range(1, W-1):
				if grid[y][x]==WALL and _touches_floor(x,y) and rng.randf()<p:
					flips.append(Vector2i(x,y))
		for v in flips: grid[v.y][v.x] = FLOOR

func _touches_floor(x:int,y:int)->bool:
	for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
		var nx=x+d.x
		var ny=y+d.y
		if grid[ny][nx]==FLOOR: return true
	return false

func _pick_spawn() -> Vector2i:
	rooms.sort_custom(func(a,b): return a.center.x < b.center.x)
	return rooms[0].center

func _pick_exit_far_from(s:Vector2i) -> Vector2i:
	var best := s; var bd := -1.0
	for r in rooms:
		var d = float(s.distance_to(r.center))
		if d > bd: bd = d; best = r.center
	return best

func _reachable(a:Vector2i, b:Vector2i) -> bool:
	# BFS
	var q := [a]; var vis := {}
	vis[a]=true
	while q.size()>0:
		var p:Vector2i = q.pop_front()
		if p==b: return true
		for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
			var n = p + d
			if n.x<0 or n.y<0 or n.x>=W or n.y>=H: continue
			if grid[n.y][n.x]==FLOOR and not vis.has(n):
				vis[n]=true; q.append(n)
	return false

func _force_carve_L(a:Vector2i, b:Vector2i, half_w:int):
	_carve_hline(a.x, b.x, a.y, half_w)
	_carve_vline(a.y, b.y, b.x, half_w)

# ---------- visualisation/post-process ----------
func bake_tiles():
	tile_map_floor.clear()
	tile_map_wall.clear()
	var floor_cells := PackedVector2Array()
	var wall_cells  := PackedVector2Array()
	for y in H:
		for x in W:
			var cell := Vector2i(x, y)
			if grid[y][x] == FLOOR:
				floor_cells.push_back(cell)
			else:
				wall_cells.push_back(cell)
	tile_map_wall.set_cells_terrain_connect(wall_cells, 0, 0)
	tile_map_floor.set_cells_terrain_connect(floor_cells, 0, 0)

	#for y in H:
		#for x in W:
			#if grid[y][x]==FLOOR:
				#tile_map_floor.set_cell(Vector2i(x,y), 0, FLOOR_ATLAS)
				#pass
			#else:
				#tile_map_wall.set_cell(Vector2i(x,y), 0, WALL_ATLAS)
				#pass

func sprinkle_decor(density:float):
	for y in range(1,H-1):
		for x in range(1,W-1):
			if grid[y][x]==FLOOR and _neighbors_floor(Vector2i(x,y))>=3 and rng.randf()<density:
				# TODO: tm_decor.set_cell(...)
				pass

func _neighbors_floor(v:Vector2i)->int:
	var c = 0
	c += int(grid[v.y][v.x-1]==FLOOR)
	c += int(grid[v.y][v.x+1]==FLOOR)
	c += int(grid[v.y-1][v.x]==FLOOR)
	c += int(grid[v.y+1][v.x]==FLOOR)
	return c

func spawn_enemies(n:int):
	var pts := []
	var s = _pick_spawn()
	for y in H:
		for x in W:
			if grid[y][x]==FLOOR and Vector2i(x,y).distance_to(s) >= 6:
				pts.append(Vector2i(x,y))
	pts.shuffle()
	for i in min(n, pts.size()):
		var pos_px = pts[i] * 16
		
		pass
