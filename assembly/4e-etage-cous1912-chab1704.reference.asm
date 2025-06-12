# ReferenceStandard_ProduitMatrice.asm
# Code pour calculer une performance de référence.
# M-A Tétrault Mars 2023/2025
# Dept. GE & GI U. de S. 
#
# Problématique/Rapport
#
# Fonction: 
# Execution: 
#
# Ce code contient certaines instructions à adressage non supporté, que MARS développe en plusieurs instructions..
# Il y en a quatre, lesquelles?
.data 0x10010000

vec_entree: .word 1,2,3,4
vec_sortie: .word 0,0,0,0
mat_A: .word 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

# vec_sortie doit donner 30, 70, 110, 150
            
               
.text 0x400000
.eqv N 4

main:
    # pas de fonctions, donc pas de protection des registres
    li $s0, 0               # j = 0
    li $s2, N
    nop
    nop

boucle_externe:
    beq  $s0, $s2, finBoucleExterne
    nop
    nop
    nop
    li   $s1, 0             # i = 0
    nop
    nop

    boucle_interne:
        beq $s1, $s2, finBoucleInterne # for i < 4
        nop
        nop
        nop
        
        # obtenir x[j]
        sll $t4, $s0, 2          # décalage pour adresse en mots
        #nop
        #nop
        lw  $t1, vec_entree($t4) # lecture de x[j]
        
        # obtenir y[i]
        sll $t5, $s1, 2          # décalage pour adresse en mots
        #nop
        #nop
        lw  $t0, vec_sortie($t5) # lecture de y[i]
        
        # Lecture de A[i][j]
        #       indice == i*N + j et N == 4
        sll $t4, $s1, 2     # i*4
        nop
        nop
        add $t4, $t4, $s0   # i*4+j
        nop
        nop
        sll $t4, $t4, 2     # décalage [i*4+j] (adresse en mots)
        #nop
        #nop
        lw  $t2, mat_A($t4) # lecture de A[i][j]
        nop
        nop

        multu $t1, $t2      # A[i][j] * x[j]
        nop
        nop
        mflo $t1            # récupération des 32 1ers bits
        nop
        nop

        add $t0, $t0, $t1   # y[i] = y[i] + A[i][j] * x[j]
        #nop
        #nop
        
        sw $t0, vec_sortie($t5) # écriture de y[i]
        
        
        addi $s1, $s1, 1    # i++
        #nop                 # un seul nop car le jump = 2e operation entre le beq qui lui est concurrant
        j boucle_interne    #
        nop
        nop
        nop
    
finBoucleInterne:
    addi $s0, $s0, 1        # j++
    #nop
    j boucle_externe
    nop
    nop
    nop
    
finBoucleExterne:
    addi $v0, $zero, 10     # fin du programme
    nop
    nop
    syscall
    nop
    nop
    nop
    nop
    




