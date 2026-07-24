extends Node2D
class_name DigAndPuzzle


@onready
var sliding_puzzle: SlidingPuzzle = $SlidingPuzzle

@onready
var fossil_dig_grid: FossilDigGrid = $FossilDigGrid


func _on_fossil_dig_grid_dig_finished() -> void:
	sliding_puzzle.input_enabled = true
	fossil_dig_grid.queue_free()
