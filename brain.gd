extends CharacterBody2D
class_name Brain


@onready
var animatedSprite = $AnimatedSprite2D

@onready
var collision_shape: CollisionShape2D = $CollisionShape2D

@onready
var ray_cast: RayCast2D = $RayCast2D

@export
var movement_enabled: bool = false

@export
var fall_terminal_velocity: int = 1000

var direction = 1

var random = RandomNumberGenerator.new()


func _ready():
	animatedSprite.play("default")


func _physics_process(delta):
	if not movement_enabled:
		return

	collision_shape.shape.size = Vector2(32, 16)

	if is_on_floor():
		#if not ray_cast.is_colliding():
		#	direction *= -1

		velocity.x = 20 * direction
		velocity.y = 0
	else:
		velocity.y = 400

	if velocity.y > fall_terminal_velocity:
		velocity.y = fall_terminal_velocity

	if move_and_slide():
		pass

	if is_on_wall():
		handle_collisions()

	if position.y > 1000:
		position.y = 1000
		process_mode = Node.PROCESS_MODE_DISABLED
		hide()


func handle_collisions():
	for index in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(index)
		var _collider = collision.get_collider()
		if collision.get_collider() is Player:
			collision_shape.shape.size = Vector2(64, 16)
		else:
			direction *= -1
