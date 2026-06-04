class_name Main
extends Node2D

# sequence of appearing is left tile, top blob, right tile, bottom blob in spawn_time deltas
@export var spawn_time = 5.0
#game speed: how fast the tileblobs are moving
@export var game_speed = 5.0

############ game field #################
const tile_blob_size = 64 # which is centered at 0/0
const gamefield_x_size = 16 # has to be even, includes 2 invisible border lines left/right of type border
const gamefield_y_size = 14 # has to be even, includes 2 invisible border lines bottom/up of type border
const gamefield_left_upper_start = Vector2(0,0)

############ tiles & blobs ##############
var active_tile_blob = 1

############### tiles general #####################
const NewTile = preload("res://tile.tscn")
var tile_matrix: Array[Array]
############### left --> right tile ################
const movement_vector_left2right = Vector2(1,0)
const start_pos_left2right = Vector2(1,gamefield_y_size/2 - 1)
const end_pos_left2right = Vector2(gamefield_x_size/2 - 1,0)
var cur_tile_left2right = null
############### right --> left tile ################
const movement_vector_right2left = Vector2(-1,0)
const start_pos_right2left = Vector2(gamefield_x_size-2,gamefield_y_size/2)
const end_pos_right2left = Vector2(gamefield_x_size/2,0)
var cur_tile_right2left = null


############### blobs general #####################
const NewBlob = preload("res://blob.tscn")
var blob_matrix: Array[Array]
############### up --> down Blob ################
const movement_vector_up2down = Vector2(0,1)
const start_pos_up2down = Vector2(gamefield_x_size/2, 1)
const out_of_gamefield_pos_up2down = gamefield_y_size-1 # whole row is of type "border"
var cur_blob_up2down = null
############### down --> up Blob ################
const movement_vector_down2up = Vector2(0,-1)
const start_pos_down2up = Vector2(gamefield_x_size/2+1, gamefield_y_size-2)
const out_of_gamefield_pos_down2up = 0
var cur_blob_down2up = null

#var cur_blob_top_down = null		#2
#var cur_tile_right_left = null		#3
#var cur_blob_bottom_up = null		#4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		check_parameters()
		tile_matrix = Utils.create_matrix(gamefield_x_size,gamefield_y_size)
		blob_matrix = Utils.create_matrix(gamefield_x_size,gamefield_y_size)
		spawn_tile()

func _draw():
	# draw the raster
	# horizontal
	for i in range(0, gamefield_y_size-1):
		draw_line(	Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2										,
						gamefield_left_upper_start.y + tile_blob_size*1/2 + i*tile_blob_size), 
					Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2 + (gamefield_x_size-2)*tile_blob_size		,
					  	gamefield_left_upper_start.y + tile_blob_size*1/2 + i*tile_blob_size), 
					Color.DARK_GRAY, 1)
	# vertical
	for i in range(0, gamefield_x_size-1):
		draw_line(	Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2 + i*tile_blob_size, 
						gamefield_left_upper_start.y + tile_blob_size*1/2), 
					Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2 + i*tile_blob_size, 
						gamefield_left_upper_start.y + tile_blob_size*1/2 + (gamefield_y_size-2)*tile_blob_size), 
					Color.DARK_GRAY, 1)
	# in the middle	
	draw_line(	Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2										, 
					gamefield_left_upper_start.y + tile_blob_size*1/2 + (gamefield_y_size-2)/2*tile_blob_size), 
				Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2 + (gamefield_x_size-2)*tile_blob_size	, 
					gamefield_left_upper_start.y + tile_blob_size*1/2 + (gamefield_y_size-2)/2*tile_blob_size), 
				Color.RED, 2)	
	draw_line(	Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2 + (gamefield_x_size-2)/2*tile_blob_size, 
					gamefield_left_upper_start.y + tile_blob_size*1/2), 
				Vector2(gamefield_left_upper_start.x + tile_blob_size*1/2 + (gamefield_x_size-2)/2*tile_blob_size, 
					gamefield_left_upper_start.y + tile_blob_size*1/2 + (gamefield_y_size-2)*tile_blob_size), 
				Color.RED, 2)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_tile():
	Log.debug(Utils.print_tile_blob_matrix(gamefield_x_size, gamefield_y_size, tile_matrix, blob_matrix))	
	if active_tile_blob == 1 || active_tile_blob == 3:
		var tile: Tile = NewTile.instantiate()
		# percentage distribution of tile type (border lines)
		var tile_type = randf()
		# 2 parallele = 5%
		if tile_type < 0.25:
			tile.visible_left = true
			tile.visible_right = true
		# a corner = 10%
		elif tile_type >= 0.25 && tile_type <0.50:
			tile.visible_right = true
			tile.visible_down = true
		# one side = 20%
		elif tile_type >= 0.50 && tile_type <0.75:
			tile.visible_down = true
			
		tile.tile_matrix_ref = tile_matrix
		tile.gamefield_left_upper_start = gamefield_left_upper_start
		tile.tile_size = Vector2(tile_blob_size, tile_blob_size)
		tile.tile_movement_complete.connect(_on_tile_movement_complete)
		# left2right
		if active_tile_blob == 1:
			cur_tile_left2right = tile
			tile.movement_vector = movement_vector_left2right
			tile.matrix_pos = start_pos_left2right
			tile.end_pos = end_pos_left2right
			active_tile_blob = 2
		#right2left
		else:
			cur_tile_right2left = tile
			tile.movement_vector = movement_vector_right2left
			tile.matrix_pos = start_pos_right2left
			tile.end_pos = end_pos_right2left
			active_tile_blob = 4
		add_child(tile)
	else:
		var blob: Blob = NewBlob.instantiate()						
		blob.tile_matrix_ref = tile_matrix
		blob.blob_matrix_ref = blob_matrix
		blob.gamefield_left_upper_start = gamefield_left_upper_start
		blob.blob_size = Vector2(tile_blob_size, tile_blob_size)
		blob.blob_movement_complete.connect(_on_blob_movement_complete)
		if active_tile_blob == 2:	
			cur_blob_up2down = blob
			blob.movement_vector = movement_vector_up2down
			blob.matrix_pos = start_pos_up2down
			blob.out_of_gamefield_pos = out_of_gamefield_pos_up2down
			active_tile_blob = 3
		else:
			cur_blob_down2up = blob
			blob.movement_vector = movement_vector_down2up
			blob.matrix_pos = start_pos_down2up
			blob.out_of_gamefield_pos = out_of_gamefield_pos_down2up
			active_tile_blob = 1			
		add_child(blob)
	

		
func _on_tile_movement_complete(direction: Vector2):
	Log.debug("got tile complete signal")
	checkForTileBlobCompletion()
	spawn_tile()

# can be that it is stuck or fell outside, trigger next
func _on_blob_movement_complete():
	Log.debug("got blob complete signal")
	checkForTileBlobCompletion()
	spawn_tile()

func checkForTileBlobCompletion():
	var array = Utils.create_debug_completion_array(gamefield_x_size, gamefield_y_size)
	# executed every time a tile or blob has movement completed
	# go through the inner columns and check if there 
	var l_inner_col = gamefield_x_size/2 - 1
	var r_inner_col = gamefield_x_size/2
	Log.debug(str("left inner termination=", l_inner_col, " right inner termination=", r_inner_col))
	for row in range(1, gamefield_y_size-2):
		var cur_tile: Tile = tile_matrix[l_inner_col][row]
		var cur_blob: Blob = blob_matrix[l_inner_col][row]
		if (cur_tile is Tile and !cur_tile.visible_right and cur_blob is Blob):
			array [l_inner_col][row] = "x"
			recursive(l_inner_col, row, array)			
	for row in range(1, gamefield_y_size-2):
		var cur_tile = tile_matrix[r_inner_col][row]
		var cur_blob = blob_matrix[r_inner_col][row]
		if (cur_tile is Tile and !cur_tile.visible_left and cur_blob is Blob):
			array [r_inner_col][row] = "x"
			recursive(r_inner_col, row, array)
	# remove now all marked tiles and blobs
	for col in range(0, gamefield_x_size):
		for row in range(0, gamefield_y_size):
			if array[col][row] == "x":
				var tile_to_be_removed: Tile = tile_matrix[col][row]
				var blob_to_be_removed: Blob = blob_matrix[col][row]
				tile_matrix[col][row] = null
				blob_matrix[col][row] = null
				# remove itself from game tree
				tile_to_be_removed.queue_free()		
				blob_to_be_removed.queue_free()	
	print(Utils.print_debug_completion_array(gamefield_x_size, gamefield_y_size, array))	
	

# assumes that the given position has been approved to be removed!
func recursive(col: int, row: int, array: Array[Array]):
	# current
	var tc: Tile = tile_matrix[col][row]	
	############# left ####################
	var tl = tile_matrix[col-1][row]
	var bl = blob_matrix[col-1][row]
	if tl is Border: # check for the blob border irrelevant
		pass
	elif tl is Tile and bl is Blob and !tc.visible_left and !tl.visible_right:
		# found next one, if it's already in the array, stop otherwise add it and continue recursion
		if array[col-1][row] != "x":
			array[col-1][row] = "x"
			recursive(col-1, row, array)
	############# right ##################
	var tr = tile_matrix[col+1][row]
	var br = blob_matrix[col+1][row]
	if tr is Border: # check for the blob border irrelevant
		pass
	elif tr is Tile and br is Blob and !tc.visible_right and !tr.visible_left:
		# found next one, if it's already in the array, stop otherwise add it and continue recursion
		if array[col+1][row] != "x":
			array[col+1][row] = "x"
			recursive(col+1, row, array)
	############# up ####################
	var tu = tile_matrix[col][row-1]
	var bu = blob_matrix[col][row-1]
	if tu is Border: # check for the blob border irrelevant
		pass
	elif tu is Tile and bu is Blob and !tc.visible_up and !tu.visible_down:
		# found next one, if it's already in the array, stop otherwise add it and continue recursion
		if array[col][row-1] != "x":
			array[col][row-1] = "x"
			recursive(col, row-1, array)
	############# down ####################
	var td = tile_matrix[col][row+1]
	var bd = blob_matrix[col][row+1]
	if td is Border: # check for the blob border irrelevant
		pass
	elif td is Tile and bd is Blob and !tc.visible_down and !td.visible_up:
		# found next one, if it's already in the array, stop otherwise add it and continue recursion
		if array[col][row+1] != "x":
			array[col][row+1] = "x"
			recursive(col, row+1, array)
	
func check_parameters():
	assert (gamefield_x_size % 2 == 0)
	assert (gamefield_y_size % 2 == 0)
