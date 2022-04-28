# @author: Danny Boldt, Charlie Reiney
# Last edited: 4/28/22
# Othello.s - A simple version of the board game Othello using
# a 6x6 grid of 0's to represent empty spaces. 
# Player 1 game piece = 1, Player 2 game piece = 2
# Once only one player's game pieces remain on the board, they win. 

# --- General algorithm ---
#1. Ask for input
#2. Print starting board
#3. Decide turn based on counter
#	if even: player 1’s turn
#	if odd: player 2’s turn
#4. Update board based on overtake conditions
#5. Jump back to Print Board label 
# --------------------------------
	
	.data
array:	.word 0, 0, 0, 3, 4, 5, 6	# Here we initialize 32 elements of the array.
	.word 0, 0, 0, 0, 0, 0, 0	# To the machine, all arrays are 1-D --
	.word 0, 0, 0, 0, 0, 0, 0	# It's only how we use the array that makes
	.word 3, 0, 0, 1, 2, 0, 0	# it 2-D.
	.word 4, 0, 0, 2, 1, 0, 0
	.word 5, 0, 0, 0, 0, 0, 0	#took 1 and 2 out of axes to avoid interfering with the game, changed to 0
	.word 6, 0, 0, 0, 0, 0, 0

nl:	  .asciiz "\n"
space:    .asciiz " "
p1piece:  .word 1
p2piece:  .word 2
gsprompt: .asciiz "Press 0 to start the game: "
row_P1:   .asciiz "Player one, what row do you want to place your piece in?: "
column_P1:.asciiz "Player one, what column do you want to place your piece in?: "
row_P2:   .asciiz "Player two, what row do you want to place your piece in?: "
column_P2:.asciiz "Player two, what column do you want to place your piece in?: "
invalid:  .asciiz "Invalid Input! That spot is either taken or not on the board!"
endgame: .asciiz "Game over"

# ------Register Allocation----------
# $s0 = base address of the array
# $s1 = number of rows
# $s2 = number of columns
# $s3 = row number
# $s4 = col number
# $s5 = offset
# $s6 = total address
# $s7 = number obtained from the array

# $t1 = Row of P1's current guess
# $t2 = Column P1's current guess
# $t3 = Row of P2's current guess
# $t4 = Column of P2's current guess
# $t5 = Input integer to start game
# t6 = counter
# t7 = remainder from counter division
# t8 = total address of current guess
# t9 = number obtained from selected spot; for checking if empty

# Start of text segment
	.text
	li $t6, 0		# counter variable for p1/p2 turns
	li $t9, 0
Gamestart:
	# Print game start prompt
	li $v0, 4		# Print the prompt
	la $a0, gsprompt
	syscall

	li $v0, 5		# register input to start the game
	syscall
	move $t5, $v0
	
	bne $t5, 0, end_game	# Quit if input to gamestart is not 0

# Label to loop back to after each player turn.
print_board:
	
main:	
	
	la $s0, array		# set the base address
	li $s1, 7		# initialize number of rows and cols
	li $s2, 7

	li $s3, 0		# initialize row number to 0
outer:
	li $s4, 0		# initialize col number to 0
inner:
				# Compute offset in 3 instructions...
	mul $s5, $s3, $s2	# multiply i * num_cols
	add $s5, $s5, $s4	# add col number
	mul $s5, $s5, 4		# multiply by 4 (size of int)
	
	add $s6, $s0, $s5	# total = base + offset
	lw $s7, 0($s6)		# load value from array

	li  $v0, 1		# print this integer
	move $a0, $s7
	syscall
	
	li $v0, 4		# print newline
	la $a0, space
	syscall
	
	addi $s4, $s4, 1	# increment col number
	blt $s4, $s2, inner	# continue with next cell in this row

	li $v0, 4		# print newline
	la $a0, nl
	syscall
	
	addi $s3, $s3, 1	# increment row number
	blt, $s3, $s1, outer	# continue with next row

# use counter to branch to correct player turn
dec_turn:
	rem  $t7, $t6, 2
	bnez $t7, turn_p2 
	
turn_p1:
	li $v0, 4		# Print player 1 prompt
	la $a0, row_P1
	syscall
	
	lw $t0, p1piece		# t0 -> p1 game piece
	
	li $v0, 5		# store player 1's row guess in t1
	syscall
	move $t1, $v0 
	
	# Check for valid input
	blt $t1, 1, invalid_input
	bgt $t1, 6, invalid_input
	
	li $v0, 4		# Print the prompt
	la $a0, column_P1
	syscall
	
	li $v0, 5		# store player 1's column guess in t2
	syscall
	move $t2, $v0
	
	# Check for valid input
	blt $t2, 1, invalid_input
	bgt $t2, 6, invalid_input
	
	j edit_board
	
turn_p2:	
	li $v0, 4		# Print player 2 prompt
	la $a0, row_P2
	syscall
	
	lw $t0, p2piece		# t0 -> p2 game piece
	
	li $v0, 5		# store player 2's guess in t1
	syscall
	move $t1, $v0 
	
	# Check for valid input
	blt $t1, 1, invalid_input
	bgt $t1, 6, invalid_input
	
	li $v0, 4		# Print the prompt
	la $a0, column_P2
	syscall
	
	li $v0, 5		# store player 2's guess in t2
	syscall
	move $t2, $v0
	
	# Check for valid input
	blt $t2, 1, invalid_input
	bgt $t2, 6, invalid_input
	
edit_board:
	# Check to see if spot is empty
	mul $t1, $t1, 28
	mul $t2, $t2, 4
	add $t8, $t1, $t2
	add $s0, $s0, $t8
	
	lw $t9, 0($s0)
	bnez $t9, invalid_input
	sw $t0, 0($s0)
	
	# If empty, set chosen spot to value in t1
	addi $t6, $t6, 1
	
# 8 conditions to check for over-taking a piece, focus
# on up, down, left, right to begin with, then implement cross.
# Check directions originating from 0($s0). s3/s4 are availabe since they update to 0 every turn. Also t1/

#reuse $s1 for int in location three spaces away
update_take_over:

#below:
	lw $s3, 28($s0)
	lw $s4, 56($s0)
	lw $s1, 84($s0)

	# branch if no change needed to spaces -> below.
	bne $t0, $s1, below_check2
	bne $s3, $s4, below_check2
	
	sw $t0, 28($s0)
	sw $t0, 56($s0)
	j above
below_check2:
	beq $s3, $t0, above
	bne $s4, $t0, above
	sw $t0, 28($s0) 

above:	
	lw $s3, -28($s0)
	lw $s4, -56($s0)
	lw $s1, -84($s0)
	
	# branch if no change needed to spaces-> above.
	bne $t0, $s1, above_check2
	bne $s3, $s4, above_check2
	
	sw $t0, -28($s0)
	sw $t0, -56($s0)
	j left
above_check2:
	beq $s3, $t0, left
	bne $s4, $t0, left
	sw $t0, -28($s0)
	
left:	
	lw $s3, -4($s0)
	lw $s4, -8($s0)
	lw $s1, -12($s0)
	
	# branch if no change needed to spaces -> left.
	bne $t0, $s1, left_check2
	bne $s3, $s4, left_check2
	
	sw $t0, -4($s0)
	sw $t0, -8($s0)
	j right
left_check2:
	beq $s3, $t0, right
	bne $s4, $t0, right
	sw $t0, -4($s0)
	
right:	
	lw $s3, 4($s0)
	lw $s4, 8($s0)
	lw $s1, 12($s0)
	
	# branch if no change needed to spaces -> right.
	bne $t0, $s1, right_check2
	bne $s3, $s4, right_check2
	
	sw $t0, 4($s0)
	sw $t0, 8($s0)
	j up_left
right_check2:
	beq $s3, $t0, up_left
	bne $s4, $t0, up_left
	sw $t0, 4($s0)
	
up_left:	
	lw $s3, -32($s0)
	lw $s4, -64($s0)
	lw $s1, -96($s0)
	
	# branch if no change needed to spaces-> above left.
	bne $t0, $s1, up_check2
	bne $s3, $s4, up_check2
	
	sw $t0, -32($s0)
	sw $t0, -64($s0)
	j up_right
up_check2:
	beq $s3, $t0, up_right
	bne $s4, $t0, up_right
	sw $t0, -32($s0)
	
up_right:	
	lw $s3, -24($s0)
	lw $s4, -48($s0)
	lw $s1, -72($s0)
	
	# branch if no change needed to spaces -> above right.
	bne $t0, $s1, up_right_check2
	bne $s3, $s4, up_right_check2
	
	sw $t0, -24($s0)
	sw $t0, -48($s0)
	j down_left
up_right_check2:
	beq $s3, $t0, down_left
	bne $s4, $t0, down_left
	sw  $t0, -24($s0)
	
down_left:	
	# (24 and 48).
	lw $s3, 24($s0)
	lw $s4, 48($s0)
	lw $s1, 72($s0)
	
	# branch if no change needed to spaces -> down left.
	bne $t0, $s1, down_left_check2
	bne $s3, $s4, down_left_check2
	
	sw $t0, 24($s0)
	sw $t0, 48($s0)
	j down_right
down_left_check2:
	beq $s3, $t0, down_right
	bne $s4, $t0, down_right
	sw $t0, 24($s0)
	
down_right:	
	
	lw $s3, 32($s0)
	lw $s4, 64($s0)
	lw $s1, 96($s0)
	
	# branch if no change needed to spaces -> down right.
	bne $t0, $s1, down_right_check2
	bne $s3, $s4, down_right_check2
	
	sw $t0, 32($s0)
	sw $t0, 64($s0)
	j after_update
down_right_check2:
	beq $s3, $t0, after_update
	bne $s4, $t0, after_update
	sw $t0, 32($s0)
	
after_update:
	
	j print_board
	
invalid_input:
	li $v0, 4		# Print invalid input if necessary
	la $a0, invalid
	syscall
	
	li $v0, 4		# print newline
	la $a0, nl
	syscall
	
	j dec_turn
	
end_game:
	li $v0, 4		# Print player 2 prompt
	la $a0, endgame
	syscall
	
	li $v0, 10		# end of program
	syscall
	
	
