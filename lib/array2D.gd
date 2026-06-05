# array2d.gd
class_name Array2D

var x_size: int
var y_size: int
var d: Array

func _init(x_size: int, y_size: int, default_value = null):
	self.x_size = x_size
	self.y_size = y_size
	d = []

	d.resize(x_size * y_size)

	if default_value != null:
		d.fill(default_value)

# index
func i(x: int, y: int) -> int:
	return y * x_size + x

# get
func g(x: int, y: int):
	return d[i(x, y)]

# set
func s(x: int, y: int, v) -> void:
	d[i(x, y)] = v

# in bounds
func b(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < x_size and y < y_size

# fill
func f(v) -> void:
	d.fill(v)

# raw array access
func raw() -> Array:
	return d
