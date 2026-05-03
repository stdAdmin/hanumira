extends Node2D
class_name Main

# sequence of appearing is left tile, top blob, right tile, bottom blob in spawn_time deltas
@export var spawn_time = 5.0
#game speed: how fast the tileblobs are moving
@export var game_speed = 5.0

############ game field #################
const tile_blob_size = 64 # which is centered at 0/0
const gamefield_x_size = 10 # has to be even
const gamefield_y_size = 8 # has to be even

############ tiles & blobs ##############
var active_tile_blob = 1

############### tiles general #####################
const NewTile = preload("res://tile.tscn")
var tile_matrix: Array[Array]
############### left --> right tile ################
const movement_vector_left2right = Vector2(1,0)
const start_pos_left2right = Vector2(1,gamefield_y_size/2)
const end_pos_left2right = Vector2(gamefield_x_size/2,0)
var cur_tile_left2right = null
############### right --> left tile ################
const movement_vector_right2left = Vector2(-1,0)
const start_pos_right2left = Vector2(gamefield_x_size,gamefield_y_size/2+1)
const end_pos_right2left = Vector2(gamefield_x_size/2+1,0)
var cur_tile_right2left = null


############### blobs general #####################
const NewBlob = preload("res://blob.tscn")
var blob_matrix: Array[Array]
############### up --> down Blob ################
const movement_vector_up2down = Vector2(0,1)
const start_pos_up2down = Vector2(gamefield_x_size/2, 1)
const out_of_gamefield_pos_up2down = gamefield_y_size+1
var cur_blob_up2down = null
############### down --> up Blob ################
const movement_vector_down2up = Vector2(0,-1)
const start_pos_down2up = Vector2(gamefield_x_size/2+1, gamefield_y_size)
const out_of_gamefield_pos_down2up = 0
var cur_blob_down2up = null

#var cur_blob_top_down = null		#2
#var cur_tile_right_left = null		#3
#var cur_blob_bottom_up = null		#4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		check_parameters()
		tile_matrix = Utils.create_matrix(gamefield_x_size+1,gamefield_y_size+1)
		blob_matrix = Utils.create_matrix(gamefield_x_size+1,gamefield_y_size+1)
		#var block: Node2D = NewNode.instantiate()
		#add_child(block)
		spawn_tile()
		pass

func _draw():
	# draw the raster
	# horizontal
	for i in range(gamefield_y_size+1):
		draw_line(	Vector2(tile_blob_size/2									, tile_blob_size/2 + i*tile_blob_size), 
					Vector2(tile_blob_size/2 + gamefield_x_size*tile_blob_size	, tile_blob_size/2 + i*tile_blob_size), 
					Color.DARK_GRAY, 1)
	# vertical
	for i in range(gamefield_x_size+1):
		draw_line(	Vector2(tile_blob_size/2 + i*tile_blob_size, tile_blob_size/2), 
					Vector2(tile_blob_size/2 + i*tile_blob_size, tile_blob_size/2 + gamefield_y_size*tile_blob_size), 
					Color.DARK_GRAY, 1)
	# in the middle
	draw_line(	Vector2(tile_blob_size/2									, tile_blob_size/2 + gamefield_y_size/2*tile_blob_size), 
				Vector2(tile_blob_size/2 + gamefield_x_size*tile_blob_size	, tile_blob_size/2 + gamefield_y_size/2*tile_blob_size), 
				Color.RED, 2)	
	draw_line(	Vector2(tile_blob_size/2 + gamefield_x_size/2*tile_blob_size, tile_blob_size/2), 
				Vector2(tile_blob_size/2 + gamefield_x_size/2*tile_blob_size, tile_blob_size/2 + gamefield_y_size*tile_blob_size), 
				Color.RED, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_tile():
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
			print("3")
			cur_tile_right2left = tile
			tile.movement_vector = movement_vector_right2left
			tile.matrix_pos = start_pos_right2left
			tile.end_pos = end_pos_right2left
			active_tile_blob = 4
		add_child(tile)
	else:
		var blob: Blob = NewBlob.instantiate()						
		blob.blob_matrix_ref = blob_matrix
		blob.blob_size = Vector2(tile_blob_size, tile_blob_size)
		blob.blob_movement_complete.connect(_on_blob_movement_complete)
		if active_tile_blob == 2:	
			print("2")	
			cur_blob_up2down = blob
			blob.movement_vector = movement_vector_up2down
			blob.matrix_pos = start_pos_up2down
			blob.out_of_gamefield_pos = out_of_gamefield_pos_up2down
			active_tile_blob = 3
		else:
			print("4")
			cur_blob_down2up = blob
			blob.movement_vector = movement_vector_down2up
			blob.matrix_pos = start_pos_down2up
			blob.out_of_gamefield_pos = out_of_gamefield_pos_down2up
			active_tile_blob = 1			
		add_child(blob)
	

		
func _on_tile_movement_complete(direction: Vector2):
	print ("got tile signal")
	spawn_tile()

func _on_blob_movement_complete():
	print ("got blob signal")
	spawn_tile()

func check_parameters():
	assert (gamefield_x_size % 2 == 0)
	assert (gamefield_y_size % 2 == 0)
