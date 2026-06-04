class_name Utils
extends Object  # optional but clean

static func create_matrix(rows: int, cols: int) -> Array[Array]:
	var border_type = Border.new()
	var g: Array[Array] = []
	for y in range(rows):
		var row := []
		row.resize(cols)
		if y==0 || y==rows-1:
			row.fill(border_type)	
		else:
			row[0] = border_type
			row[cols-1] = border_type
		g.append(row)
	return g
	
static func create_debug_completion_array(rows: int, cols: int) -> Array[Array]:
	var g: Array[Array] = []
	for y in range(rows):
		var row := []
		row.resize(cols)
		row.fill("-")
		g.append(row)
	return g	

static func print_debug_completion_array(rows: int, cols: int, array: Array[Array]) -> String:
	var out = ""
	for col in range(0, cols):
		out +=  "%02d" % col
		for row in range(0, rows):
			if row == 0 or row == rows-1 or col == 0 or col == cols-1: out += "%"
			else: out += array[row][col]
		out += "\n"
	return out

# border (only when both have it) = O
# empty (both) = -
# only tile = t
# only blob = b
# both = X
# none of it = error = e
static func print_tile_blob_matrix(rows: int, cols: int, tile_array: Array[Array], blob_array: Array[Array]) -> String:
	var out = ""
	for col in range(0, cols):
		out +=  "%02d" % col
		for row in range(0, rows):
			if   tile_array[row][col] is Border and blob_array[row][col] is Border: out+= "O"
			elif tile_array[row][col] == null and blob_array[row][col] == null: out+= "-"
			elif tile_array[row][col] is Tile and blob_array[row][col] == null: out+= "t"
			elif tile_array[row][col] == null and blob_array[row][col] is Blob: out+= "b"
			elif tile_array[row][col] is Tile and blob_array[row][col] is Blob: out+= "X"
			else: out+="e"
		out += "\n"
	return out

		
