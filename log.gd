class_name Log

const DEBUG_LOGGING := false

static func debug(msg):
	if DEBUG_LOGGING:
		print("[DEBUG] ", msg)

static func info(msg):
	print("[INFO] ", msg)

static func warn(msg):
	push_warning(str(msg))

static func error(msg):
	push_error(str(msg))
