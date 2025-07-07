class_name ProjectileConstants
extends RefCounted


const PROJ_CALLER_GROUP_NAME: StringName = "projectile_caller_group"
const PROJ_PROCESSOR_GROUP_NAME: StringName = "projectile_processor_group"
const PROJ_WRAPPER_GROUP_NAME: StringName = "projectile_wrapper_group"
const PROJ_STEP_TARGET_NAME: StringName = "step"


enum ProjectileType{
    AREA  = 0, 
    #PHYSIC = 1,
    INSTANTIATED = 2
}

enum ProjectileDirectionality{
    STRICT     = 0,
    ADAPTATIVE = 1,
    MODIFIABLE = 2
}

enum ProjectileSpread{
    NONE     = 0,
    LINEAR   = 1,
    ANGULAR  = 2,
    CIRCULAR = 3,
    EVENLY   = 4
}

enum WeaponChargeType{
	CONTINOUS = 0,
	DISCRETE  = 1,
	MANDATORY = 2
}

enum WeaponChargeTrigger{
	ON_READY   = 0,
	ON_RELEASE = 1
}



static func get_pseudo_position(direction_type: int, position: Vector2, destination: Vector2) -> Vector2:
	match direction_type:
		ProjectileDirectionality.STRICT:
			return position
		ProjectileDirectionality.ADAPTATIVE:
			return Vector2(position.x, destination.y)
		ProjectileDirectionality.MODIFIABLE:
			return position
		_:
			return position


static func get_pseudo_direction(direction_type: int, position: Vector2, destination: Vector2) -> Vector2:
	match direction_type:
		ProjectileDirectionality.STRICT:
			return (destination - Vector2(position.x, destination.y)).normalized()
		ProjectileDirectionality.ADAPTATIVE:
			return (destination - Vector2(position.x, destination.y)).normalized()
		ProjectileDirectionality.MODIFIABLE:
			return (destination - position).normalized()
		_:
			return (destination - position).normalized()


static func get_position(spread_type: int, pseudo_position: Vector2, pseudo_direction: Vector2, instances: int, index: int, vertical_spread: float, add_randomness: bool) -> Vector2:
	
	if spread_type == ProjectileSpread.NONE || spread_type == ProjectileSpread.CIRCULAR || instances < 2:
		return pseudo_position

	var magnitude: float
	if add_randomness:
		magnitude = randf_range(-(vertical_spread / 2), vertical_spread / 2)
	else:
		var separation: float = vertical_spread / (instances - 1)
		magnitude = (vertical_spread / 2) - (index * separation)
	
	return (Vector2(pseudo_direction.y * -1, pseudo_direction.x) * magnitude) + pseudo_position


static func get_direction(spread_type: int, pseudo_direction: Vector2, instances: int, index: int, linear_deviation: float, angular_spread: float, speed: float) -> Vector2:
	
	if speed == 0:
		return Vector2.ZERO

	var buffer: Vector2

	match spread_type:
		ProjectileSpread.NONE:
			buffer = pseudo_direction
		ProjectileSpread.LINEAR:
			buffer = pseudo_direction
		ProjectileSpread.ANGULAR:
			if instances < 2:
				buffer = pseudo_direction
			else:
				var separation: float = angular_spread / (instances - 1)
				var angle: float = deg_to_rad((angular_spread / 2) - (index * separation))
				buffer = Vector2(pseudo_direction.x * cos(angle) - pseudo_direction.y * sin(angle), pseudo_direction.x * sin(angle) + pseudo_direction.y * cos(angle))
		ProjectileSpread.CIRCULAR:
			if instances < 2:
				buffer = pseudo_direction
			else:
				var separation: float = 360.0 / instances
				var angle: float = deg_to_rad((index * separation))
				buffer = Vector2(pseudo_direction.x * cos(angle) - pseudo_direction.y * sin(angle), pseudo_direction.x * sin(angle) + pseudo_direction.y * cos(angle))
		_:
			buffer = pseudo_direction
    
	return (buffer + Vector2(randf_range(-linear_deviation, linear_deviation), randf_range(-linear_deviation, linear_deviation)) / speed)
