extends Spatial


var FVectorX :int = 0
var FVectorZ :int = 0
var FVector:Vector3 = Vector3()
var RotationCalculated:int = 0
var RoundedRotation:int = 0

var RY:int= 0
var MouseSensivity = 0.3

var WallNormal:Vector3 = Vector3.ZERO
var Colided:bool = false
var ColidedY:bool = false
var WallCount:int = 0
var CountedWalls:int = 0
var CountedWallsY:int = 0
var CalculatedMovement:Vector3 = Vector3(0,0,0)
var OnFollor = false
var OnWall = false
var CurrentWallY
var Fall:int = int(0)



var FallVelocity:int = 0
var Jumping = false

var TurnAroundLeftPressed = false
var TurnRateLeft = 0
var CanTurn = false
var MovementNotLocked = true


var FarToPlane:bool = false
var CountedWallClasicalRayCast = 0

var NoMove = false

var Velocity = Vector3.ZERO
var LastPosition = Vector3.ZERO
var VeloctiyCounter = 0

var WallRuning = false
var CanWallRun = true
var WallRunTimeStep = 0
var WallBoost = Vector3.ZERO

#Offline Thinks
func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			RY = int(-event.relative.x * MouseSensivity)



func _ready():
	CountWalls()

func CountWalls():
	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		WallCount += 1


# Rollback
func _get_local_input() -> Dictionary:
	var input := {}
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")\
	or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		input["F"] = Input.is_action_pressed("ui_up")
		input["B"] = Input.is_action_pressed("ui_down")
		input["L"] = Input.is_action_pressed("ui_left")
		input["R"] = Input.is_action_pressed("ui_right")
	input["RY"] = RY
	if Input.is_action_just_pressed("Jump"):
		input["Jump"] = int(1)
	if Input.is_action_just_pressed("TurnAroundLeft"):
		input["TurnAroundLeft"] = true
	return input

func _network_process(input: Dictionary) -> void:
	TrunMovement(input.get("TurnAroundLeft",false))
	CalculateForwardVector(input.get("RY",0),input.get("F",false),input.get("B",false),input.get("L",false),input.get("R",false))
	WallRun()
	RayCasting((global_translation * 10) + Vector3(-FVector.x,0,-FVector.z),0)
	RayCastY((global_translation * 10) + Vector3(-FVector.x,0,-FVector.z),0)
	OneShotRayCast() # The Reson This Name it works PhysicFrames per second and it is lower than other raycast
	WallRunCoolDown()
#	IsOnFloor()
	Jump(input.get("Jump",0))
	MakeMovement()
	CalculateVelocity()

func _save_state() -> Dictionary:
	return {
		global_transform = global_transform,
	}

func _load_state(state: Dictionary) -> void:
	global_transform = state['global_transform']
#Rollback





func CalculateForwardVector(Rotate,F,B,L,R):
# warning-ignore:narrowing_conversion
	RoundedRotation = round(rotation_degrees.y)
	rotate_y(deg2rad(int((Rotate * 3))))
	if L == true and F == true:
			RoundedRotation += 45
			if RoundedRotation >= 180:
				var X = RoundedRotation + -180
				RoundedRotation = (180 - X) * -1
		
	if L == true and F == false and B == false:
			RoundedRotation += 90
			if RoundedRotation >= 180:
				var X = RoundedRotation + -180
				RoundedRotation = (180 - X) * -1

	if L == true and B == true:
			RoundedRotation += -45
			if RoundedRotation <= -180:
				var X = RoundedRotation + 180
				RoundedRotation = (180 + X)

	if R == true and F == true:
			RoundedRotation += -45
			if RoundedRotation <= -180:
				var X = RoundedRotation + 180
				RoundedRotation = (180 + X)

	if R == true and F == false and B == false:
			RoundedRotation += -90
			if RoundedRotation <= -180:
				var X = RoundedRotation + 180
				RoundedRotation = (180 + X)

	if R == true and B == true:
		RoundedRotation += 45
		if RoundedRotation >= 180:
			var X = RoundedRotation + -180
			RoundedRotation = (180 - X) * -1



	if RoundedRotation <= 90 and RoundedRotation >= 0:
		FVectorZ = -RoundedRotation
		FVectorX = 90 - RoundedRotation

	if RoundedRotation > 90:
		RoundedRotation = RoundedRotation
		RotationCalculated = RoundedRotation - 90 
		FVectorX = -RotationCalculated
		FVectorZ = 90 - RotationCalculated
		FVectorZ = -FVectorZ
	
	if RoundedRotation < 0 and RoundedRotation > -90:
		RotationCalculated = RoundedRotation * -1
		FVectorZ = RotationCalculated
		FVectorX = 90 - RotationCalculated

	if RoundedRotation <=-90:
		RotationCalculated = RoundedRotation + 90
		FVectorZ = 90 + RotationCalculated
		FVectorX = RotationCalculated * -1
		FVectorX = -FVectorX


	FVector.x = -FVectorZ
	FVector.z = FVectorX
	if FVector.x > 90 or FVector.z > 90:
		print("Not Possibile Speed")
	

	if F == true or L == true or R == true:
		if B == false:
			FVector = Vector3(stepify(FVector.x, 10),(-Fall * 10),stepify(FVector.z, 10)) / 10

	if B == true:
		FVector = Vector3(stepify(-FVector.x, 10),(-Fall * 10),stepify(-FVector.z, 10)) / 10
	
	if F == false and B == false and R == false and L == false:
		FVector = Vector3(0,-Fall,0)


func Jump(Pressed):
	if ColidedY == false:
		Fall += 1
		if Fall >= 5:
			Fall = 5
			if Pressed > 0:
				if WallRuning == true:
					FVector = (WallNormal * 9)
					Fall = -7
					CanWallRun = false
	else:
		Fall = 0
		if Pressed > 0:
			Fall = 0
			Fall = -10



func RayCasting(RayStep,StepSize):
	CountedWalls = 0
	Colided = false
	RayStep = RayStep + FVector
	var RoundedStep = Vector3(stepify((RayStep.x),10), stepify((RayStep.y),10), stepify((RayStep.z),10))
	if not StepSize > 10:
		for W in get_tree().get_nodes_in_group("StaticCollsions"):
			CountedWalls += 1
			var Wall = get_node(str("../Wall") + str(CountedWalls))


			if (RoundedStep.x + 100) >= Wall.PWV1.x and (RoundedStep.x - 100) <= Wall.PWV2.x:
				if (RoundedStep.z + 100) == Wall.PWV1.z:
					if RoundedStep.y < Wall.PWHV.y and (RoundedStep.y + 270) > Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.z = CalculatedMovement.z - 2
						WallNormal = Vector3(0,0,-1)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break
						return


				if (RoundedStep.z -100) == Wall.PWV4.z:
					if RoundedStep.y < Wall.PWHV.y and (RoundedStep.y + 270) > Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.z = CalculatedMovement.z + 2
						WallNormal = Vector3(0,0,1)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break
						return


			if (RoundedStep.z + 100) >= Wall.PWV1.z and (RoundedStep.z - 100) <= Wall.PWV3.z:
				if (RoundedStep.x + 100) == Wall.PWV3.x:
					if RoundedStep.y < Wall.PWHV.y and (RoundedStep.y + 270) > Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.x = CalculatedMovement.x - 2
						WallNormal = Vector3(-1,0,0)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break
						return


				if (RoundedStep.x - 100) == Wall.PWV4.x:
					if RoundedStep.y < Wall.PWHV.y and (RoundedStep.y + 270) > Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.x = CalculatedMovement.x + 2
						WallNormal = Vector3(1,0,0)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break 
						return


			if CountedWalls == WallCount:
				if Colided == false:
					OnWall = false
					CountedWalls = 0
					StepSize += 1
					RayCasting(RayStep,StepSize)


func RayCastY(RayStep,StepSize):
	CountedWallsY = 0
	ColidedY = false
	RayStep = RayStep + FVector
	var RoundedStep = Vector3(stepify((RayStep.x),10), stepify((RayStep.y),10), stepify((RayStep.z),10))
	if not StepSize > 10:
		for W in get_tree().get_nodes_in_group("StaticCollsions"):
			CountedWallsY += 1
			var Wall = get_node(str("../Wall") + str(CountedWallsY))
			# Clasical RayCast for finding Floor
			if (RoundedStep.x + 90) > Wall.PWV1.x and (RoundedStep.x - 90) < Wall.PWV2.x:
				if (RoundedStep.z + 90) > Wall.PWV1.z and (RoundedStep.z - 90)< Wall.PWV3.z:
					if (RoundedStep.y + 270) == Wall.PWV1.y:
						Fall = 5
						WallNormal = Vector3(0,1,0)


					# Clasical RayCast for finding Celling
					if RoundedStep.y == Wall.PWHV.y:
						global_translation.y = ((Wall.PWHV.y / 10) + clamp(Fall,0,5))
						ColidedY = true
						WallNormal = Vector3(0,-1,0)

			if CountedWallsY == WallCount:
				if ColidedY == false:
					CountedWallsY = 0
					StepSize += 1
					RayCastY(RayStep,StepSize)


func MakeMovement():
	if Colided == true:
		if OnFollor:
			global_translation = Vector3(CalculatedMovement.x,global_translation.y,CalculatedMovement.z)
		else:
			global_translation.x = CalculatedMovement.x
			global_translation.y += FVector.y
			global_translation.z = CalculatedMovement.z
	else:
		global_translation += FVector


func TrunMovement(Pressed):
	if OnWall:
		if Fall < 2:
			CanTurn = true
	else:
		CanTurn = false
	if Pressed and CanTurn and FarToPlane and MovementNotLocked:
		TurnAroundLeftPressed = true
		TurnRateLeft = 0
	if TurnAroundLeftPressed:
		WallBoost = Vector3.ZERO
		TurnRateLeft += 60
		MovementNotLocked = false
		rotate_y(deg2rad(int(60)))
		CanWallRun = false
		if TurnRateLeft == 180:
			Fall = -5
			MovementNotLocked = true
			CanTurn = false
			TurnAroundLeftPressed = false

func WallRun():
	WallRuning = false
	var RoundedRotationWR = round(rotation_degrees.y)
	if OnWall and FarToPlane and CanWallRun:
		if WallNormal.x != 0:
			
			if WallNormal.x == 1:
				if RoundedRotationWR >= -50 and RoundedRotationWR <= 180 or RoundedRotationWR <= -130:
					if RoundedRotationWR >= -50 and RoundedRotationWR < 90:
						FVector = Vector3(-2,0,5)
						WallBoost = Vector3(0,0,5)
						WallRuning = true
					
					if RoundedRotationWR >= 90 and RoundedRotationWR <= 180 or RoundedRotationWR <= -130:
						FVector = Vector3(-2,0,-5)
						WallBoost = Vector3(0,0,-5)
						WallRuning = true
			if WallNormal.x == -1:
				
				if RoundedRotationWR <= -0 or RoundedRotationWR <= 30 and RoundedRotationWR >= -180 or RoundedRotationWR >= 140:
					if RoundedRotationWR >= 140 or RoundedRotationWR >= -180 and RoundedRotationWR <= -90:
						FVector = Vector3(2,0,-5)
						WallBoost = Vector3(0,0,-5)
						WallRuning = true
					
					if RoundedRotationWR <= 40 and RoundedRotationWR > -90:
						FVector = Vector3(2,0,9)
						WallBoost = Vector3(0,0,5)
						WallRuning = true

		if WallNormal.z != 0:
			if WallNormal.z == -1:
				if RoundedRotationWR >= 40:
					FVector = Vector3(9,0,2)
					WallBoost = Vector3(5,0,0)
					WallRuning = true
				if RoundedRotationWR <= -40:
					FVector = Vector3(-9,0,2)
					WallBoost = Vector3(-5,0,0)
					WallRuning = true
			if WallNormal.z == 1:
				if RoundedRotationWR <= 140 and RoundedRotationWR >= -140:
					if RoundedRotationWR <= 140 and RoundedRotationWR >= 0:
						FVector = Vector3(9,0,-2)
						WallBoost = Vector3(5,0,0)
						WallRuning = true
					if RoundedRotationWR >= -140 and RoundedRotationWR < 0:
						FVector = Vector3(-9,0,-2)
						WallBoost = Vector3(-5,0,0)
						WallRuning = true

func OneShotRayCast():
	CountedWallClasicalRayCast = 0
	var NearestWall
	FarToPlane = true
	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		CountedWallClasicalRayCast += 1
		var Wall = get_node(str("../Wall") + str(CountedWallClasicalRayCast))
		if (global_translation.x + 1) > Wall.V1.x and (global_translation.x + -1) < Wall.V2.x:
			if (global_translation.z + 1) > Wall.V1.z and (global_translation.z + -1)< Wall.V3.z:
				if not global_translation.y < Wall.V1.y:
					if (global_translation.y + -5) < Wall.HV.y:
						if Wall == null:
							pass
						else:
							if NearestWall == null:
								NearestWall = Wall
							else:
								if (global_translation.y - Wall.HV.y) < (global_translation.y - NearestWall.HV.y):
									NearestWall = Wall

		if CountedWallClasicalRayCast == WallCount:
			if NearestWall != null:
				if (global_translation.y + -5) < NearestWall.HV.y:
					FarToPlane = false


func CalculateVelocity():
	if ColidedY == true:
		if VeloctiyCounter == 1:
			Velocity = global_translation - LastPosition
			VeloctiyCounter = 0
		else:
			LastPosition = global_translation
			VeloctiyCounter += 1


func WallRunCoolDown():
	if CanWallRun == false:
		if WallRunTimeStep >= 10:
			CanWallRun = true
			WallRunTimeStep = 0
		else:
			WallRunTimeStep += 1
			if ColidedY == false:
				FVector = (WallNormal * 4) + WallBoost
				FVector.y = -Fall
	




