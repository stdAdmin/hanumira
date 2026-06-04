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
			out += array[row][col]
		out += "\n"
	return out

		
