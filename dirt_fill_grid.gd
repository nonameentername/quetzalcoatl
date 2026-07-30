extends Node2D

@onready
var quetzalcoatl: Quetzalcoatl = $Quetzalcoatl

signal finished


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Quetzalcoatl:
		body.movement_enabled = false
		finished.emit()
