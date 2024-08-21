# Main program
main:
    # Call the play_delete_sound_effect function
    # jal play_delete_sound_effect
    # jal play_lr_sound_effect
    jal play_clap_sound_effect
    jal play_clap_sound_effect
    jal play_clap_sound_effect

    # Exit the program
    li $v0, 10         # Load immediate value 10 into register $v0 (syscall code for exit)
    syscall            # Perform the exit syscall


# Function to play the delete sound effect
play_delete_sound_effect:
    li  $v0, 33        # Load immediate value 33 into register $v0 (syscall code for playing sound)
    addi $a0, $zero, 50    # Add immediate: set $a0 to the frequency of the sound (50)
    addi $a1, $zero, 100   # Add immediate: set $a1 to the volume of the sound (100)
    addi $a2, $zero, 121   # Add immediate: set $a2 to the wave type of the sound (121)
    addi $a3, $zero, 127   # Add immediate: set $a3 to the sound duration (127)
    syscall            # Perform the system call to play the sound
    jr $ra             # Jump back to the calling routine (likely the end of a function)

# Function to play the move left/right sound effect
play_lr_sound_effect:
    li  $v0, 33        # Load immediate value 33 into register $v0 (syscall code for playing sound)
    addi $a0, $zero, 50    # Add immediate: set $a0 to the frequency of the sound (50)
    addi $a1, $zero, 100   # Add immediate: set $a1 to the volume of the sound (100)
    addi $a2, $zero, 50   # Add immediate: set $a2 to the wave type of the sound (121)
    addi $a3, $zero, 127   # Add immediate: set $a3 to the sound duration (127)
    syscall            # Perform the system call to play the sound
    jr $ra             # Jump back to the calling routine (likely the end of a function)
    
# Function to play the clap sound effect
play_clap_sound_effect:
    li  $v0, 33        # Load immediate value 33 into register $v0 (syscall code for playing sound)
    addi $a0, $zero, 100  # Set $a0 to the frequency of the clap sound (adjust as needed)
    addi $a1, $zero, 100   # Set $a1 to the volume of the clap sound
    addi $a2, $zero, 5     # Set $a2 to the wave type for a simple waveform for the clap sound
    addi $a3, $zero, 127   # Set $a3 to the sound duration (adjust as needed)
    syscall            # Perform the system call to play the sound
    jr $ra             # Jump back to the calling routine (likely the end of a function)