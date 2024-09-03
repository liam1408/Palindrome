# Liam Meshulam
# program that gets a string with hexadecimal numbers and coverts to decimal 
# and then prints their values sorted by order for unsigned and signed arrays

##################### data #####################
.data
    stringhex: .space 37     # Space for input string
    NUM: .space 12          # Array for values
    unsign: .space 12       # Array for unsigned sorted values
    sign: .space 12         # Array for signed sorted values
    prompt: .asciiz "Enter a string with hexadecimal characters (max 36): "
    error: .asciiz "Illegal String\n"
    unsign_msg: .asciiz "\n Unsigned sorted values: "
    sign_msg: .asciiz "\n Signed sorted values: "
##################### text #####################
.text
.globl main

##################### main #####################
main:
    # Print prompt and read input
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 8
    la $a0, stringhex
    li $a1, 37
    syscall

    # Validate input
    la $a0, stringhex
    jal is_valid

    # Check if valid
    beqz $v0, invalid_input_iv

    # Call convert procedure
    la $a0, stringhex
    la $a1, NUM
    move $a2, $v0       # Number of pairs
    jal convert

    # Call sortunsign procedure
    la $a0, unsign      # Address of the unsign array
    la $a1, NUM         # Address of the NUM array
    move $a2, $v0       # Number of bytes to sort
    jal sortunsign

    # Call sortsign procedure
    la $a0, sign      # Address of the sign array
    la $a1, NUM         # Address of the NUM array
    move $a2, $v0       # Number of bytes to sort
    jal sortsign
    	
    # Call printunsign procedure
    la $a0, unsign
    move $a1, $v0       
    jal printunsign  
    
    # Call printsign procedure
    la $a0, sign
    jal printsign   
    

    # Exit program
    li $v0, 10
    syscall

invalid_input_iv:
    # Print error message
    li $v0, 4
    la $a0, error
    syscall

    # Exit program
    li $v0, 10
    syscall
    
##################### is_valid #####################
is_valid:

    li $t0, 0            # Number of hexa pairs
    li $t1, 0            # Counter for hexa numbers
    li $t2, 0            # Flag for whether last character was $
    li $t3, 0            # check register

check_loop:
    lb $t3, 0($a0)      # Load character from string
    beqz $t3, check_end # If end of string

    beq $t3, '$', check_dollar # Check if character is $

    beq $t3, 10, check_end # Check if character is newline

    li $t4, 48          # ASCII '0'
    li $t5, 57          # ASCII '9'
    li $t6, 65          # ASCII 'A'
    li $t7, 70          # ASCII 'F'
    blt $t3, $t4, invalid_input #If value is smaller than '0'
    bgt $t3, $t5, check_hex_upper #If value is bigger than '9'

    j check_next_char

check_hex_upper:
    blt $t3, $t6, invalid_input #If value is smaller than 'A'
    bgt $t3, $t7, invalid_input #If value is bigger than 'F'

    j check_next_char

check_dollar:

    lb $t4, -1($a0)    # Load previous character
    beq $t4, $, invalid_input # If previous character was $, invalid

    bne $t1, 2, invalid_input # There should be exactly 2 digits between $

    addi $t0, $t0, 1
    li $t1, 0            # Reset digit counter
    li $t2, 1            # Set flag that last character was $

    addi $a0, $a0, 1
    j check_loop

check_after_dollar:

    li $t1, 0    
    addi $a0, $a0, 1     # Move to next character
    j check_loop

check_next_char:

    addi $t1, $t1, 1     # Increment digit counter if not $
    
    # Move to next character
    addi $a0, $a0, 1
    li $t2, 0            # Reset flag
    j check_loop

check_end:

    lb $t4, -1($a0)     # Load last character
    li $t5, '$'          # ASCII value for dollar sign $
    li $t6, 10          # ASCII value for newline
    beq $t4, $t5, valid_end # If last character is $, it's valid
    beq $t4, $t6, valid_end

    j invalid_input

valid_end:

    li $t5, 1           # Minimum number of pairs
    blt $t0, $t5, invalid_input
    li $t5, 12          # Maximum number of pairs
    bgt $t0, $t5, invalid_input

    # If everything is valid
    move $v0, $t0       # Return number of pairs
    jr $ra

invalid_input:
    li $v0, 0           # Return 0 for invalid input
    jr $ra

##################### convert #####################
convert:

    li $t0, 0            # Index for NUM array
    li $t1, 0            # Hexa pair counter

convert_loop:

    lb $t2, 0($a0)      # Load first character of the pair
    lb $t3, 1($a0)      # Load second character of the pair

    blt $t2, '0', convert_error
    bgt $t2, '9', convert_check_upper
    sub $t2, $t2, '0'   # Convert ASCII digit (0-9) to number
    j convert_check_second

convert_check_upper:
    blt $t2, 'A', convert_error
    bgt $t2, 'F', convert_error
    sub $t2, $t2, 'A'   # Convert ASCII letter (A-F) to number
    addi $t2, $t2, 10   # Convert A-F to 10-15

convert_check_second:
    # Convert second character to its numeric value
    blt $t3, '0', convert_error
    bgt $t3, '9', convert_check_upper2
    sub $t3, $t3, '0'   # Convert ASCII digit (0-9) to number
    j convert_save

convert_check_upper2:
    blt $t3, 'A', convert_error
    bgt $t3, 'F', convert_error
    sub $t3, $t3, 'A'   # Convert ASCII letter (A-F) to number
    addi $t3, $t3, 10   # Convert A-F to 10-15

convert_save:

    # Combine two characters into a single byte
    sll $t2, $t2, 4     # Shift the first digit left by 4 bits
    or $t2, $t2, $t3    # Combine with the second digit

    sb $t2, 0($a1)      # Store byte in NUM array

    addi $a0, $a0, 3    # Move past current pair and $
    addi $a1, $a1, 1    # Move to next byte in NUM
    addi $t1, $t1, 1    # Increment pair counter
    bne $t1, $a2, convert_loop # Repeat until all pairs are processed

    jr $ra

convert_error:
    li $v0, 0
    jr $ra

##################### sortunsign #####################

sortunsign:

    li $t0, 0            # Outer loop counter
    li $t1, 0            # Inner loop counter
    li $t2, 0            # register for comparison
    li $t3, 0            # register for swapping
    la $t4, unsign       # Load address of unsign array
    la $t5, NUM          # Load address of NUM array
    move $t6, $a2        # Number of bytes to sort

    li $t0, 0            # Initialize index for copying for NUM
    
copy_loop:

    bge $t0, $a2, sort_start # If done copying, go to sort_start
    lbu $t7, 0($t5)      # Load byte from NUM array
    sb $t7, 0($t4)      # Store byte in unsign array
    addi $t5, $t5, 1    # Move to next byte in NUM array
    addi $t4, $t4, 1    # Move to next byte in unsign array
    addi $t0, $t0, 1    # Increment index
    j copy_loop         # Repeat for all bytes

sort_start:

    move $t0, $a2       # Set outer loop counter to number of bytes
    la $t4, unsign      # Reload base address of unsign array

outer_loop:
    li $t1, 0           # Inner loop counter
    subi $t0, $t0, 1    # Decrement outer loop counter
    blez $t0, sort_done # If outer loop counter <= 0  sorting is done

    la $t4, unsign      # Reload base address of unsign

inner_loop:
    lbu $t2, 0($t4)     # Load current byte
    lbu $t3, 1($t4)     # Load next byte
    bge $t2, $t3, no_swap # If current byte >= next byte then no_swap

    sb $t3, 0($t4)     # Store next byte in current position
    sb $t2, 1($t4)     # Store current byte in next position

no_swap:
    addi $t4, $t4, 1   # Move to next pair of bytes
    addi $t1, $t1, 1   # Increment inner loop counter
    blt $t1, $t0, inner_loop # Repeat until all bytes are processed

    j outer_loop       # Repeat outer loop for sorting

sort_done:
    jr $ra             # Return from procedure

##################### printunsign #####################
printunsign:
    move $t0, $a0           # Save the original address of unsign into $t0
    li $t1, 0               # Counter for bytes
    
    li $v0, 4               # Print array message
    la $a0, unsign_msg
    syscall

printunsign_loop:
    bge $t1, $a1, printunsign_done  # Exit loop if all values are printed

    lbu $t2, 0($t0)        # Load byte

    beqz $t2, print_zero # Check if zero

    
    li $t3, 100            
    divu $t4, $t2, $t3     # Divide by 100
    mflo $t5               # hundreds digit place
    mfhi $t6               

    li $t3, 10             
    divu $t7, $t6, $t3     # Divide by 10
    mflo $t8               # tens digit place
    mfhi $t9               


    bnez $t5, print_hundreds
    li $t5, 0
    j print_tens

print_hundreds:
    addi $t5, $t5, '0'     # Convert to ASCII
    li $v0, 11            
    move $a0, $t5
    syscall

print_tens:
    bnez $t8, print_units  # Skip if tens place is zero
    li $t8, 0             
    j print_units

print_units:
    addi $t8, $t8, '0'     # Convert tens place to ASCII
    li $v0, 11             
    move $a0, $t8
    syscall

print_units_no_tens:
    addi $t9, $t9, '0'     # Convert units place to ASCII
    li $v0, 11             
    move $a0, $t9
    syscall

    li $v0, 11             
    li $a0, ' '          
    syscall

    addi $t0, $t0, 1       # Move to next byte in unsign
    addi $t1, $t1, 1       # Increment counter
    j printunsign_loop     # Repeat loop

print_zero:
    li $a0, '0'            # Print zero if byte is zero
    li $v0, 11            
    syscall

    li $v0, 11 
    li $a0, ' ' 
    syscall

    addi $t0, $t0, 1       # Move to next byte in unsign
    addi $t1, $t1, 1       # Increment counter
    j printunsign_loop     # Repeat loop

printunsign_done:
    li $v0, 11 
    li $a0, 10 
    syscall
    jr $ra

##################### sortsign #####################
sortsign:
    la $t4, sign         # Load address of sign array
    la $t5, NUM          # Load address of NUM array
    move $t6, $a2        # Number of bytes to sort


    li $t0, 0
    
copy_loop_sign:
    bge $t0, $a2, sort_start_sign # If done copying, go sort
    lb $t7, 0($t5)       # Load byte from NUM array
    sb $t7, 0($t4)       # Store byte in sign array
    addi $t5, $t5, 1     # Move to next byte in NUM array
    addi $t4, $t4, 1     # Move to next byte in sign array
    addi $t0, $t0, 1     # Increment index
    j copy_loop_sign     # Repeat for all bytes

sort_start_sign:

    subi $t0, $a2, 1    # Set the outer loop counter
    beqz $t0, sort_done_sign # If no passes are needed dont sort

outer_loop_sign:
    li $t1, 0           # Inner loop counter
    li $t2, 0           # Reset address to start of sign array
    la $t4, sign

inner_loop_sign:
    lb $t2, 0($t4)      # Load current byte
    lb $t3, 1($t4)      # Load next byte
    blt $t3, $t2, no_swap_sign # If current byte <= next byte no swap

    sb $t3, 0($t4)      # Store next byte in current position
    sb $t2, 1($t4)      # Store current byte in next position

no_swap_sign:
    addi $t4, $t4, 1    # Move to next pair of bytes
    addi $t1, $t1, 1    # Increment inner loop counter
    blt $t1, $t0, inner_loop_sign # Continue inner loop if not at end

    subi $t0, $t0, 1    # Decrement outer loop counter
    bgtz $t0, outer_loop_sign    # If outer loop counter > 0 repeat outer loop

sort_done_sign:
    jr $ra              # Return to main


##################### printsign #####################
printsign:
    move $t0, $a0           # Save the original address of unsign into $t0
    li $t1, 0               # Counter for bytes
    
    li $v0, 4               # Print array message
    la $a0, sign_msg
    syscall

printsign_loop:
    bge $t1, $a1, printsign_done  # Exit loop if all bytes are printed

    lbu $t2, 0($t0)        # Load byte from unsign into $t2

    beqz $t2, print_zero_sign     # Check if byte is zero

    li $t3, 0x80
    and $t4, $t2, $t3
    beqz $t4, positive_number

    # if Number is negative
    li $t3, 0xFF
    xor $t2, $t2, $t3
    addi $t2, $t2, 1

    # Print '-' sign for negative number
    li $v0, 11 
    li $a0, '-'
    syscall

positive_number:

    li $t3, 100
    divu $t4, $t2, $t3     # Divide by 100
    mflo $t5               # hundreds digit place
    mfhi $t6 

    li $t3, 10
    divu $t7, $t6, $t3     # Divide by 10
    mflo $t8               # tens digit place
    mfhi $t9


    bnez $t5, print_hundreds_sign
    li $t5, 0 
    j print_tens_sign

print_hundreds_sign:
    addi $t5, $t5, '0'
    li $v0, 11
    move $a0, $t5
    syscall

print_tens_sign:
    bnez $t8, print_units_sign
    li $t8, 0
    j print_units_sign

print_units_sign:
    addi $t8, $t8, '0'
    li $v0, 11
    move $a0, $t8
    syscall

print_units_no_tens_sign:
    addi $t9, $t9, '0'
    li $v0, 11
    move $a0, $t9
    syscall

    li $v0, 11
    li $a0, ' '
    syscall

    addi $t0, $t0, 1       # Move to next byte in unsign
    addi $t1, $t1, 1       # Increment counter
    j printsign_loop       # Repeat loop

print_zero_sign:
    li $a0, '0'
    li $v0, 11
    syscall

    li $v0, 11
    li $a0, ' '
    syscall

    addi $t0, $t0, 1       # Move to next byte in unsign
    addi $t1, $t1, 1       # Increment counter
    j printsign_loop       # Repeat loop

printsign_done:
    li $v0, 11
    li $a0, 10
    syscall
    jr $ra                 # Return to main
