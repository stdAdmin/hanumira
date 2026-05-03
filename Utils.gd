class_name Utils

extends Object  # optional but clean

static func create_matrix(rows: int, cols: int) -> Array[Array]:
	var g: Array[Array] = []
	for y in range(rows):
		var row := []
		row.resize(cols)
		g.append(row)
	return g
	

	
