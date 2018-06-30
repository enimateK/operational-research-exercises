/* Modelisation de l'exercice 4 partie 1 du TD 1
Par Benjamin Dutriaux et John Chen */

    param tailleC; # nombre de créneaux
	set C := 0..tailleC; # ensemble des indices des créneaux (0 à 11)

	param mdroite{C}; # coefficients des membres de droite

# Déclaration de variables non-négatives sous la forme
# d'un tableau de variables indicées sur les créneaux
	
	var x{C} >= 0 integer; # Nombre d'infirmières commençant

# Fonction objectif

	minimize Infirmieres : sum{j in C} x[j];

# Contraintes

	# Nombre d'infirmières par créneaux
		s.t. nbInfirmieres{i in C} :  x[(i)mod 12] + x[(i-1)mod 12] + x[(i-3)mod 12] +x[(i-4)mod 12] >=  mdroite[i];
	

# Résolution
	solve;

# Affichage des résultats

	display : x;	# affichage des infirmieres par créneaux
	display : 'z=',  sum{j in C} x[j] ; # affichage de la valeur optimale (100 infirmières)
	
data;

	#Nombre de créneaux (-1 car on compte le 0)

		param tailleC := 11;

	#Nombre d'infirmières requis par créneaux
	                
		param mdroite :=  	0 35 
					1 40 
					2 40 
					3 35 
					4 30 
					5 30 
					6 35 
					7 30 
					8 20 
					9 15 
					10 15
					11 15;
	            
	
end;
