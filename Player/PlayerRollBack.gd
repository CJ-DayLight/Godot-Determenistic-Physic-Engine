extends Spatial


var FVectorX :int = 0
var FVectorZ :int = 0
var FVector:Vector3 = Vector3()
var RotationCalculated:int = 0
var RoundedRotation:int = 0



var Colided:bool = false
var ColidedY:bool = false
var WallCount:int = 0
var CountedWalls:int = 0
var CountedWallsY:int = 0
var CalculatedMovement:Vector3 = Vector3(0,0,0)
var OnFollor = false
var OnWall = false

var Fall:int = int(0)
var FallVelocity:int = 0
var Jumping = false

var TurnAroundLeftPressed = false
var TurnRateLeft = 0
var CanTurn = false


func _ready():
	CountWalls()

func CountWalls():
	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		WallCount += 1



func _get_local_input() -> Dictionary:
	var input := {}
	if Input.is_action_pressed("ui_up"):
		input["F"] = int(1)
	input["RY"] = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	if Input.is_action_pressed("Jump"):
		input["Jump"] = int(1)
	if Input.is_action_just_pressed("TurnAroundLeft"):
		input["TurnAroundLeft"] = true
	return input

func _network_process(input: Dictionary) -> void:
	TrunMovement(input.get("TurnAroundLeft",false))
	CalculateForwardVector(input.get("RY",0),input.get("F",0))
	RayCasting((global_translation * 10) + Vector3(-FVector.x,0,-FVector.z),0)
	RayCastY((global_translation * 10) + Vector3(-FVector.x,0,-FVector.z),0)
#	IsOnFloor()
	Jump(input.get("Jump",0))
	MakeMovement()

func _save_state() -> Dictionary:
	return {
		global_transform = global_transform,
	}

func _load_state(state: Dictionary) -> void:
	global_transform = state['global_transform']






func CalculateForwardVector(Rotate,F):
# warning-ignore:narrowing_conversion
	RoundedRotation = round(rotation_degrees.y)
	rotate_y(deg2rad(int((Rotate * 3))))


	if RoundedRotation <= 90 and RoundedRotation >= 0:
		FVectorZ = -RoundedRotation
		FVectorX = 90 - RoundedRotation

	if RoundedRotation > 90:
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
	if F == 1:
		FVector = Vector3(stepify(FVector.x, 10),(-Fall * 10),stepify(FVector.z, 10)) / 10
	else:
		FVector = Vector3(0,-Fall,0)


func Jump(Pressed):
	if ColidedY == false:
		Fall += 1
		if Fall >= 5:
			Fall = 5
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
			if (RoundedStep.x + 90) > Wall.PWV1.x and (RoundedStep.x - 90) < Wall.PWV2.x:
				if (RoundedStep.z + 90) > Wall.PWV1.z and (RoundedStep.z - 90)< Wall.PWV3.z:
					if (RoundedStep.y + 270) == Wall.PWV1.y:
						Fall = 5

					if RoundedStep.y == Wall.PWHV.y:
						global_translation.y = ((Wall.PWHV.y / 10) + clamp(Fall,0,5))
						ColidedY = true

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
		CanTurn = true
	if Pressed and CanTurn:
		TurnAroundLeftPressed = true
		TurnRateLeft = 0
	if TurnAroundLeftPressed:
		TurnRateLeft += 60
		rotate_y(deg2rad(int(60)))
		if TurnRateLeft == 180:
			CanTurn = false
			TurnAroundLeftPressed = false
				
		
		
		
		
		
		
		
		
		
