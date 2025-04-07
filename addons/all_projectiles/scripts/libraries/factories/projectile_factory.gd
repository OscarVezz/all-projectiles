class_name ProjectileFactory
extends RefCounted


static func create_projectile(resource: ProjectileBlueprint2D, packed_info: PackedInfo) -> Projectile2D:
	
	if resource.proj_type == ProjectileConstants.ProjectileType.AREA:
		return AreaProjectile2D.new(resource, packed_info)
	# elif resource.proj_type == ProjectileConstants.ProjectileType.PHYSIC:
	# 	return PhysicProjectile2D.new(resource, packed_info)
	elif resource.proj_type == ProjectileConstants.ProjectileType.INSTANTIATED:
		return InstancedProjectile2D.new(resource, packed_info)
	else:
		return AreaProjectile2D.new(resource, packed_info) 
