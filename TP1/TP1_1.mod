/* Modelisation de l'exercice 1 du TD 1
Par Benjamin Dutriaux et John Chen */

    param tailleC; # nombre de Casquettes
	set C := 1..tailleC; # ensemble des indices des Casquettes

	param tailleH; # Heures disponibles
	set H := 1..tailleH; # ensemble des indices des Heures disponibles

	param obj{C}; # coefficients de la fonction objectif
	param coeffcontr{H,C}; # coefficients des membres de gauche des contraintes (durée des opérations)
	param mdroite{H}; # coefficients des membres de droite (heures)

# Déclaration de variables non-négatives sous la forme
# d'un tableau de variables indicées sur les médicaments
	
	var x{C} >= 0;

# Fonction objectif

	maximize profit : sum{j in C} obj[j]*x[j];

# Contraintes

	# Temps par type de casquette
	s.t. Atelier {i in H} : sum{j in C} coeffcontr[i,j]*x[j] <= mdroite[i];

# Résolution (qui est ajoutée en fin de fichier si on ne le précise pas)
	solve;

# Affichage des résultats
	display : x;	# affichage du nombre de casquettes à créer par type
	display : 'z=', sum{j in C} obj[j]*x[j]; # affichage de la valeur optimale (profit)

data;

	param tailleC := 2;

	param tailleH := 2;

	param obj := 1 12 2 20;

	param coeffcontr : 1  2   :=
	                 1 0.2 0.4
	                 2 0.2 0.6;
	                 
	param mdroite := 1 400
	                 2 800;
	            
	
end;
