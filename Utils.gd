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
	

	
