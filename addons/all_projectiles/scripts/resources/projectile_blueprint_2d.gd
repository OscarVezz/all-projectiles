## Holds all the projectile instance information.

@tool
@icon("res://addons/all_projectiles/icons/projectile_resource_2d.svg")

class_name ProjectileBlueprint2D
extends Resource


@export_category("Main Attributes")
@export var proj_type: ProjectileConstants.ProjectileType:
    set(value):
        proj_type = value
        notify_property_list_changed()

## Main projectile graphic texture
@export var texture: Texture2D
## Applied uniform Scale of the projectile
@export var size: float
## Projectile2D Instance active duration in Seconds
@export var lifetime: float
## Distance traveled in Pixels per Second
@export var linear_speed: float 
## Size of the projectile Collision in Pixels.
## The Collision radius of the projectile is affected by the size of the projectile itself.
@export var radius: int

@export_group("Collisions")
## Collision layer of the projectile itself
@export_flags_2d_physics var collision_layer: int
## Collision layers that can interact with the projectile
@export_flags_2d_physics var collision_mask: int
@export_group("")



@export_category("Projectile2D Type Properties")
## Name of the method that the projectile will call upon collision
@export var on_hit_call: String 
@export_group("AREA Projectile2D Properties")
## If true the projectile can interact with other areas
@export var area_monitoreable: bool
@export_group("")
@export_group("INSTANTIATED Projectile2D Properties")
## Path to the mandatory Area2D element or child component of the Projectile2D Scene
@export var collision_path: String
## The Scene to instantiate as a Projectile2D
@export var instance: PackedScene
@export_group("")



@export_category("Offesinve Attributes")
## Sum of health points that this projectile removes from targets
@export var damage: int
## How many different targets this projectile can Hit
@export var pierce: int



@export_category("Beheaviour Attributes")
## If true the projectile will look at the direction it travels
@export var look_at: bool

@export_group("Seeking Behaviour")
## If true the projectile will follow its targets
@export var seeking: bool
## The projectile will actively seek targets on these Collision layers. Use it so your projectiles don't seek into walls
@export_flags_2d_physics var seeking_mask: int
## Max distance rotated in degrees per second
@export var angular_speed: float
## Angular speed used after the first hit (Useful for ricochet beheaviours)
@export var after_hit_angular_speed: float
## Radius of the sphere cast to search for secondary targets
@export var cast_radius: float
@export_group("")

@export_group("Pierce Properties")
## If true the projectile will ignore all potential collisions in the way to hit its assigned target
@export var lock_to_target: bool
## If true the projectile will be able to hit already hit targets
@export var allow_rehit: bool
## Min amount of time between
@export var rehit_cooldown: float
@export_group("")



@export_category("Instances")
## Amount of projectiles to instantiate
@export var instances: int:
    set(value):
        instances = value
        notify_property_list_changed()
## The type of direction the projectiles will take once instantiated
@export var proj_directionality: ProjectileConstants.ProjectileDirectionality

@export_group("Spread")
## The type of spread the projectiles will take once instantiated
@export var proj_spread: ProjectileConstants.ProjectileSpread:
    set(value):
        proj_spread = value
        notify_property_list_changed()
## The fixed amount of radial extension in which the angular spread projectiles will be evenly distributed (in degrees)
@export var angular_spread: float
## The fixed amount of linear extension in which the linear and angular projectiles will be evenly distributed (in pixels)
@export var vertical_spread: float
## If true the linear and angular projectiles positions will be randomly spread
@export var randomize_positions: bool
@export_group("")

@export_group("Deviation")
## The random amount of deviation the velocity vector of the projectile can differ once instantiated (in pixels)
@export var linear_deviation: float
@export_group("")



@export_category("Secondary Projectiles")
## Secondary projectile to be instantiated once the main projectile runs out of pierce or runs out of lifetime
@export var on_expired_projectile: ProjectileBlueprint2D




func _init() -> void:
    proj_type = ProjectileConstants.ProjectileType.AREA

    texture = null
    size = 1.0
    lifetime = 1.0
    linear_speed = 1000

    radius = 50
    collision_layer = 0
    collision_mask = 0

    area_monitoreable = true
    collision_path = "Collision"
    on_hit_call = "damage"

    damage = 1
    pierce = 1

    look_at = true

    seeking = false
    seeking_mask = 0
    angular_spread = 0
    after_hit_angular_speed = 0
    cast_radius = 200

    lock_to_target = false
    allow_rehit = false
    rehit_cooldown = 0.1

    instances = 1
    proj_directionality = ProjectileConstants.ProjectileDirectionality.MODIFIABLE
    proj_spread = ProjectileConstants.ProjectileSpread.NONE
    angular_spread = 0
    vertical_spread = 0
    randomize_positions = false
    linear_deviation = 0



func _validate_property(property: Dictionary) -> void:
    if property.name in ["proj_spread", "angular_spread", "vertical_spread", "randomize_positions"] and instances < 2:
        property.usage = PROPERTY_USAGE_NO_EDITOR
    if property.name == "angular_spread" and proj_spread != ProjectileConstants.ProjectileSpread.ANGULAR:
        property.usage = PROPERTY_USAGE_NO_EDITOR
    if property.name in ["vertical_spread", "randomize_positions"] and proj_spread != ProjectileConstants.ProjectileSpread.ANGULAR and proj_spread != ProjectileConstants.ProjectileSpread.LINEAR:
        property.usage = PROPERTY_USAGE_NO_EDITOR
    if property.name in ["texture", "size", "radius", "collision_layer", "collision_mask"] and proj_type == ProjectileConstants.ProjectileType.INSTANTIATED:
        property.usage = PROPERTY_USAGE_NO_EDITOR
    if property.name == "area_monitoreable" and proj_type != ProjectileConstants.ProjectileType.AREA:
        property.usage = PROPERTY_USAGE_NO_EDITOR
    if property.name in ["instance", "collision_path"] and proj_type != ProjectileConstants.ProjectileType.INSTANTIATED:
        property.usage = PROPERTY_USAGE_NO_EDITOR
