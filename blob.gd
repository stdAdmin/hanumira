
class_name Blob
extends Node2D

# set by game
var gamefield_left_upper_start: Vector2
var movement_vector
var matrix_pos: Vector2
var out_of_gamefield_pos: int
var blob_size: Vector2

var current_cnt_movement: float = 0
var current_cnt_joystick_move: float = 0

@export var speed_movement: float = 0.03
@export var speed_joystick_move: float = 0.2

var tile_matrix_ref: Array2D     # set during instantiate
var blob_matrix_ref: Array2D    # set during instantiate
signal blob_movement_complete()  # blob cannot continue and "hangs" at/in a tile
signal blob_fell_ouside()  		 # essentially it fell outside of screen

var being_in_focus = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = gamefield_left_upper_start + Vector2 (matrix_pos * blob_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cur_matrix_pos =  (position-gamefield_left_upper_start) / blob_size
	var cur_tile = tile_matrix_ref.g(cur_matrix_pos.x, cur_matrix_pos.y)
	# movement via joystick, only when actively_controlled
	if being_in_focus:
		current_cnt_joystick_move += speed_joystick_move
		if  current_cnt_joystick_move >=1:
			current_cnt_joystick_move = 0
			# being up or down?
			var x_motion
			if movement_vector.y > 0:			
				x_motion = sign(Input.get_axis("cr_left_left","cr_left_right")) # 0, -1, 1
			else:
				x_motion = sign(Input.get_axis("cr_right_left","cr_right_right")) # 0, -1, 1
			if (x_motion != 0):
				var next_joy_matrix_pos = (position-gamefield_left_upper_start) / blob_size + Vector2(x_motion, 0)
				var next_tile_matrix_entry = tile_matrix_ref.g(next_joy_matrix_pos.x, next_joy_matrix_pos.y)
				var next_blob_matrix_entry = blob_matrix_ref.g(next_joy_matrix_pos.x, next_joy_matrix_pos.y)
				# check endpos
				# 1. reached border, remove the blob, inform score
				if next_blob_matrix_entry is Border:
					# simply do nothing, not allowed
					Log.debug("Not allowed to move a blob into the right/left borders")	
				# 2. field occupied				
				elif next_blob_matrix_entry != null:  
					Log.debug("joy next blob field already occupied by other blob ")                        
				# 3. next blob field is free and has no border at the tiles
				else:
					# left to right allowed and no blob there
					if x_motion == 1:
						if cur_tile != null && cur_tile.visible_right:
							# simply do nothing, not allowed
							Log.debug ("Not allowed BLOB when left->right allowed: cur_tile in which this blob is has a border on the right and you cannot move through that by going right")						
						elif (tile_matrix_ref.g(next_joy_matrix_pos.x, next_joy_matrix_pos.y) !=null &&
							  tile_matrix_ref.g(next_joy_matrix_pos.x, next_joy_matrix_pos.y).visible_left):  
							# simply do nothing, not allowed
							Log.debug ("Not allowed BLOB when left->right allowed: the tile right to the blob has a border on its left and you cannot move through that by going right")			
						else:
							position += Vector2(x_motion, 0) * blob_size
							blob_matrix_ref.s(cur_matrix_pos.x, cur_matrix_pos.y, null)
							blob_matrix_ref.s(next_joy_matrix_pos.x, next_joy_matrix_pos.y, self)
							matrix_pos = next_joy_matrix_pos	
							Log.debug ("joy Moved blob successfully")									# left to right allowed and no blob there
					elif x_motion == -1:
						if cur_tile != null && cur_tile.visible_left:
							# simply do nothing, not allowed
							Log.debug ("Not allowed BLOB when right->left allowed: cur_tile in which this blob is has a border on the left and you cannot move through that by going left")							
						elif (tile_matrix_ref.g(next_joy_matrix_pos.x, next_joy_matrix_pos.y) != null &&
							   tile_matrix_ref.g(next_joy_matrix_pos.x, next_joy_matrix_pos.y).visible_right):  
							# simply do nothing, not allowed
							Log.debug ("Not allowed BLOB when right->left allowed: the tile left to the blob has a border on its right and you cannot move through that by going left")		
						else:
							position += Vector2(x_motion, 0) * blob_size
							blob_matrix_ref.s(cur_matrix_pos.x, cur_matrix_pos.y, null)
							blob_matrix_ref.s(next_joy_matrix_pos.x, next_joy_matrix_pos.y, self)
							matrix_pos = next_joy_matrix_pos	
							Log.debug ("joy Moved blob successfully")											  
					else:
						Log.error("error in blob joy movement. not left nor right movement")			
			
	# movement via time
	current_cnt_movement += speed_movement
	if  current_cnt_movement >=1: 
		current_cnt_movement = 0
		var next_blob_matrix_pos = (position-gamefield_left_upper_start) / blob_size + movement_vector
		var next_blob_matrix_entry = blob_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y)
		#1 up->down
		if movement_vector.y > 0:
			# 1. check for current tile if this blob is inside a tile and down movement is inhibited
			if (cur_tile != null && cur_tile.visible_down):
				emit_signal("blob_movement_complete")
				Log.debug("time blob_movement_complete: borderline inside tile")
			# 2. check if next field is Border
			# remove the blob completely now from matrix and scene
			elif (next_blob_matrix_entry is Border):
				emit_signal("blob_fell_ouside")
				emit_signal("blob_movement_complete")
				Log.debug("time blob_movement_complete: blob fell outside")
				# remove itself from game tree !!!first free and then set to null, otherwise last ref is gone BEFORE the free!!!
				queue_free()	
				# remove itself from blob matrix
				blob_matrix_ref.s(cur_matrix_pos.x, cur_matrix_pos.y, null)
			# 3. check if next field is a tile and the tile has a border on top
			elif (tile_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y) != null && 
				  tile_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y).visible_up):
				emit_signal("blob_movement_complete")
				Log.debug("time blob_movement_complete: borderline as outer edge in next tile")	
			# 4. check if next field has no blob
			elif (blob_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y) != null):
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: next cell has already a blob")
			# 5. movement allowed
			else:
				position += movement_vector * blob_size
				blob_matrix_ref.s(cur_matrix_pos.x, cur_matrix_pos.y, null)
				blob_matrix_ref.s(next_blob_matrix_pos.x, next_blob_matrix_pos.y, self)
				matrix_pos = next_blob_matrix_pos	
		#2 down->up
		if movement_vector.y < 0:
			# 1. check for current tile if this blob is inside a tile and up movement is inhibited
			if (cur_tile != null && cur_tile.visible_up):
				emit_signal("blob_movement_complete")
				Log.debug("time blob_movement_complete: borderline inside tile")
			# 2. check if next field is Border
			# remove the blob completely now from matrix and scene
			elif (next_blob_matrix_entry is Border):
					emit_signal("blob_fell_ouside")
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: blob fell outside")
					# remove itself from game tree !!!first free and then set to null, otherwise last ref is gone BEFORE the free!!!
					queue_free()
					# remove itself from blob matrix
					blob_matrix_ref.s(cur_matrix_pos.x, cur_matrix_pos.y, null)
			# 3. check if next field is a tile and the tile has a border on bottom
			elif (tile_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y) != null && 
				  tile_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y).visible_down):
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: borderline as outer edge in next tile")
			
			# 4. check if next field has no blob
			elif (blob_matrix_ref.g(next_blob_matrix_pos.x, next_blob_matrix_pos.y) != null):
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: next cell has already a blob")
			# 5. movement allowed
			else:
				position += movement_vector * blob_size
				blob_matrix_ref.s(cur_matrix_pos.x, cur_matrix_pos.y, null)
				blob_matrix_ref.s(next_blob_matrix_pos.x, next_blob_matrix_pos.y, self)
				matrix_pos = next_blob_matrix_pos
				Log.debug ("time Moved blob successfully")
