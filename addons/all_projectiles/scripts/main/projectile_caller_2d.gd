## A node able to request the creation of projectiles to the main processor.
## Can hold multiple projectile blueprints.

@icon("res://addons/all_projectiles/icons/projectile_caller_2d.svg")

class_name ProjectileCaller2D
extends Node2D


@export var projectile_resources: Array[ProjectileBlueprint2D]

var projectile_processor: ProjectileProcessor2D




func request_projectile(index: int, _position: Vector2, destination: Vector2, target: Node2D = null, 
	move_method: Callable = Callable(), start_method: Callable = Callable(), collision_method: Callable = Callable(),
	expired_method: Callable = Callable()) -> bool:
	
	if !validate_request(index):
		return false
	projectile_processor.add_projectiles_resource(projectile_resources[index], _position, destination, target, 
	move_method, start_method, collision_method, expired_method)
	return true
 


 
func validate_request(index: int) -> bool:
	return validate_proj_processor() && validate_proj_resource(index)


func validate_proj_resource(index: int) -> bool:

	if !(index < projectile_resources.size()):
		printerr("Projectile_Caller doesn't have any assigned Projectile_Resorce or call is invalid")
		return false

	if (projectile_resources[index] == null):
		printerr("Projectile_Caller doesn't have an assigned Projectile_Resorce at index %d or is invalid" %index)
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
	
	printerr("Projectile_Caller cannot find a valid Projectile_Processor")
	return false



func _enter_tree() -> void:
	add_to_group(ProjectileConstants.PROJ_CALLER_GROUP_NAME)

func _exit_tree() -> void:
	remove_from_group(ProjectileConstants.PROJ_CALLER_GROUP_NAME)
