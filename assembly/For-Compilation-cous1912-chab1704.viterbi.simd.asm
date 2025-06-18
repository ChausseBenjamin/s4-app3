.data

base_vec:   .word 250,250,250,250 # Quick constant for acs

# survivor input for each test_case
si_1: .word 0,0,0,0
# si_2: .word 2,0,2,2
# si_3: .word 4,2,4,0
# si_4: .word 0,4,2,4
# si_5: .word 2,4,0,4
# si_6: .word 4,0,4,2

metrique_1: .word 4,3,3,2
            .word 0,3,5,4
            .word 4,3,3,2
            .word 2,5,3,2

so:   .word 0,0,0,0  # Survivor output

# Misc
.eqv GRACEFUL_STOP 10
.eqv VEC_SIZE 16 # in bytes
.eqv MAT_SIZE 64 # 4*VEC_SIZE for a 4x4 matrix

# Calcul Survivant function parameters in the C code are
.eqv Survivor_SINPUT_REG $a0 # Survivor Input vector (4)
.eqv Survivor_MET_REG    $a1 # Metrics Input Matrix (4x4)
.eqv Survivor_OUTPUT_REG $a2 # Survivor Output Ptr to write data (vector)

# acs function parameters in the code are
.eqv acs_SINPUT_REG $a0 #
.eqv acs_MET_REG    $a1 # Metrics vector
.eqv acs_OUTPUT_REG $a2 # Output Ptr for write (one int returned)

.globl main
.globl acs
.globl CalculSurvivants

.text

main:
  # Prep function parameter addresses to call CalculSurvivants
  la Survivor_SINPUT_REG, si_1
  la Survivor_MET_REG,    metrique_1
  la Survivor_OUTPUT_REG, so

  jal CalculSurvivants

  li $v0 GRACEFUL_STOP
  syscall

CalculSurvivants:
  # Extract input parameters and store them in this function's stack scope
  .eqv Survivor_RETURN_ADDR     0
  .eqv Survivor_SINPUT_ADDR     4
  .eqv Survivor_MET_ADDR        8
  .eqv Survivor_OUTPUT_ADDR     12
  .eqv Survivor_MAT_OFFSET_ADDR 16 # Iterator over the matrix rows
  addi $sp, $sp, -32

  sw $ra,                 Survivor_RETURN_ADDR($sp)
  sw Survivor_SINPUT_REG, Survivor_SINPUT_ADDR($sp)
  sw Survivor_MET_REG,       Survivor_MET_ADDR($sp)
  sw Survivor_OUTPUT_REG, Survivor_OUTPUT_ADDR($sp)

  # Quickly overwrite the output with a vector populated with 250s into the
  # output address. SIMD allows doing this in parallel hence the lwv.
  # Acs will overwrite these values if necessary afterwards
  lw $t0, Survivor_OUTPUT_ADDR($sp)
  nop
  lw $1, base_vec
  sw $1, 0($t0)
  nop

  # Prepare loop that jumps throught the 4 vector rows
  li $t0, 0
  sw $t0, Survivor_MAT_OFFSET_ADDR($sp)

  survivorLoop:
    # Load the Latest Matrix offset to check if it's time to leave the loop
    # or increment it
    lw  $t0, Survivor_MAT_OFFSET_ADDR($sp)
    beq $t0, MAT_SIZE, survivorEnd # The total 4x4 matrix byte-size busts (64)

    # Setup parameters for acs call
    lw acs_SINPUT_REG, Survivor_SINPUT_ADDR($sp)
    lw $t5, Survivor_MET_ADDR($sp)
    add $t4, $t5, $t0
    move acs_MET_REG, $t4 # Correct row withing the matrix

    # If the iterator operates on the byte address of a matrix row (0,16,32,48)
    # The output[i] byte address (0,4,8,12) can be retrieved via a rightshift
    add $t2, $t0, 0
    srl  $t1, $t2, 2

    lw $t5, Survivor_OUTPUT_ADDR($sp)
    add $t4, $t5, $t1
    move acs_OUTPUT_REG, $t4

    # Just before jumping store the next matrix row/vector offset
    addi $t0, $t0, VEC_SIZE # size of a vector/row = 16
    sw   $t0, Survivor_MAT_OFFSET_ADDR($sp)
    jal acs


    j survivorLoop

  survivorEnd:
    lw $ra, Survivor_RETURN_ADDR($sp)
    addi $sp, $sp, 32 # Free stack memory
    jr $ra

  acs:
    # Extract input parameters and store them in this function's stack scope
    .eqv acs_RETURN_ADDR     0
    .eqv acs_SINPUT_ADDR     4
    .eqv acs_MET_ADDR        8
    .eqv acs_OUTPUT_ADDR     12
    #addi $sp, $sp, -16

    #sw acs_SINPUT_REG, acs_SINPUT_ADDR($sp)
    #sw acs_MET_REG,       acs_MET_ADDR($sp)
    #sw acs_OUTPUT_REG, acs_OUTPUT_ADDR($sp)

    #move acs_OUTPUT_REG, $t0 # should be the 250 previously loaded

    #lwv $z0 acs_SINPUT_REG
    nop
    lw $1, 0(acs_SINPUT_REG)
    lw $2, 0(acs_MET_REG)
    addu $3, $1, $2 	# z2 is the sum of both vectors
    andi $t1, $3, 0 	# t1 is the minimum fron the vector
    nop

    # If the output (pre-set at 250) is already smaller the the vector minimum,
    # skip the reassignment and jump to the return
    lw $t0, 0(acs_OUTPUT_REG)
    blt $t0, $t1, acsEnd

    sw $t1, 0(acs_OUTPUT_REG)

    acsEnd:
      #lw $ra, acs_RETURN_ADDR($sp)
      #addi $sp, $sp, 16 # Free stack memory
      jr $ra

