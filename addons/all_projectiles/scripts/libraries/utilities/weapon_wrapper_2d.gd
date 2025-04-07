## A node able to request the creation of projectiles to the main processor.
## Can hold a single projectile blueprint.
## Mainly used as an intermediary between a constant requested signal.

@tool
@icon("res://addons/all_projectiles/icons/weapon_wrapper_2d.svg")

class_name WeaponWrapper2D
extends Node2D


@export_category("Main Attributes")
@export var projectile_resource: ProjectileBlueprint2D: set = validate_resource

func validate_resource(value: ProjectileBlueprint2D) -> void:
	if (value.proj_type == ProjectileConstants.ProjectileType.AREA):
		if (value.texture == null):
			printerr("Invalid Projectile_Resource (Area Projectile2D lacks mandatory \"Texture\" component)")
			projectile_resource = null
			return
	elif (value.proj_type == ProjectileConstants.ProjectileType.INSTANTIATED):
		if (value.instance == null):
			printerr("Invalid Projectile_Resource (Instantiated Projectile2D lacks mandatory \"Instance\" component)")
			projectile_resource = null
			return

	projectile_resource = value


## Time between weapon attacks (in seconds)
@export var attack_speed: float

@export_group("Position")
## Added distance to projectile position on creation
@export var attack_offset: Vector2
## If true the wrapper will ignore the projectile requested position and will be instantiated on the wrapper position itself
@export var override_position: bool
@export_group("")



var projectile_processor: ProjectileProcessor2D

var _previous_time: int
var _current_time: int
var _delta_time: float
var _paused_time: float




func request_projectile(_position: Vector2, destination: Vector2, target: Node2D = null, 
	move_method: Callable = Callable(), start_method: Callable = Callable(), 
	collision_method: Callable = Callable()) -> bool:
	
	if !validate_request():
		return false
	

	_current_time = Time.get_ticks_msec()
	_delta_time = (_current_time - _previous_time) / 1000.0
	if !(_delta_time > attack_speed + _paused_time):
		return false
	

	_previous_time = _current_time
	_paused_time = 0.0

	var start_pos: Vector2
	if (override_position):
		start_pos = global_position
	else:
		start_pos = _position + attack_offset
	projectile_processor.add_projectiles_resource(projectile_resource, start_pos, destination, target, move_method, start_method, collision_method)
	return true
 




func validate_request() -> bool:
	return validate_proj_processor() && validate_proj_resource()


func validate_proj_resource() -> bool:
	if (projectile_resource == null):
		printerr("Weapon_Wrapper doesn't have any assigned Projectile_Resorce or call is invalid")
		return false

	return true


func validate_proj_processor() -> bool:
	if (projectile_processor != null):
		return true

	# Try to find a valid ProjPross in the SceneTree singleton
	projectile_processor = get_tree().get_first_node_in_group(ProjectileConstants.PROJ_PROCESSOR_GROUP_NAME)
	if (projectile_processor != null):
		return true
	
	# Create a valid ProjPross in the current scene
	projectile_processor = ProjectileProcessor2D.new()
	projectile_processor.name = "ProjectileProcessor2D"
	get_tree().current_scene.add_child(projectile_processor)

	if (projectile_processor != null):
		return true
	
	printerr("Weapon_Wrapper cannot find a valid Projectile_Processor")
	return false



func _enter_tree() -> void:
	add_to_group(ProjectileConstants.PROJ_WRAPPER_GROUP_NAME)

func _exit_tree() -> void:
	remove_from_group(ProjectileConstants.PROJ_WRAPPER_GROUP_NAME)