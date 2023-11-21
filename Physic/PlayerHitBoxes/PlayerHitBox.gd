tool
extends Spatial

export var PlayerBaseVelocityExport:int = 10
var PlayerBaseVelocity:int = 0
export var EXHeight :int = 2
export var EXDepth :int = 2
export var EXWidth :int = 2

var Height :int = 0
var Depth :int = 0
var Width :int = 0


var V1 :Vector3 = Vector3(1,1,1)
var V2 :Vector3 = Vector3(1,1,1)
var V3 :Vector3 = Vector3(1,1,1)
var V4 :Vector3 = Vector3(1,1,1)
var HV :Vector3 = Vector3(0,0,1)



var PWV1 :Vector3 = Vector3.ZERO
var PWV2 :Vector3 = Vector3.ZERO
var PWV3 :Vector3 = Vector3.ZERO
var PWV4 :Vector3 = Vector3.ZERO
var PWHV :Vector3 = Vector3.ZERO


var CZ1:Vector3 = Vector3.ZERO
var CZ2:Vector3 = Vector3.ZERO
var CZ3:Vector3 = Vector3.ZERO
var CZ4:Vector3 = Vector3.ZERO


var ParalelScaleLocal = 1



func _ready():
	ParalelScaleLocal = 1
	PlayerBaseVelocity = (PlayerBaseVelocityExport * ParalelScaleLocal)
	Depth = (EXDepth * ParalelScaleLocal)
	Height = (EXHeight * ParalelScaleLocal)
	Width = (EXWidth * ParalelScaleLocal)
	V1 = global_translation
	V2 = global_translation + Vector3(Width,0,0)
	V3 = global_translation + Vector3(0,0,Depth)
	V4 = global_translation + Vector3(Width,0,Depth)
	HV = global_translation + Vector3(0,Height,0)



	$V1.global_translation = V1
	$V2.global_translation = V2
	$V3.global_translation = V3
	$V4.global_translation = V4

	PWV1 = global_translation * 10
	PWV2 = (global_translation * 10) + (Vector3(Width,0,0) * 10)
	PWV3 = (global_translation * 10) + (Vector3(0,0,Depth) * 10)
	PWV4 = (global_translation * 10) + (Vector3(Width,0,Depth) * 10)
	PWHV = (global_translation * 10) + (Vector3(0,Height,0) * 10)
	$CSGPolygon.polygon = PoolVector2Array([Vector2(0, 0), Vector2(Depth,0), Vector2(Depth,Height), Vector2(0,Height)])
	$CSGPolygon.depth = Width
	ChekingArea()


#func _physics_process(delta):
#	Depth = (EXDepth * ParalelScaleLocal)
#	Height = (EXHeight * ParalelScaleLocal)
#	Width = (EXWidth * ParalelScaleLocal)
#	V1 = global_translation
#	V2 = global_translation + Vector3(Width,0,0)
#	V3 = global_translation + Vector3(0,0,Depth)
#	V4 = global_translation + Vector3(Width,0,Depth)
#	HV = global_translation + Vector3(0,Height,0)
#
#
#
#	$V1.global_translation = V1
#	$V2.global_translation = V2
#	$V3.global_translation = V3
#	$V4.global_translation = V4
#
#	PWV1 = global_translation * 10
#	PWV2 = (global_translation * 10) + (Vector3(Width,0,0) * 10)
#	PWV3 = (global_translation * 10) + (Vector3(0,0,Depth) * 10)
#	PWV4 = (global_translation * 10) + (Vector3(Width,0,Depth) * 10)
#	PWHV = (global_translation * 10) + (Vector3(0,Height,0) * 10)
#	$CSGPolygon.polygon = PoolVector2Array([Vector2(0, 0), Vector2(Depth,0), Vector2(Depth,Height), Vector2(0,Height)])
#	$CSGPolygon.depth = Width
#	ChekingArea()


func ChekingArea():
	CZ1 = global_translation
	CZ2 = global_translation + (Vector3(Width,0,0) + Vector3(PlayerBaseVelocity,0,0))
	CZ3 = global_translation + (Vector3(0,0,Depth) + Vector3(0,0,PlayerBaseVelocity))
	CZ4 = global_translation + (Vector3(Width,0,Depth) + Vector3(PlayerBaseVelocity,0,PlayerBaseVelocity))
	
	CZ1.x = CZ1.x + -PlayerBaseVelocity / 2
	CZ1.z = CZ1.z + -PlayerBaseVelocity / 2
	
	CZ2.x = CZ2.x + -PlayerBaseVelocity / 2 
	CZ2.z = CZ2.z + -PlayerBaseVelocity / 2
	
	CZ3.x = CZ3.x + -PlayerBaseVelocity / 2
	CZ3.z = CZ3.z + -PlayerBaseVelocity / 2
	
	CZ4.x = CZ4.x + -PlayerBaseVelocity / 2
	CZ4.z = CZ4.z + -PlayerBaseVelocity / 2

#	CZH = global_translation + Vector3(0,Height,0)
	$CheckingZone/CZ1.global_translation = CZ1
	$CheckingZone/CZ2.global_translation = CZ2
	$CheckingZone/CZ3.global_translation = CZ3
	$CheckingZone/CZ4.global_translation = CZ4


func CheckWorthToProjectileCalculation(NFP) -> bool: # NFP stands for Next Frame Position
	if NFP.x >= CZ3.x and NFP.x <= CZ4.x and NFP.z >= CZ2.z and NFP.z <= CZ4.z:
		return true
	else:
		return false



#func CheckWorthToRayCastProjectile(NFP) -> bool: # NFP stands for Next Frame Position
#	if NFP.x >= CZ3.x and NFP.x <= CZ4.x and NFP.z >= CZ2.z and NFP.z <= CZ4.z:
#		return true
#	else:
#		return false


