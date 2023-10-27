extends Node

#var MaxSpeed = 5


#var TurnAroundLeftPressed = false
#var TurnRateLeft = 0
#var CanTurn = false
#var MovementNotLocked = true

#var FarToPlane:bool = false
#var CountedWallClasicalRayCast = 0

#var WallRuning = false
#var CanWallRun = true
#var WallRunTimeStep = 0
#var WallBoost = Vector3.ZERO





#func _network_process(input: Dictionary) -> void:
#	TrunMovement(input.get("TurnAroundLeft",false))
#	WallRun()
#	OneShotRayCast() # The Reson This Name it works PhysicFrames per second and it is lower than other raycast
#	WallRunCoolDown()
#	IsOnFloor()
#	Jump(input.get("Jump",0))


#func WallRunCoolDown():
#	if CanWallRun == false:
#		if WallRunTimeStep >= 10:
#			CanWallRun = true
#			WallRunTimeStep = 0
#		else:
#			WallRunTimeStep += 1
#			if ColidedY == false:
#				FVector = (WallNormal * 4) + WallBoost
#				FVector.y = -Fall



#func WallRun():
#	WallRuning = false
#	var RoundedRotationWR = round(rotation_degrees.y)
#	if OnWall and FarToPlane and CanWallRun:
#		if WallNormal.x != 0:
#
#			if WallNormal.x == 1:
#				if RoundedRotationWR >= -50 and RoundedRotationWR <= 180 or RoundedRotationWR <= -130:
#					if RoundedRotationWR >= -50 and RoundedRotationWR < 90:
#						FVector = Vector3(-2,0,5)
#						WallBoost = Vector3(0,0,5)
#						WallRuning = true
#
#					if RoundedRotationWR >= 90 and RoundedRotationWR <= 180 or RoundedRotationWR <= -130:
#						FVector = Vector3(-2,0,-5)
#						WallBoost = Vector3(0,0,-5)
#						WallRuning = true
#			if WallNormal.x == -1:
#
#				if RoundedRotationWR <= -0 or RoundedRotationWR <= 30 and RoundedRotationWR >= -180 or RoundedRotationWR >= 140:
#					if RoundedRotationWR >= 140 or RoundedRotationWR >= -180 and RoundedRotationWR <= -90:
#						FVector = Vector3(2,0,-5)
#						WallBoost = Vector3(0,0,-5)
#						WallRuning = true
#
#					if RoundedRotationWR <= 40 and RoundedRotationWR > -90:
#						FVector = Vector3(2,0,9)
#						WallBoost = Vector3(0,0,5)
#						WallRuning = true
#
#		if WallNormal.z != 0:
#			if WallNormal.z == -1:
#				if RoundedRotationWR >= 40:
#					FVector = Vector3(9,0,2)
#					WallBoost = Vector3(5,0,0)
#					WallRuning = true
#				if RoundedRotationWR <= -40:
#					FVector = Vector3(-9,0,2)
#					WallBoost = Vector3(-5,0,0)
#					WallRuning = true
#			if WallNormal.z == 1:
#				if RoundedRotationWR <= 140 and RoundedRotationWR >= -140:
#					if RoundedRotationWR <= 140 and RoundedRotationWR >= 0:
#						FVector = Vector3(9,0,-2)
#						WallBoost = Vector3(5,0,0)
#						WallRuning = true
#					if RoundedRotationWR >= -140 and RoundedRotationWR < 0:
#						FVector = Vector3(-9,0,-2)
#						WallBoost = Vector3(-5,0,0)
#						WallRuning = true

#func OneShotRayCast():
#	CountedWallClasicalRayCast = 0
#	var NearestWall
#	FarToPlane = true
#	for W in get_tree().get_nodes_in_group("StaticCollsions"):
#		CountedWallClasicalRayCast += 1
#		var Wall = get_node(str("../Wall") + str(CountedWallClasicalRayCast))
#		if (global_translation.x + 1) > Wall.V1.x and (global_translation.x + -1) < Wall.V2.x:
#			if (global_translation.z + 1) > Wall.V1.z and (global_translation.z + -1)< Wall.V3.z:
#				if not global_translation.y < Wall.V1.y:
#					if (global_translation.y + -5) < Wall.HV.y:
#						if Wall == null:
#							pass
#						else:
#							if NearestWall == null:
#								NearestWall = Wall
#							else:
#								if (global_translation.y - Wall.HV.y) < (global_translation.y - NearestWall.HV.y):
#									NearestWall = Wall
#
#		if CountedWallClasicalRayCast == WallCount:
#			if NearestWall != null:
#				if (global_translation.y + -5) < NearestWall.HV.y:
#					FarToPlane = false



#func TrunMovement(Pressed):
#	if OnWall:
#		if Fall < 2:
#			CanTurn = true
#	else:
#		CanTurn = false
#	if Pressed and CanTurn and FarToPlane and MovementNotLocked:
#		TurnAroundLeftPressed = true
#		TurnRateLeft = 0
#	if TurnAroundLeftPressed:
#		WallBoost = Vector3.ZERO
#		TurnRateLeft += 60
#		MovementNotLocked = false
#		rotate_y(deg2rad(int(60)))
#		CanWallRun = false
#		if TurnRateLeft == 180:
#			Fall = -5
#			MovementNotLocked = true
#			CanTurn = false
#			TurnAroundLeftPressed = false




#func Jump(Pressed):
#	if ColidedY == false:
#		Fall += 1
#		if Fall >= 5:
#			Fall = 5
#			if Pressed > 0:
#				if WallRuning == true:
#					FVector = (WallNormal * 9)
#					Fall = -7
#					CanWallRun = false
#	else:
#		Fall = 0
#		if Pressed > 0:
#			Fall = 0
#			Fall = -10



#func Sprint(Presed):
#	if Presed:
#		Speed = 5
#	else:
#		Speed = 1
