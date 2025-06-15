.data
# Essentiellement ceci permet de simuler que genmetrique change metrique et si.
metrique_1: .word 4,3,3,2 # Bon, ca utilise pas ma constante de 4...
            .word 0,3,5,4 # Comme du buckley... It taste aweful. And it works!
            .word 4,3,3,2 # Correspond a metrique du code en C, la premiere fois que CalculSurvivant est appeller.
            .word 2,5,3,2


si_1: .word 0,0,0,0  # Pareil que le code C. (premiere appel) (terrible nom de variable en passant. SI peut dire tout et rien.)
; si_2: .word 2,0,2,2
; si_3: .word 4,2,4,0
; si_4: .word 0,4,2,4
; si_5: .word 2,4,0,4
; si_6: .word 4,0,4,2


so:   .word 0,0,0,0  # Pareil que le code C. (reutiliser dans tout les calls) (terrible nom de variable en passant. SO peut dire tout et rien.)

before_msg: .asciiz "\ns0 before: "
after_msg: .asciiz "s0 after: "
newline:   .asciiz "\n"
comma:      .asciiz ", "


.eqv NOMBRE_ETAT 4           # Sert le meme but que `#define N 4`. (terrible nom de #define en passant.)
.eqv NOMBRE_ETAT_FOR_LOOP_MAX 16   # Quand on pointe dans un vecteur, on se deplace de 4. Cet constante est essentiellement (NOMBRE_ETAT * 4)
.eqv LONGUEUR_MESSAGE 12           # Meme but que `#define L 12`. (C'est important de bien nommer nos variables au lieu d'utiliser une lettre de l'alphabet.)

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

  .eqv FOR_INDEX                       0
  .eqv MET_ADDRESS                     4
  .eqv SINPUT_ADDRESS                  8
  .eqv SOUTPUT_ADDRESS                 12
  .eqv CalculSurvivants_RETURN_ADDRESS 16($sp)

  addi $sp, $sp, -20

  sw CalculSurvivants_METRIQUE_PARAM_REGISTER, MET_ADDRESS($sp)  # Extracting metrique matrix address param and putting it in the stack.
  sw CalculSurvivants_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp)  # Extracting sinput vector address and putting it in the stack.
  sw CalculSurvivants_SOUTPUT_PARAM_REGISTER, SOUTPUT_ADDRESS($sp)# Extracting soutput vector address and putting it in the stack.
  sw $ra, CalculSurvivants_RETURN_ADDRESS

  li $t0, 0        # La boucle vas faire N iterations mais commence a 0.
  sw $t0, FOR_INDEX($sp)  # Putting that 0 as the initial for loop index.

  CS_Check_For_Condition:
    lw $t0, FOR_INDEX($sp)              # Load the value of i into $t0 so all calls can use it. provided $t0 is reloaded after acs call.
    beq $t0, NOMBRE_ETAT_FOR_LOOP_MAX, CS_For_End   # End the loop if i == NOMBRE_ETAT_FOR_LOOP_MAX

    # --- Storing 250 in soutput. --- #
    li $t1, 250               # Putting 250 into $t1 so it can be put as soutput[i] later.
    lw $t2, SOUTPUT_ADDRESS($sp)      # Loading the address of soutput into $t2 to reference it later.
    addu $t3, $t2, $t0            # Offsetting the address by i so we read soutput[i] instead of soutput[0]
    sw $t1, 0($t3)               # Put 250 at the ith address of soutput... (soutput[i = 250)

    # --- Setup pour appel de ACS --- #
    lw $t1, MET_ADDRESS($sp)         # Loading Metrique address from the stack into $t1
    sll $t3, $t0, 2             # Multiply by 4 i. Because we need to read the first values of the vectors within the 2D matrix and not the values of the first vector.
    addu $t2, $t1, $t3            # Offsetting the address so we read metrique[i*4] instead of metrique[0][0]
    move acs_METRIQUE_PARAM_REGISTER, $t2   # This puts the address position of the current subvector into $a0 (metrique[i])

    lw acs_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp) # Puts sinput into the sinput of acs (function input parameter)

    lw $t1, SOUTPUT_ADDRESS($sp)      # Putting soutput into $t1 to later put into acs_SOUTPUT_PARAM_REGISTER
    addu $t2, $t1, $t0             # Offsets the address of souput so we're not reading soutput[0] but soutput[i]
    move acs_SOUTPUT_PARAM_REGISTER, $t2   # Putting SOUTPUT_ADDRESS[i] into ACS input register.

    jal acs

    # --- Increase the count and go back to checking the condition --- #
    lw $t1, FOR_INDEX($sp)    # Putting the for loop index into $t1
    addi $t2, $t1, 4      # Putting for loop index + 4 into $t2
    sw $t2, FOR_INDEX($sp)    # Putting the result back into the for loop index.
    jal CS_Check_For_Condition   # Jumping to check for loop condition.

  CS_For_End:
    lw $ra, CalculSurvivants_RETURN_ADDRESS # loading CalculSurvivants return address.
    addi $sp, $sp, 20             # freeing the stack AFTER fetching the return address.
    jr $ra                   # returning CalculSurvivants

acs:
  .eqv FOR_INDEX 0
  .eqv MET_ADDRESS 4
  .eqv SINPUT_ADDRESS 8
  .eqv SOUTPUT_ADDRESS 12
  .eqv ACS_RETURN_ADDRESS 16($sp)

  # --- Loading the input parameters --- #
  addi $sp, $sp, -20                   # Making place for ACS stack size.
  sw acs_METRIQUE_PARAM_REGISTER, MET_ADDRESS($sp)  # Extracting metrique matrix address param and putting it in the stack.
  sw acs_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp)  # Extracting sinput vector address and putting it in the stack.
  sw acs_SOUTPUT_PARAM_REGISTER, SOUTPUT_ADDRESS($sp)  # Extracting soutput vector address and putting it in the stack.
  sw $ra, ACS_RETURN_ADDRESS              # Saving return address for later

  # --- Initializing the for loop index --- #
  li $t0, 0        # Putting 0 into $t0
  sw $t0, FOR_INDEX($sp)  # Putting that 0 as the initial for loop index.

  ACS_Check_For_Condition:
    lw $t0, FOR_INDEX($sp)              # Loading the for loop index into $t0, so all other calls can use it.
    beq $t0, NOMBRE_ETAT_FOR_LOOP_MAX, Acs_For_End  # Checking if we need to return yet. ( i == NOMBRE_ETAT_FOR_LOOP_MAX )

    lw $t1, MET_ADDRESS($sp)    # loading metrique address into $t1
    addu $t2, $t1, $t0          # Offset the address by i so we can read metrique[i]
    lw $t5, 0($t2)              # Loaded metric[i] into $t5

    lw $t2, SINPUT_ADDRESS($sp) # loading sinput address into $t2
    addu $t3, $t2, $t0          # Offset the address by i so we can read sinput[i]
    lw $t6, 0($t3)              # $t6 = sinput[i]

    # --- Addition and comparison --- #
    addu $t1, $t5, $t6           # met[j] + sinput[j] into $t1; (temp = met[j] + sinput[j])
    lw $t3, SOUTPUT_ADDRESS($sp) # Put the address of soutput into a register to use it in the next line
    lw $t4, 0($t3)               # load soutput[i] into a register so we can compare it later.

    blt $t1, $t4, acs_is_less    # temp < soutput then branch to where soutput gets overwritten
    # if we're here it's cuz it's not less than soutput!
    jal acs_end_of_check
    acs_is_less:
      # Woah, it is less! We gotta change the value of soutput!
      sw $t1, 0($t3)         # soutput[i] = temp
    acs_end_of_check:

    # --- Increase the count and go back to checking the condition --- #
    lw $t1, FOR_INDEX($sp)      # Putting the for loop index into $t1
    addi $t2, $t1, 4            # Putting for loop index + 4 into $t2
    sw $t2, FOR_INDEX($sp)      # Putting the result back into the for loop index.
    jal ACS_Check_For_Condition # Jumping to check for loop condition.

  Acs_For_End:
    # free up la stack que la fonction a prise.
    lw $ra, ACS_RETURN_ADDRESS     # loading CalculSurvivants return address.
    addi $sp, $sp, 20         # freeing the stack AFTER fetching the return address.
    jr $ra               # returning to whoever called it.
