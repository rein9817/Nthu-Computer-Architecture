.globl main

.data
enter_prompt: .asciiz "Enter n values (enter -1 to exit):"
input_prompt: .asciiz "Input n: "

fib_msg: .asciiz "fib["
equals_msg: .asciiz "] = "
count_msg: .asciiz "1s count in 32 LSBs of fib["
colon_msg: .asciiz "]: "
negative_one_error: .asciiz "Program terminated."
negative_error: .asciiz "Invalid input! Please enter a non-negative integer or -1 to exit."
newline: .asciiz "\n" # Newline character for formatting 
    
matrix: .word 1 1 1 0 
result: .space 16
n: .word 0 

.text
main:
    la $a0, enter_prompt
    li $v0, 4
    syscall 

    la $a0, newline
    li $v0, 4
    syscall

MAIN_LOOP:
    la $a0, input_prompt
    li $v0, 4
    syscall

    li $v0, 5
    syscall 
    move $t0, $v0 # $t0 = n

    li $t1, -1
    beq $t0, $t1, EXIT_NEGATIVE_ONE
    bltz $t0, INVALID_INPUT
    
    move $s7, $t0
    
    addi $sp, $sp, -16 # allocate space for result matrix
    la $a0, matrix  # load the address of the base matrix
    move $a1, $t0  # load n into $a1
    move $a2, $sp
    jal  mat_fast_power_recursive

    # Get fib[n] = result[0][1]
    lw $s0, 4($sp) # fib[n] = result[0][1]
    # print "fib[n] = "
    la $a0, fib_msg # "fib["
    li $v0, 4
    syscall
    
    move $a0, $s7 # print n
    li $v0, 1
    syscall
    
    la $a0, equals_msg # "] = "
    li $v0, 4
    syscall
    
    move $a0, $s0 # print fib[n]
    li $v0, 1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall

    move $a0, $s0
    jal  count_bits
    move $s1, $v0 # bit count 
    
    # Print "1s count in 32 LSBs of fib[n]: "
    la $a0, count_msg
    li $v0, 4
    syscall
    
    move $a0, $s7 # print n
    li $v0, 1
    syscall
    
    la $a0, colon_msg # "]: "
    li $v0, 4
    syscall

    move $a0, $s1
    li $v0, 1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    addi $sp, $sp, 16
    j MAIN_LOOP

INVALID_INPUT:
    la $a0, negative_error
    li $v0, 4
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    j MAIN_LOOP

EXIT_NEGATIVE_ONE:
    la $a0, negative_one_error
    li $v0, 4
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    
EXIT:
    li $v0, 10
    syscall

    
mat_mul:
    # res[0][0]
    lw $t0, 0($a0)  # a[0][0]
    lw $t1, 0($a1)  # b[0][0]
    multu $t0, $t1
    mflo $t2    # t2 = a[0][0] * b[0][0] 

    lw $t0, 4($a0) # a[0][1]
    lw $t1, 8($a1) # b[1][0]
    multu $t0, $t1
    mflo $t3 # t3 = (a[0][1] * b[1][0]) mod 2^32

    addu $t4, $t2, $t3 # res[0][0] = t2 + t3 
    sw $t4, 0($a2)   # Store res[0][0]

    # res[0][1]
    lw $t0, 0($a0)  # a[0][0]
    lw $t1, 4($a1)  # b[0][1]
    multu $t0, $t1
    mflo $t2 

    lw $t0, 4($a0)  # a[0][1]
    lw $t1, 12($a1)  # b[1][1]
    multu $t0, $t1
    mflo $t3   # a[0][1] * b[1][1]

    addu $t4, $t2, $t3 # res[0][1] = t2 + t3
    sw $t4, 4($a2) # Store res[0][1]

    # res[1][0]
    lw $t0, 8($a0)  # a[1][0]
    lw $t1, 0($a1)  # b[0][0]
    multu $t0, $t1
    mflo $t2    # t2 = a[1][0] * b[0][0]

    lw $t0, 12($a0) # a[1][1]
    lw $t1, 8($a1)  # b[1][0]
    multu $t0, $t1
    mflo $t3     # t3 = (a[1][1] * b[1][0]) mod 2^32
    addu $t4, $t2, $t3  # res[1][0] = t2 + t3
    sw $t4, 8($a2)   # Store res[1][0]

    # res[1][1]
    lw $t0, 8($a0)   # a[1][0]
    lw $t1, 4($a1)  # b[0][1]
    multu $t0, $t1
    mflo $t2   # t2 = a[1][0] * b[0][1]
    lw $t0, 12($a0)
    lw $t1, 12($a1)
    multu $t0, $t1
    mflo $t3
    addu $t4, $t2, $t3
    sw $t4, 12($a2)
    jr $ra


mat_fast_power_recursive:
    addi $sp, $sp, -72
    sw $ra, 68($sp)
    sw $s0, 64($sp)
    sw $s1, 60($sp)
    sw $s2, 56($sp)
    sw $s3, 52($sp)
    sw $s4, 48($sp)
    sw $s5, 44($sp)
    sw $a0, 40($sp) # Save $a0 base
    sw $a1, 36($sp) # Save $a1 exp
    sw $a2, 32($sp) # res

    move $s0, $a1  # exp
    move $s1, $a0  # base
    move $s2, $a2  # res

    beq $s0, $zero, EXP_ZERO
    li $t0, 1 # check if exp == 1
    beq $s0, $t0, EXP_ONE
    srl $t0, $s0, 1
    # function call
    move $a0, $s1  # base
    move $a1, $t0  # exp / 2
    addiu $a2, $sp, 0 
    jal mat_fast_power_recursive

    addiu $a0, $sp, 0 # $a0 = temp
    addiu $a1, $sp, 0 # $a1 = temp
    move $a2, $s2 # $a2 = res
    jal mat_mul

    andi $t0, $s0, 1
    beq $t0, $zero, END_RECURSION
    addiu $t1, $sp, 16
    
    # memcpy 
    lw $t2, 0($s2)
    sw $t2, 0($t1)
    lw $t2, 4($s2)
    sw $t2, 4($t1)
    lw $t2, 8($s2)
    sw $t2, 8($t1)
    lw $t2, 12($s2)
    sw $t2, 12($t1)

    move $a0, $t1  # $a0 = temp2
    move $a1, $s1  # $a1 = base
    move $a2, $s2  # $a2 = res
    jal mat_mul

END_RECURSION:
    lw $ra, 68($sp)
    lw $s0, 64($sp)
    lw $s1, 60($sp)
    lw $s2, 56($sp)
    lw $s3, 52($sp)
    lw $s4, 48($sp)
    lw $s5, 44($sp)
    lw $a0, 40($sp)
    lw $a1, 36($sp)
    lw $a2, 32($sp) 
    addi $sp, $sp, 72
    jr $ra

EXP_ZERO:
    li $t0, 1
    sw $t0, 0($s2)     # res[0][0] = 1
    sw $t0, 12($s2)    # res[1][1] = 1
    sw $zero, 4($s2)   # res[0][1] = 0
    sw $zero, 8($s2)   # res[1][0] = 0
    j END_RECURSION

EXP_ONE:
    lw $t0, 0($s1)   # base[0][0]
    sw $t0, 0($s2)   # res[0][0] = base[0][0]
    lw $t0, 4($s1)   # base[0][1]
    sw $t0, 4($s2)   # res[0][1] = base[0][1]
    lw $t0, 8($s1)   # base[1][0]
    sw $t0, 8($s2)   # res[1][0] = base[1][0]
    lw $t0, 12($s1)  # base[1][1]
    sw $t0, 12($s2)  # res[1][1] = base[1][1]
    j END_RECURSION

count_bits:
    addi $sp, $sp, -12
    sw   $ra, 8($sp) 
    sw   $a0, 4($sp)
    sw   $s0, 0($sp)            
    
    bne  $a0, $zero, NEXT
    li   $v0, 0
    j END
NEXT:
    andi $s0, $a0, 1 # 
    srl  $a0, $a0, 1 
    jal  count_bits
    add  $v0, $v0, $s0
END:
    lw   $ra, 8($sp)
    lw   $a0, 4($sp)
    lw   $s0, 0($sp)
    addi $sp, $sp, 12
    jr   $ra