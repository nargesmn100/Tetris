################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Narges Movahedian Nezhad, 1009080600
# Student 2: Nadim Mottu, 1008933095
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
ADDR_DSPL: .word 0x10008000 # The address of the bitmap display. Don't forget to connect it!
ADDR_KBRD: .word 0xffff0000 # The address of the keyboard. Don't forget to connect it!




##############################################################################
# Mutable Data
##############################################################################
# Game state values:
time: .word 0
game_state: .word 0
# Bitmap Constants:
display_width: .word 64
display_height: .word 64
unit_width: .word 2
unit_height: .word 2


# Grid Constants:
grid_x: .word 5
grid_y: .word 5
grid_width: .word 12
grid_height: .word 22
grid_address: .space 4096

# Collision Constants:
collision_mask: .byte '7':1024


# Color Constants:
c_white: .word 0xffffff
c_grey1: .word 0x161616
c_grey2: .word 0x010101
c_yellow: .word 0xffff00
c_teal: .word 0x00ffff
c_red: .word 0xff0000
c_green: .word 0x00ff00
c_orange: .word 0xff4000
c_pink: .word 0xff00ff
c_purple: .word 0x9100ff

# Tetromino Maps:
o_bit_map: .byte '0', '0', '0', '0', '0', '1', '1', '0', '0', '1', '1', '0', '0', '0', '0', '0'
i_bit_map: .byte '0', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1', '0'
s_bit_map: .byte '0', '0', '0', '0', '0', '1', '1', '0', '1', '1', '0', '0', '0', '0', '0', '0'
z_bit_map: .byte '0', '0', '0', '0', '0', '1', '1', '0', '0', '0', '1', '1', '0', '0', '0', '0'
l_bit_map: .byte '0', '0', '0', '0', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1', '1', '0'
j_bit_map: .byte '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '1', '0', '0', '1', '1', '0'
t_bit_map: .byte '0', '0', '0', '0', '0', '1', '1', '1', '0', '0', '1', '0', '0', '0', '0', '0'

pause_bit_map: .byte '0', '1', '0', '1', '0', '1', '0', '1', '0', '1', '0', '1', '0', '0', '0', '0'

sad_bit_map: .byte  '1', '0', '0', '1',
                    '0', '0', '0', '0',
                    '0', '1', '1', '0',
                    '1', '0', '0', '1'


# Player controls:
block_start_x: .word 8
block_start_y: .word 5
curr_block_x: .word 9
curr_block_y: .word 5
curr_block_type: .byte 4
curr_block_rotation: .byte 0
##############################################################################
# Code
##############################################################################
	.text
	.globl main
	

	# Run the Tetris game.
main:
    # Initialize the game
    la $t0, grid_address    # $t0 = base address for display.  Load base address for display into $t0
    lw $t4, c_white         # $t4 = white. Load white color into $t4
    lw $t8, c_white         # $t8 = white. Load white color into $t8  
    
    # Bottom
    lw $a0, grid_x              # Load x coordinate of grid
    lw $t1, grid_y              # Load y coordinate of grid into $t1
    lw $t2, grid_height         # Load grid height into $t2
    add $a1, $t1, $t2           # Calculate bottom y coordinate
    lw $a2, grid_width          # set length of line. Load grid width into $a2
    li $a3, 1                   # Set line height to 1 pixel
    jal draw_rectangle          # Call draw_rectangle to draw bottom of grid
    
    # Draw inside of grid:
    lw $t8, c_grey1         # Load grey1 color into $t8
    lw $t4, c_grey2         # Load grey2 color into $t4
    lw $a0, grid_x          # Load x coordinate of grid
    addi $a0, $a0, 1        # Adjust x coordinate
    lw $a1, grid_y          # Load y coordinate of grid
    lw $a2, grid_width      # Load grid width into $a2
    subi $a2, $a2, 1        # Adjust grid width
    lw $a3, grid_height     # Load grid height into $a3
    jal draw_rectangle      # Call draw_rectangle to draw inside of grid
    li $s1, 0               # Initialize $s1 to 0
    
    lw $t4, c_white          # Load white color into $t4
    lw $t8, c_white          # Load white color into $t8  
    
    # Draw left line of grid
    lw $a0, grid_x          # Load x coordinate of grid
    lw $a1, grid_y          # Load y coordinate of grid
    li $a2, 1               # Set line length to 1 pixel
    lw $a3, grid_height     # Load grid height into $a3
    jal draw_rectangle      # Call draw_rectangle to draw left line of grid
    
    # Draw right line of grid
    lw $a0, grid_x               # Load x coordinate of grid
    lw $t1, grid_width           # Load grid width into $t1
    add $a0, $a0, $t1            # Add grid width to x coordinate to get right edge
    subi $a0, $a0, 1             # Adjust x coordinate to draw the right line
    lw $a1, grid_y               # Load y coordinate of grid
    li $a2, 1                    # Set line length to 1 pixel
    lw $a3, grid_height          # Load grid height into $a3
    jal draw_rectangle           # Call draw_rectangle to draw right line of grid
    jal create_new_tetronimo     # Call function to make a new Tetronimo

game_loop:
	# 1a. Check if key has been pressed
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard. Load base address for keyboard into $t0
    lw $t8, 0($t0)                  # Load first word from keyboard
    bne $t8, 1, no_keyboard_input   # If first word 1, key is pressed
    # 1b. Check which key has been pressed
    jal respond_to_keyboard_input
    
    no_keyboard_input:
    lw $t3, game_state              # Load game state into $t3
    # Check game state
    beq $t3, 0 no_pause             # If game state is 0, skip pause state
    bne $t3, 1 game_over            # If game state is not 1, check for game over
    lw $t0 ADDR_DSPL                # Load address of bitmap display into $t0
	li $a0 7                        # Set block type
	li $a1 26                       # Set x coordinate
	li $a2 2                        # Set y coordinate
	li $a3 0                        # Set rotation
    jal draw_new_block              # Call function to draw new block
    j sleep                         # Jump to sleep state
    game_over:
    # Play Tetris theme music: Top of music sheet
    jal e_full
    jal b_half
    jal c_half
    jal d_full
    jal c_half
    jal b_half      # First 4 beats done
    jal a_full
    jal a_half
    jal c_half
    jal e_full
    jal d_half
    jal c_half      # Second 4 beats done
    jal b_one_and_half
    jal c_half
    jal d_full
    jal e_full      # Third 4 beats done 
    jal c_full
    jal a_full 
    jal a_full 
    jal pause_full      # Fourth 4 beats done
    jal pause_half
    jal d_full
    jal f_half
    jal e_full
    jal f_half
    jal f_half      # Fifth 4 beats done
    jal e_one_and_half
    jal c_half
    jal e_full
    jal d_half
    jal c_half      # Sixth 4 beats done
    jal b_one_and_half
    jal c_half
    jal d_full
    jal e_full      # Seventh 4 beats done
    jal c_full
    jal a_full
    jal a_full
    jal pause_full  # Eighth 4 beats done
    jal e_double
    jal c_double    # Ninth 4 beats done
    jal d_double 
    jal b_double    # Tenth 4 beats done
    jal c_double 
    jal a_double    # Eleventh 4 beats done 
    jal g_quadrup   # Twelveth 4 beats done
    lw $t0 ADDR_DSPL                # Load address of bitmap display into $t0
	li $a0 8                        # Set block type
	li $a1 26                       # Set x coordinate
	li $a2 2                        # Set y coordinate
	li $a3 0                        # Set rotation
    jal draw_new_block              # Call function to draw new block
    j sleep                         # Jump to sleep state
    no_pause:
    
    
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	lw $a0 ADDR_DSPL                   # Load address of bitmap display into $a0
	la $a1 grid_address                # Load address of grid into $a1
	jal draw_grid                      # Call function to draw grid
	jal draw_collision_box             # Call function to draw collision box
	
	# Draw Block
	lw $t0 ADDR_DSPL                        # Load address of bitmap display into $t0
	lb $a0 curr_block_type                  # Load current block type into $a0  
	lw $a1 curr_block_x                     # Load current block x coordinate into $a1
	lw $a2 curr_block_y                     # Load current block y coordinate into $a2
	lb $a3 curr_block_rotation              # Load current block rotation into $a3
	jal draw_new_block                      # Call function to draw new block
	lb $a0 curr_block_type                  # Load current block type into $a0
	
	jal check_rows_complete                # Call function to check for completed rows
	
	# Gravity:
	lw $t0 time                    # Load time into $t0
	addi $t0, $t0, 1               # Increment time
	sw $t0 time                    # Store updated time
	bne $t0, 16 sleep              # If time is not 16, go to sleep state
	li $t0 0                       # Reset time to 0
	sw $t0 time                    # Store reset time
	jal respond_to_S               # Call function to respond to 'S' key
	
	sleep:
	# 4. Sleep
    li $v0, 32           # Set syscall code for sleep
    li $a0, 17           # Set time to sleep (in milliseconds)
    syscall              # Perform syscall to sleep
    #5. Go back to 1
   
    j game_loop         # Jump back to the beginning of the game loop

j function_end

# Function to respond to keyboard input
    respond_to_keyboard_input:
    # - $t0: address of keyboard
    # - $t1: key_pressed
        lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
        lw $t1, 4($t0)                  # Load second word from keyboard
        
        beq $t1, 0x70, respond_to_p              # Check if 'p' key is pressed
        
        lw $t3, game_state                           # Load game state into $t3
        bne $t3, 0 end_respond_to_keyboard           # If game state is not 0, skip to end_respond_to_keyboard
        
        # Check which key is pressed
        beq $t1, 0x61, respond_to_A
        beq $t1, 0x77, respond_to_W
        beq $t1, 0x73, respond_to_S
        beq $t1, 0x64, respond_to_D
        j end_respond_to_keyboard               # Jump to end if no valid key pressed
        
        # Handle 'p' key press
        respond_to_p:
            lw $t2, game_state                                          # Load game state into $t2 
            # Check current game state and perform corresponding action
            beq $t2, 0, change_pause_state_to_paused                    # If game is not paused, change state to paused    
            beq $t2, 1, change_pause_state_to_unpause                   # If game is paused, change state to unpause
            beq $t2, 2, retry                                           # If game over, retry
            j end_respond_to_keyboard
            change_pause_state_to_paused:
            li $t2, 1                                # Set game state to paused
            sw $t2, game_state                       # Store updated game state
            j end_respond_to_keyboard
            change_pause_state_to_unpause:
            li $t2, 0                           # Set game state to unpause
            sw $t2, game_state                  # Store updated game state
            j end_respond_to_keyboard
            
            # Retry the game
            retry:
            li $t2, 0                               # Set game state to initial state
            sw $t2, game_state                      # Store updated game state
            addi $sp, $sp, -4                       # Adjust stack pointer
            sw $ra, 0($sp)                          # Save return address
            jal clear_collision                     # Call function to clear collisions
            lw $ra, 0($sp)                          # Restore return address
            addi $sp, $sp, 4                        # Restore stack pointer
            
            j end_respond_to_keyboard
            
        # Respond to 'A' key press (move left)
        respond_to_A:
            lw $t2, curr_block_x
            addi $t2, $t2, -1                           # Decrement x coordinate
            
            # Check for collision after moving left    
            addi $sp, $sp, -4                           # Adjust stack pointer
            sw $t2, 0($sp)                              # Save updated x coordinate
            addi $sp, $sp, -4                           
            sw $ra, 0($sp)                              # Save return address
            lb $a0, curr_block_type
            add $a1, $zero, $t2
            lw $a2, curr_block_y
            lb $a3, curr_block_rotation
            jal place_meeting_block                     # Check for collision
            addi $sp, $sp, -4   
            sw $v0, 0($sp)                              # Save collision result
            jal play_lr_sound_effect                    # Play left/right movement sound effect
            lw $v0, 0($sp)                              # Load collision result
            addi $sp, $sp, 4                            # Restore stack pointer
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            lw $t2, 0($sp)
            addi $sp, $sp, 4
            bne $v0, 0, end_respond_to_keyboard         # If collision, jump to end
            sw $t2, curr_block_x                         # Update x coordinate
            
            j end_respond_to_keyboard
        
        # Respond to 'W' key press (rotate)
        respond_to_W:
            lb $t2, curr_block_rotation
            addi $t2, $t2, 1
            bne $t2, 4, update_rotation
            li $t2, 0
            
            update_rotation:
            addi $sp, $sp, -4   
            sw $t2, 0($sp)
            addi $sp, $sp, -4   
            sw $ra, 0($sp) 
            lb $a0, curr_block_type
            lw $a1, curr_block_x
            lw $a2, curr_block_y
            add $a3, $t2, $zero
            jal place_meeting_block                     # Check for collision
            addi $sp, $sp, -4   
            sw $v0, 0($sp)                              # Save collision result
            jal play_clap_sound_effect                    # Play left/right movement sound effect
            lw $v0, 0($sp)                              # Load collision result
            addi $sp, $sp, 4                            # Restore stack pointer
            lw $ra, 0($sp)                              # Restore return address
            addi $sp, $sp, 4                            # Restore stack pointer
            lw $t2, 0($sp)
            addi $sp, $sp, 4
            bne $v0, 0, end_respond_to_keyboard         # If collision, jump to end
            
            sb $t2, curr_block_rotation                 # Update rotation
            j end_respond_to_keyboard
        
        # Respond to 'D' key press (move right)
        respond_to_D:
            lw $t2, curr_block_x
            addi $t2, $t2, 1
            
            # Check for collision after moving right
            addi $sp, $sp, -4   
            sw $t2, 0($sp)
            addi $sp, $sp, -4   
            sw $ra, 0($sp) 
            lb $a0, curr_block_type
            add $a1, $zero, $t2
            lw $a2, curr_block_y
            lb $a3, curr_block_rotation
            jal place_meeting_block
            addi $sp, $sp, -4   
            sw $v0, 0($sp)
            jal play_lr_sound_effect
            lw $v0, 0($sp)
            addi $sp, $sp, 4
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            lw $t2, 0($sp)
            addi $sp, $sp, 4
            
            
            bne $v0, 0, end_respond_to_keyboard                     # If collision, jump to end_respond_to_keyboard
            sw $t2, curr_block_x                                    # Update x coordinate
            j end_respond_to_keyboard                               # Jump to end
        
        # Respond to 'S' key press (move down)
        respond_to_S:
            lw $t2, curr_block_y
            addi $t2, $t2, 1
            
            addi $sp, $sp, -4   
            sw $t2, 0($sp)
            addi $sp, $sp, -4   
            sw $ra, 0($sp) 
            lb $a0, curr_block_type
            add $a2, $zero, $t2
            lw $a1, curr_block_x
            lb $a3, curr_block_rotation
            jal place_meeting_block
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            lw $t2, 0($sp)
            addi $sp, $sp, 4
            bne $v0, 0, collide_down
            sw $t2, curr_block_y
            j end_respond_to_keyboard
            collide_down:
            lb $a0 curr_block_type                              
	        lw $a1 curr_block_x
	        lw $a2 curr_block_y
	        lb $a3 curr_block_rotation
            addi $sp, $sp, -4                               # Adjust stack pointer
            sw $ra, 0($sp)       
    	    jal add_tetronimo_collider                      # Add tetromino collider
    	    jal create_new_tetronimo                        # Create new tetromino
            lw $ra, 0($sp)                                  # Restore return address
            addi $sp, $sp, 4                                # Restore stack pointer
            
            
    end_respond_to_keyboard:
    jr $ra
    
    
    draw_rectangle:
    # The code for drawing a rectangle
    # - $a0: the x coordinate of the starting point for this line.
    # - $a1: the y coordinate of the starting point for this line.
    # - $a2: the length of this line, measured in pixels
    # - $a3: the height of this line, measured in pixels
    # - $t0: the address of the first pixel (top left)
    # - $t1: the horizontal offset of the first pixel in the line.
    # - $t2: the vertical offset of the first pixel in the line.
    # - #t3: the location in bitmap memory of the current pixel to draw 
    # - $t4: the colour value to draw on the bitmap
    # - $t5: the bitmap location for the end of the horizontal line.
    # - $t7: stores whether the coordinate is odd or even
    # - $t8: colour value 2
    sll $t2, $a1, 7                         # Convert vertical offset to pixels (by multiplying $a1 by 128)
    sll $t6, $a3, 7                         # Convert height of rectangle from pixels to rows of bytes (by multiplying $a3 by 128)
    add $t6, $t2, $t6                       # Calculate value of $t2 for the last line in the rectangle.
    addi $t7, $zero, 0
        draw_rectangle_outer_top:
        sll $t1, $a0, 2                     # Convert horizontal offset to pixels (by multiplying $a0 by 4)
        sll $t5, $a2, 2                     # Convert length of line from pixels to bytes (by multiplying $a2 by 4)
        add $t5, $t1, $t5                   # Calculate value of $t1 for end of the horizontal line.
            draw_rectangle_inner_top:
            add $t3, $t1, $t2               # Store the total offset of the starting pixel (relative to $t0)
            add $t3, $t0, $t3               # Calculate the location of the starting pixel ($t0 + offset)
            beq $t7, $zero, caseblue
            casered:
            sw $t8, 0($t3)
            addi $t7 $zero 0
            j draw_rectangle_endcases
            caseblue:
            sw $t4, 0($t3)
            addi $t7 $zero 1
            draw_rectangle_endcases:
            j colorsetcomplete
            colorsetcomplete:
            addi $t1, $t1, 4                # Move horizontal offset to the right by one pixel
            beq $t1, $t5, draw_rectangle_inner_end     # Break out of the line-drawing loop
            j draw_rectangle_inner_top                 # Jump to the start of the inner loop
            draw_rectangle_inner_end:
        addi $t2, $t2, 128                  # Move vertical offset down by one line
        beq $t2, $t6, draw_rectangle_outer_end         # On last line, break out of the outer loop
        j draw_rectangle_outer_top                     # Jump to the top of the outer loop
        draw_rectangle_outer_end:
        jr $ra
    
    draw_grid:
    # - $a0 starting display address
    # - $a1 starting memory address
    # - $t0 current display address
    # - $t1 current address in memory
    # - $t2 current value in memory
    # - $t3 final location in memory
    
    add $t0, $zero, $a0
    add $t1, $zero, $a1
    addi $t3, $a1, 4096
        draw_grid_loop_top:
            lw $t2, 0($t1)
            sw $t2, 0($t0)
            beq $t1, $t3, draw_grid_end_loop
            addi $t0, $t0, 4
            addi $t1, $t1, 4
            j draw_grid_loop_top
        draw_grid_end_loop:
    jr $ra
    
    
    
    draw_new_block:
    # - $t0 display address
    # - $a0 code for the block that will be drawn
    # - $a1 x_coordinate
    # - $a2 y_coordinate
    # - $a3 rotation
    # - $t1 current position in block array
    # - $t2 color of tetromino
    # - $t3 current position in bitmap
    # - $t5 range from 1 to 16
    # - $t6 row complete change
    # - $t7 column complete change
        beq $a0 0 case_draw_o
        beq $a0 1 case_draw_i
        beq $a0 2 case_draw_s
        beq $a0 3 case_draw_z
        beq $a0 4 case_draw_l
        beq $a0 5 case_draw_j
        beq $a0 6 case_draw_t
        beq $a0 7 case_draw_pause
        beq $a0 8 case_draw_sad
        
        case_draw_o:
            la $t1 o_bit_map
            lw $t2 c_yellow
            j decide_rotation_case
        case_draw_i:
            la $t1 i_bit_map
            lw $t2 c_teal
            j decide_rotation_case
        case_draw_s:
            la $t1 s_bit_map
            lw $t2 c_red
            j decide_rotation_case 
        case_draw_z:
            la $t1 z_bit_map
            lw $t2 c_green
            j decide_rotation_case 
        case_draw_l:
            la $t1 l_bit_map
            lw $t2 c_orange
            j decide_rotation_case 
        case_draw_j:
            la $t1 j_bit_map
            lw $t2 c_pink
            j decide_rotation_case
        case_draw_t:
            la $t1 t_bit_map
            lw $t2 c_purple
            j decide_rotation_case 
        case_draw_pause:
            la $t1 pause_bit_map
            lw $t2 c_white
            j decide_rotation_case 
        case_draw_sad:
            la $t1 sad_bit_map
            lw $t2 c_white
            j decide_rotation_case 
            
            
        decide_rotation_case:
            beq $a3 0 case_rotation_0
            beq $a3 1 case_rotation_1
            beq $a3 2 case_rotation_2
            beq $a3 3 case_rotation_3
        case_rotation_0:
            li $t6 1
            li $t7 0
            j begin_drawing_block
        case_rotation_1:
            addi $t1, $t1, 3
            li $t6 4
            li $t7 -17
            j begin_drawing_block
        case_rotation_2:
            addi $t1, $t1, 15
            li $t6 -1
            li $t7 0
            j begin_drawing_block
        case_rotation_3:
            addi $t1, $t1, 12
            li $t6 -4
            li $t7 17
            j begin_drawing_block
        
        
        begin_drawing_block:
            lw $t0, ADDR_DSPL
            li $t5 0
            sll $t3, $a2, 7
            sll $t4, $a1, 2
            add $t3, $t4, $t3
            add $t3, $t0, $t3
            # t4 is free
            draw_block_outer_loop:
                draw_block_draw_row:
                lb $t4, 0($t1)
                li $t8, '0'
                beq $t4, $t8, draw_block_draw_row_update_vals
                sw $t2, 0($t3)
                draw_block_draw_row_update_vals:
                add $t1, $t1, $t6
                addi $t3, $t3, 4
                addi $t5, $t5 1
                
                # Check if $t5 is divisible by 4
                li $t8, 4
                div $t4, $t5, $t8
                mfhi $t4
                bne $t4, $zero draw_block_outer_loop
            addi $t3, $t3, 112
            add $t1, $t1, $t7
            li $t4, 16
            bne $t5, $t4, draw_block_outer_loop
        jr $ra
        
        
    place_meeting:
    # Check if there's a collision between the block and the grid boundaries
    # - $a0: x coordinate of the block
    # - $a1: y coordinate of the block
    # - $t0: minimum x coordinate of the grid
    # - $t1: maximum x coordinate of the grid
    # - $t2: maximum y coordinate of the grid
    lw $t0, grid_x                                      # Load minimum x coordinate of the grid
    addi $t0, $t0, 1                                    # Add 1 to adjust for display border
    lw $t1, grid_width                                  # Load maximum x coordinate of the grid
    add $t1, $t1, $t0                                   # Calculate maximum x coordinate
    lw $t2, grid_y                                      # Load y coordinate of the grid
    lw $t3, grid_height                                 # Load height of the grid
    add $t2, $t2, $t3                                   # Calculate maximum y coordinate
    
    sub $t0, $t0, $a0                                   # Calculate horizontal distance to left boundary
    sub $t1, $t1, $a0                                   # Calculate horizontal distance to right boundary
    sub $t2, $t2, $a1                                   # Calculate vertical distance to bottom boundary
    
    subi $t1, $t1, 2                                    # Adjust for block width
    
    blez $t0, place_meeting_condition1                  # If left boundary collision, jump to condition1
    li $v0 1                                            # Set collision flag to 1
    jr $ra                                              # Return from function
    place_meeting_condition1:
    bgtz $t1, place_meeting_condition2                  # If no right boundary collision, jump to condition2
    li $v0 1                                            # Set collision flag to 1
    jr $ra                                              # Return from function
    place_meeting_condition2:
    bgtz $t2, place_meeting_condition3                  # If no bottom boundary collision, jump to condition3
    li $v0 1                                            # Set collision flag to 1
    jr $ra                                              # Return from function
    place_meeting_condition3:
    la $t3 collision_mask                               
    add $t3, $t3, $a0                                   # Calculate address of collision at (x,y)
    sll $t4, $a1 5                                      # Calculate offset for y coordinate
    add $t3, $t3, $t4                                   # Add y offset to address
    lb $t4, 0($t3)                                      # Load collision data at address
    
    beq $t4 '7' gg_no_collisions                        # If no collision, jump to gg_no_collisions
    li $v0 1                                            # Set collision flag to 1
    jr $ra 
    gg_no_collisions:
    li $v0 0                                            # Set collision flag to 0
    jr $ra  
    
    
    place_meeting_block:
    # Check if the block collides with any obstacles in the grid
    # - $t0 display address
    # - $a0 code for the block that will be drawn
    # - $a1 x_coordinate
    # - $a2 y_coordinate
    # - $a3 rotation
    # - $t1 current position in block array
    # - $t2 color of tetromino
    # - $t3 current position in bitmap
    # - $t5 range from 1 to 16
    # - $t6 row complete change
    # - $t7 column complete change
        beq $a0 0 case_check_o                      
        beq $a0 1 case_check_i
        beq $a0 2 case_check_s
        beq $a0 3 case_check_z
        beq $a0 4 case_check_l
        beq $a0 5 case_check_j
        beq $a0 6 case_check_t
        
        # Check for specific block types and rotations
        case_check_o:
            la $t1 o_bit_map
            j check_decide_rotation_case
        case_check_i:
            la $t1 i_bit_map
            j check_decide_rotation_case
        case_check_s:
            la $t1 s_bit_map
            j check_decide_rotation_case 
        case_check_z:
            la $t1 z_bit_map
            j check_decide_rotation_case 
        case_check_l:
            la $t1 l_bit_map
            j check_decide_rotation_case 
        case_check_j:
            la $t1 j_bit_map
            j check_decide_rotation_case
        case_check_t:
            la $t1 t_bit_map
            j check_decide_rotation_case 
        
        # Decide which rotation case to check based on rotation parameter
        check_decide_rotation_case:
            beq $a3 0 case_check_rotation_0
            beq $a3 1 case_check_rotation_1
            beq $a3 2 case_check_rotation_2
            beq $a3 3 case_check_rotation_3
        # Check for collision in each rotation case
        case_check_rotation_0:
            li $t6 1                                # Set row complete change for rotation 0
            li $t7 0                                # Set column complete change for rotation 0
            j begin_checking_block                  # Jump to begin checking block
        case_check_rotation_1:
            addi $t1, $t1, 3
            li $t6 4
            li $t7 -17
            j begin_checking_block
        case_check_rotation_2:
            addi $t1, $t1, 15
            li $t6 -1
            li $t7 0
            j begin_checking_block
        case_check_rotation_3:
            addi $t1, $t1, 12
            li $t6 -4
            li $t7 17
            j begin_checking_block
        
        # - $t1 is address of bitmap
        # - $t6 row change
        # - $t7 column change
        # - $t2 current x being checked
        # - $t3 current y being checked
        # - $t4 maximum x
        # - $t5 maximum y
        begin_checking_block:
            add $t3, $zero, $a2                                                 # Initialize y coordinate for checking
            addi $t5, $t3, 4                                                    # Calculate maximum y coordinate for loop
            # Loop through each column of the block
            check_loop_through_column:
                beq $t5, $t3 check_loop_through_column_end                      # Check if the end of the column is reached
                add $t2, $zero, $a1                                             # Initialize x coordinate for checking
                addi $t4, $t2, 4                                                # Calculate maximum x coordinate for loop
                # Loop through each row of the block
                check_loop_through_row:
                    beq $t4, $t2 check_loop_through_row_end                         # Check if the end of the row is reached
                    lb $t0, 0($t1)                                                  # Load byte from bitmap
                    beq $t0, '0' check_loop_row_update_vals                         # Check if the byte is non-zero (indicating a block)
                    
                    # Store registers in the stack to preserve their values
                    addi $sp, $sp, -4       
                    sw $ra, 0($sp)          
                    addi $sp, $sp, -4       
                    sw $a0, 0($sp)          
                    addi $sp, $sp, -4       
                    sw $a1, 0($sp)
                    addi $sp, $sp, -4   
                    sw $a2, 0($sp)
                    addi $sp, $sp, -4   
                    sw $a3, 0($sp) 
                    addi $sp, $sp, -4   
                    sw $t1, 0($sp) 
                    addi $sp, $sp, -4   
                    sw $t6, 0($sp)
                    addi $sp, $sp, -4   
                    sw $t7, 0($sp)
                    addi $sp, $sp, -4   
                    sw $t2, 0($sp) 
                    addi $sp, $sp, -4   
                    sw $t3, 0($sp) 
                    addi $sp, $sp, -4   
                    sw $t4, 0($sp) 
                    addi $sp, $sp, -4   
                    sw $t5, 0($sp) 
                    
                    # Set arguments for place_meeting function
                    add $a0, $zero, $t2
                    add $a1, $zero, $t3
                    jal place_meeting                       # Call place_meeting function
                    # Retrieve saved registers from the stack
                    lw $t5, 0($sp)
                    addi $sp, $sp, 4                        # Deallocate space for $ra from the stack
                    lw $t4, 0($sp)
                    addi $sp, $sp, 4
                    lw $t3, 0($sp)
                    addi $sp, $sp, 4
                    lw $t2, 0($sp)
                    addi $sp, $sp, 4
                    lw $t7, 0($sp)
                    addi $sp, $sp, 4
                    lw $t6, 0($sp)
                    addi $sp, $sp, 4
                    lw $t1, 0($sp)
                    addi $sp, $sp, 4
                    lw $a3, 0($sp)
                    addi $sp, $sp, 4
                    lw $a2, 0($sp)
                    addi $sp, $sp, 4
                    lw $a1, 0($sp)
                    addi $sp, $sp, 4
                    lw $a0, 0($sp)
                    addi $sp, $sp, 4
                    lw $ra, 0($sp)
                    addi $sp, $sp, 4
                    beq $v0, 1 place_meeting_block_end    # Check if there is a collision
                    
                    # Update address to check next row
                    check_loop_row_update_vals:
                    add $t1, $t1, $t6
                    addi $t2, $t2, 1                      # Move to next column
                    j check_loop_through_row
                # Move to next column in bitmap
                check_loop_through_row_end:
                add $t1, $t1, $t7
                addi $t3, $t3, 1                          # Move to next row in block
                j check_loop_through_column
            check_loop_through_column_end:   
        place_meeting_block_end:
        jr $ra
        
        # Draw collision box based on collision mask
        draw_collision_box:
        # $t0: position in bitmap
        # $t1: position in collision_box
        
        lw $t0, ADDR_DSPL                                               # Load display address into $t0
        la $t1, collision_mask                                          # Load address of collision mask into $t1
        li $t2, 0
        # Loop through each byte in the collision mask
        top_draw_collision_box:
            beq $t2 1024 end_draw_collision_box                         # Check if the loop counter has reached the end
            lb $t3, 0($t1)                                              # Load byte from collision mask
            beq $t3, '7' draw_collisions_update_val                     # Check if the byte represents a block
            beq $t3, '0' case_d_o
            beq $t3, '1' case_d_i
            beq $t3, '2' case_d_s
            beq $t3, '3' case_d_z
            beq $t3, '4' case_d_l
            beq $t3, '5' case_d_j
            beq $t3, '6' case_d_t
            
                case_d_o:
                lw $t4 c_yellow
                sw $t4, 0($t0)
                j draw_collisions_update_val
                case_d_i:
                lw $t4 c_teal
                sw $t4, 0($t0)
                j draw_collisions_update_val
                case_d_s:
                lw $t4 c_red
                sw $t4, 0($t0)
                j draw_collisions_update_val
                case_d_z:
                lw $t4 c_green
                sw $t4, 0($t0)
                j draw_collisions_update_val
                case_d_l:
                lw $t4 c_orange
                sw $t4, 0($t0)
                j draw_collisions_update_val
                case_d_j:
                lw $t4 c_pink
                sw $t4, 0($t0)
                j draw_collisions_update_val
                case_d_t:
                lw $t4 c_purple
                sw $t4, 0($t0)
                j draw_collisions_update_val
            
            draw_collisions_update_val:
            # Move to next position in bitmap
            addi $t0, $t0, 4
            addi $t1, $t1, 1
            addi $t2, $t2, 1
            j top_draw_collision_box
        end_draw_collision_box:        
        jr $ra
        
        
        clear_collision:
          # Load the address of collision_mask into $t0
          la $t0, collision_mask
          li $t1, 0
          li $t2, '7'                                       # Initialize $t2 to ASCII value '7' (indicating no collision)
          
          
          clear_loop_top:
          beq $t1 1024 clear_loop_end                       # Check if the loop counter has reached 1024 (size of collision_mask)
          sb $t2, 0($t0)                                    # Store ASCII '7' (indicating no collision) into the collision mask
          addi $t0, $t0, 1                                  # Increment memory address to move to the next byte in the collision mask
          addi $t1, $t1, 1                                  # Increment loop counter
          j clear_loop_top
          clear_loop_end:
          
        
        jr $ra
        
        
        add_tetronimo_collider:
        # Determine the type of tetromino and set the corresponding bitmap address
        # a0 tetronimo type
        # a1 x
        # a2 y
        # a3 rotation
        # t1 address in block array
        # t2 address in collision
        # t3 row
        # t4 column
        # t5
        # t6 row complete change
        # t7 column complete change
        beq $a0 0 case_draw_o_c
        beq $a0 1 case_draw_i_c
        beq $a0 2 case_draw_s_c
        beq $a0 3 case_draw_z_c
        beq $a0 4 case_draw_l_c
        beq $a0 5 case_draw_j_c
        beq $a0 6 case_draw_t_c
        
        case_draw_o_c:
            la $t1 o_bit_map
            li $t5 '0'
            j decide_rotation_case_c
        case_draw_i_c:
            la $t1 i_bit_map
            li $t5 '1'
            j decide_rotation_case_c
        case_draw_s_c:
            la $t1 s_bit_map
            li $t5 '2'
            j decide_rotation_case_c
        case_draw_z_c:
            la $t1 z_bit_map
            li $t5 '3'
            j decide_rotation_case_c
        case_draw_l_c:
            la $t1 l_bit_map
            li $t5 '4'
            j decide_rotation_case_c
        case_draw_j_c:
            la $t1 j_bit_map
            li $t5 '5'
            j decide_rotation_case_c
        case_draw_t_c:
            la $t1 t_bit_map
            li $t5 '6'
            j decide_rotation_case_c
        
        # Decide rotation case based on rotation parameter
        decide_rotation_case_c:
            beq $a3 0 case_rotation_0_c
            beq $a3 1 case_rotation_1_c
            beq $a3 2 case_rotation_2_c
            beq $a3 3 case_rotation_3_c
        case_rotation_0_c:
            li $t6 1
            li $t7 0
            j begin_drawing_block_c
        case_rotation_1_c:
            addi $t1, $t1, 3
            li $t6 4
            li $t7 -17
            j begin_drawing_block_c
        case_rotation_2_c:
            addi $t1, $t1, 15
            li $t6 -1
            li $t7 0
            j begin_drawing_block_c
        case_rotation_3_c:
            addi $t1, $t1, 12
            li $t6 -4
            li $t7 17
            j begin_drawing_block_c
            
        # Start drawing the block by setting up the row and column
        begin_drawing_block_c:
        sll $t3, $a2 5
        la $t2, collision_mask
        add $t2, $t2, $t3
        add $t2, $t2, $a1
        li $t4 0
        # Loop through each row of the block
        draw_block_row_c:
        beq $t4 4 draw_block_row_end_c
        li $t3 0
            # Loop through each column of the block
            draw_block_column_c:
                beq $t3 4 draw_block_column_end_c
                lb $t0 0($t1)
                beq $t0 '0' updata_val                              # Check if the current block is empty
                sb $t5 0($t2)                                       # Store the tetromino type into the collision mask
                # Update addresses for next block
                updata_val:
                add $t1, $t1, $t6
                addi $t2, $t2, 1
                addi $t3, $t3, 1
                j draw_block_column_c
            draw_block_column_end_c:
        add $t1, $t1, $t7
        addi $t2, $t2, 28
        addi $t4, $t4, 1
        j draw_block_row_c
        draw_block_row_end_c:        
        jr $ra
    
        create_new_tetronimo:
        li $v0 , 42                                                 # System call for creating a new tetromino
        li $a0 , 0
        li $a1 , 7
        syscall 
        # Get the starting coordinates for the new tetromino
        lw $t0, block_start_x
        lw $t1, block_start_y
        # Store the starting coordinates
        sw $t0, curr_block_x
        sw $t1, curr_block_y   
        # Store the tetromino type
        sb $a0, curr_block_type
        # Store the return address in the stack
        addi $sp, $sp, -4   
        sw $ra, 0($sp) 
        # Set up arguments for place_meeting_block function
        add $a0, $zero, $a0
        add $a1, $zero, $t0
        add $a2, $zero, $t1
        lb $a3, curr_block_rotation
        
        # Call place_meeting_block function to check if the new tetromino collides
        jal place_meeting_block
        # Retrieve the return address from the stack
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        beq $v0 1 game_over_condition                               # Check if the new tetromino collides
        jr $ra
        game_over_condition:
        li $t0, 2
        sw $t0, game_state
        
        jr $ra
        
        check_rows_complete:
        # t0 number needed for complete row
        # t1 number found so far
        # t2 current row
        # t4 address in collision mask
        # t5 current column
        lw $t0, grid_width
        subi $t0, $t0, 2
        la $t4, collision_mask
        li $t2, 0
        check_single_row:
        beq $t2, 32, check_rows_complete_end
        li $t5, 0
        li $t1, 0
            check_single_byte:
            beq $t5, 32, check_single_byte_complete
            lb $t6 0($t4)
            beq $t6, '7', upd
            addi $t1, $t1, 1
            beq $t1, $t0 play_delete_sound_effect
            upd:
            addi $t4, $t4, 1
            addi $t5, $t5, 1
            j check_single_byte
            check_single_byte_complete:
            addi $t2, $t2, 1
            
            
        j check_single_row
        check_rows_complete_end:
        jr $ra
        
        complete_row_found:
        beq $t2, 1 done_completing_rows
        la $t4, collision_mask
        sll $t0, $t2, 5 # mult by 32
        add $t4, $t4, $t0
        li $t1, 0
        loop_delete_row_top:
        beq $t1 32 loop_delete_row_bottom
        lb $t0, -32($t4)
        sb $t0, 0($t4)        
        addi $t4, $t4, 1
        addi $t1, $t1, 1
        j loop_delete_row_top
        loop_delete_row_bottom:
        subi $t2, $t2, 1
        j complete_row_found
        done_completing_rows:
        jr $ra
        
        # Function to play the delete sound effect
        play_delete_sound_effect:
            li  $v0, 33                                 # Load immediate value 33 into register $v0 (syscall code for playing sound)
            addi $a0, $zero, 50                         # Add immediate: set $a0 to the frequency of the sound (50)
            addi $a1, $zero, 100                        # Add immediate: set $a1 to the volume of the sound (100)
            addi $a2, $zero, 121                        # Add immediate: set $a2 to the wave type of the sound (121)
            addi $a3, $zero, 127                        # Add immediate: set $a3 to the sound duration (127)
            syscall                                     # Perform the system call to play the sound
        j complete_row_found             
        
        # Function to play the move left/right sound effect
        play_lr_sound_effect:
            li  $v0, 33                                 # Load immediate value 33 into register $v0 (syscall code for playing sound)
            addi $a0, $zero, 50                         # Add immediate: set $a0 to the frequency of the sound (50)
            addi $a1, $zero, 100                        # Add immediate: set $a1 to the volume of the sound (100)
            addi $a2, $zero, 50                         # Add immediate: set $a2 to the wave type of the sound (50)
            addi $a3, $zero, 127                        # Add immediate: set $a3 to the sound duration (127)
            syscall                                     # Perform the system call to play the sound
            jr $ra                                      # Jump back to the calling routine (likely the end of a function)
            
        # Function to play the clap sound effect
        play_clap_sound_effect:
            li  $v0, 33                                 # Load immediate value 33 into register $v0 (syscall code for playing sound)
            addi $a0, $zero, 100                        # Set $a0 to the frequency of the clap sound 
            addi $a1, $zero, 100                        # Set $a1 to the volume of the clap sound
            addi $a2, $zero, 5                          # Set $a2 to the wave type for a simple waveform for the clap sound
            addi $a3, $zero, 127                        # Set $a3 to the sound duration 
            syscall                                     # Perform the system call to play the sound
            jr $ra                                      # Jump back to the calling routine (likely the end of a function)
        
         
         
         # Music notes correspond with specific pitches. From middle C:
        # C = 60
        # D = 62
        # E = 64
        # F = 65
        # G = 67
        # A = 69
        # B = 71
        # (To go up an octave, add 12)
            
        
        # Function to play a note C with a half note duration
        c_half:
            li $v0, 33    # async play note syscall
            li $a0, 60    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note D with a half note duration
        d_half:
            li $v0, 33    # async play note syscall
            li $a0, 62    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note E with a half note duration
        e_half:
            li $v0, 33    # async play note syscall
            li $a0, 64    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note F with a half note duration
        f_half:
            li $v0, 33    # async play note syscall
            li $a0, 65    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note G with a half note duration
        g_half:
            li $v0, 33    # async play note syscall
            li $a0, 67    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note A with a half note duration
        a_half:
            li $v0, 33    # async play note syscall
            li $a0, 69    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note B with a half note duration
        b_half:
            li $v0, 33    # async play note syscall
            li $a0, 71    # midi pitch
            li $a1, 250   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note C with a full note duration
        c_full:
            li $v0, 33    # async play note syscall
            li $a0, 60    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note D with a full note duration
        d_full:
            li $v0, 33    # async play note syscall
            li $a0, 62    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note E with a full note duration
        e_full:
            li $v0, 33    # async play note syscall
            li $a0, 64    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note F with a full note duration
        f_full:
            li $v0, 33    # async play note syscall
            li $a0, 65    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note G with a full note duration
        g_full:
            li $v0, 33    # async play note syscall
            li $a0, 67    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note A with a full note duration
        a_full:
            li $v0, 33    # async play note syscall
            li $a0, 69    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note B with a full note duration
        b_full:
            li $v0, 33    # async play note syscall
            li $a0, 71    # midi pitch
            li $a1, 500   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note B with a one and a half note duration
        b_one_and_half:
            li $v0, 33    # async play note syscall
            li $a0, 71    # midi pitch
            li $a1, 750   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
        
        # Function to play a note E with a one and a half note duration
        e_one_and_half:
            li $v0, 33    # async play note syscall
            li $a0, 64    # midi pitch
            li $a1, 750   # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note E with a double note duration
        e_double:
            li $v0, 33    # async play note syscall
            li $a0, 64    # midi pitch
            li $a1, 1000  # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note C with a double note duration
        c_double:
            li $v0, 33    # async play note syscall
            li $a0, 60    # midi pitch
            li $a1, 1000  # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note D with a double note duration
        d_double:
            li $v0, 33    # async play note syscall
            li $a0, 62    # midi pitch
            li $a1, 1000  # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note B with a double note duration
        b_double:
            li $v0, 33    # async play note syscall
            li $a0, 71    # midi pitch
            li $a1, 1000  # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note A with a double note duration
        a_double:
            li $v0, 33    # async play note syscall
            li $a0, 69    # midi pitch
            li $a1, 1000  # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        # Function to play a note G with a quadruple (4 beat) note duration
        g_quadrup:
            li $v0, 33    # async play note syscall
            li $a0, 67    # midi pitch
            li $a1, 2000  # duration
            li $a2, 4     # instrument
            li $a3, 200   # volume
            syscall
            jr $ra
            
        
        # Function to create a half note duration pause
        pause_half:
            li $v0, 33        # async play note syscall
            li $a0, 0         # pitch 0 represents silence
            li $a1, 250       # duration for a full note
            li $a2, 4         # instrument (silence)
            li $a3, 0         # volume (mute)
            syscall
            jr $ra            # return from function
            
         # Function to create a full note duration pause
        pause_full:
            li $v0, 33        # async play note syscall
            li $a0, 0         # pitch 0 represents silence
            li $a1, 500       # duration for a full note
            li $a2, 4         # instrument (silence)
            li $a3, 0         # volume (mute)
            syscall
            jr $ra            # return from function
         
function_end: