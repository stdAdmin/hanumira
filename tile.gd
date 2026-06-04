class_name Tile
extends Node2D

# set by game
var gamefield_left_upper_start: Vector2
var movement_vector
var matrix_pos: Vector2
var end_pos: Vector2
var tile_size: Vector2

# boundary status, initially set by game., modified by rotation
var visible_left: bool = false
var visible_up: bool = false
var visible_right: bool = false
var visible_down: bool = false

var current_cnt_movement: float = 0
var current_cnt_joystick_move: float = 0
var current_cnt_joystick_press: float = 0

var left_joystick_pressed = false
var right_joystick_pressed = false

@export var speed_movement: float = 0.03
@export var speed_joystick_move: float = 0.2
@export var speed_joystick_press: float = 0.1

var tile_matrix_ref: Array[Array] # set during instantiate
signal tile_movement_complete(data: Vector2)  # vector indicates direction

var being_in_focus = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = gamefield_left_upper_start + Vector2 (matrix_pos * tile_size)
	#position = Vector2(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# check the joystick presses independent of the move cycle, TODO: maybe same for movement
	left_joystick_pressed = Input.is_action_pressed("cr_left_button")
	right_joystick_pressed = Input.is_action_pressed("cr_right_button")

	var cur_matrix_pos =  (position-gamefield_left_upper_start) / tile_size
	var cur_matrix_entry = tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y]
	## movement via joystick, only when actively_controlled
	if being_in_focus:
		current_cnt_joystick_move += speed_joystick_move
		if  current_cnt_joystick_move >=1:
			current_cnt_joystick_move = 0
			# being left or right?
			var y_motion
			if movement_vector.x > 0:			
				y_motion = sign(Input.get_axis("cr_left_up","cr_left_down")) # 0, -1, 1
			else:
				y_motion = sign(Input.get_axis("cr_right_up","cr_right_down")) # 0, -1, 1
			var next_joy_matrix_pos = (position-gamefield_left_upper_start) / tile_size + Vector2(0, y_motion)
			# check endpos
			if !(next_joy_matrix_pos.x == 0 || next_joy_matrix_pos.y == 0 ||                                            # check if not going outside the boundaries in display
				 next_joy_matrix_pos.x == tile_matrix_ref.size() || next_joy_matrix_pos.y == tile_matrix_ref[0].size() ||# check if not going outside the boundaries of the matrix
				 tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] != null):                                # check if not going to occupy an already occupied field
					position += Vector2(0, y_motion) * tile_size
					tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
					tile_matrix_ref[next_joy_matrix_pos.x][next_joy_matrix_pos.y] = self
					matrix_pos = next_joy_matrix_pos				

		current_cnt_joystick_press += speed_joystick_press
		if  current_cnt_joystick_press >=1:
			current_cnt_joystick_press = 0
			# being left or right?
			if movement_vector.x > 0:			
				if left_joystick_pressed:
					left_joystick_pressed = 0.0
					var temp = visible_left
					visible_left = visible_down
					visible_down = visible_right
					visible_right = visible_up
					visible_up = temp
			else:
				if right_joystick_pressed:
					right_joystick_pressed = 0.0
					var temp = visible_left
					visible_left = visible_down
					visible_down = visible_right
					visible_right = visible_up
					visible_up = temp
			
	$boundary_left.visible = visible_left
	$boundary_up.visible = visible_up
	$boundary_right.visible = visible_right
	$boundary_down.visible = visible_down
	
	# movement via time
	current_cnt_movement += speed_movement
	if  current_cnt_movement >=1: 
		current_cnt_movement = 0
		#1 left->right
		var next_matrix_pos = (position-gamefield_left_upper_start) / tile_size + movement_vector
		if (movement_vector.x > 0):
			# hittimg endpos in middle or next field is occupied
			if !(next_matrix_pos.x > end_pos.x || tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):
				position += movement_vector * tile_size
				tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				matrix_pos = next_matrix_pos					
			else:
				#print ("end reached")
				if being_in_focus:
					emit_signal("tile_movement_complete", movement_vector)
					being_in_focus = false
		#2 right->left
		elif (movement_vector.x < 0):
			if !(next_matrix_pos.x < end_pos.x || tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] != null):
				position += movement_vector * tile_size
				tile_matrix_ref[cur_matrix_pos.x][cur_matrix_pos.y] = null
				tile_matrix_ref[next_matrix_pos.x][next_matrix_pos.y] = self
				matrix_pos = next_matrix_pos					
			else:
				#print ("end reached")
				if being_in_focus:
					emit_signal("tile_movement_complete", movement_vector)
					being_in_focus = false		
					
