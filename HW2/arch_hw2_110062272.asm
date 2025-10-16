.globl main

.data
base_prompt: .asciiz "base: "
exp_prompt: .asciiz "exponent: " 

result_msg: .asciiz "result: "
hamming_msg: .asciiz "hamming weight: "
neg_error: .asciiz "Error: Exponent cannot be negative."
zero_error: .asciiz "Both base and exponent are zero. Exiting."

newline: .asciiz "\n" # Newline character for formatting 


.text
main:
MAIN_LOOP:

# read base 
la $a0, base_prompt
li $v0,4 # print string 
syscall

li $v0,5
syscall 
move $t0,$v0

# read exponent
la $a0,exp_prompt
li $v0,4
syscall

li $v0,5
syscall 
move $t1,$v0

# zero check
or $t2,$t0,$t1
beq $t2,$zero,both_zero

# negative check
slt $t3, $t1, $zero      # if exponent < 0, $t3 = 1
bne $t3, $zero, both_negative

#binary exponentiation algorithm
# t0 = base
# t1 = exponent
# t2 = result
addi $t2,$zero,1 # result=1
WHILE:
    beq $t1,$zero,WHILE_EXIT
    # while(temp_exponent>0) end

    andi $t3, $t1,1 # temp = exponent & 1
    beq $t3,$zero,JUDGE_EXIT
    mul $t2,$t2,$t0 # result = result * base
JUDGE_EXIT:
    mul $t0,$t0,$t0 # base = base * base
    srl $t1,$t1,1 # exponent >>= 1 
    j WHILE

WHILE_EXIT:
    move $s0, $t2
    la $a0, result_msg
    li $v0,4
    syscall

    # print the calculation result
    move $a0,$s0 # save the result
    li $v0,1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall

# hamming weight calculation
li $t0, 0  # weight_count = 0
li $t1, 0  # i = 0
addi $t2, $zero, 32
FOR:
    beq $t1,$t2,FOR_EXIT # for(i=0;i<32;i++)

    srlv $t3,$s0,$t1
    andi $t3,$t3,1
    beq $t3,$zero, SKIP_COUNT
    addi $t0,$t0,1 # weight_count++
    
SKIP_COUNT:
    addi $t1, $t1,1 # i++
    j FOR

FOR_EXIT:
    #print the hamming result
    la $a0,hamming_msg
    li $v0,4
    syscall
    move $a0,$t0
    li $v0,1
    syscall
    
    la $a0, newline
    li $v0,4 
    syscall
    j MAIN_LOOP

both_zero:
    la $a0, zero_error
    li $v0,4
    syscall

    la $a0, newline
    li $v0,4 
    syscall
    j EXIT
    
both_negative:
    la $a0,neg_error
    li $v0,4
    syscall
    la $a0, newline
    li $v0,4 # print string 
    syscall
    j MAIN_LOOP
    
EXIT:
    li $v0, 10
    syscall
