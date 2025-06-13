.data
# Essentiellement ceci permet de simuler que genmetrique change metrique et si.
metrique_1: .word 4,3,3,2 # Bon, ca utilise pas ma constante de 4...
            .word 0,3,5,4 # Comme du buckley... It taste aweful. And it works!
            .word 4,3,3,2 # Correspond a metrique du code en C, la premiere fois que CalculSurvivant est appeller.
            .word 2,5,3,2

metrique_2: .word 3,4,2,3
            .word 5,2,2,3
            .word 3,4,2,3 # Correspond a metrique du code en C, la deuxieme fois que CalculSurvivant est appeller.
            .word 3,0,4,5

metrique_3: .word 4,5,3,0
            .word 2,3,3,4
            .word 2,3,5,2 # Correspond a metrique du code en C, la troisieme fois que CalculSurvivant est appeller.
            .word 2,3,3,4

metrique_4: .word 2,5,3,2
            .word 4,3,3,2
            .word 0,3,5,4 # Correspond a metrique du code en C, la quatrieme fois que CalculSurvivant est appeller.
            .word 4,3,3,2

metrique_5: .word 3,2,4,3
            .word 5,4,0,3
            .word 3,2,4,3 # Correspond a metrique du code en C, la cinquieme fois que CalculSurvivant est appeller.
            .word 3,2,2,5

metrique_6: .word 3,4,2,3
            .word 3,0,4,5
            .word 3,4,2,3 # Correspond a metrique du code en C, la sixieme fois que CalculSurvivant est appeller.
            .word 5,2,2,3

base_vec:   .word 250,250,250,250 # Used

si_1: .word 0,0,0,0  # Pareil que le code C. (premiere appel) (terrible nom de variable en passant. SI peut dire tout et rien.)
si_2: .word 2,0,2,2
si_3: .word 4,2,4,0
si_4: .word 0,4,2,4
si_5: .word 2,4,0,4
si_6: .word 4,0,4,2


so:   .word 0,0,0,0  # Pareil que le code C. (reutiliser dans tout les calls) (terrible nom de variable en passant. SO peut dire tout et rien.)

before_msg: .asciiz "\ns0 before: "
after_msg:  .asciiz "s0 after: "
newline:    .asciiz "\n"
comma:      .asciiz ", "

.eqv CalculSurvivants_METRIQUE_PARAM_REGISTER $a0
.eqv CalculSurvivants_SINPUT_PARAM_REGISTER   $a1
.eqv CalculSurvivants_SOUTPUT_PARAM_REGISTER  $a2

.eqv acs_METRIQUE_PARAM_REGISTER $a0
.eqv acs_SINPUT_PARAM_REGISTER   $a1
.eqv acs_SOUTPUT_PARAM_REGISTER  $a2

.globl main
.globl acs # Terrible function name.
.globl CalculSurvivants

.text

main:
  la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_1
  la CalculSurvivants_SINPUT_PARAM_REGISTER, si_1
  la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so

  jal CalculSurvivants

  li $v0, 10
  syscall

CalculSurvivants:
  .eqv MET_ADDRESS                      0
  .eqv SINPUT_ADDRESS                   4
  .eqv SOUTPUT_ADDRESS                  8
  .eqv CalculSurvivants_RETURN_ADDRESS 12($sp)

  addi $sp, $sp, -16
  sw CalculSurvivants_METRIQUE_PARAM_REGISTER, MET_ADDRESS($sp)
  sw CalculSurvivants_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp)
  sw CalculSurvivants_SOUTPUT_PARAM_REGISTER, SOUTPUT_ADDRESS($sp)
  sw $ra, CalculSurvivants_RETURN_ADDRESS

  lw $t0, MET_ADDRESS($sp)
  lw $t1, SINPUT_ADDRESS($sp)
  lw $t2, SOUTPUT_ADDRESS($sp)

  lwv $z1, 0($t1) # Load sinput[0] upto sinput[3]

  li $t3, 0 # i = 0
CS_Loop:
  beq $t3, 16, CS_End # Loop over i = 0, 4, 8, 12 (4 iterations × 4 bytes)

  # soutput[i] = 250
  ; li $t4, 250
  sw $t4, 0($t2)

  # Prepare ACS arguments
  addu $t5, $t0, $t3            # &met[i*N]
  move acs_METRIQUE_PARAM_REGISTER, $t5
  move acs_SINPUT_PARAM_REGISTER, $t1
  move acs_SOUTPUT_PARAM_REGISTER, $t2

  jal acs

  addi $t3, $t3, 4              # i += 1 (word index)
  addi $t2, $t2, 4              # advance output pointer
  j CS_Loop

CS_End:
  lw $ra, CalculSurvivants_RETURN_ADDRESS
  addi $sp, $sp, 16
  jr $ra


acs:
  lwv $z2, 0(acs_METRIQUE_PARAM_REGISTER)  # Load met[0..3]
  lwv $z3, 0(acs_SINPUT_PARAM_REGISTER)    # Load sinput[0..3]

  addv $z4, $z2, $z3        # z4 = met + sinput

  # Find minimum across z4[0..3] → $t0
  sumv $z4, $z4             # z4[0] = min(z4[0], z4[1], z4[2], z4[3])
  sw $z4, 0(acs_SOUTPUT_PARAM_REGISTER)  # Store the result

  jr $ra
