
.data
    message_number: .asciiz "Enter the number : "
    message_system: .asciiz "Enter the system : "
    digits: .space 32        # Space to store digits for the converted number
    debug_msg: .asciiz "Debug: "
    
.text

main:
    # output first message
    la $a0, message_number
    li $v0, 4
    syscall 
    
    # get first data (number)
    li $v0, 5
    syscall
    move $t0, $v0
    
    # output second message
    la $a0, message_system
    li $v0, 4
    syscall 
    
    # get second data (base)
    li $v0, 5
    syscall
    move $t1, $v0
    
    #load arguments of function
    move $a0,$t0
    move $a1,$t1
    # Call DecimalToOther
    jal DecimalToOther
    
    
PrintDigits_loop:
    blt $t4, $zero, done_printing    # if $t4 < 0 , done printing

PrintDigit:
    lb $a0, digits($t4)          # load the digit in reverse order
    li $v0, 11                   
    syscall
    sub $t4, $t4, 1              # get the next digit
    j PrintDigits_loop

done_printing:
    li $v0, 10
    syscall
    
    
    
DecimalToOther:
    # parameters: $a0 = number, $a1 = system

    addi $sp, $sp, -12      # 12 = 3 "number of used register" * 4 "size"
    sw $t0, 0($sp)     
    sw $t1, 4($sp)         
    sw $t2, 8($sp)          

    li $t0, 0    # result
    li $t1, 0    # i "counter"

DecimalToOther_loop:    
    blez $a0, DecimalToOther_done  # If number <= 0, break loop
    div $a0, $a1                
    mfhi $t2   # rem
    # Debug print remainder
    #la $a0, debug_msg
    #li $v0, 4
    #syscall
    #move $a0, $t2
    #li $v0, 1
    #syscall
    addi $t2, $t2, 48            # convert remainder to ASCII ('0' = 48)
    sb $t2, digits($t1)          # save rem in the array
    mflo $a0                     # get the quotient , number = number / base
    addi $t1, $t1, 1             # i++
    j DecimalToOther_loop

DecimalToOther_done:
    sb $zero, digits($t1)        # Null-terminate the string
    sub $t4, $t1, 1              #t4 = the last digit index
    lw $t0, 0($sp)              
    lw $t1, 4($sp)               
    lw $t2, 8($sp)               
    addi $sp, $sp, 12      
    jr $ra     

    