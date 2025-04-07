class_name AreaProjectile2D
extends Projectile2D


var graphics: Texture2D;
var texture_size: Vector2;   

var radius: int;           
var collision_layer: int
var collision_mask: int

var shape: RID
var area: RID

var _transform: Transform2D



func _init(_resource: ProjectileBlueprint2D, _pi: PackedInfo) -> void:
	super(_resource, _pi)

	# Maybe this can be in a "Physic stuff" class?
	graphics = _resource.texture;
	texture_size = _resource.texture.get_size()/2

	radius = _resource.radius;
	collision_layer = _resource.collision_layer;
	collision_mask = _resource.collision_mask;

	shape = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape, radius) 
	# Until here


	area = PhysicsServer2D.area_create()
	PhysicsServer2D.area_add_shape(area, shape)
	PhysicsServer2D.area_set_collision_layer(area, collision_layer)
	PhysicsServer2D.area_set_collision_mask(area, collision_mask)

	PhysicsServer2D.area_set_monitorable(area, _resource.area_monitoreable)
	PhysicsServer2D.area_set_area_monitor_callback(area, area_monitor_callback)
	PhysicsServer2D.area_set_monitor_callback(area, body_monitor_callback)

	PhysicsServer2D.area_set_space(area, _pi.world_2d)

	if (_resource.look_at):
		transform = Transform2D(atan2(direction.y, direction.x), Vector2.ONE * _resource.size, 0.0, position)
	else:
		transform = Transform2D(0.0, Vector2.ONE * _resource.size, 0.0, position)

	if (_pi.start_method.is_valid()):
		_pi.start_method.call(self)



func area_monitor_callback(status: int, area_rid: RID, instance_id: int, area_shape_index: int, self_shape_index: int) -> void:
	if (status != PhysicsServer2D.AREA_BODY_ADDED):
		return
	
	var collider: Node2D = instance_from_id(instance_id)
	collider = validate_target(collider)
	if (use_custom_collision_method):
		custom_collision_method.call(self, area_rid, collider, area_shape_index, self_shape_index)
		return
	
	if !validate_collision(area_rid, collider):
		return
	
	if collider.has_method(resource.on_hit_call):
		collider.call(resource.on_hit_call, self)
	on_pierced(area_rid)


func body_monitor_callback(status: int, body_rid: RID, instance_id: int, body_shape_index: int, self_shape_index: int) -> void:
	if (status != PhysicsServer2D.AREA_BODY_ADDED):
		return
	
	var collider: Node2D = instance_from_id(instance_id)
	collider = validate_target(collider)
	if (use_custom_collision_method):
		custom_collision_method.call(self, body_rid, collider, body_shape_index, self_shape_index)
		return
	
	if !validate_collision(body_rid, collider):
		return
	
	if collider.has_method(resource.on_hit_call):
		collider.call(resource.on_hit_call, self)
	on_pierced(body_rid)



func disable() -> void:
	PhysicsServer2D.free_rid(area)
	PhysicsServer2D.free_rid(shape)
	super()





func get_transform_2D() -> Transform2D:
	return _transform

func set_transform_2D(t: Transform2D) -> void:
	_transform = t
	PhysicsServer2D.area_set_transform(area, t)
