/* Modelisation de l'exercice 1 du TD 2
Par Benjamin Dutriaux et John Chen */


# Déclaration des données du problème

 param maxIndex;
 set S := 1..maxIndex; # index 

 set ind; # index
 
 set Sind within S cross ind; # double-indice 
        


 param obj{ind}; # Vecteur des coefficients de la fonction objectif 

 param coeffcontr{(i,j) in Sind}; # Matrice des coefficients définissant les membres de gauche des contraintes (double-indice)

 param mdroite{S}; # Vecteur des membres de droite des contraintes 


# Déclaration d'un tableau de variables binaires
 
 var x{ind} binary; 

# Fonction objectif

 maximize z : sum{j in ind} obj[j]*x[j];

# Contraintes

 s.t. y{i in S} : sum{(i,j) in Sind} coeffcontr[i,j] * x[j] >= mdroite[i]; 

# Résolution (qui est ajoutée en fin de fichier si on ne le précise pas)

 solve;

# Affichage des résultats

 display : x; # affichage "standard" des variables
 display{j in ind : x[j] = 1} : j; # affichage plus lisible  
 display : "objectif : ", sum{j in ind} obj[j]*x[j];

# données numériques dont le début est indiqué par le mot-clé "data;"

data;

 param maxIndex := 11;
 
 set ind := 1 2 3 4 5 6 7 8 9;

 set Sind := (1,1) (1,5) (2,2) (2,5) (3,3) (3,5) (4,3) (4,4) (5,2) (5,7) (6,5) (6,7) (7,5) (7,4) (8,6) (8,7) (9,6) (9,8) (10,8)
                (10,4) (11,5) (11,9);


        param obj := 1 1 2 3 3 7 4 3 5 12 6 4 7 9 8 4 9 3; 

 param coeffcontr := [1,1] 1 [1,5] 1 [2,2] 1 [2,5] 1 [3,3] 1 [3,5] 1 [4,3] 1 [4,4] 1 [5,2] 1 
      [5,7] 1 [6,5] 1 [6,7] 1 [7,5] 1 [7,4] 1 [8,6] 1 [8,7] 1 [9,6] 1 [9,8] 1 [10,8] 1
                     [10,4] 1 [11,5] 1 [11,9] 1;

 param mdroite := 1  1
                  2  1
                  3  1
                  4  1
                  5  1
                  6  1
                  7  1
                  8  1
                  9  1
                  10 1
                         11 1;
 
# Fin

end;