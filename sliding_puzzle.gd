extends Node2D
class_name SlidingPuzzle


@export
var input_enabled: bool:
	set(value):
		input_enabled = value
		update_puzzle_pieces()

var puzzle_pieces: Array[PuzzlePiece]
var finished: bool = false


signal solved


func _ready() -> void:
	for puzzle_piece in get_children():
		if puzzle_piece is PuzzlePiece:
			puzzle_pieces.append(puzzle_piece)

	update_puzzle_pieces()


func _physics_process(delta: float) -> void:
	var is_solved: bool = true

	for puzzle_piece in puzzle_pieces:
		is_solved = is_solved && puzzle_piece.valid_position
	
	if is_solved and not finished:
		finished = true
		solved.emit()
		print ("solved")


func update_puzzle_pieces():			
	for puzzle_piece in puzzle_pieces:
		puzzle_piece.input_enabled = input_enabled
