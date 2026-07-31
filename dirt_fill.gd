extends Area2D

@onready
var sprite: AnimatedSprite2D = $AnimatedSprite2D

var cleared: bool = false


func _on_body_entered(body: Node2D) -> void:
	if body is Quetzalcoatl and not cleared:
		sprite.play()
		cleared = true
		CsoundServer.get_csound("Main").event_string('i "synth" 0 0.1 0 %d 90' % (64))
