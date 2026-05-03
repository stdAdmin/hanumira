extends Node2D

# sequence of appearing is left tile, top blob, right tile, bottom blob in spawn_time deltas
@export var spawn_time = 5.0
#game speed: how fast the tileblobs are moving
@export var game_speed = 5.0

############ tiles & blobs ##############
var active_tile_blob = 1

############### tiles general #####################
const NewTile = preload("res://tile.tscn")
var tile_matrix: Array[Array]

############### left --> right tile ################
const movement_vector_left2right = Vector2(1,0)
const start_pos_left2right = Vector2(1,1)
const end_pos_left2right = Vector2(5,0)
var cur_tile_left2right = null

############### right --> left tile ################
const movement_vector_right2left = Vector2(-1,0)
const start_pos_right2left = Vector2(10,1)
const end_pos_right2left = Vector2(6,0)
var cur_tile_right2left = null


#var cur_blob_top_down = null		#2
#var cur_tile_right_left = null		#3
#var cur_blob_bottom_up = null		#4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		tile_matrix = Utils.create_matrix(50,50)
		#var block: Node2D = NewNode.instantiate()
		#add_child(block)
		spawn_tile()
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_tile():
	if active_tile_blob == 1 || active_tile_blob == 3:
		var tile: Tile = NewTile.instantiate()
		tile.tile_matrix_ref = tile_matrix
		tile.tile_movement_complete.connect(_on_tile_movement_complete)
		# left2right
		if active_tile_blob == 1:
			cur_tile_left2right = tile
			tile.movement_vector = movement_vector_left2right
			tile.matrix_pos = start_pos_left2right
			tile.end_pos = end_pos_left2right
			active_tile_blob = 3
			#right2left
		else:
			cur_tile_right2left = tile
			tile.movement_vector = movement_vector_right2left
			tile.matrix_pos = start_pos_right2left
			tile.end_pos = end_pos_right2left
			active_tile_blob = 1				
		add_child(tile)

		
func _on_tile_movement_complete(direction: Vector2):
	print ("got it")
	spawn_tile()
	
