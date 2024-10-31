class_name StageThree
extends CameraControllerBase


@export var follow_speed:float =  0.7
@export var catchup_speed:float =  0.94
@export var leash_distance:float = 50


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
	
	# This will change the speed according to the vessel's velocity
	var target_speed:int = target.BASE_SPEED
	if Input.is_action_pressed("ui_accept"):
		target_speed = target.HYPER_SPEED
	else:
		target_speed = target.BASE_SPEED
	
		
	if target.velocity == Vector3(0, 0, 0) or dist > leash_distance:
		global_position += direction * target_speed * catchup_speed * delta 
	else:
		global_position += direction * follow_speed * target_speed * delta 
	
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
