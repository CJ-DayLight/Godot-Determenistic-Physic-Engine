extends Spatial


var FVectorX :int = 0
var FVectorZ :int = 0
var FVector :Vector3 = Vector3()
var RotationCalculated :int = 0
var RoundedRotation:int = 0



var Colided = false
var WallCount = 0
var CountedWalls = 0
var CalculatedMovement = Vector3(0,0,0)

func _ready():
	CountWalls()

func CountWalls():
	yield(get_tree().create_timer(1),"timeout")
	for Wall in get_tree().get_nodes_in_group("StaticCollsions"):
		print(Wall.name)
		WallCount += 1
		




#func _physics_process(delta):
#	CalculateForwardVector(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"))
#	RayCasting((global_translation * 10) + -FVector,0)
#	MakeMovement()

func CalculateForwardVector(Rotate):
	RoundedRotation = round(rotation_degrees.y)
	rotate_y(deg2rad(int((Rotate * 3))))
#	if Input.is_action_pressed("ui_right"):
#		rotate_y(deg2rad(int(-2)))


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
	FVector = Vector3(stepify(FVector.x, 10),0,stepify(FVector.z, 10)) / 10


func RayCasting(RayStep,StepSize):
	CountedWalls = 0
	Colided = false
	RayStep = RayStep + FVector
	var RoundedStep = Vector3(stepify((RayStep.x),10), stepify((RayStep.y),10), stepify((RayStep.z),10))
	if not StepSize >= 10:
		for Wall in get_tree().get_nodes_in_group("StaticCollsions"):
			CountedWalls += 1
			if RoundedStep.x >= Wall.PWV1.x and RoundedStep.x <= Wall.PWV2.x:
				
				if RoundedStep.z == Wall.PWV1.z:
					if RoundedStep.y <= Wall.PWHV.y and RoundedStep.y >= Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.z = CalculatedMovement.z - 2
						Colided = true
						CountedWalls = 0
						break
					
				if RoundedStep.z == Wall.PWV4.z:
					if RoundedStep.y <= Wall.PWHV.y and RoundedStep.y >= Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.z = CalculatedMovement.z + 2
						Colided = true
						CountedWalls = 0
						break

			if RoundedStep.z >= Wall.PWV1.z and RoundedStep.z <= Wall.PWV3.z:
				if RoundedStep.y <= Wall.PWHV.y and RoundedStep.y >= Wall.PWV1.y:
					if RoundedStep.x == Wall.PWV3.x:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.x = CalculatedMovement.x - 2
						Colided = true
						CountedWalls = 0
						break

				if RoundedStep.x == Wall.PWV4.x:
					if RoundedStep.y <= Wall.PWHV.y and RoundedStep.y >= Wall.PWV1.y:
						$"../RoundedStep".global_translation = (RoundedStep / 10)
						CalculatedMovement = (RoundedStep / 10)
						CalculatedMovement.x = CalculatedMovement.x + 2
						Colided = true
						CountedWalls = 0
						break

			if CountedWalls == WallCount:
				if Colided == false:
					CountedWalls = 0
					StepSize += 1
					RayCasting(RayStep,StepSize)


func MakeMovement():
	if Input.is_action_pressed("ui_up"):
		if Colided == false:
			global_translation += FVector
		else:
			global_translation = CalculatedMovement
