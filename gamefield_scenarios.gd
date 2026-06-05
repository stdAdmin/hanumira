class_name gamefield_scenarios

# border (only when both have it) = O
# empty (both) = -
# only tile = t
# only blob = b
# both = X
# none of it = error = e

static var scenario_1: Array[String] =[
	"0000000000000000",
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0--------------0",	
	"0000000000000000"
]
static func convert_scenarios_in_true_arrays(rows: int, cols: int, string_array: Array[String]) -> Array[Array]:
	var ret:Array[Array] = []
	for col in range(cols):
		var chars = []
		for ch in string_array[col]:
			chars.append(ch)	
		ret.append(chars)	
	return ret
	
