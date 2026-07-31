extends StaticBody2D
class_name QuetzalcoatlBody

@export
var direction: Vector2

@onready
var sprite: Sprite2D = $Body


func _ready() -> void:
	direction = Vector2.LEFT


func _physics_process(delta):
	sprite.rotation = direction.angle()
