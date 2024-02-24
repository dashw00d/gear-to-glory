extends Node2D

# Maximum speed of the background movement
var max_speed = 1500

# Dragging Vars
var is_dragging = false
var last_mouse_position = Vector2.ZERO
var min_drag_distance = 10  # Pixels
var drag_multiplier = 2.0

# Button Vars
var current_target_position = Vector2()
var open_menu: Dictionary = {}  # Assuming all menus are Control nodes
var button_targets = {
	"Travel": Vector2(-100, 0),  # These are example values
	"Storage": Vector2(-750, 0),
	"Skills": Vector2(-1100, 0),
	"Crafting": Vector2(-1800, 0),
	"Alchemy": Vector2(-2500, 0),
	"Quests": Vector2(-3500, 0)
}


func _ready() -> void:
	%CloseButton.close_button_pressed.connect(_on_close_button_pressed.bind())
	$BackgroundContainer.position = Vector2()
	current_target_position = button_targets["Crafting"]
	for button_name in button_targets.keys():
		var button_path = "ButtonControl/MarginContainer/ButtonContainer/" + button_name
		var button = get_node_or_null(button_path)
		if button:
			button.mouse_entered.connect(_on_Button_hovered.bind(button_name))
			button.pressed.connect(_on_Button_pressed.bind(button_name))
			# Optionally, connect mouse_exited for when you want to reset or change behavior on hover exit
		else:
			print("Button with name '%s' not found in path '%s'." % [button_name, button_path])


func _on_Button_hovered(button_name: String):
	current_target_position = button_targets[button_name]


func _on_Button_pressed(button_name: String):
	# hide_all_menus() # make sure no other menu is open
	if open_menu.has(button_name):
		_on_close_button_pressed(button_name)
		return
	else:
		max_speed = 0
		hide_all_menus()  # Make sure no other menu is open
		%ModalBG.visible = true
		match button_name:
			"Travel":
				switch_to_battle_scene()
			"Storage":
				%Inventory.visible = true
				%CloseButton.visible = true
				open_menu[button_name] = %Inventory
			"Skills":
				pass
			"Crafting":
				pass
			"Alchemy":
				pass
			"Quests":
				pass
			_:
				print("Button with name '%s' not found in button_targets." % button_name)


func switch_to_battle_scene():
	# Instantiate the battle scene
	get_tree().change_scene_to_file("res://scenes/battle.tscn")


func _on_close_button_pressed(button_name: String = ""):
	# Check if a specific button_name was provided
	if button_name != "" and open_menu.has(button_name):
		var menu_to_close = open_menu[button_name]
		menu_to_close.visible = false
		open_menu.erase(button_name)
	else:
		# No specific button_name, so close the last opened menu
		if open_menu.size() > 0:
			var last_menu_name = open_menu.keys()[open_menu.size() - 1]
			var menu_to_close = open_menu[last_menu_name]
			menu_to_close.visible = false
			open_menu.erase(last_menu_name)

	max_speed = 1500
	%ModalBG.visible = false
	%CloseButton.visible = false
	clear_focus()


func _input(event: InputEvent) -> void:
	if open_menu.size() == 0:  # Dragging is disabled if a menu is open.
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					is_dragging = true
					last_mouse_position = event.position
				else:
					is_dragging = false

	if event.is_action_pressed("ui_cancel"):
		# Check if there is any menu open before attempting to close
		if open_menu.size() > 0:
			for menu_name in open_menu.keys():
				_on_close_button_pressed(menu_name)
			# Optionally, clear the open_menu dictionary if you want to close all menus at once
			# open_menu.clear()


func hide_all_menus():
	for menu in open_menu.values():
		menu.visible = false
	open_menu.clear()
	%ModalBG.visible = false
	%CloseButton.visible = false


func handle_drag_movement(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var mouse_position = get_viewport().get_mouse_position()
	# Invert the drag direction by subtracting the current mouse position from the last mouse position
	var drag_distance = last_mouse_position - mouse_position

	# Apply a conditional drag multiplier based on drag distance
	var drag_multiplier = 3 if abs(drag_distance.x) >= 200 or abs(drag_distance.y) >= 200 else 0

	var move_speed_x = clamp(drag_distance.x * drag_multiplier, -max_speed, max_speed)
	var move_speed_y = clamp(drag_distance.y * drag_multiplier, -max_speed, max_speed)

	# Apply the movement speed to the target position
	current_target_position.x += move_speed_x * delta
	current_target_position.y += move_speed_y * delta

	# Smooth transition towards the current target position using lerp
	var lerp_speed = 15.0
	$BackgroundContainer.position = $BackgroundContainer.position.lerp(
		current_target_position, lerp_speed * delta
	)

	# Clamp the background and target positions
	clamp_positions(viewport_size)


func clamp_positions(viewport_size: Vector2) -> void:
	var scene_width = 4672  # Adjust to your background size
	var scene_height = viewport_size.y  # Assuming vertical movement is not desired

	# Clamp background position
	$BackgroundContainer.position.x = clamp(
		$BackgroundContainer.position.x, viewport_size.x - scene_width, 0
	)
	$BackgroundContainer.position.y = clamp(
		$BackgroundContainer.position.y, viewport_size.y - scene_height, 0
	)

	# Clamp target position to prevent it from invisibly moving off-screen
	var min_x = viewport_size.x - scene_width
	var min_y = viewport_size.y - scene_height
	current_target_position.x = clamp(current_target_position.x, min_x, 0)
	current_target_position.y = clamp(current_target_position.y, min_y, 0)


func _process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	if is_dragging:
		handle_drag_movement(delta)
		# last_mouse_position = get_viewport().get_mouse_position()  # Update for next frame
	else:
		# This block handles smooth movement towards the target position
		var lerp_speed = 5.0  # Adjust this value as needed for a smoother or faster transition
		$BackgroundContainer.position = $BackgroundContainer.position.lerp(current_target_position, lerp_speed * delta)
		clamp_positions(get_viewport_rect().size)

func _on_modal_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# The ColorRect was clicked, check if it's outside the currently open menu
		var clicked_outside = true
		for menu_name in open_menu:
			var menu = open_menu[menu_name]
			if menu.get_global_rect().has_point(event.global_position):
				clicked_outside = false
				break

		if clicked_outside:
			for menu_name in open_menu.keys():
				_on_close_button_pressed(menu_name)  # Assuming this function now takes a menu name
			clear_focus()


func clear_focus():
	for child in $ButtonControl/MarginContainer/ButtonContainer.get_children():
		child.release_focus()
