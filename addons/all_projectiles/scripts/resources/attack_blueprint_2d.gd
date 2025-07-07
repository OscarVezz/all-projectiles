## Utility resource for projectile instancing.
## Holds all the weapon use information.

@tool
@icon("res://addons/all_projectiles/icons/attack_resource_2d.svg")

class_name AttackBlueprint
extends  Resource

@export_category("Main Attributes")
## Time between the attack being initiated and it having an effect (in seconds)
@export var attack_anticipate_time: float
## Time between weapon attacks (in seconds)
@export var attack_duration_time: float:
	set(value):
		if (value < 0.001):
			attack_duration_time = 0.001
		else:
			attack_duration_time = value
## Time between the end of an attack an the start of another action (in seconds)
@export var attack_recovery_time: float


@export_category("Spawn Properties")
@export_group("Position")
## Added distance to projectile position on creation
@export var attack_offset: Vector2
## Overwrites the direction of its spawned projectiles if it is greater than zero.
@export var direction_override: Vector2
@export_group("")
@export_group("Charge")
## Time it takes to even start an attack (in seconds)
@export var attack_charge_time: float
## How the charging of the attack will be tracked
@export var charge_type: ProjectileConstants.WeaponChargeType
## How the charging of the attack will end
@export var charge_trigger: ProjectileConstants.WeaponChargeTrigger
@export_group("")


@export_category("Attack Attributes")
@export_group("Attack Requirements")
## Grid of all actions that can be skipped into this attack 
@export_flags_2d_physics var on_change_transition_actions: int
## Grid of all actions that can transition into this attack 
@export_flags_2d_physics var on_update_transition_actions: int
@export_group("")

@export_group("Attack Authorizations")
## Grid of all allow secondary actions while charging an attack
@export_flags_2d_physics var charging_actions: int
## Grid of all allow secondary actions while winding up an attack
@export_flags_2d_physics var anticipate_actions: int
## Grid of all allow secondary actions while performing an attack
@export_flags_2d_physics var execute_actions: int
## Grid of all allow secondary actions while recovering from an attack
@export_flags_2d_physics var recovery_actions: int


@export_category("Complements")
@export_group("Custom Trails")
## Custom trail
@export var trail: PackedScene
## Custom blast
@export var blast: PackedScene
@export_group("")
@export_group("Charge Audio")
## Custom charge audio
@export var charge_audio: AudioStream
@export var charge_db: float
@export var charge_heastart: float
@export_group("")
@export_group("Release Audio")
## Custom release audio
@export var release_audio: AudioStream
@export var release_db: float
@export var release_heastart: float

@export_group("")


func _init() -> void:
	attack_anticipate_time = 0
	attack_duration_time = 0.1
	attack_recovery_time = 0

	attack_charge_time = 0
	charge_type = ProjectileConstants.WeaponChargeType.CONTINOUS
	charge_trigger = ProjectileConstants.WeaponChargeTrigger.ON_RELEASE
