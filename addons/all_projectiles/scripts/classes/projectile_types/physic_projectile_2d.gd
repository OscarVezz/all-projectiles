class_name PhysicProjectile2D
extends Projectile2D


var graphics: Texture2D;    

var radius: int;           
var collision_layer: int
var collision_mask: int

var shape: RID
var body: RID
var _transform: Transform2D 



func _init(_resource: ProjectileBlueprint2D, _pi: PackedInfo) -> void:
    super(_resource, _pi)


    # Quizas mover esto a una super class de "Phisic stuff"
    graphics = _resource.texture;

    radius = _resource.radius;
    collision_layer = _resource.collision_layer;
    collision_mask = _resource.collision_mask;

    shape = PhysicsServer2D.circle_shape_create()
    PhysicsServer2D.shape_set_data(shape, radius) 
    # Hasta aqui


    body = PhysicsServer2D.body_create()
    PhysicsServer2D.body_add_shape(body, shape)
    PhysicsServer2D.body_set_collision_layer(body, collision_layer)
    PhysicsServer2D.body_set_collision_mask(body, collision_mask)

    # Parametrizar
    # Añadir parametros para el tipo de body
    PhysicsServer2D.body_set_max_contacts_reported(body, 1)

    PhysicsServer2D.body_set_space(body, _pi.world_2d)

    transform = Transform2D(0.0, position)
    PhysicsServer2D.body_set_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform)



func move(_delta: float) -> void:
    transform = PhysicsServer2D.body_get_state(body, PhysicsServer2D.BODY_STATE_TRANSFORM)
    
    # Collision code
    # Posiblemente a remplazar con un area que siga constantemente al body
    var state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(body)
    print(state.get_contact_count())



func disable() -> void:
    PhysicsServer2D.free_rid(body)
    PhysicsServer2D.free_rid(shape)
    super()





func get_transform_2D() -> Transform2D:
    return _transform

func set_transform_2D(t: Transform2D) -> void:
    _transform = t
    #PhysicsServer2D.area_set_transform(area, t)