##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
.data
displayaddress: .word 0x10008000

# . . .
.text
# . . .

lw $t0, displayaddress  # $t0 = base address for display
li $t4, 0xffffff        # $t4 = white
li $t8, 0x161616        # $t8 = grey1
li $t9, 0x010101        # $t9 = grey2
li $s1, 0               # $s1 = 0 iff we don't want checkers
# Bottom
addi $a0, $zero, 5      # set x coordinate
addi $a1, $zero, 27      # set y coordinate
addi $a2, $zero, 12      # set length of line
addi $a3, $zero, 1      # set height of line
jal draw_rectangle        # call the rectangle-drawing function

# Inside of grid:
li $s1, 1               # $s1 = 0 iff we don't want checkers
addi $a0, $zero, 6      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 11      # set length of line
addi $a3, $zero, 22      # set height of line
jal draw_rectangle        # call the rectangle-drawing function
li $s1, 0
# Left line
addi $a0, $zero, 5      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line to 8
addi $a3, $zero, 22      # set height of line
jal draw_rectangle        # call the rectangle-drawing function

# Right
addi $a0, $zero, 16      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 22      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function

li $s0 4
# Choose tetromino
beq $s0 0 draw_o
beq $s0 1 draw_i
beq $s0 2 draw_s
beq $s0 3 draw_z
beq $s0 4 draw_l
beq $s0 5 draw_j
beq $s0 6 draw_t

# Draw tetromino:
draw_o:
li $t4, 0xffff00        # $t4 = Yellow
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 2      # set length of line
addi $a3, $zero, 2      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend

draw_i:
li $t4, 0x00ffff        # $t4 = Teal
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 4      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend

draw_s:
li $t4, 0xff0000        # $t4 = red
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 2      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
addi $a0, $zero, 12      # set x coordinate
addi $a1, $zero, 6      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 2      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend

draw_z:
li $t4, 0x00ff00        # $t4 = green
addi $a0, $zero, 12      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 2      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 6      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 2      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend

draw_l:
li $t4, 0xff4000        # $t4 = orange
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 3      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 7      # set y coordinate
addi $a2, $zero, 2      # set length of line
addi $a3, $zero, 1      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend

draw_j:
li $t4, 0xff00ff        # $t4 = pink
addi $a0, $zero, 12      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 3      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 7      # set y coordinate
addi $a2, $zero, 2      # set length of line
addi $a3, $zero, 1      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend

draw_t:
li $t4, 0x9100FF        # $t4 = purple
addi $a0, $zero, 10      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 3      # set length of line
addi $a3, $zero, 1      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
addi $a0, $zero, 11      # set x coordinate
addi $a1, $zero, 5      # set y coordinate
addi $a2, $zero, 1      # set length of line
addi $a3, $zero, 2      # set height of line 
jal draw_rectangle        # call the rectangle-drawing function
j functionend



# The code for drawing a horizontal line
# - $a0: the x coordinate of the starting point for this line.
# - $a1: the y coordinate of the starting point for this line.
# - $a2: the length of this line, measured in pixels
# - $a3: the height of this line, measured in pixels
# - $t0: the address of the first pixel (top left) in the bitmap
# - $t1: the horizontal offset of the first pixel in the line.
# - $t2: the vertical offset of the first pixel in the line.
# - #t3: the location in bitmap memory of the current pixel to draw 
# - $t4: the colour value to draw on the bitmap
# - $t5: the bitmap location for the end of the horizontal line.
# - $t7: stores whether the coordinate is odd or even
draw_rectangle:
sll $t2, $a1, 7         # convert vertical offset to pixels (by multiplying $a1 by 128)
sll $t6, $a3, 7         # convert height of rectangle from pixels to rows of bytes (by multiplying $a3 by 128)
add $t6, $t2, $t6       # calculate value of $t2 for the last line in the rectangle.
addi $t7, $zero, 0
outer_top:
sll $t1, $a0, 2         # convert horizontal offset to pixels (by multiplying $a0 by 4)
sll $t5, $a2, 2         # convert length of line from pixels to bytes (by multiplying $a2 by 4)
add $t5, $t1, $t5       # calculate value of $t1 for end of the horizontal line.

inner_top:
add $t3, $t1, $t2           # store the total offset of the starting pixel (relative to $t0)
add $t3, $t0, $t3           # calculate the location of the starting pixel ($t0 + offset)
bgtz $s1, checkers
notcheckers:
sw $t4, 0($t3)              # paint the current unit on the first row yellow
j colorsetcomplete
checkers:
sw $t8, 0($t3)              # paint the current unit on the first row yellow

beq $t7, $zero, caseblue
casered:
sw $t8, 0($t3)
addi $t7 $zero 0
j endcases
caseblue:
sw $t9, 0($t3)
addi $t7 $zero 1
endcases:
j colorsetcomplete
colorsetcomplete:
addi $t1, $t1, 4            # move horizontal offset to the right by one pixel
beq $t1, $t5, inner_end     # break out of the line-drawing loop
j inner_top                 # jump to the start of the inner loop
inner_end:
addi $t2, $t2, 128          # move vertical offset down by one line
beq $t2, $t6, outer_end     # on last line, break out of the outer loop
j outer_top                 # jump to the top of the outer loop
outer_end:

jr $ra                      # return to calling program

functionend: