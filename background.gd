extends Node2D

const W: int = 320
const H: int = 180
const SPEED: float = 120.0

var img: Image
var tex: ImageTexture
var player: Vector2i = Vector2i(W / 2, H / 2)
var target: Vector2i = Vector2i(250, 90)

func _ready() -> void:
	img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	tex = ImageTexture.create_from_image(img)
	queue_redraw()

func _process(delta: float) -> void:
	var move: Vector2 = Vector2.ZERO
	move.x = Input.get_axis("ui_left", "ui_right")
	move.y = Input.get_axis("ui_up", "ui_down")

	if move.length() > 0.0:
		move = move.normalized()

	var step: Vector2 = move * SPEED * delta
	player += Vector2i(round(step.x), round(step.y))

	player.x = clamp(player.x, 0, W - 1)
	player.y = clamp(player.y, 0, H - 1)

	render_raster()
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(tex, Rect2(Vector2.ZERO, Vector2(W, H) * 3.0), false)

func render_raster() -> void:
	img.fill(Color.BLACK)

	draw_raster_line(player, target, Color.LIME)
	draw_raster_line(Vector2i(20, 20), player, Color.CYAN)

	draw_dot(player, Color.WHITE)
	draw_dot(target, Color.RED)

	tex.update(img)

func draw_dot(p: Vector2i, color: Color) -> void:
	for y in range(-2, 3):
		for x in range(-2, 3):
			set_px(p.x + x, p.y + y, color)

func set_px(x: int, y: int, color: Color) -> void:
	if x >= 0 and x < W and y >= 0 and y < H:
		img.set_pixel(x, y, color)

func draw_raster_line(a: Vector2i, b: Vector2i, color: Color) -> void:
	var x0: int = a.x
	var y0: int = a.y
	var x1: int = b.x
	var y1: int = b.y

	var dx: int = abs(x1 - x0)
	var sx: int = 1 if x0 < x1 else -1
	var dy: int = -abs(y1 - y0)
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx + dy

	while true:
		set_px(x0, y0, color)

		if x0 == x1 and y0 == y1:
			break

		var e2: int = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
