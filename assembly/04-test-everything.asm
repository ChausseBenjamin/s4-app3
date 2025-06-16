.data 0x00001001

base_val: .word 0xDEAD
base_add: .word 0xBEEF
out_norm: .word 0
sum_norm: .word 0

#                B, E, N, C
ben_vec:   .word 66,69,78,67
lower_vec: .word 32,32,32,32
out_vec:   .word 0,0,0,0
min_val:   .word 0

.eqv GRACEFUL_STOP 10

.globl main

.text

main:
  test_vanilla_load:
    lw   $t4, base_val
    nop
    nop
    nop
    nop
    nop

  test_vanilla_store:
    sw  $t4,  out_norm # Output should be 0xDEAD
    nop
    nop
    nop
    nop
    nop

  test_vanilla_add:
    lw   $t5,  base_add   # 0xBEEF
    add  $t6,  $t4, $t5 # $t6 = 0xDEAD+0xBEEF = 19D9C
    sw   $t6,  sum_norm
    nop
    nop
    nop
    nop
    nop

  test_vec_load:
    lw   $t0, ben_vec
    nop
    nop
    nop
    nop
    nop

  test_vec_store:
    sw  $t0,  out_vec # Output should be the same as ben_vec
    nop
    nop
    nop
    nop
    nop

  test_vec_add:
    lw   $t1,  lower_vec # Load lowercaseTransform into $z1
    add  $t2,  $t0, $t1  # Make $z2 a lowercase $z0 using $z1
    sw   $t2,  out_vec   # Overwrite the output with lowercase
    nop
    nop
    nop
    nop
    nop

  test_vec_min:
    #TODO: Replace ori with our custom `minw $t3, $z0` ($t0 should be 66)
    ori  $t3,  $t0,     42
    sw   $t3,  min_val
    nop
    nop
    nop
    nop
    nop

  end:
    li $v0 GRACEFUL_STOP
    syscall
