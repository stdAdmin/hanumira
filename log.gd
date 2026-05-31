class_name Log

const DEBUG_LOGGING := false
#const DEBUG_LOGGING := true

#const INFO_LOGGING := false
const INFO_LOGGING := true

static func debug(msg):
	if DEBUG_LOGGING:
		print("[DEBUG] ", msg)

static func info(msg):
	if INFO_LOGGING:
		print("[INFO] ", msg)

static func warn(msg):
	push_warning(str(msg))

static func error(msg):
	push_error(str(msg))
