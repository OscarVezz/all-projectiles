class_name Projectile2D


signal projectile_requested(_resource: ProjectileBlueprint2D, _position: Vector2, _destination: Vector2, _target: Node2D)

## Static variable for collision detection
static var current_space: PhysicsDirectSpaceState2D

## Variable state for projectile update validation
var is_active: bool
## Variable state for projectile lifetime & pierce validation
var is_expired: bool

## Variable state of the projectile current transform
var transform: Transform2D:
	get:
		return get_transform_2D()
	set(value):
		set_transform_2D(value)
## Variable state of the projectile current position
var position: Vector2
## Variable state of the projectile current motion direction
var direction: Vector2
## Fixed projectile destination
var destination: Vector2

## Variable state of the projectile current speed
var speed: float
## Variable state of the projectile remaining lifetime
var lifetime: float
## Variable state of the projectile remaining pierce
var pierce: int

## Fixed projectile blueprint 
var resource: ProjectileBlueprint2D
## Variable selected seeking object
var target: Node2D

# Homing
## The RID for seeking shape casting 
var cast_shape: RID
## The parameters for seeking shape casting
var query: PhysicsShapeQueryParameters2D
## Variable state for the projectile seeking angular speed
var angular_speed: float
## Variable state of the projectile current hit
var first_hit: bool 

# Piercing
## The list of already hit RID's for piercing avoidance
var excluded_targets: Array[RID]
## Variable state of the projectile current rehit cooldown
var rehit_cooldown: float

# Callables
## Does the projectile use a custom move method
var use_custom_move_method: bool
## Callable for the projectile custom move method
var custom_move_method: Callable
## Does the projectile use a custom collision method
var use_custom_collision_method: bool
## Callable for the projectile custom collision method
var custom_collision_method: Callable
## Does the projectile use a custom expired method
var use_custom_expired_method: bool
## Callable for the projectile custom expired method
var custom_expired_method: Callable

## Variable state of the projectile current falling behaviour
var is_falling_flag: bool

## Arbitrary variable for custom properties 1
var arg1: Variant
## Arbitrary variable for custom properties 2
var arg2: Variant


func _init(_resource: ProjectileBlueprint2D, _pi: PackedInfo) -> void:
	resource = _resource
	target =_pi.target

	position = _pi.position
	direction = _pi.direction
	destination = _pi.destination
	
	speed = _resource.linear_speed
	lifetime = _resource.lifetime
	pierce = _resource.pierce
 
	is_active = true
	is_expired = false
	
	# Homing
	first_hit = true
	angular_speed = resource.angular_speed

	cast_shape = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(cast_shape, resource.cast_radius)
	if (query == null):
		query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collision_mask = resource.seeking_mask
	query.shape_rid = cast_shape
	
	# Pierce
	rehit_cooldown = -resource.lifetime - 1.0

	# Custom Methods
	use_custom_move_method = false
	if (_pi.move_method.is_valid()):
		custom_move_method = _pi.move_method
		use_custom_move_method = true
	
	use_custom_collision_method = false
	if (_pi.collision_method.is_valid()):
		custom_collision_method = _pi.collision_method
		use_custom_collision_method = true
	
	use_custom_expired_method = false
	if (_pi.expired_method.is_valid()):
		custom_expired_method = _pi.expired_method
		use_custom_expired_method = true
	
	is_falling_flag = false
	arg1 = null
	arg2 = null





func update_lifetime(delta: float) -> bool:
	if (is_expired):
		on_expired()
		return false
	
	rehit_cooldown += delta
	lifetime -= delta
	if lifetime < 0.0:
		is_expired = true
		on_expired()
		return false
	else:
		return true



func move(delta: float)-> void:
	var angle: float

	if (resource.seeking):
		if (target != null):
			angle = seek_target(delta)
		else:
			try_retarget()


	if (use_custom_move_method):
		var dir: Vector2 = custom_move_method.call(self, delta)
		position += dir * delta * speed
		angle = transform.x.angle_to(dir)
	else:
		position += direction * delta * speed
	

	if (resource.look_at):
		transform = transform.rotated(angle)
	transform.origin = position



func disable() -> void:
	PhysicsServer2D.free_rid(cast_shape)
	excluded_targets.clear()
	query.exclude = excluded_targets
	is_active = false






func seek_target(_delta: float) -> float:
	var clamped_angle: float = clampf(direction.angle_to((target.global_position - position).normalized()), 
							   -deg_to_rad(angular_speed * _delta), deg_to_rad(angular_speed * _delta))
	
	direction = direction.rotated(clamped_angle)

	return clamped_angle


func try_retarget() -> void:
	# if (current_space == null):		# Redundant??
	# 	return
	query.transform = Transform2D(0.0, transform.origin)

	var result: Dictionary = current_space.get_rest_info(query)
	if (result):
		var id: int = result.collider_id
		var collider: CollisionObject2D = instance_from_id(id)
		target = validate_target(collider)






func validate_collision(colliding_rid: RID, colliding_node: Node) -> bool:
	if (is_expired):
		return false

	# While "target != null" isn't necessary, the resulting beheaviour will be prefered by the common user
	if (resource.lock_to_target && target != null):
		if (target != colliding_node):
			return false

	if (excluded_targets.has(colliding_rid)):
		return false
	
	return true


func validate_target(collider: Node) -> Node:
	if (collider.is_in_group(ProjectileConstants.PROJ_STEP_TARGET_NAME)):
		return validate_target(collider.get_parent())
	else:
		return collider



func on_pierced(pierced_rid: RID) -> void:
	if (first_hit):
		angular_speed = resource.after_hit_angular_speed
		rehit_cooldown = 0.0
		first_hit = false

	if (resource.allow_rehit):
		if (rehit_cooldown > resource.rehit_cooldown):
			excluded_targets.clear()
			rehit_cooldown = 0.0

	excluded_targets.append(pierced_rid)
	query.exclude = excluded_targets
	target = null

	pierce -= 1;
	if (pierce < 1):
		is_expired = true


func on_expired() -> void:
	if (resource.on_expired_projectile != null):
		projectile_requested.emit(resource.on_expired_projectile, position, position + transform.x, null)
	
	if (use_custom_expired_method):
		custom_expired_method.call(self)





func get_transform_2D() -> Transform2D:
	return Transform2D()

func set_transform_2D(_transform: Transform2D) -> void:
	pass
