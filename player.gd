extends KinematicBody

export var runSpeed = 10.0
export var maxAccelSpeed = 75.0

export var gravityAcceleration = 10.0

export var jumpSpeed = 5.0

export var groundFriction = 10.0

var wishDir = Vector3(0, 0, 0)
var velocity = Vector3(0, 0, 0)

var cameraLimit = 1.56

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var rotation = global_transform.basis.get_euler()
	
	var inputValue = Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
		0,
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	).normalized()
	wishDir.x = cos(rotation.y) * -inputValue.x - sin(rotation.y) * inputValue.z
	wishDir.z = sin(rotation.y) * inputValue.x - cos(rotation.y) * inputValue.z
	
	velocity = accelerate(wishDir, delta)
	
	velocity.y -= gravityAcceleration * delta
	if is_on_floor():
		velocity.y = 0
		if Input.get_action_strength("jump") > 0:
			velocity.y = jumpSpeed
		else:
			velocity = friction(delta)
	#print(sqrt(velocity.x * velocity.x + velocity.z + velocity.z))
	move_and_slide(velocity, Vector3(0, 1, 0))

func _input(event):
	if event is InputEventMouseMotion:
		var xRot = event.relative.y * -0.01
		var currentXRot = $Camera.global_transform.basis.get_euler().x
		if abs(currentXRot + xRot) > cameraLimit:
			$Camera.rotate_x(sign(xRot) * cameraLimit - currentXRot)
		else:
			$Camera.rotate_x(xRot)
		rotate_y(event.relative.x * -0.01)

func accelerate(wishDir, delta):
	var currentSpeed = velocity.dot(wishDir)
	var addSpeed = runSpeed - currentSpeed
	addSpeed = max(min(addSpeed, maxAccelSpeed * delta), 0)
	var newVelocity = velocity + wishDir * addSpeed
	newVelocity.y = velocity.y
	return newVelocity

func friction(delta):
	var speed = self.velocity.length()
	if speed == 0:
		return self.velocity
	var drop = speed * groundFriction * delta
	var newSpeed = speed - drop
	newSpeed /= speed
	return self.velocity * max(newSpeed, 0)
