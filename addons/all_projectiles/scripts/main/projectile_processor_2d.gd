## Adds, draws and processes all requested projectiles.

@icon("res://addons/all_projectiles/icons/projectile_processor_2d.svg")

class_name ProjectileProcessor2D
extends Node2D


signal projectile_array_expanded
signal projectile_inactive_queue_expanded
signal projectile_inactive_queue_contracted


var projectiles: Array[Projectile2D]
var inactive_projectiles_queue: Array[int] 

var world_RID: RID 
var packed_info: PackedInfo

var visible_collisions: bool



func _ready() -> void:
	# It is extremely possible that ProjCall will end up being responsible for assigning 
	# worlds and Scenes on projectile creation and not just by static variables on the ProjPross
	# That's because I may end up allowing the creation of more than one ProjPross on the SceneTree
	world_RID = get_world_2d().space 
	packed_info = PackedInfo.new()

	InstancedProjectile2D.current_scene = get_tree().current_scene
	Projectile2D.current_space = get_world_2d().direct_space_state

	visible_collisions = get_tree().debug_collisions_hint



func add_projectiles_resource(_resource: ProjectileBlueprint2D, _position: Vector2, _destination: Vector2, _target: Node2D = null,
	 _move_method: Callable = Callable(), _start_method: Callable = Callable(), _collision_method: Callable = Callable(),
	 _expired_method: Callable = Callable()) -> void:
	
	var iterations: int = _resource.instances

	var pseudo_position: Vector2 = ProjectileConstants.get_pseudo_position(_resource.proj_directionality, _position, _destination)
	var pseudo_direction: Vector2 = ProjectileConstants.get_pseudo_direction(_resource.proj_directionality, _position, _destination)

	for i: int in iterations:
		var individual_position: Vector2 = ProjectileConstants.get_position(_resource.proj_spread, pseudo_position, pseudo_direction, 
				iterations, i, _resource.vertical_spread, _resource.randomize_positions)
		var indididual_direction: Vector2 = ProjectileConstants.get_direction(_resource.proj_spread, pseudo_direction,
				iterations, i, _resource.linear_deviation, _resource.angular_spread, _resource.linear_speed)
		_add_projectile(_resource, individual_position, indididual_direction, _destination, _target, i, 
		_move_method, _start_method, _collision_method, _expired_method)




func _add_projectile(_resource: ProjectileBlueprint2D, _position: Vector2, _direction: Vector2, _destination: Vector2, _target: Node2D, 
	_index: int, _move_method: Callable, _start_method: Callable, _collision_method: Callable,
	_expired_method: Callable = Callable()) -> void:
	
	packed_info.reassing(_position, _direction, _destination, _target, _index, world_RID, 
	_move_method, _start_method, _collision_method, _expired_method)

	if inactive_projectiles_queue.size() > 0:
		var id: int = inactive_projectiles_queue.pop_front()
		projectile_inactive_queue_contracted.emit() 

		if _resource.proj_type == projectiles[id].resource.proj_type:
			projectiles[id]._init(_resource, packed_info) 
		else:
			projectiles[id] = ProjectileFactory.create_projectile(_resource, packed_info)
			projectiles[id].projectile_requested.connect(add_projectiles_resource)

	else:
		projectiles.append(ProjectileFactory.create_projectile(_resource, packed_info))
		projectiles[projectiles.size() - 1].projectile_requested.connect(add_projectiles_resource)
		projectile_array_expanded.emit()
	



func _process(delta: float) -> void:
	
	for i: int in projectiles.size():

		if !projectiles[i].is_active:
			continue
		
		if !projectiles[i].update_lifetime(delta):
			projectiles[i].disable()

			inactive_projectiles_queue.push_back(i)
			projectile_inactive_queue_expanded.emit()
	
	queue_redraw()



func _physics_process(delta: float) -> void:
	
	for i: int in projectiles.size():

		if !projectiles[i].is_active:
			continue
		
		projectiles[i].move(delta)



func _draw() -> void:
	for i: int in projectiles.size():

		if !projectiles[i].is_active:
			continue

		if projectiles[i] is InstancedProjectile2D:
			continue

		var proj: AreaProjectile2D = projectiles[i] 
		draw_set_transform_matrix(proj.transform)
		draw_texture(proj.graphics, -proj.texture_size)
		
		if (visible_collisions):
			draw_circle(Vector2.ZERO, proj.radius, Color(0.0, 0.6, 0.7, 0.42))
			draw_circle(Vector2.ZERO, proj.radius, Color(0.0, 0.6, 0.7, 1), false)




func _enter_tree() -> void:
	if (get_tree().get_first_node_in_group(ProjectileConstants.PROJ_PROCESSOR_GROUP_NAME) != null):
		queue_free()

	add_to_group(ProjectileConstants.PROJ_PROCESSOR_GROUP_NAME)


func _exit_tree() -> void:
	remove_from_group(ProjectileConstants.PROJ_PROCESSOR_GROUP_NAME)
	for proj: Projectile2D in projectiles:
		if (proj.is_active):
			proj.disable()

	projectiles.clear()
