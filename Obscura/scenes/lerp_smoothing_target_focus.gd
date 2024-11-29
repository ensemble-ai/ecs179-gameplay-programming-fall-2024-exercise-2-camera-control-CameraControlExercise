class_name LerpsmoothingTargetFocus
extends CameraControllerBase


@export var lead_speed:float = 1.2
@export var catchup_delay_duration:float = 1.5 # maybe use the timer from exercise one
@export var catchup_speed:float = 2
@export var leash_distance:float = 50

var timer:float = 0.0
var is_catching_up:bool = false

func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		position = target.position
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	
	var dist = (tpos - cpos).length()
	var direction = (tpos - cpos).normalized()
	

		
	if target.velocity == Vector3(0, 0, 0):
		timer += delta * 1
		if timer >= catchup_delay_duration:
			is_catching_up = true
	else:
		timer = 0.0
		is_catching_up = false
	
	if is_catching_up:
		global_position += direction * target_speed * catchup_speed * delta
	elif dist > leash_distance:
		global_position += direction * target_speed * catchup_speed * delta
	else:
		global_position += target.velocity * lead_speed * delta
	
	super(delta)

func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	immediate_mesh.surface_add_vertex(Vector3(0, 0, 2.5))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -2.5))
	
	immediate_mesh.surface_add_vertex(Vector3(-2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(2.5, 0, 0))
	
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
