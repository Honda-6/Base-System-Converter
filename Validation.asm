.data
	input_message: .asciiz "Enter a number\n"
	Wrong_number_message_part1:.asciiz "This number: "
	Wrong_number_message_part2: .asciiz "does not belong to the "
	Wrong_number_message_part3:.asciiz " system.\n"
	base_message: .asciiz "Enter base between 2 and 16 \n"
	buffer: .space 50
.text 
	input:
		la $a0,input_message
		li $v0,4
		syscall 
		li $v0,8
		la $a0,buffer
		li $a1,50
		syscall	
		la $a0,base_message
		li $v0,4
		syscall 
		li $v0,5
		syscall
		move $a1,$v0
		la $a0, buffer
		jal validation
		j return
	
	validation:
		read_parameter:
			#number as string
			move $t0,$a0
			#base
			move $t1,$a1
			li $t2,'9'
			li $t6,'0'
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
			li $t5,'A'
			sub $t4,$t3,$t5
			addi $t4,$t4,10
			j check

	
	wrong_number:
		move $t7,$a0
		la $a0,Wrong_number_message_part1
		li $v0,4
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
		jr $ra
	print_goBack:
		jr $ra		
	return:
		li $v0,10
		syscall
	
