extends Node2D
class_name FossilDigGrid


var blocks_cleared: int = 0


signal dig_finished


func _ready() -> void:
	pass


func _on_fossil_dig_piece_cleared() -> void:
	blocks_cleared += 1

	if blocks_cleared == 9:
		dig_finished.emit()
