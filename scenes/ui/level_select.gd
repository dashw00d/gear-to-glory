extends Node2D

@onready var map_coords = Utils.load_json_array("res://assets/data/maps/map1_coords.json")
@onready var map_sprite = $MapSprite
@onready var marker = $Marker
var scale_factor
var area_to_polygon_map = {}
const TIMER_LIMIT = 1
var timer = 0.0


func _ready():
	map_sprite.input_pickable = true
	#var background = Sprite2D.new()
	#background.texture = preload("res://assets/sprites/ui/map1_level_select.png")
	#background.z_index = -1
	#background.position = Vector2(3330, 1597)
	#add_child(background)
	draw_polygons()
	scale_factor = _calculate_scale_factor()


func get_polygon_center(polygon: Array) -> Vector2:
	var sum = Vector2.ZERO
	for point in polygon:
		sum += Vector2(point[0], point[1])
	return sum / polygon.size()


func draw_polygons():
	for polygon in map_coords:
		var points = PackedVector2Array()
		for point in polygon:
			points.append(Vector2(point[0], point[1]))

		# Create Area2D for mouse detection
		var area = Area2D.new()
		var collision_shape = CollisionPolygon2D.new()
		collision_shape.polygon = points
		area.add_child(collision_shape)
		area.name = "ClickableArea"  # Or any other name that makes sense in your context
		add_child(area)

		# Create Polygon2D for visual representation
		var poly_node = Line2D.new()
		poly_node.points = points
		poly_node.width = 8
		poly_node.default_color = Color(0, 0, 0, .5)

		add_child(poly_node)

		# Map the Area2D to the Polygon2D
		area_to_polygon_map[area] = poly_node


func find_polygon_node_related_to_area(area: Area2D) -> Line2D:
	return area_to_polygon_map.get(area)  # This will return the associated Polygon2D node, or Nil if not found


# Somewhere else in your script, you'd handle the hover effect:
func _process(delta):
	var mouse_pos = get_local_mouse_position()
	timer += delta
	if timer > TIMER_LIMIT:  # Prints every 2 seconds
		timer = 0.0
		print("fps: " + str(Engine.get_frames_per_second()))

		if check_click_against_map_coords(mouse_pos):
			for area in get_children():
				if area is Area2D:
					# Assuming you have a reference to the related Polygon2D node
					var poly = find_polygon_node_related_to_area(area)
					if area.get("polygon"):
						if is_point_in_polygon(mouse_pos, area.get("polygon")):
							print("hi")
							# Mouse is over the polygon, change the outline color to indicate hover
							poly.default_color = Color(0, 0, 0, 1)  # Change to a different color for hover
						else:
							# Mouse is not over the polygon, revert the outline color
							poly.default_color = Color(0.8, 0.2, 0.2, 0)


func _calculate_scale_factor():
	var base_size = Vector2(1920, 1080)
	var current_size = Vector2(DisplayServer.window_get_size())  # alternate get_viewport().get_visible_rect().size
	# Calculate scale factor
	return current_size / base_size
	# Store this scale factor for use in input event handling


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Corrected method to convert global click position to local coordinate system
		var local_click_pos = map_sprite.to_local(event.global_position / scale_factor)
		print(local_click_pos)
		check_click_against_map_coords(local_click_pos)
		get_viewport().set_input_as_handled()  # This line should actually be `event.set_handled()` in Godot 4


func check_click_against_map_coords(click_pos: Vector2):
	for polygon in map_coords:
		if is_point_in_polygon(click_pos, polygon):
			print("Clicked within a polygon!")
			var center = get_polygon_center(polygon)
			# Assuming the marker should be positioned relative to the map_sprite
			marker.global_position = map_sprite.global_position + center
			return true


func is_point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var count = 0
	var n = polygon.size()
	for i in range(n):
		# Assuming each point in the polygon array is itself an array [x, y]
		# Convert them to Vector2 objects
		var a = Vector2(polygon[i][0], polygon[i][1])
		var b = Vector2(polygon[(i + 1) % n][0], polygon[(i + 1) % n][1])

		if (a.y <= point.y and point.y < b.y) or (b.y <= point.y and point.y < a.y):
			var t = (point.y - a.y) / (b.y - a.y)
			if point.x < a.x + t * (b.x - a.x):
				count += 1
	return count % 2 == 1
