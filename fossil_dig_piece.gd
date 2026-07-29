extends StaticBody2D
class_name FossilDigPiece


@onready
var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready
var effect: CPUParticles2D = $CPUParticles2D

var current_level: int = 1

signal cleared
signal clearing


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dig()


func dig() -> void:
	if current_level < 7:
		effect.emitting = false
		effect.emitting = true
		clearing.emit()
		current_level += 1
		animated_sprite.play(str(current_level))

		if current_level == 7:
			cleared.emit()
