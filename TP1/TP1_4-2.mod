/* Modelisation de l'exercice 4 partie 2 du TD 1
Par Benjamin Dutriaux et John Chen */

    param tailleC; # nombre de créneaux
	set C := 0..tailleC; # ensemble des indices des créneaux (0 à 11)

	param mdroite{C}; # coefficients des membres de droite

# Déclaration de variables non-négatives sous la forme
# d'un tableau de variables indicées sur les créneaux
	
	var xn{C} >= 0 integer; # Nombre d'infirmières commençant sans heures sup
    var xs{C} >= 0 integer; # Nombre d'infirmières commençant avec heures sup


# Fonction objectif

	minimize HeuresSup : sum{j in C} xs[j];

# Contraintes

	# Nombre d'infirmières par créneaux
	s.t. nbInfirmieres{i in C} :  xn[(i)mod 12]+ xs[(i)mod 12]+ xn[(i-1)mod 12] + xs[(i-1)mod 12]+ xn[(i-3)mod 12] + xs[(i-3)mod 12] +xn[(i-4)mod 12] +xs[(i-4)mod 12]+xs[(i-5)mod 12] >=  mdroite[i];
    
	# Indique que l'on souhaite moins de 80 infimières
	s.t. Moins80 : sum{i in C}xn[i]+ sum{j in C}xs[j]  <= 80;

	

# Résolution 
	solve;

# Affichage des résultats

	display : xn;	# affichage des infirmieres sans heure sup par créneaux
    display : xs;	# affichage des infirmieres avec heure sup par créneaux
	display : 'Infirmieres sans heures sup', sum{j in C} xn[j]; # Infirmières sans heures sup
	display : 'z=', sum{j in C} xs[j]; # affichage de la valeur optimale (40 infirmières avec heures sup)
	
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
