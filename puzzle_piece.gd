@tool
extends AnimatableBody2D
class_name PuzzlePiece

@export
var number: int

@export
var texture: Texture2D

@export
var input_enabled: bool:
	set(value):
		input_enabled = value
		self.input_pickable = value
	get():
		return input_enabled

@onready
var top_ray: RayCast2D = $TopRayCast2D

@onready
var bottom_ray: RayCast2D = $BottomRayCast2D

@onready
var left_ray: RayCast2D = $LeftRayCast2D

@onready
var right_ray: RayCast2D = $RightRayCast2D

@onready
var label: Label = $Label

@onready
var sprite: Sprite2D = $Sprite2D

var valid_position: bool = false


func _ready() -> void:
	label.text = str(number)
	if texture:
		sprite.texture = texture


func _physics_process(delta: float) -> void:
	update_valid_position()


func check_collisions():
	if not top_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x, position.y - 128)
		tween.tween_property(self, "position", end, 0.1)

	elif not bottom_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x, position.y + 128)
		tween.tween_property(self, "position", end, 0.1)

	elif not left_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x - 128, position.y)
		tween.tween_property(self, "position", end, 0.1)

	elif not right_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x + 128, position.y)
		tween.tween_property(self, "position", end, 0.1)


func update_valid_position():
	var index = 1 + (3 * int(position.y) / 128) + int(position.x) / 128
	valid_position = index == number


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			check_collisions()
