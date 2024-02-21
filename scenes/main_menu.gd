extends Node2D

# Edge threshold percentages of the viewport size (0.0 to 1.0)
var edge_threshold_x_percentage = 0.3 # 10% of the viewport width
var edge_threshold_y_percentage = 0.3 # 5% of the viewport height

# Maximum speed of the background movement
var max_speed = 1500

var current_target_position = Vector2()
var open_menu: Dictionary = {}  # Assuming all menus are Control nodes


var button_targets = {
	"Travel": Vector2(-100, 0), # These are example values
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
		hide_all_menus() # Make sure no other menu is open
		%ModalBG.visible = true
		match button_name:
			"Travel":
				pass
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

func _process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	# Edge scrolling logic
	# Ensure it doesn't interfere with button-driven movement by checking if we are close to the target

	var edge_threshold_x = viewport_size.x * edge_threshold_x_percentage
	var edge_threshold_y = viewport_size.y * edge_threshold_y_percentage
	var mouse_pos = get_viewport().get_mouse_position()

	var move_speed_x = 0.0
	var move_speed_y = 0.0

	if mouse_pos.x < edge_threshold_x:
		move_speed_x = max_speed * (1 - mouse_pos.x / edge_threshold_x)
	elif mouse_pos.x > viewport_size.x - edge_threshold_x:
		move_speed_x = -max_speed * (1 - (viewport_size.x - mouse_pos.x) / edge_threshold_x)

	if mouse_pos.y < edge_threshold_y:
		move_speed_y = max_speed * (1 - mouse_pos.y / edge_threshold_y)
	elif mouse_pos.y > viewport_size.y - edge_threshold_y:
		move_speed_y = -max_speed * (1 - (viewport_size.y - mouse_pos.y) / edge_threshold_y)

	# Incremental movement towards the edge if not already moving towards a target
	current_target_position.x += move_speed_x * delta
	current_target_position.y += move_speed_y * delta

	# Smooth transition towards the current target position using lerp
	var lerp_speed = 5.0  # Adjust the speed of the transition
	$BackgroundContainer.position = $BackgroundContainer.position.lerp(current_target_position, lerp_speed * delta)

	# Optional: Clamp the background position to prevent it from moving too far
	var scene_width = 4672  # Adjust to your background size
	# prevent y axis from moving 
	var scene_height = get_viewport_rect().size.y # Set to bg image height to activate
	$BackgroundContainer.position.x = clamp($BackgroundContainer.position.x, viewport_size.x - scene_width, 0)
	$BackgroundContainer.position.y = clamp($BackgroundContainer.position.y, viewport_size.y - scene_height, 0)


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
				_on_close_button_pressed(menu_name) # Assuming this function now takes a menu name
			clear_focus()

func clear_focus():
	for child in $ButtonControl/MarginContainer/ButtonContainer.get_children():
		child.release_focus()


