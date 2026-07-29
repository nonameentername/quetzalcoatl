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

@onready
var line: Line2D = $Line2D

var valid_position: bool = false


signal moved (number: int)


func _ready() -> void:
	label.text = str(number)
	if texture:
		sprite.texture = texture


func _physics_process(delta: float) -> void:
	update_valid_position()


func try_move():
	pulse_glow()

	if not top_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x, position.y - 128)
		tween.tween_property(self, "position", end, 0.1)
		pulse_line()
		moved.emit(number)

	elif not bottom_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x, position.y + 128)
		tween.tween_property(self, "position", end, 0.1)
		pulse_line()
		moved.emit(number)

	elif not left_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x - 128, position.y)
		tween.tween_property(self, "position", end, 0.1)
		pulse_line()
		moved.emit(number)

	elif not right_ray.is_colliding():
		var tween = get_tree().create_tween()
		var end = Vector2(position.x + 128, position.y)
		tween.tween_property(self, "position", end, 0.1)
		pulse_line()
		moved.emit(number)


func update_valid_position():
	var index = 1 + (3 * int(position.y) / 128) + int(position.x) / 128
	valid_position = index == number


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass
	#if event is InputEventMouseButton:
	#	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
	#		try_move()


func pulse_glow():
	var tween = get_tree().create_tween()
	var target_color = Color.WHITE * 3.0
	
	tween.tween_property(self, "modulate", target_color, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func pulse_line():
	var target_color = Color.WHITE * 3.0

	var tween = get_tree().create_tween()
	tween.tween_property(line, "modulate", target_color, 0.2)
	tween.parallel().tween_property(line, "scale", Vector2(10, 10), 0.2)

	tween.tween_property(line, "modulate", Color.TRANSPARENT, 0.0)
	tween.parallel().tween_property(line, "scale", Vector2(1, 1), 0.1)
