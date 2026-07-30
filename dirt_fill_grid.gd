extends Node2D

@onready
var quetzalcoatl: Quetzalcoatl = $Quetzalcoatl

var enabled: bool = false

signal finished


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Quetzalcoatl and enabled:
		body.movement_enabled = false
		finished.emit()
