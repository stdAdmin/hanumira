class_name Utils
extends Object  # optional but clean
	
static func create_matrix(cols: int, rows: int) -> Array2D:
	var border_type = Border.new()
	var array = Array2D.new(cols, rows, null)
	for y in range(0, rows):
		for x in range(0, cols):
			if y==0 || y==rows-1:
				array.s(x, y, border_type)
			elif x==0 || x==cols-1:
				array.s(x, y, border_type)	
	return array
	
	
static func create_debug_completion_array(rows: int, cols: int) -> Array2D:
	var g = Array2D.new(cols, rows, "-")
	return g	

static func print_debug_completion_array(array: Array2D) -> String:
	var out = ""
	for row in range(0, array.y_size):
		out +=  "%02d" % row
		for col in range(0, array.x_size):
			if row == 0 or row == array.y_size-1 or col == 0 or col == array.x_size-1: out += "%"
			else: out += array.g(row, col)
		out += "\n"
	return out

# border (only when both have it) = O
# empty (both) = -
# only tile = t
# only blob = b
# both = X
# none of it = error = e
static func print_tile_blob_matrix(tile_array: Array2D, blob_array: Array2D) -> String:
	var out = ""
	for row in range(0, tile_array.y_size):
		out +=  "%02d" % row
		for col in range(0, tile_array.x_size):
			if   tile_array.g(col, row) is Border and blob_array.g(col, row) is Border: out+= "O"
			elif tile_array.g(col, row) == null and blob_array.g(col, row) == null: out+= "-"
			elif tile_array.g(col, row) is Tile and blob_array.g(col, row) == null: out+= "t"
			elif tile_array.g(col, row) == null and blob_array.g(col, row) is Blob: out+= "b"
			elif tile_array.g(col, row) is Tile and blob_array.g(col, row) is Blob: out+= "X"
			else: out+="e"
		out += "\n"
	out += "\n\n"
	return out

static func get_current_datetime_ms() -> String:
	var unix_ms := int(Time.get_unix_time_from_system() * 1000.0)
	var dt := Time.get_datetime_dict_from_system()

	return "%04d-%02d-%02d %02d:%02d:%02d.%03d" % [
		dt.year,
		dt.month,
		dt.day,
		dt.hour,
		dt.minute,
		dt.second,
		unix_ms % 1000
	]
