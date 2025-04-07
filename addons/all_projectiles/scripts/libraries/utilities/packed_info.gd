class_name PackedInfo
extends RefCounted


## The position from which the projectiles are being called
var position: Vector2
## The direction to when the projectiles are being directed
var direction: Vector2
## The original destination the projectile was being headed
var destination: Vector2
## The target to where the projectiles are being home-in
var target: Node2D

# DEPRECATED
## The individual instance id for multiple projectile instances in one call
var instance_id: int

# Maybe just made it static
## The physic server world RID for non instanced projectiles
var world_2d: RID

# Custom projectile methods
var move_method: Callable
var start_method: Callable
var collision_method: Callable
var expired_method: Callable


func _init() -> void:
    position = Vector2.ZERO
    direction = Vector2.ZERO
    target = null

    instance_id = 1

    world_2d = RID()


func reassing(_position: Vector2, _direction: Vector2, _destination: Vector2, _target: Node2D, _instance_id: int, 
    _world_2d: RID, _move_method: Callable, _start_method: Callable, _collision_method: Callable,
    _expired_method: Callable) -> void:

    position = _position
    direction = _direction
    destination = _destination
    target = _target

    instance_id = _instance_id
    world_2d = _world_2d

    move_method = _move_method
    start_method = _start_method
    collision_method = _collision_method
    expired_method = _expired_method