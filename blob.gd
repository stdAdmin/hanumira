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
signal blob_movement_complete()  # essentially it fell outside of screen

var being_in_focus = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = gamefield_left_upper_start + Vector2 (matrix_pos * blob_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cur_matrix_pos =  (position-gamefield_left_upper_start) / blob_size
	var cur_tile:Tile = tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y]
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
			var next_joy_matrix_pos = (position-gamefield_left_upper_start) / blob_size + Vector2(x_motion, 0)
			# check endpos
			#print ("curMatrixPos:", cur_matrix_pos, " nextJoyMatrixPos:", next_joy_matrix_pos)
			if !(next_joy_matrix_pos.x == 0 || next_joy_matrix_pos.y == 0 ||                                            # check if not going outside the boundaries in display
				 next_joy_matrix_pos.x >= blob_matrix_ref.size() || next_joy_matrix_pos.y >= blob_matrix_ref[0].size() ||# check if not going outside the boundaries of the matrix
				 blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null):                                # check if not going to occupy an already occupied field
					# coming from the left
					if !(x_motion == 1 && 
						 ( (cur_tile != null && cur_tile.visible_right) ||
						   (tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null 
							&& tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y].visible_left) ) ):    
						position += Vector2(x_motion, 0) * blob_size
						blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
						blob_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] = self
						matrix_pos = next_joy_matrix_pos				
	# movement via time
	current_cnt_movement += speed_movement
	if  current_cnt_movement >=1: 
		current_cnt_movement = 0

		var next_matrix_pos = (position-gamefield_left_upper_start) / blob_size + movement_vector
		#1 up->down
		if (movement_vector.y > 0 && movement_vector.x == 0):
			# check for current tile if this blob is inside a tile and down movement is inhibited
			if (cur_tile != null && cur_tile.visible_down):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					being_in_focus = false	
			#  check for next tile if this blob is htting a tile and down movement into tile is inhibited
			elif (next_matrix_pos.y < out_of_gamefield_pos && 
				  tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null && 
				  tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y].visible_up):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					being_in_focus = false			
			elif !(next_matrix_pos.y >= out_of_gamefield_pos || blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):			
				# check for the next tile if there is one
				var tile:Tile = tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y];
				position += movement_vector * blob_size
				blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				matrix_pos = next_matrix_pos					
			else:
				if being_in_focus:
					emit_signal("blob_movement_complete")
					being_in_focus = false
		#2 down->up
		if (movement_vector.y < 0 && movement_vector.x == 0):
			# check for current tile if this blob is inside a tile and up movement is inhibited
			if (cur_tile != null && cur_tile.visible_up):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					being_in_focus = false	
			#  check for next tile if this blob is htting a tile and up movement into tile is inhibited
			elif (next_matrix_pos.y > out_of_gamefield_pos && 
					tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null && 
					tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y].visible_down):
				if being_in_focus:
					emit_signal("blob_movement_complete")
					being_in_focus = false		
			elif !(next_matrix_pos.y <= out_of_gamefield_pos || blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):
				position += movement_vector * blob_size
				blob_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				blob_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				matrix_pos = next_matrix_pos					
			else:
				if being_in_focus:
					emit_signal("blob_movement_complete")
					being_in_focus = false

func tryMove(now:Vector2, future: Vector2)-> bool:
	
	return false
