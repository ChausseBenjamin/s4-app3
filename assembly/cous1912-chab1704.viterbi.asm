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
	
si_1: .word 0,0,0,0	# Pareil que le code C. (premiere appel) (terrible nom de variable en passant. SI peut dire tout et rien.)
si_2: .word 2,0,2,2
si_3: .word 4,2,4,0
si_4: .word 0,4,2,4
si_5: .word 2,4,0,4
si_6: .word 4,0,4,2


so:   .word 0,0,0,0	# Pareil que le code C. (reutiliser dans tout les calls) (terrible nom de variable en passant. SO peut dire tout et rien.)

before_msg: .asciiz "\ns0 before: "
after_msg: .asciiz "s0 after: "
newline:   .asciiz "\n"
comma: 	   .asciiz ", "


.eqv NOMBRE_ETAT 4     			# Sert le meme but que `#define N 4`. (terrible nom de #define en passant.)
.eqv NOMBRE_ETAT_FOR_LOOP_MAX 16 	# Quand on pointe dans un vecteur, on se deplace de 4. Cet constante est essentiellement (NOMBRE_ETAT * 4)
.eqv LONGUEUR_MESSAGE 12       		# Meme but que `#define L 12`. (C'est important de bien nommer nos variables au lieu d'utiliser une lettre de l'alphabet.)

.eqv CalculSurvivants_METRIQUE_PARAM_REGISTER $a0
.eqv CalculSurvivants_SINPUT_PARAM_REGISTER $a1
.eqv CalculSurvivants_SOUTPUT_PARAM_REGISTER $a2

.eqv acs_METRIQUE_PARAM_REGISTER $a0
.eqv acs_SINPUT_PARAM_REGISTER $a1
.eqv acs_SOUTPUT_PARAM_REGISTER $a2

.globl main
.globl acs # Terrible function name.
.globl CalculSurvivants

.text

# met, si et so sont des matrices 2 dimmensions.
# Leurs addresses sont donnees a CalculSuivant.
# Calcul suivant donne l'addresse de debut des sous vecteurs a ACS. Ce dernier utilise les vrai valeurs.
main:	
	# Comment marche le test unitaire?
	# CalculSurvivant affecte juste la valeur de s0.
	# J'ai modifier le code C++ pour qu'il print tout le contenue de s0, si et metrique AVANT le call de CalculSurvivant et APRES le call.
	# Les valeurs donners ont ete mis dans metrique_1, metrique_2 etc etc.
	# J'ai pris note des valeurs de s0 avant et apres les calls de calculSurvivant.
	# Je simule donc les effets externe du code C++
	# Chaque call indique la valeur que s0 doit avoir.
	# Le main print exactement le meme print que le code c modifier:
	# ```c
	#	printf("\ns0 before: %d, %d, %d, %d \n", so[0], so[1], so[2], so[3]);
	#	CalculSurvivants( &metriques[0][0], &si[0], &so[0] );
	#	printf("s0 after: %d, %d, %d, %d \n", so[0], so[1], so[2], so[3]);
	# ```
	
	#########################################################
	## Execution 1. So devrait devenir (2,0,2,2)
	#########################################################
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_1
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_1
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#---------------------------------------------------------------------- [Print the value of s0]
	li $v0, 4            # syscall: print string
    	la $a0, before_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_1
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_1
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	jal CalculSurvivants
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_1
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_1
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#----------------------------------------------------------------------
	li $v0, 4            # syscall: print string
    	la $a0, after_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	#########################################################
	## Execution 2. So devrait devenir (4,2,4,0)
	#########################################################
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_2
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_2
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#---------------------------------------------------------------------- [Print the value of s0]
	li $v0, 4            # syscall: print string
    	la $a0, before_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_2
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_2
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	jal CalculSurvivants
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_2
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_2
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#----------------------------------------------------------------------
	li $v0, 4            # syscall: print string
    	la $a0, after_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	#########################################################
	## Execution 3. So devrait devenir (0,4,2,4)
	#########################################################
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_3
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_3
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#---------------------------------------------------------------------- [Print the value of s0]
	li $v0, 4            # syscall: print string
    	la $a0, before_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_3
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_3
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	jal CalculSurvivants
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_3
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_3
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#----------------------------------------------------------------------
	li $v0, 4            # syscall: print string
    	la $a0, after_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	#########################################################
	## Execution 4. So devrait devenir (2,4,0,4)
	#########################################################
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_4
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_4
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#---------------------------------------------------------------------- [Print the value of s0]
	li $v0, 4            # syscall: print string
    	la $a0, before_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_4
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_4
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	jal CalculSurvivants
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_4
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_4
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#----------------------------------------------------------------------
	li $v0, 4            # syscall: print string
    	la $a0, after_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	#########################################################
	## Execution 5. So devrait devenir (4,0,4,2)
	#########################################################
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_5
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_5
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#---------------------------------------------------------------------- [Print the value of s0]
	li $v0, 4            # syscall: print string
    	la $a0, before_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------

	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_5
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_5
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	jal CalculSurvivants
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_5
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_5
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#----------------------------------------------------------------------
	li $v0, 4            # syscall: print string
    	la $a0, after_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	#########################################################
	## Execution 6. So devrait rester (4,0,4,2)
	#########################################################
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_6
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_6
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#---------------------------------------------------------------------- [Print the value of s0]
	li $v0, 4            # syscall: print string
    	la $a0, before_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_6
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_6
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	jal CalculSurvivants
	
	la CalculSurvivants_METRIQUE_PARAM_REGISTER, metrique_6
	la CalculSurvivants_SINPUT_PARAM_REGISTER, si_6
	la CalculSurvivants_SOUTPUT_PARAM_REGISTER, so
	
	lw $t1, 0(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t2, 4(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t3, 8(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	lw $t4, 12(CalculSurvivants_SOUTPUT_PARAM_REGISTER)
	
	#----------------------------------------------------------------------
	li $v0, 4            # syscall: print string
    	la $a0, after_msg
    	syscall

    	li $v0, 1            # syscall: print integer
    	move $a0, $t1
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t2
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t3
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, comma
    	syscall
    	
    	li $v0, 1            # syscall: print integer
    	move $a0, $t4
    	syscall

   	li $v0, 4            # syscall: print string (newline)
    	la $a0, newline
    	syscall
	#----------------------------------------------------------------------
	
	# --- Fin du code. call le 10 and yeet out of here. We're done. --- #
	li $v0, 10
	syscall
		
# Parametres:
#	- $a0 = met
#	- $a1 = sinput
#	- $a2 = soutput
# Les memes registres sont garder car ils sont transferer dans des registres temporaires t0 a t3 lesquels ne sont pas utiliser par acs.
# A chaque iteration, 250 est mis comme valeur de soutput.
# ACS est appeller avec le 250 et debute ca comparaison iterative.
# Dans la boucle for, l'address de met est envoyer a ACS avec l'index 0, 4, 8, 12. Autrement dit (i * N)
CalculSurvivants:

	.eqv FOR_INDEX 0
	.eqv MET_ADDRESS 4
	.eqv SINPUT_ADDRESS 8
	.eqv SOUTPUT_ADDRESS 12
	.eqv CalculSurvivants_RETURN_ADDRESS 16($sp)

	# Utiliser la stack libere les registres temporaire et assure que rien niaisse avec des registres utilise.
	# Hors, j'ai: i, addresse de met, sinput et soutput ET $ra a sauvegarder.
	# $ra est important pour revenir dans la fonction main.
	addi $sp, $sp, -20	# Making place for the CalculSurvivants stack size.
	
	# transfering parameter registers into the stack
	sw CalculSurvivants_METRIQUE_PARAM_REGISTER, MET_ADDRESS($sp)	# Extracting metrique matrix address param and putting it in the stack.
	sw CalculSurvivants_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp)	# Extracting sinput vector address and putting it in the stack.
	sw CalculSurvivants_SOUTPUT_PARAM_REGISTER, SOUTPUT_ADDRESS($sp)# Extracting soutput vector address and putting it in the stack.
	sw $ra, CalculSurvivants_RETURN_ADDRESS
	
    	#---------------------------------------------------------------------
	
	# La boucle vas faire N iterations mais commence a 0.
	li $t0, 0		# Putting 0 into $t0
	sw $t0, FOR_INDEX($sp)	# Putting that 0 as the initial for loop index.
	
	CS_Check_For_Condition:
		# Branche a la fin de la for loop si l'index de lecture a atteint le nombre d'etat.
		lw $t0, FOR_INDEX($sp)				# Load the value of i into $t0 so all calls can use it. provided $t0 is reloaded after acs call.
		beq $t0, NOMBRE_ETAT_FOR_LOOP_MAX, CS_For_End 	# End the loop if i == NOMBRE_ETAT_FOR_LOOP_MAX
		
		# Sinon, on fait le contenue de la boucle for.
		# ---------- contenue du for loop du code C commence ici. ----------
		# Calculer l'offset dans les vecteurs sachant que chaque donnees = 4 bytes.
		# Pour sauver des calculs, i incremente deja de 4! Et est compare avec nombre_etat_for loop qui prend en compte cet offset.
		
		# --- Storing 250 in soutput. --- #
		li $t1, 250 			# Putting 250 into $t1 so it can be put as soutput[i] later.
		lw $t2, SOUTPUT_ADDRESS($sp)	# Loading the address of soutput into $t2 to reference it later.
		addu $t3, $t2, $t0		# Offsetting the address by i so we read soutput[i] instead of soutput[0]
		sw $t1, 0($t3)			# Put 250 at the ith address of soutput... (soutput[i = 250)
		
		# --- Setup pour appel de ACS --- #
		# On load toutes les variables a envoyer
		lw $t1, MET_ADDRESS($sp) 	# Loading Metrique address from the stack into $t1
		sll $t3, $t0, 2 		# Multiply by 4 i. Because we need to read the first values of the vectors within the 2D matrix and not the values of the first vector.
		addu $t2, $t1, $t3		# Offsetting the address so we read metrique[i*4] instead of metrique[0][0]
		move acs_METRIQUE_PARAM_REGISTER, $t2  # This puts the address position of the current subvector into $a0 (metrique[i])

		
		lw acs_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp) # Puts sinput into the sinput of acs (function input parameter)
		
		lw $t1, SOUTPUT_ADDRESS($sp)	 # Putting soutput into $t1 to later put into acs_SOUTPUT_PARAM_REGISTER
		addu $t2, $t1, $t0		 # Offsets the address of souput so we're not reading soutput[0] but soutput[i]
		move acs_SOUTPUT_PARAM_REGISTER, $t2 # Putting SOUTPUT_ADDRESS[i] into ACS input register.
		
		jal acs # Jumping to ACS. (executing the function)
		
		
		# --- Increase the count and go back to checking the condition --- #
		lw $t1, FOR_INDEX($sp)		# Putting the for loop index into $t1
		addi $t2, $t1, 4		# Putting for loop index + 4 into $t2
		sw $t2, FOR_INDEX($sp)		# Putting the result back into the for loop index.
		jal CS_Check_For_Condition 	# Jumping to check for loop condition.
		
	CS_For_End:
		# free up la stack que la fonction a prise.
		lw $ra, CalculSurvivants_RETURN_ADDRESS # loading CalculSurvivants return address.
		addi $sp, $sp, 20 # freeing the stack AFTER fetching the return address.
		jr $ra # returning CalculSurvivants 
	

# Parametres:
#	- $a0 = met 	(vecteur)
#	- $a1 = sinput	(vecteur
#	- $a2 = soutput
# En accordance avec le code d'origine, cet fonction fait "N" iterations (nombre d'etats)
# Dans ces iterations, soutput est mis a "temp" si met[j] + sinput[j] est plus petit que soutput. Sinon, il garde ca valeur.
# Cet comparaison est fait pour chaque etat (iterations).
# soutput devient donc de plus en plus petit a chaque iteration que si la comparaison est fruiteuse.
acs:
	# Pour eviter d'apprendre par coeur les nombres d'emplacement dans la stack.
	.eqv FOR_INDEX 0
	.eqv MET_ADDRESS 4
	.eqv SINPUT_ADDRESS 8
	.eqv SOUTPUT_ADDRESS 12
	.eqv ACS_RETURN_ADDRESS 16($sp)

	# --- Loading the input parameters --- #
	addi $sp, $sp, -20 					# Making place for ACS stack size.
	sw acs_METRIQUE_PARAM_REGISTER, MET_ADDRESS($sp)	# Extracting metrique matrix address param and putting it in the stack.
	sw acs_SINPUT_PARAM_REGISTER, SINPUT_ADDRESS($sp)	# Extracting sinput vector address and putting it in the stack.
	sw acs_SOUTPUT_PARAM_REGISTER, SOUTPUT_ADDRESS($sp)	# Extracting soutput vector address and putting it in the stack.
	sw $ra, ACS_RETURN_ADDRESS				# Saving return address for later
	
	# --- Initializing the for loop index --- #
	li $t0, 0		# Putting 0 into $t0
	sw $t0, FOR_INDEX($sp)	# Putting that 0 as the initial for loop index.
	
	ACS_Check_For_Condition:
		lw $t0, FOR_INDEX($sp)				# Loading the for loop index into $t0, so all other calls can use it.
		beq $t0, NOMBRE_ETAT_FOR_LOOP_MAX, Acs_For_End  # Checking if we need to return yet. ( i == NOMBRE_ETAT_FOR_LOOP_MAX )
		
		lw $t1, MET_ADDRESS($sp)    # loading metrique address into $t1
		addu $t2, $t1, $t0	    # Offset the address by i so we can read metrique[i]
		lw $t5, 0($t2)	            # Loaded metric[i] into $t5
				
		lw $t2, SINPUT_ADDRESS($sp) # loading sinput address into $t2
		addu $t3, $t2, $t0	    # Offset the address by i so we can read sinput[i]
		lw $t6, 0($t3)	            # $t6 = sinput[i]
								
		# --- Addition and comparison --- #
		addu $t1, $t5, $t6 	       # met[j] + sinput[j] into $t1; (temp = met[j] + sinput[j])
		lw $t3, SOUTPUT_ADDRESS($sp)   # Put the address of soutput into a register to use it in the next line
		lw $t4, 0($t3)                 # load soutput[i] into a register so we can compare it later.

		blt $t1, $t4, acs_is_less      # temp < soutput then branch to where soutput gets overwritten 
		# if we're here it's cuz it's not less than soutput!
		# Nothing changes..
		jal acs_end_of_check
		acs_is_less:
			# Woah, it is less! We gotta change the value of soutput!
			sw $t1, 0($t3) # soutput[i] = temp
		acs_end_of_check:
		
		
		# --- Increase the count and go back to checking the condition --- #
		lw $t1, FOR_INDEX($sp)		# Putting the for loop index into $t1
		addi $t2, $t1, 4		# Putting for loop index + 4 into $t2
		sw $t2, FOR_INDEX($sp)		# Putting the result back into the for loop index.
		jal ACS_Check_For_Condition 	# Jumping to check for loop condition.

	Acs_For_End:
		# free up la stack que la fonction a prise.
		lw $ra, ACS_RETURN_ADDRESS 	# loading CalculSurvivants return address.
		addi $sp, $sp, 20 		# freeing the stack AFTER fetching the return address.
		jr $ra 				# returning to whoever called it.
