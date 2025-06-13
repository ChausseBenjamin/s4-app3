.data 0x10010000

vec_entree: .word 1,2,3,4
vec_sortie: .word 0,0,0,0

# 1  | 2  | 3  | 4
# 5  | 6  | 7  | 8
# 9  | 10 | 11 | 12
# 13 | 14 | 15 | 16

mat_A: .word 1,5,9,13,2,6,10,14,3,7,11,15,4,8,12,16 # grouped in columns

.text 0x400000
.eqv N 4  # single step (4-byte word)
.eqv M 16 # column step (4 rows * 4-byte words = 16 bytes)


main:
  li $s1, 0         # i = 0
  li $s2, 4         # N columns
  li $s3, 0         # idx = 0 (will jump by increments of 16 for correct column start)

  lwv $z1, vec_entree # vector storage uses $zN instead of $vN to avoid confusion with $v0
  la  $s4, vec_sortie # index 0 of the output vector (will get incremented)

loop:
  # Load from mat_A[i] up to mat_A[i+4] into $z2 (aka column) using $s3 as reference
  lwv $z2, mat_A($s3)

  # NOTE: The custom SIMD instruction `multv r a b` does r[n] = a[n]*b[n] for each vector component
  multv $z3, $z1, $z2

  # NOTE: The custom SIMD instruction `sumv a b` stores b[0]+b[1]+b[2]+b[3] into a
  sumv $t0, $z3

  # Store the calculated $t0 at the Nth index of vec_sortie
  sw $t0, 0($s4)

  addi $s1, $s1, 1   # i++
  addi $s4, $s4, 4   # Increase addr position within vec_sortie
  addi $s3, $s3, M   # idx += 16
  blt  $s1, $s2, loop # while i < 4

end:
  li $v0, 10 # end of program
  syscall
