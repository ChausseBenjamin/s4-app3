# Remise du rapport

## Rapport

Le rapport d'APP est à remettre le vendredi 13 Juin 2025, 17h00. Il doit être remis par binôme (équipe de
2) et contient deux parties :

1. Un document manuscrit (PDF) et
2. trois fichiers de code (voir en 4.3.2). Les deux parties seront évaluées selon la grille de la table 5.2.


### Document manuscrit
Le rapport manuscrit doit répondre aux questions posées par l'énoncé de la problématique : relire la pro-
blématique. Plusieurs indications et indices y sont écrits et beaucoup moins mystérieux à ce stade qu'au
premier tutorat. En complément au texte de la problématique, les quelques précisions ci-bas.

Chacun des éléments doit être accompagné d'une description adéquate pour en faciliter la compréhension
et pour justifier vos calculs ou choix de conception. Le rapport doit suivre le guide de rédaction remis en
S1 et vous avez jusqu'à 8 pages pour le contenu. Ces 8 pages excluent la page titre, la table des matières,
l'introduction, la conclusion et les références. Votre rapport doit être en format PDF, et le nom du fichier
doit suivre le format cip1-cip2.pdf o`u cip1 et cip2 sont les CIP de chaque étudiant de l'équipe.

#### Performances d'organisations

A l'aide du code de référence de calcul matriciel, documentez sous
forme d'équations algébriques et calculez son temps d'exécution en cycles d'horloge pour l'organisation
unicycle. De même, identifiez et calculez toutes les pénalités causées par deux organisation en pipeline
(procédural 4), soit l'organisation avec branchement au 4e étage (COD5 figure 4.51) et l'organisation
avec branchement au 2e étage, unité d'avancement et unité de détection des aléas (COD5 figure 4.65).
Enfin, calculez le temps d'exécution en vous basant sur les vitesses d'opération des organisations
suivantes :

- 25 ns pour l'organisation unicycle.
- 10 ns pour l'organisation pipeline.

#### Performances SIMD

Dans le code de référence, identifiez les instructions qui seraient à convertir en
SIMD, puis calculez le nouveau temps d'exécution en cycles d'horloge, pour enfin le comparer avec
celui en unicycle. Est-ce que le gain de performance permet d'anticiper qu'il est possible d'atteindre
les objectifs de la problématique ?

#### Performances des mémoires sur processeur unicycle

`A l'aide du code de référence de calcul matriciel
sans SIMD, et en vous basant sur une organisation unicycle, calculez le nombre de coups d'horloge
supplémentaires due aux données pour le cas de la DRAM de la problématique, et ensuite pour le
cas d'une cache de données attachée à cette DRAM utilisant 256 blocs, 2 mots de 32-bits par bloc et
l'écriture à la DRAM en write-through. Documentez votre calcul sous forme d'équations algébriques
avant de produire le résultat numérique. Notez que cet exercice est possible avec la version en C du
code.

#### Configuration des caches

Définissez et <ul>justifiez</ul> votre choix pour la configuration de la cache de
données minimisant à la fois sa taille et les pénalités d'accès aux données
(en coups d'horloge).

#### Integration

En partant cette fois d'une organisation unicycle avec mémoire DRAM (comme celui
utilisé au labo 2), proposez un système optimal et priorisez les modifications par leurs gains effectifs
sur la performance et leur temps de développement pressenti. (ex : extensions SIMD, restructuration
du code assembleur, etc.). Choisir et justifier un changement à laisser tomber si le calendrier de
développement devait être devancé (temps limité).


# Codes assembleur de la problématique

Suite à la rétroaction du devoir, corrigez au besoin votre code assembleur Viterbi. Dérivez de ce code une
nouvelle version exploitant les instructions SIMD que vous avez choisies d'implémenter et documentées dans
votre plan de vérification formatif. Remettez également la version SIMD du code de référence. Ces trois
codes sont considérés comme faisant partie du rapport. Vous devez donc les remettre dans la boite de dépˆot
Moodle prévue. Le nom des fichiers doit être :

- cip1-cip2.viterbi.asm
- cip1-cip2.viterbi.simd.asm
- cip1-cip2.reference.simd.asm
