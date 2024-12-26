.data
currentSystem: .word 0
newSystem: .word 0
number: .space 50
input1: .asciiz "Enter the current system: "
input2: .asciiz "Enter the number: "
input3: .asciiz "Enter the new system: "
Wrong_number_message_part1: .asciiz "This number: "
Wrong_number_message_part2: .asciiz "does not belong to the "
Wrong_number_message_part3: .asciiz " system.\n"
invalid_newSystem_message: .asciiz "Can't convert to this system."
digits: .space 32        # Space to store digits for the converted number

.text

input: 
    li $v0, 4 # syscall for printing input1 
    la $a0, input1 # load the address of input1
    syscall 

    li $v0, 5 # syscall for reading an integer (currentSystem) 
    syscall 
    sw $v0, currentSystem

    li $v0, 4  # syscall for printing input2
    la $a0, input2 # load the address of input2
    syscall

    li $v0, 8 #syscall for reading a string (number)
    la $a0, number # load the address of number 
    li $a1, 50 # set the maximum length of the number
    syscall 

    li $v0, 4 # syscall for printing input3
    la $a0, input3 # load the address of input3
    syscall

    li $v0, 5 # syscall for reading an integer (newSystem)
    syscall
    sw $v0, newSystem

checkNewSystem:
    lw $t0, newSystem # loads newSystem value into temp $t0
    slti $t1, $t0, 2 # checks if $t0 < 2 
    beq $t1, 1, printNewSystemError # prints an error msg and terminate 
    slti $t1, $t0, 17 # checks if $t0 < 17 and stores answer in $t1
    beq $t1, 0, printNewSystemError # if $t1 = 0, this means newSystem >= 16, prints error msg & terminate

callValidation:
    la $a0, number
    lw $a1, currentSystem
    jal validation
    
conversionChecking:
    lw $t0, currentSystem # loads currentSystem in $t0
    lw $t1, newSystem # loads newSystem in $t1
    sne $t2, $t0, 10 # $t2 = currentSystem != 10 
    sne $t3, $t1, 10 # $t3 = newSystem != 10
    and $t4, $t3, $t2 # $t4 = $t2 and $t3
    beq $t4, 1, callBothFunctions # if $t4 = 1, then both systems are not decimal, call both functions 
    beq $t2, 0, callBothFunctions 
    beq $t3, 0, callOtherToDecimal
    
callBothFunctions:
   lw $s6, currentSystem
   jal OtherToDecimal
   lw $a1, newSystem
   jal DecimalToOther
   j PrintDigits_loop
   j return 
    
callOtherToDecimal:
   la $a0, number
   lw $s6, currentSystem
   jal OtherToDecimal
   jal printDecimal
   j return

#---- validation ----

validation:
    identify_registers:
        #number as string
        move $t0,$a0
        #base
        move $t1,$a1
        li $t2,'9'
        li $t6,'0'
        li $t5,'A'
    while_loop:
        lb $t3,0($t0)
        beq $t3,$zero,print_goBack
        move $t4,$zero
        bgt $t3,$t2,numbers_greater_than_nine
        move $t4,$t3
        sub $t4,$t4,$t6
        check:
            bge $t4,$t1,wrong_number
        addi $t0,$t0,1
        j while_loop
        
    numbers_greater_than_nine:
        sub $t4,$t3,$t5
        addi $t4,$t4,10
        j check

wrong_number:
    move $t7,$a0
    li $v0,4
    la $a0,Wrong_number_message_part1
    syscall
    move $a0,$t7
    li $v0,4
    syscall
    la $a0,Wrong_number_message_part2
    li $v0,4
    syscall
    move $a0,$a1
    li $v0,1
    syscall
    la $a0,Wrong_number_message_part3
    li $v0,4
    syscall
    j return
print_goBack:
    jr $ra		
    
    
#---- DecimalToOther ----
    
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
    bgt $t2, 9, morethan10
    addi $t2, $t2, 48            # convert remainder to ASCII ('0' = 48)
    j store

morethan10:
     addi $t2, $t2, 55            # convert remainder to ASCII ('0' = 55)
     
store:
    sb $t2, digits($t1)          
    mflo $a0                     
    addi $t1, $t1, 1             
    j DecimalToOther_loop
    
DecimalToOther_done:
    sb $zero, digits($t1)        # Null-terminate the string
    sub $t4, $t1, 1              #t4 = the last digit index
    lw $t0, 0($sp)              
    lw $t1, 4($sp)               
    lw $t2, 8($sp)               
    addi $sp, $sp, 12      
    jr $ra      


#---- OtherToDecimal ----

OtherToDecimal:
    move $a3, $ra
    
    lb $t2, ($a0) #first char    
    jal get_end_of_string
    move $s0,$a0
    
    la $s4 number
    li $s2, 0
    ble $s0,$s4, end  #empty input
    li $t4, 1
    
    jal before_conversion
    
end:
    move $a0, $s2    #move result
    move $ra, $a3
    jr $ra
    
get_end_of_string:
    beq $t2, 10, return_to_main  #while char is not new line
    addi $a0,$a0,1
    lb $t2, ($a0)
    j get_end_of_string
    
return_to_main:
    addi $a0, $a0, -1  #discard new line
    jr $ra

before_conversion:
    move $s7,$ra  #store the address of main
    
convert:
    lb $t5, ($s0)
    jal a_capital 
    addi $t5, $t5,-48  #minus '0'
    addi $s0, $s0,-1    #length--
    mul $t6,$t4,$t5    #digit times base power i
    add $s2,$s2,$t6    
    mul $t4,$t4,$s6 #increment the power of base
    bge $s0,$s4 convert
    move $ra,$s7  # get back the address of main from which the jump to this method occured
    jr $ra #back to main
    
a_capital:
    blt $t5, 65 , back_to_conversion
    addi $t5,$t5, 10
    addi $ra, $ra,4  #skip the (minus 48) line
    bge $t5, 97, a_small
    subi $t5,$t5,65
    
back_to_conversion:
    jr $ra  #continue from where you jumped (convert)
    
a_small:	
    subi $t5,$t5,97
    j back_to_conversion


#---- print result of decimal to other ----

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

#---- print result of other to decimal ----

printDecimal:
   li $v0, 1
   syscall  
   
#---- new system error ---- 

printNewSystemError:
    li $v0, 4
    la $a0, invalid_newSystem_message
    syscall
    j return

return:
    li $v0,10
    syscall
