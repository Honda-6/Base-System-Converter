.data
	userinput: .space  50
	
.text

	main:
		li $v0 5 
		syscall
		
		move $s6,$v0  # store the base
	
		li $v0 8
		la $a0 userinput   #number
		li $a1 50
		syscall
		
		lb $t2, ($a0) #first char
		jal get_end_of_string
		move $s0,$a0
		
		la $s4 userinput
		li $s2, 0
		ble $s0,$s4, end  #empty input
		li $t4, 1
		
		jal before_conversion
		
	end:
		move $a0, $s2    #move result
		li $v0 1
		syscall
		li $v0 10
		syscall
		
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