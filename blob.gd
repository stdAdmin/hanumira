extends Node2D
class_name Blob

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

var tile_matrix_ref: Array[Array] # set during instantiate
var blob_matrix_ref: Array[Array] # set during instantiate
signal blob_movement_complete()  # blob cannot continue and "hangs" at/in a tile
signal blob_fell_ouside()  		 # essentially it fell outside of screen

var being_in_focus = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = gamefield_left_upper_start + Vector2 (matrix_pos * blob_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cur_matrix_pos =  (position-gamefield_left_upper_start) / blob_size
	var cur_tile = tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y]
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
				var next_tile_matrix_entry = tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y]
				var next_blob_matrix_entry = blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y]
				# check endpos
				# 1. reached border, remove the blob, inform score
				if next_blob_matrix_entry is Border:
					# simply do nothing, not allowed
					Log.debug("joy next blob outside")	
				# 2. field occupied				
				elif next_blob_matrix_entry != null:  
					Log.debug("joy next blob field already occupied by other blob ")                        
				# 3. next blob field is free and has no border at the tiles
				else:
					# left to right allowed and no blob there
					if x_motion == 1:
						if cur_tile != null && cur_tile.visible_right:
							# simply do nothing, not allowed
							pass							
						elif (tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] !=null &&
							  tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y].visible_left):  
							# simply do nothing, not allowed
							pass			
						else:
							position += Vector2(x_motion, 0) * blob_size
							blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
							blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] = self
							matrix_pos = next_joy_matrix_pos	
							Log.debug ("joy Moved blob successfully")									# left to right allowed and no blob there
					elif x_motion == -1:
						if cur_tile != null && cur_tile.visible_left:
							# simply do nothing, not allowed
							pass									
						elif (tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null &&
							   tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y].visible_right):  
							# simply do nothing, not allowed
							pass		
						else:
							position += Vector2(x_motion, 0) * blob_size
							blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
							blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] = self
							matrix_pos = next_joy_matrix_pos	
							Log.debug ("joy Moved blob successfully")											  
					else:
						Log.error("error in blob joy movement. not left nor right movement")			
			
	# movement via time
	current_cnt_movement += speed_movement
	if  current_cnt_movement >=1: 
		current_cnt_movement = 0
		var next_blob_matrix_pos = (position-gamefield_left_upper_start) / blob_size + movement_vector
		var next_blob_matrix_entry = blob_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y]
		#1 up->down
		if movement_vector.y > 0:
			# 1. check for current tile if this blob is inside a tile and down movement is inhibited
			if (cur_tile != null && cur_tile.visible_down):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: borderline inside tile")
					being_in_focus = false	
			# 2. check if next field is Border
			# remove the blob completely now from matrix and scene
			elif (next_blob_matrix_entry is Border):
				if being_in_focus:
					emit_signal("blob_fell_ouside")
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: blob fell outside")
					being_in_focus = false
					# remove itself from blob matrix
					blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
					# remove itself from game tree
					queue_free()	
			# 3. check if next field is a tile and the tile has a border on top
			elif (tile_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y] != null && 
				  tile_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y].visible_up):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: borderline as outer edge in next tile")
					being_in_focus = false				
			# 4. check if next field has no blob
			elif (blob_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y] != null):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: next cell has already a blob")
					being_in_focus = false		
			# 5. movement allowed
			else:
				position += movement_vector * blob_size
				blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				blob_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y] = self
				matrix_pos = next_blob_matrix_pos	
		#2 down->up
		if movement_vector.y < 0:
			# 1. check for current tile if this blob is inside a tile and up movement is inhibited
			if (cur_tile != null && cur_tile.visible_up):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: borderline inside tile")
					being_in_focus = false	
			# 2. check if next field is Border
			# remove the blob completely now from matrix and scene
			elif (next_blob_matrix_entry is Border):
				if being_in_focus:
					emit_signal("blob_fell_ouside")
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: blob fell outside")
					being_in_focus = false
					# remove itself from blob matrix
					blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
					# remove itself from game tree
					queue_free()
			# 3. check if next field is a tile and the tile has a border on bottom
			elif (tile_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y] != null && 
				  tile_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y].visible_down):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: borderline as outer edge in next tile")
					being_in_focus = false				
			# 4. check if next field has no blob
			elif (blob_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y] != null):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					Log.debug("time blob_movement_complete: next cell has already a blob")
					being_in_focus = false		
			# 5. movement allowed
			else:
				position += movement_vector * blob_size
				blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				blob_matrix_ref[next_blob_matrix_pos.x][next_blob_matrix_pos.y] = self
				matrix_pos = next_blob_matrix_pos
				Log.debug ("time Moved blob successfully")

func tryMove(now:Vector2, future: Vector2)-> bool:
	
	return false

















#func _process(delta: float) -> void:
	#var cur_matrix_pos =  (position-gamefield_left_upper_start) / blob_size
	#var cur_tile:Tile = tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y]
	## movement via joystick, only when actively_controlled
	#if being_in_focus:
		#current_cnt_joystick_move += speed_joystick_move
		#if  current_cnt_joystick_move >=1:
			#current_cnt_joystick_move = 0
			## being up or down?
			#var x_motion
			#if movement_vector.y > 0:			
				#x_motion = sign(Input.get_axis("cr_left_left","cr_left_right")) # 0, -1, 1
			#else:
				#x_motion = sign(Input.get_axis("cr_right_left","cr_right_right")) # 0, -1, 1
			#var next_joy_matrix_pos = (position-gamefield_left_upper_start) / blob_size + Vector2(x_motion, 0)
			## check endpos
			#if !(next_joy_matrix_pos.x == 0 || next_joy_matrix_pos.y == 0 ||                                            # check if not going outside the boundaries in display
				 #next_joy_matrix_pos.x >= blob_matrix_ref.size() || 
				 #next_joy_matrix_pos.y >= blob_matrix_ref[0].size() || # check if not going outside the boundaries of the matrix
				 #blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null):                                # check if not going to occupy an already occupied field
					## coming from the left
					#if !(x_motion == 1 && 
						 #( (cur_tile != null && cur_tile.visible_right) ||
						   #(tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null 
							#&& tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y].visible_left) ) ):    
						#position += Vector2(x_motion, 0) * blob_size
						#blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
						#blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] = self
						#matrix_pos = next_joy_matrix_pos				
	## movement via time
	#current_cnt_movement += speed_movement
	#if  current_cnt_movement >=1: 
		#current_cnt_movement = 0
#
		#var next_matrix_pos = (position-gamefield_left_upper_start) / blob_size + movement_vector
		##1 up->down
		#if (movement_vector.y > 0 && movement_vector.x == 0):
			## check for current tile if this blob is inside a tile and down movement is inhibited
			#if (cur_tile != null && cur_tile.visible_down):
				#if being_in_focus:
					#emit_signal("blob_movement_complete")
					#being_in_focus = false	
			##  check for next tile if this blob is htting a tile and down movement into tile is inhibited
			#elif (next_matrix_pos.y < out_of_gamefield_pos && 
				  #tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null && 
				  #tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y].visible_up):
				#if being_in_focus:
					#emit_signal("blob_movement_complete")
					#being_in_focus = false			
			#elif !(next_matrix_pos.y >= out_of_gamefield_pos || blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):			
				## check for the next tile if there is one
				#var tile:Tile = tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y];
				#position += movement_vector * blob_size
				#blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				#blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				#matrix_pos = next_matrix_pos					
			#else:
				#if being_in_focus:
					#emit_signal("blob_movement_complete")
					#being_in_focus = false
		##2 down->up
		#if (movement_vector.y < 0 && movement_vector.x == 0):
			## check for current tile if this blob is inside a tile and up movement is inhibited
			#if (cur_tile != null && cur_tile.visible_up):
				#if being_in_focus:
					#emit_signal("blob_movement_complete")
					#being_in_focus = false	
			##  check for next tile if this blob is htting a tile and up movement into tile is inhibited
			#elif (next_matrix_pos.y > out_of_gamefield_pos && 
					#tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null && 
					#tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y].visible_down):
				#if being_in_focus:
					#emit_signal("blob_movement_complete")
					#being_in_focus = false		
			#elif !(next_matrix_pos.y <= out_of_gamefield_pos || blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):
				#position += movement_vector * blob_size
				#blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				#blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				#matrix_pos = next_matrix_pos					
			#else:
				#if being_in_focus:
					#emit_signal("blob_movement_complete")
					#being_in_focus = false
#
#func tryMove(now:Vector2, future: Vector2)-> bool:
	#
	#return false
