// TP3 Exercice 4 du TD 2 par John CHEN et Benjamin DUTRIAUX

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glpk.h> 

/* Structure contenant les donn�es du probl�me */

typedef struct {
	int nbvar; // Nombre de variables
	int nbcontr; // Nombre de contraintes
	int *couts; // Tableau des couts
	int **contr; // Matrice des contraintes
	int *sizeContr; // Tableau des nombres de variables dans chacune des contraintes
	int *droite; // Tableau des valeurs des membres de droites des contraintes
} donnees;


/* lecture des donnees */

void lecture_data(char *file, donnees *p)
{

	FILE *fin; // Pointeur sur un fichier
	int i,j;
	int val;
    int contraintes, mbdroite;

	fin = fopen(file,"r"); // Ouverture du fichier en lecture

	/* Premi�re ligne du fichier, on lit le nombre de variables et le nombre de contraintes */

	fscanf(fin,"%d",&val);
	p->nbvar = val * val;
	p->nbcontr = val * 2;

	/* On peut maintenant faire les allocations dynamiques d�pendant du nombre de variables et du nombre de contraintes */

	p->couts = (int *) malloc (p->nbvar * sizeof(int));
	p->droite = (int *) malloc (p->nbcontr * sizeof(int));
	p->sizeContr = (int *) malloc (p->nbcontr * sizeof(int));
	p->contr = (int **) malloc (p->nbcontr * sizeof(int *));

	/* Deuxi�me ligne du fichier, on lit les coefficients de la fonction objectif */

	for(i = 0;i < p->nbvar;i++)
	{
		fscanf(fin,"%d",&val);
		p->couts[i] = val;
	}

	// R�cup�ration des membres des contraintes
    fscanf(fin,"%d",&val);
	contraintes = val;
	// R�cup�ration des membres de droite
    fscanf(fin,"%d",&val);
	mbdroite = val;

	for(i = 0;i < p->nbcontr;i++) // Pour chaque contrainte,
	{

		p->sizeContr[i] = contraintes;
		p->contr[i] = (int *) malloc (p->sizeContr[i] * sizeof(int));
		// Lecture des indice des variables intervenant dans la contrainte
		for(j = 0;j < p->sizeContr[i];j++)
		{
			fscanf(fin,"%d",&val);
			p->contr[i][j] = val;
		}
		p->droite[i] = mbdroite;
	}

	fclose(fin); // Fermeture du fichier
}


int main(int argc, char *argv[])
{
	/* Donn�es du probl�me */

	donnees p;

	/* structures de donn�es propres � GLPK */

	glp_prob *prob; // d�claration d'un pointeur sur le probl�me
	int *ia;
	int *ja;
	double *ar; // d�claration des 3 tableaux servant � d�finir la matrice "creuse" des contraintes

	/* Les d�clarations suivantes sont optionnelles, leur but est de donner des noms aux variables et aux contraintes.
	   Cela permet de lire plus facilement le mod�le saisi si on en demande un affichage � GLPK, ce qui est souvent utile pour d�tecter une erreur! */

	char **nomcontr;
	char **numero;
	char **nomvar;

    /* variables recuperant les resultats de la resolution du probleme (fonction objectif et valeur des variables) */

	double z;
	double *x;

	/* autres d�clarations */ 

	int i,j;
	int nbcreux; // nombre d'elements de la matrice creuse
	int pos; // compteur utilise dans le remplissage de la matrice creuse

	/* Chargement des donn�es � partir d'un fichier */

	lecture_data(argv[1],&p);

	/* Transfert de ces donn�es dans les structures utilis�es par la biblioth�que GLPK */

	prob = glp_create_prob(); /* allocation m�moire pour le probl�me */ 
	glp_set_prob_name(prob, "exo4");  /* affectation d'un nom */
	glp_set_obj_dir(prob, GLP_MAX); /* Il s'agit d'un probl�me de maximisation */

	/* D�claration du nombre de contraintes (nombre de lignes de la matrice des contraintes) : p.nbcontr */

	glp_add_rows(prob, p.nbcontr);
	nomcontr = (char **) malloc (p.nbcontr * sizeof(char *));
	numero = (char **) malloc (p.nbcontr * sizeof(char *));

	/* On commence par pr�ciser les bornes sur les constrainte, les indices commencent � 1 (!) dans GLPK */

	for(i=1;i<=p.nbcontr;i++)
	{
		/* partie optionnelle : donner un nom aux contraintes */
		nomcontr[i - 1] = (char *) malloc (8 * sizeof(char)); 
		numero[i - 1] = (char *) malloc (3  * sizeof(char));
		strcpy(nomcontr[i-1], "contrainte");
		sprintf(numero[i-1], "%d", i);
		strcat(nomcontr[i-1], numero[i-1]); /* Les contraintes sont nomm�s "contrainte1", "contrainte2"... */	
		glp_set_row_name(prob, i, nomcontr[i-1]);

		/* partie indispensable : les bornes sur les contraintes */
		glp_set_row_bnds(prob, i, GLP_FX, p.droite[i-1], 0.0);
		/* Avec GLPK, on peut d�finir simultan�ment deux contraintes, si par exemple, on a pour une contrainte i : "\sum x_i >= 0" et "\sum x_i <= 5",
		   on �crit alors : glp_set_row_bnds(prob, i, GLP_DB, 0.0, 5.0); la constante GLP_DB signifie qu'il y a deux bornes sur "\sum x_i" qui sont ensuite donn�es
		   Ici, nous n'avons qu'une seule contrainte du type "\sum x_i >= p.droite[i-1]" soit une borne inf�rieure sur "\sum x_i", on �crit donc glp_set_row_bnds(prob, i, GLP_LO, p.droite[i-1], 0.0); le param�tre "0.0" est ignor�. 
		   Les autres constantes sont GLP_UP (borne sup�rieure sur le membre de gauche de la contrainte) et GLP_FX (contrainte d'�galit�).   
		 Remarque : les membres de gauches des contraintes "\sum x_i ne sont pas encore saisis, les variables n'�tant pas encore d�clar�es dans GLPK */ 
	}

	/* D�claration du nombre de variables : p.nbvar */

	glp_add_cols(prob, p.nbvar);
	nomvar = (char **) malloc (p.nbvar * sizeof(char *));

	/* On pr�cise le type des variables, les indices commencent � 1 �galement pour les variables! */

	for(i=1;i<=p.nbvar;i++)
	{
		/* partie optionnelle : donner un nom aux variables */
		nomvar[i - 1] = (char *) malloc (3 * sizeof(char));
		sprintf(nomvar[i-1],"x%d",'B'+i-1);
		glp_set_col_name(prob, i , nomvar[i-1]); /* Les variables sont nomm�es "xA", "xB"... afin de respecter les noms de variables de l'exercice 2.4 */

		/* partie obligatoire : bornes �ventuelles sur les variables, et type */
		glp_set_col_bnds(prob, i, GLP_DB, 0.0, 1.0); /* bornes sur les variables, comme sur les contraintes */
		glp_set_col_kind(prob, i, GLP_BV); /* les variables sont par d�faut continues, nous pr�cisons ici qu'elles sont binaires avec la constante GLP_BV, on utiliserait GLP_IV pour des variables enti�res */
	}

	/* d�finition des coefficients des variables dans la fonction objectif */

	for(i = 1;i <= p.nbvar;i++) glp_set_obj_coef(prob,i,p.couts[i - i]);

	/* D�finition des coefficients non-nuls dans la matrice des contraintes, autrement dit les coefficients de la matrice creuse */
	/* Les indices commencent �galement � 1 ! */

	nbcreux = 0;
	for(i = 0;i < p.nbcontr;i++) nbcreux += p.sizeContr[i];

	ia = (int *) malloc ((1 + nbcreux) * sizeof(int));
	ja = (int *) malloc ((1 + nbcreux) * sizeof(int));
	ar = (double *) malloc ((1 + nbcreux) * sizeof(double));

	pos = 1;
	for(i = 0;i < p.nbcontr;i++)
	{
		for(j = 0;j < p.sizeContr[i];j++)
		{
			ia[pos] = i + 1;
			ja[pos] = p.contr[i][j];
			ar[pos] = 1.0;
			pos++;
		}
	}

    /* chargement de la matrice dans le probl�me */
	
	glp_load_matrix(prob,nbcreux,ia,ja,ar);

	/* Optionnel : �criture de la mod�lisation dans un fichier (utile pour debugger) */
	
	glp_write_lp(prob,NULL,"exo4.lp");

	/* R�solution, puis lecture des r�sultats */

	glp_simplex(prob,NULL);	glp_intopt(prob,NULL); /* R�solution */
	z = glp_mip_obj_val(prob); /* R�cup�ration de la valeur optimale. Dans le cas d'un probl�me en variables continues, l'appel est diff�rent : z = glp_get_obj_val(prob);*/
	x = (double *) malloc (p.nbvar * sizeof(double));
	for(i = 0;i < p.nbvar; i++) x[i] = glp_mip_col_val(prob,i+1); /* R�cup�ration de la valeur des variables, Appel diff�rent dans le cas d'un probl�me en variables continues : for(i = 0;i < p.nbvar;i++) x[i] = glp_get_col_prim(prob,i+1);	*/

	printf("z = %lf\n",z);
	for(i = 0;i < p.nbvar;i++) printf("x%c = %d, ",'B'+i,(int)(x[i] + 0.5)); /* un cast est ajoute, x[i] pourrait �tre egal à 0.99999... */
	puts("");

	/* lib�ration m�moire */
	glp_delete_prob(prob);
	free(p.couts);
	free(p.sizeContr);
	free(p.droite);
	for(i = 0;i < p.nbcontr;i++) free(p.contr[i]);
	free(p.contr);

	/* J'adore qu'un plan se d�roule sans accroc! */
	return 0;
}
