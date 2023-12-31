extends "res://Player/DetermenisticLib.gd"



var WallData:Array = []
var WallDataCD:Array = []
var WallDataN:Array = []
var CDWallsNumber = 0
var ActiveWalls = 0
var IndexHelper = 0
var ActiveWallArray: Array = []
var CountedWallsCheck = 0


#ForwardVector
var FVector:Vector3 = Vector3()
var FVectorX:int = 0
var FVectorZ:int = 0
#ForwardVector

#Mouse
var RY:int= 0
var RX:int=0
var MouseSensivity:float = 0.5
var AimResult:Vector3 = Vector3(0,0,0)
#Mouse

#Physic
var WallNormal:Vector3 = Vector3.ZERO
var Colided:bool = false
var ColidedY:bool = false
var WallCount:int = 0
var CountedWalls:int = 0
var CountedWallsY:int = 0
var CalculatedMovement:Vector3 = Vector3(0,0,0)
var OnWall:bool = false
#Physic

#Accel
var CurrentSpeed:int = 0
var Acceleration:int = 1
var Deceleration:int = 1
var SlideFrction:int = 1
#Accel

#WallRun/WallJump/WallTurn
var CountedWallClasicalRayCast:int = 0
var FarToPlane:bool = false
#WallRun/WallJump/WallTurn

#Debug
var Velocity:Vector3 = Vector3.ZERO
var LastPosition:Vector3 = Vector3.ZERO
var VeloctiyCounter:int = 0
#Debug

#WallTrun
var CanTurn:bool = false
var TurnAroundLeftPressed:bool = false
var TurnRateLeft:int = 0
#WallTrun

#WallRun
var CanWallRun:bool = true
var WallRuning:bool = false
# WallRun

var SlideTimer:int = 10

const Bullet = preload("res://Wappons/BasicPistol/Projectile/Mesh/RubberBullet.tscn")

#Offline Thinks


func CalculateVelocity() -> void:
	if VeloctiyCounter == 1:
		Velocity = global_translation - LastPosition
		VeloctiyCounter = 0
	else:
		LastPosition = global_translation
		VeloctiyCounter += 1



func _physics_process(delta):
#	CalculateVelocity()
	RY = int(0)
	RX = int(0)
	if is_network_master():
		CalculateAimVector()


func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			RY = int(-event.relative.x * MouseSensivity)
			RX = int(event.relative.y * (MouseSensivity + 0.2))


func _ready():
#	var TestBullet = Bullet.instance()
#	add_child(TestBullet)
	yield(get_tree().create_timer(1), "timeout")
	StoreWallData()


func StoreWallData():
	global_translation *= 10
	scale *= 10
	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		WallCount += 1
		WallData.append(W.PWV1)
		WallData.append(W.PWV2)
		WallData.append(W.PWV3)
		WallData.append(W.PWV4)
		WallData.append(W.PWHV)

	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		WallDataCD.append(W.CZ2)
		WallDataCD.append(W.CZ3)
		WallDataCD.append(W.CZ4)


func CalculateAimVector():
	var AimVector = (-$Camera.global_transform.basis.z * 10)
	var TotalVector = abs(AimVector.x) + abs(AimVector.y) + abs(AimVector.z)
	var FormulaValue = (TotalVector / 100)
	var CalculatedAimX = (AimVector.x / FormulaValue)
	var CalculatedAimY = (AimVector.y / FormulaValue)
	var CalculatedAimZ = (AimVector.z / FormulaValue)
	CalculatedAimX = stepify(CalculatedAimX,1)
	CalculatedAimY = stepify(CalculatedAimY,1)
	CalculatedAimZ = stepify(CalculatedAimZ,1)
	AimResult = Vector3(CalculatedAimX,CalculatedAimY,CalculatedAimZ)





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
	input["RX"] = RX
	input["AimResult"] = AimResult
	if Input.is_action_just_pressed("Jump"):
		input["Jump"] = int(1)
	if Input.is_action_just_pressed("TurnAroundLeft"):
		input["TurnAroundLeft"] = true
	if Input.is_action_pressed("Slide"):
		input["Slide"] = true
	if Input.is_action_just_pressed("Shoot"):
		input["Shoot"] = true
	
	
	return input

func _network_process(input: Dictionary) -> void:
	CalculateForwardVector(input.get("RY",0),input.get("RX",0),input.get("F",false),input.get("B",false),input.get("L",false),input.get("R",false),input.get("Slide",false))
	CalculateWorthToRayCast()
	RayCasting((global_translation * 10) + Vector3(-FVector.x,0,-FVector.z),0)
	RayCastY((global_translation * 10) + Vector3(-FVector.x,0,-FVector.z),0)
	Shoot(input.get("AimResult",Vector3.ZERO),input.get("Shoot",false))
	Slide(input.get("Slide",false))
	WallRun()
	Jump(input.get("Jump",0))
	TrunMovement(input.get("TurnAroundLeft",false))
#	OneShotRayCast()
	MakeMovement()

func _save_state() -> Dictionary:
	return {
		global_transform = global_transform,
		CurrentSpeed = CurrentSpeed,
		ColidedY = ColidedY,
		TurnRateLeft = TurnRateLeft,
		FarToPlane = FarToPlane,
		TurnAroundLeftPressed = TurnAroundLeftPressed,
		FVector = FVector,
		CanWallRun = CanWallRun,
		SlideTimer = SlideTimer,
		SlideFrction = SlideFrction,
	}

func _load_state(state: Dictionary) -> void:
	global_transform = state['global_transform']
	CurrentSpeed = state['CurrentSpeed']
	ColidedY = state['ColidedY']
	TurnRateLeft = state['TurnRateLeft']
	FarToPlane = state['FarToPlane']
	TurnAroundLeftPressed = state['TurnAroundLeftPressed']
	FVector = state['FVector']
	CanWallRun = state['CanWallRun']
	SlideTimer = state['SlideTimer']
	SlideFrction = state['SlideFrction']
	
#Rollback





func CalculateForwardVector(Rotate,RX,F:bool,B:bool,L:bool,R:bool,Slide:bool) -> void:
	var RotationCalculated:int = 0
	var RoundedRotation:int = 0
# warning-ignore:narrowing_conversion
	RoundedRotation = round(rotation_degrees.y)
	rotate_y(deg2rad(int((Rotate * 2))))
	rotation_degrees.x += RX
	rotation_degrees.x = Clamp(rotation_degrees.x,-90,90)

	if ColidedY == true:
		if Slide == false:
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
		

			if F == true or L == true or R == true:
				if B == false:
					FVector.x = stepify(FVector.x, 10)
					FVector.z = stepify(FVector.z, 10)
					CurrentSpeed += Acceleration
					if CurrentSpeed >= 5:
						CurrentSpeed = 1

			if B == true:
				FVector.x = stepify(-FVector.x, 10)
				FVector.z = stepify(-FVector.z, 10)
				CurrentSpeed = 3
			
			if F == false and B == false and R == false and L == false:
				FVector.x = stepify(FVector.x, 10)
				FVector.z = stepify(FVector.z, 10)
				CurrentSpeed -= Deceleration
				if CurrentSpeed <= 0:
					CurrentSpeed = 0
					FVector.x = 0
					FVector.z = 0
		else:
			FVector.x = stepify(FVector.x, 10)
			FVector.z = stepify(FVector.z, 10)
			CurrentSpeed -= SlideFrction
			if CurrentSpeed <= 0:
				CurrentSpeed = 0
				FVector.x = 0
				FVector.z = 0
	else:
		if B == true:
			CurrentSpeed -= 1
			if CurrentSpeed <= 0:
					CurrentSpeed = 0
			FVector.x = stepify(FVector.x, 10)
			FVector.z = stepify(FVector.z, 10)


	FVector.x = Clamp(FVector.x,-90,90)
	FVector.z = Clamp(FVector.z,-90,90)
	
	if FVector.x > 90 or FVector.z > 90:
		print("Not Possibile Speed")


func RayCasting(RayStep:Vector3,StepSize:int) -> void: #Dynamic
	Colided = false
	CountedWalls = 0
	RayStep = RayStep + FVector
	for ActiveNumbers in ActiveWallArray:
		var IndexHelperPW = (ActiveNumbers * 5)
		var PWV1 = WallData[0 + IndexHelperPW]
		var PWV2 = WallData[1 + IndexHelperPW]
		var PWV3 = WallData[2 + IndexHelperPW]
		var PWV4 = WallData[3 + IndexHelperPW]
		var PWHV = WallData[4 + IndexHelperPW]
		CountedWalls += 1
		var RoundedStep = Vector3(stepify((RayStep.x),100), stepify((RayStep.y),100), stepify((RayStep.z),100))
		if not StepSize > 5:
			if (RoundedStep.x + 1000) >= PWV1.x and (RoundedStep.x - 1000) <= PWV2.x and (RoundedStep.z + 1000) >= PWV1.z and (RoundedStep.z - 1000) <= PWV3.z:
				if (RoundedStep.x + 1000) >= PWV1.x and (RoundedStep.x - 1000) <= PWV2.x:
					if (RoundedStep.z + 1000) == PWV1.z\
					and RoundedStep.y < PWHV.y and (RoundedStep.y + 2700) > PWV1.y:
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.z = CalculatedMovement.z - 20
						WallNormal = Vector3(0,0,-1)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break
						return


					if (RoundedStep.z -1000) == PWV4.z\
					and RoundedStep.y < PWHV.y and (RoundedStep.y + 2700) > PWV1.y:
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.z = CalculatedMovement.z + 20
						WallNormal = Vector3(0,0,1)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break
						return


				if (RoundedStep.z + 1000) >= PWV1.z and (RoundedStep.z - 1000) <= PWV3.z:
					if (RoundedStep.x + 1000) == PWV3.x\
					and RoundedStep.y < PWHV.y and (RoundedStep.y + 2700) > PWV1.y:
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.x = CalculatedMovement.x - 20
						WallNormal = Vector3(-1,0,0)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break
						return


					if (RoundedStep.x - 1000) == PWV4.x\
					and RoundedStep.y < PWHV.y and (RoundedStep.y + 2700) > PWV1.y:
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.x = CalculatedMovement.x + 20
						WallNormal = Vector3(1,0,0)
						Colided = true
						OnWall = true
						CountedWalls = 0
						break 
						return
						
			if CountedWalls == CountedWallsCheck:
				if Colided == false:
					OnWall = false
					CountedWalls = 0
					StepSize += 1
					RayCasting(RayStep,StepSize)


func RayCastY(RayStep:Vector3,StepSize:int) -> void:
	ColidedY = false
	CountedWallsY = 0
	RayStep = RayStep + FVector
	for ActiveNumbers in ActiveWallArray:
		var IndexHelperPW = (ActiveNumbers * 5)
		var PWV1 = WallData[0 + IndexHelperPW]
		var PWV2 = WallData[1 + IndexHelperPW]
		var PWV3 = WallData[2 + IndexHelperPW]
		var PWV4 = WallData[3 + IndexHelperPW]
		var PWHV = WallData[4 + IndexHelperPW]
		var RoundedStep = Vector3(stepify((RayStep.x),100), stepify((RayStep.y),100), stepify((RayStep.z),100))
		CountedWallsY += 1
		if not StepSize > 5:
			if (RoundedStep.y + 2700) == PWV1.y or RoundedStep.y == PWHV.y:
			# Clasical RayCast for finding Floor
				if (RoundedStep.x + 900) > PWV1.x and (RoundedStep.x - 900) < PWV2.x:
					if (RoundedStep.z + 900) > PWV1.z and (RoundedStep.z - 900)< PWV3.z:
						if (RoundedStep.y + 2700) == PWV1.y:
							FVector.y = 5
							WallNormal = Vector3(0,1,0)


							# Clasical RayCast for finding Celling
						if RoundedStep.y == PWHV.y:
							global_translation.y = ((PWHV.y / 10))
							ColidedY = true
							WallNormal = Vector3(0,-1,0)

			if CountedWallsY == CountedWallsCheck:
				if ColidedY == false:
					CountedWallsY = 0
					StepSize += 1
					RayCastY(RayStep,StepSize)


func Jump(Pressed:int) -> void:
	if not WallRuning:
		if ColidedY == false:
			FVector.y += -5
			if FVector.y <= -50:
				FVector.y = -50
		else:
			CanWallRun = true
			FVector.y = 0
			if Pressed > 0:
				FVector.y = 0
				FVector.y = 60
	else:
		if Pressed > 0:
			FVector += (WallNormal * 40)
			FVector.y = 50
			CanWallRun = false


func MakeMovement() -> void:
	if Colided == true:
			global_translation.x = CalculatedMovement.x
			global_translation.y += FVector.y
			global_translation.z = CalculatedMovement.z
	else:
		global_translation.x += (FVector.x / 10) * CurrentSpeed
		global_translation.y += FVector.y
		global_translation.z += (FVector.z / 10) * CurrentSpeed


func OneShotRayCast() -> void:
	CountedWallClasicalRayCast = 0
	var NearestWall
	FarToPlane = true
	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		CountedWallClasicalRayCast += 1
		var Wall = get_node(str("../Walls/Wall") + str(CountedWallClasicalRayCast))
		if (global_translation.x + 10) > Wall.V1.x and (global_translation.x + -10) < Wall.V2.x:
			if (global_translation.z + 10) > Wall.V1.z and (global_translation.z + -10)< Wall.V3.z:
				if not global_translation.y < Wall.V1.y:
					if (global_translation.y + -250) < Wall.HV.y:
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
				if (global_translation.y + -250) < NearestWall.HV.y:
					FarToPlane = false


func TrunMovement(Pressed:bool) -> void:
	if OnWall:
		if FVector.y > -10:
			if Pressed and FarToPlane:
				TurnAroundLeftPressed = true
				TurnRateLeft = 0

	if TurnAroundLeftPressed:
		TurnRateLeft += 60
		rotate_y(deg2rad(int(60)))
		CanWallRun = false
		FVector += (WallNormal * 50)
		CurrentSpeed = 10
		FVector.y += 20
		if TurnRateLeft == 180:
			TurnAroundLeftPressed = false
			CanWallRun = true


func WallRun() -> void:
	WallRuning = false
	var RoundedRotationWR = round(rotation_degrees.y)
	if OnWall and FarToPlane and CanWallRun:
		if WallNormal.x != 0:

			if WallNormal.x == 1:
				if RoundedRotationWR >= -50 and RoundedRotationWR <= 180 or RoundedRotationWR <= -130:
					if RoundedRotationWR >= -50 and RoundedRotationWR < 90:
						FVector = Vector3(-20,0,90)
						WallRuning = true

					if RoundedRotationWR >= 90 and RoundedRotationWR <= 180 or RoundedRotationWR <= -130:
						FVector = Vector3(-20,0,-90)
						WallRuning = true
			if WallNormal.x == -1:

				if RoundedRotationWR <= -0 or RoundedRotationWR <= 30 and RoundedRotationWR >= -180 or RoundedRotationWR >= 140:
					if RoundedRotationWR >= 140 or RoundedRotationWR >= -180 and RoundedRotationWR <= -90:
						FVector = Vector3(20,0,-90)
						WallRuning = true

					if RoundedRotationWR <= 40 and RoundedRotationWR > -90:
						FVector = Vector3(20,0,90)
						WallRuning = true

		if WallNormal.z != 0:
			if WallNormal.z == -1:
				if RoundedRotationWR >= 40:
					FVector = Vector3(90,0,20)
					WallRuning = true
				if RoundedRotationWR <= -40:
					FVector = Vector3(-90,0,20)
					WallRuning = true
			if WallNormal.z == 1:
				if RoundedRotationWR <= 140 and RoundedRotationWR >= -140:
					if RoundedRotationWR <= 140 and RoundedRotationWR >= 0:
						FVector = Vector3(90,0,-20)
						WallRuning = true
					if RoundedRotationWR >= -140 and RoundedRotationWR < 0:
						FVector = Vector3(-90,0,-20)
						WallRuning = true


func Slide(Pressed) -> void:
	if Pressed:
		if ColidedY == true:
			SlideTimer -= 1
			if SlideTimer <= 0:
				SlideTimer = 0

			if SlideTimer >= 50 and CurrentSpeed >= 4:
				CurrentSpeed = 7
				SlideFrction = 0
			else:
				SlideFrction = 1
		else:
			CurrentSpeed = 5
	else:
		if ColidedY == true:
			SlideTimer += 1
			SlideFrction = 1
			if SlideTimer >= 100:
				SlideTimer = 100


func Shoot(AimResult,input) -> void:
	if input == true:
		var SpwanPosition = $Camera.global_translation
		SyncManager.spawn("RubberBullet",get_parent(),Bullet,{GlobalTranslation = SpwanPosition,FVector = AimResult})


func CalculateWorthToRayCast() -> void:
	ActiveWallArray.clear()
	CountedWallsCheck = 0
	IndexHelper = 0
	for WallNumber in WallCount:
		var NFP = global_translation + FVector
		var CZ2 = WallDataCD[0 + IndexHelper]
		var CZ3 = WallDataCD[1 + IndexHelper]
		var CZ4 = WallDataCD[2 + IndexHelper]
		if NFP.x >= CZ3.x and NFP.x <= CZ4.x and NFP.z >= CZ2.z and NFP.z <= CZ4.z:
			ActiveWallArray.append(WallNumber)
			CountedWallsCheck += 1
		IndexHelper += 3




