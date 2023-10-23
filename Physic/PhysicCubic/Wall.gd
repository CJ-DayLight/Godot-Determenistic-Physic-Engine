tool
extends Spatial


export var Height :int = 2
export var Depth :int = 2
export var Width :int = 2


var V1 :Vector3 = Vector3(1,1,1)
var V2 :Vector3 = Vector3(1,1,1)
var V3 :Vector3 = Vector3(1,1,1)
var V4 :Vector3 = Vector3(1,1,1)



var PWV1 :Vector3 = Vector3.ZERO
var PWV2 :Vector3 = Vector3.ZERO
var PWV3 :Vector3 = Vector3.ZERO
var PWV4 :Vector3 = Vector3.ZERO
var PWHV :Vector3 = Vector3.ZERO



#func _ready():
#	V1 = global_translation
#	V2 = global_translation + Vector3(Width,0,0)
#	V3 = global_translation + Vector3(0,0,Depth)
#	V4 = global_translation + Vector3(Width,0,Depth)
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


func _physics_process(delta):
	V1 = global_translation
	V2 = global_translation + Vector3(Width,0,0)
	V3 = global_translation + Vector3(0,0,Depth)
	V4 = global_translation + Vector3(Width,0,Depth)
	
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
