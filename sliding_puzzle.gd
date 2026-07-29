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
	var numbers: Array[int] = []
	for i in range(0, 9):
		numbers.append(i)

	#numbers.shuffle()

	while not is_solvable(numbers):
		numbers.shuffle()

	for puzzle_piece in get_children():
		if puzzle_piece is PuzzlePiece:
			puzzle_pieces.append(puzzle_piece)

	#for i in range(0, 8):
	#	puzzle_pieces[i].position = calculate_position(numbers, i + 1)

	update_puzzle_pieces()


func calculate_position(numbers: Array[int], index: int) -> Vector2:
	var new_location

	for location in range(0, numbers.size()):
		if index == numbers[location]:
			new_location = location

	var x = new_location % 3
	var y = new_location / 3

	return Vector2(128 * x, 128 * y)


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


func is_solvable(puzzle: Array[int]) -> bool:
	var inversions := 0

	for i in range(puzzle.size()):
		if puzzle[i] == 0: # Ignore blank
			continue

		for j in range(i + 1, puzzle.size()):
			if puzzle[j] != 0 and puzzle[i] > puzzle[j]:
				inversions += 1

	return inversions % 2 == 0
