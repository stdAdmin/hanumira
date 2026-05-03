extends Node2D
class_name Tile

# set by game
var movement_vector
var matrix_pos: Vector2
var end_pos: Vector2

@export var tile_size: Vector2 = Vector2 (64,64) 


var current_cnt_movement: float = 0
var current_cnt_joystick: float = 0

@export var speed_movement: float = 0.03
@export var speed_joystick: float = 0.2

var tile_matrix_ref: Array[Array] # set during instantiate
signal tile_movement_complete(data: Vector2)  # vector indicates direction

var being_in_focus = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2 (matrix_pos * tile_size)
	#print (matrix_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cur_matrix_pos =  position / tile_size
	# movement via joystick, only when actively_controlled
	if being_in_focus:
		current_cnt_joystick += speed_joystick
		if  current_cnt_joystick >=1:
			current_cnt_joystick = 0
			# being left or right?
			var y_motion
			if movement_vector.x > 0:			
				y_motion = sign(Input.get_axis("cr_left_up","cr_left_down")) # 0, -1, 1
			else:
				y_motion = sign(Input.get_axis("cr_right_up","cr_right_down")) # 0, -1, 1
			var next_joy_matrix_pos = position / tile_size + Vector2(0, y_motion)
			# check endpos
			#print ("curMatrixPos:", cur_matrix_pos, " nextJoyMatrixPos:", next_joy_matrix_pos)
			if !(next_joy_matrix_pos.x == 0 || tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null):
					position += Vector2(0, y_motion) * tile_size
					tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
					tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] = self
					matrix_pos = next_joy_matrix_pos				
	
	# movement via time
	cur_matrix_pos =  position / tile_size
	current_cnt_movement += speed_movement
	if  current_cnt_movement >=1: 
		current_cnt_movement = 0

		var next_matrix_pos = position / tile_size + movement_vector
		# check endpos
		#print ("move_vec:", movement_vector, " curMatrixPos:", cur_matrix_pos, " nextMatrixPos:", next_matrix_pos, " end_pos:", end_pos)
		#1 left->right
		if (movement_vector.x > 0 && movement_vector.y == 0):
			if !(next_matrix_pos.x > end_pos.x || tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):
				position += movement_vector * tile_size
				tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				matrix_pos = next_matrix_pos					
			else:
				print ("end reached")
				if being_in_focus:
					emit_signal("tile_movement_complete", movement_vector)
					being_in_focus = false
		
		#2 right->left
		elif (movement_vector.x < 0 && movement_vector.y == 0):
			if !(next_matrix_pos.x < end_pos.x || tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):
				position += movement_vector * tile_size
				tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				matrix_pos = next_matrix_pos					
			else:
				print ("end reached")
				if being_in_focus:
					emit_signal("tile_movement_complete", movement_vector)
					being_in_focus = false		
					
