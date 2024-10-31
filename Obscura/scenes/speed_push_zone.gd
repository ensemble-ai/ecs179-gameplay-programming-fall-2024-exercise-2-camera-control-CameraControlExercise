class_name SpeedPushZone
extends CameraControllerBase

@export var push_ratio:float = 0.5
@export var pushbox_top_left:Vector2 = Vector2(8, 8)
@export var pushbox_bottom_right:Vector2 = Vector2(8, 8)
@export var speedup_zone_top_left:Vector2 = Vector2(3, 3)
@export var speedup_zone_bottom_right:Vector2 = Vector2(3, 3)

var box_width:float = abs(pushbox_top_left.x) + abs(pushbox_bottom_right.x)
var box_height:float = abs(pushbox_top_left.y) + abs(pushbox_bottom_right.y)

var inner_box_width:float = abs(speedup_zone_top_left.x) + abs(speedup_zone_bottom_right.x)
var inner_box_height:float = abs(speedup_zone_top_left.y) + abs(speedup_zone_bottom_right.y)

func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	
	box_width = abs(pushbox_top_left.x) + abs(pushbox_bottom_right.x)
	box_height = abs(pushbox_top_left.y) + abs(pushbox_bottom_right.y)
	inner_box_width = abs(speedup_zone_top_left.x) + abs(speedup_zone_bottom_right.x)
	inner_box_height = abs(speedup_zone_top_left.y) + abs(speedup_zone_bottom_right.y)
	
	if !current:
		position = target.position
		return
	
	if draw_camera_logic:
		draw_logic()
		
	var tpos = target.global_position
	var cpos = global_position
	
	var right_zone = (cpos.x + box_width / 2.0) - (cpos.x + inner_box_width / 2.0)
	var left_zone = (cpos.x - box_width / 2.0) - (cpos.x - inner_box_width / 2.0)
	var top_zone = (cpos.z - box_width / 2.0) - (cpos.z - inner_box_width / 2.0)
	var bttom_zone = (cpos.z + box_width / 2.0) - (cpos.z + inner_box_width / 2.0)
	
	
	
	#boundary checks
	#left
	
	
	#left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - box_width / 2.0)
	var inner_diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - inner_box_width / 2.0) # helps me figure if I am outside of the box
	if diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
	# This condiction determines if the vessel is at push_zone
	if diff_between_left_edges > 0 and inner_diff_between_left_edges < 0 and target.velocity.x < 0:
		global_position.x += target.velocity.x * push_ratio * delta
		
	
	#right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + box_width / 2.0)
	var inner_diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + inner_box_width / 2.0)
	if diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
	if diff_between_right_edges < 0 and inner_diff_between_right_edges > 0 and target.velocity.x > 0:
		global_position.x += target.velocity.x * push_ratio * delta
		
	#top
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - box_height / 2.0)
	var inner_diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - inner_box_height / 2.0)
	if diff_between_top_edges < 0:
		global_position.z += diff_between_top_edges
		
	if diff_between_top_edges > 0 and inner_diff_between_top_edges < 0 and target.velocity.z < 0:
		global_position.z += target.velocity.z * push_ratio * delta 
	#bottom
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + box_height / 2.0)
	var inner_diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + inner_box_height / 2.0)
	if diff_between_bottom_edges > 0:
		global_position.z += diff_between_bottom_edges
		
	if diff_between_bottom_edges < 0 and inner_diff_between_bottom_edges > 0 and target.velocity.z > 0:
		global_position.z += target.velocity.z * push_ratio * delta 
	
		
	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	
	var left:float = -box_width / 2
	var right:float = box_width / 2
	var top:float = -box_height / 2
	var bottom:float = box_height / 2
	
	var inner_left:float = -inner_box_width / 2
	var inner_right:float = inner_box_width / 2
	var inner_top:float = -inner_box_height / 2
	var inner_bottom:float = inner_box_height / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	
	
	#
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_top))
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_bottom))

	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_bottom))
	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_bottom))

	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_bottom))
	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_top))

	immediate_mesh.surface_add_vertex(Vector3(inner_left, 0, inner_top))
	immediate_mesh.surface_add_vertex(Vector3(inner_right, 0, inner_top))
	
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
