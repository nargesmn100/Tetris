##############################################################################
# Example: Tetris Music
#
# This file demonstrates how to play the Tetris theme music in MIPS assembly.
##############################################################################
.data
counter: .word 10  # Counter initialized to 10

.text
main:
    jal play_tetris_music_higher_pitch
    
play_tetris_music_higher_pitch:
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
    
end_program:
    # Exit the program
    li $v0, 10         # Load immediate value 10 into register $v0 (syscall code for exit)
    syscall            # Perform the exit syscall
   
    
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