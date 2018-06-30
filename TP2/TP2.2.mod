/* Modelisation de l'exercice 6 du TD 2
Par Benjamin Dutriaux et John Chen */

	param m; # nb indices lignes
    param n; # nb indices colonnes
	
	
	set indRow:= 1..m; # indices lignes
    set indCol:= 1..n; # indices colonnes
	
	set Demande := 1..n; # indices demandes
    param Dem{Demande}; # tableau demandes
	
	set Ouverture:= 1..m; # indices ouvertures entrepots
    param Ouv{Ouverture}; # tableau ouverture entrepots (obj)
	
	set Capacite := 1..m; # indices des capacites
    param Cap{Capacite}; # tableau capacite
	
    param Transport{indCol,indRow}; # tableau cout de transport
    
    
    set indY := 1..m; # Ensemble pour la variable de d?cision y
	param mdroite{indCol}; # Coefficients de droite des contraintes
	
# Variables 
    var Construit{indY} binary; # tableau binaire, 1 si l'entrepot est ouvert 0 sinon
    var Livraison{indCol,indRow} >= 0 ; # pourcentage
    
# Fonction objectif
	minimize objcout : sum{j in indRow} Ouv[j]*Construit[j] + sum {i in indCol} sum {z in indRow} Transport[i,z]*Livraison[i,z]; # minimisation du cout
    
s.t. C1 {j in indRow}: sum { i in indCol} Dem[i]*Livraison[i,j] <= Construit[j]*Cap[j];  # livraison = demande
s.t. C2{i in indCol} : sum {j in indRow} Livraison[i,j]==mdroite[i]; 
s.t. C3 {j in indRow, i in indCol}: Livraison[i,j]<= 1; # livraison entre 0 et 1

solve;

# Affichage des résultats

	display : "Entrepots ouverts :", Construit;# affichage des variables
	display : "objectif : ", sum{j in indRow} Ouv[j]*Construit[j] + sum {i in indCol} sum {z in indRow} Transport[i,z]*Livraison[i,z]; # resultat fonction obj

	
	data;

param m := 12;
param n := 12;                                      
param mdroite default 1;
param Cap:=1 300 2 250 3 100 4 180 5 275 6 300 7 200 8 220 9 270 10 250 11 230 12 180;
param Dem := 1 120 2 80 3 75 4 100 5 110 6 100 7 90 8 60 9 30 10 150 11 95 12 120;
param Ouv:=1 3500 2 9000 3 10000 4 4000 5 3000 6 9000 7 9000 8 3000 9 4000 10 10000 11 9000 12 3500;
# nous avons mis 99999 a la place d'infini car nous ne savions pas comment faire
param Transport : 1  2  3  4  5  6  7  8  9  10  11 12 :=
                1 100 80 50 50 60 100 120 90 60 70 65 110
                2 120 90 60 70 65 110 140 110 80 80 75 130
                3 140 110 80 80 75 130 160 125 100 100 80 150
                4 160 125 100 100 80 150 190 150 130 99999 99999 99999
                5 190 150 130 99999 99999 99999 200 180 150 99999 99999 99999
                6 200 180 150 99999 99999 99999 100 80 50 50 60 100
                7 100 80 50 50 60 100 120 90 60 70 65 110
                8 120 90 60 70 65 110 140 110 80 80 75 130 
                9 140 110 80 80 75 130 160 125 100 100 80 150
                10 160 125 100 100 80 150 190 150 130 99999 99999 99999
                11 190 150 130 99999 99999 99999 200 180 150 99999 99999 99999
                12 200 180 150 99999 99999 99999 100 80 50 50 60 100;
               
end;