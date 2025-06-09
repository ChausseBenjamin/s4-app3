# Plan de vérification formatif

Le but de cette activité est de valider vos choix d'instructions et de vous offrir une rétroaction rapide avant la
rédaction du code VHDL. Dans votre document de maximum 3 pages, présentez brièvement les instructions
SIMD que vous aurez choisies (vous pouvez renvoyer aux annexes) et votre plan de vérification vis-à-vis de
ces instructions. À ce niveau, imaginez au moins un test par instruction qui tente de prouver qu'il existe une
erreur dans le futur code VHDL de vos collègues. C'est plus efficace de prendre le point de vue de l'avocat
du diable...

Votre plan sera évalué sommativement à la validation.
Remettez votre plan de validation en format PDF avant le mardi 10 Juin 2025, 17h00. Le nom du fichier
doit suivre le format cip1-cip2.pdf où cip1 et cip2 sont les CIP de chaque étudiant de l'équipe. Il ne faut
pas oublier d'insérer le tiret entre les deux CIP. Le système n'acceptera pas le dépôt si le CIP de l'usager
effectuant le dépôt n'est pas indiqué dans le nom du fichier.

Instructions:
- lwv
- swv
- addv
- multv

Trucs à mettre dedans:
- présentez brièvement les instructions choisies
- plan de vérification vis-à-vis de ces instructions

Test normal
Test avec données négatives
test avec données overflow
Tests avec registres plus gros que 4.


Les instructions choisis sont en fonction du fait que l'on veut implémenter des instructions SIMD (ou vectorielles) dans notre architecture MIPS afin d'améliorer
la vitesse du programme. Ceci fait du sense puisqu'une analyze vite fait du programme initiale fournie démontre la redondance multiple de vecteurs de 4 éléments.
En utilisant de tel instructions, il ne sera plus nécessaire de faire 2 boucles pour les calculs et qu'une seule vas suffir. À cause de la gestion des opérations en blocs de 4 valeurs de 32 bits, les instructions choisis n'ont pas de sous-ensembles permettent d'autres tailles de vecteurs que 4.

Suite à l'analyse du code, 3 des opérations de l'annexe du guide étudiant ont été identifié comme utile. Soit `lw` (load word vector) qui permet de charger 4 valeurs consécutives de la mémoire vers un vecteur de taille 4, `swv` (store word vector) qui permet de stocker un vecteur de 4 mots consécutifs en mémoire et `addv` (add vectors) qui permet de faire l'addition de chacun des mots des 2 vecteurs ensemble (soit position 0 A avec position 0 B, etc). Ces derniers sont tous des opérations arithmétiques vu dans le code c fournis. Cependant, une quatrième opérations, laquel n'est pas dans l'annexe est nécessaire. C'est `multv`, qui permet la même chose que `addv` mais une multiplication au lieu d'addition. Notez que tous ces instructions ne spécifie pas de signe et donc ils sont signés.

