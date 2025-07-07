class_name InstancedProjectile2D
extends Projectile2D


## Static variables for projectile instancing
static var current_scene: Node

## The projectile in-world instance 
var instance: Node2D
## The mandatory projectile area collision component
var area: Area2D



func _init(_resource: ProjectileBlueprint2D, _pi: PackedInfo) -> void:
	super(_resource, _pi)

	# Projectile2D Instantiate
	instance = _resource.instance.instantiate()
	instance.position = position
	current_scene.add_child(instance)

	# Collision linking
	area = instance.get_node_or_null(_resource.collision_path)
	if (area == null):
		printerr("Invalid projectile creation. \"%s\" doesn't have a valid \"Area2D\" component at path \"%s\"" % [_resource.resource_path, _resource.collision_path])
		is_expired = true
		return

	area.area_shape_entered.connect(area_monitor_callback)
	area.body_shape_entered.connect(body_monitor_callback)

	if (_resource.look_at):
		instance.look_at(position + direction) 

	if (_pi.start_method.is_valid()):
		_pi.start_method.call(self)



func area_monitor_callback(area_rid: RID, collider: Node2D, area_shape_index: int, self_shape_index: int) -> void:
	collider = validate_target(collider)
	if (use_custom_collision_method):
		custom_collision_method.call(self, area_rid, collider, area_shape_index, self_shape_index)
		return
	
	if !validate_collision(area_rid, collider):
		return

	if collider.has_method(resource.on_hit_call):
		collider.call(resource.on_hit_call, self)
	on_pierced(area_rid)


func body_monitor_callback(body_rid: RID, collider: Node2D, body_shape_index: int, self_shape_index: int) -> void:
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
	instance.queue_free()
	super()





func get_transform_2D() -> Transform2D:
	return instance.transform

func set_transform_2D(t: Transform2D) -> void:
	instance.transform = t
