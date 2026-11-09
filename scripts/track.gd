
extends Node2D

const TRACK_WIDTH := 180.0
const BORDER_WIDTH := 18.0
const BAKE_INTERVAL := 6.0

const GRASS_COLOR := Color("#527D42")
const GRASS_PATCH_COLOR := Color("#608D4C")
const ROAD_COLOR := Color("#383C43")
const BORDER_COLOR := Color("#D7D7D7")
const LINE_COLOR := Color("#D9D9C7")

var track_curve := Curve2D.new()
var road_points := PackedVector2Array()


func _ready() -> void:
	build_track_curve()
	road_points = track_curve.get_baked_points()
	queue_redraw()



func build_track_curve() -> void:
	track_curve.clear_points()
	track_curve.bake_interval = BAKE_INTERVAL

	# Each point represents a major track position.
	# The first point is repeated at the end to close the circuit.
	var points := PackedVector2Array([
		# Start / finish straight
		Vector2(500, 400),
		Vector2(1150, 400),
		Vector2(1700, 400),

		# Fast upper section
		Vector2(2150, 470),
		Vector2(2500, 650),
		Vector2(2700, 950),
		Vector2(2750, 1200),

		# Dead Man's Hairpin
		Vector2(2700, 1400),
		Vector2(2550, 1570),
		Vector2(2350, 1640),
		Vector2(2150, 1570),
		Vector2(2020, 1400),
		Vector2(2000, 1180),

		# Technical S-bends
		Vector2(1800, 1080),
		Vector2(1600, 1220),
		Vector2(1400, 1080),
		Vector2(1200, 1220),
		Vector2(1000, 1080),

		# Lower-left sweeping section
		Vector2(800, 1180),
		Vector2(650, 1030),
		Vector2(550, 820),

		# Final approach — wider chicane
		Vector2(550, 820),
		Vector2(350, 760),
		Vector2(200, 600),
		Vector2(150, 450),
		Vector2(200, 400),

		# Start / finish connection
		Vector2(500, 400)
	])

	# Automatically calculate smooth Bézier handles.
	for i in range(points.size()):
		var previous_index := i - 1
		var next_index := i + 1

		if i == 0:
			previous_index = points.size() - 2

		if i == points.size() - 1:
			next_index = 1

		var tangent: Vector2 = (
			points[next_index] - points[previous_index]
		) * 0.25

		track_curve.add_point(
			points[i],
			-tangent,
			tangent
		)


func _draw() -> void:
	# Large grass background
	draw_rect(
		Rect2(-100, -100, 3400, 2400),
		GRASS_COLOR
	)

	# Decorative grass patches
	for i in range(100):
		var x := float((i * 173) % 3300)
		var y := float((i * 97) % 2300)

		draw_circle(
			Vector2(x, y),
			12.0,
			GRASS_PATCH_COLOR
		)

	if road_points.size() < 2:
		return

	# Outer road border
	draw_polyline(
		road_points,
		BORDER_COLOR,
		TRACK_WIDTH + BORDER_WIDTH,
		true
	)

	# Asphalt
	draw_polyline(
		road_points,
		ROAD_COLOR,
		TRACK_WIDTH,
		true
	)

	# Dashed centerline
	for i in range(0, road_points.size() - 1, 8):
		var end_index := mini(
			i + 3,
			road_points.size() - 1
		)

		draw_line(
			road_points[i],
			road_points[end_index],
			LINE_COLOR,
			3.0,
			true
		)
