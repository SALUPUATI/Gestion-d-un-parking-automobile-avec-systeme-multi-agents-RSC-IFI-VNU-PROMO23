/**
* Name: model1
* Author: emman
* Description: Describe here the model and its experiments
* Tags: Tag1, Tag2, TagN
*/

model model1

global {
	/** Insert the global definitions, variables and actions here */
	file shape_file_parking <- file("../includes/Surface_Parking.shp");
	file shape_file_entree_voiture <- file("../includes/Entree1.shp");
	file shape_file_entree_camion <- file("../includes/Entree2.shp");
	file shape_file_sortie_voiture <- file("../includes/Sortie1.shp");
	file shape_file_Sortie_camion <- file("../includes/Sortie2.shp");
	file shape_file_chemin_voiture <- file("../includes/Ligne_Voiture.shp");
	file shape_file_chemin_camion <- file("../includes/Ligne_Camion.shp");
	file shape_file_place_voiture <- file("../includes/Stationnement_Voiture.shp");
	file shape_file_place_camion <- file("../includes/Stationnement_Camion.shp");
	
	geometry shape <- envelope(shape_file_parking);
	
	float temps_stationnement <-  50; // ceci est le temps de stationnement dans le parking
	float speed_min <- 0.1 #km/#h;
	float speed_max <- 3.0 #km/#h;
	float step <- 15 #mn;
	int prixVoiture <- 0;
	int prixCamion <- 0;
	int nbrVoiture <- 10;
	int nbrCamion <- 5;
	
	graph route_graph;
	graph voiture_graph;
	graph camion_graph;
	
	init{
		create route from: shape_file_parking;
		route_graph <- as_edge_graph(route);
		create ligne1 from: shape_file_chemin_voiture;
		create ligne2 from: shape_file_chemin_camion;
		
		voiture_graph <- as_edge_graph(ligne1);
		create depart from: shape_file_entree_voiture;
		create stationnement1 from: shape_file_place_voiture;
		create sortie1 from: shape_file_sortie_voiture;
	
		
		camion_graph <- as_edge_graph(ligne2);
		create depart from: shape_file_entree_voiture;
		create stationnement2 from: shape_file_place_camion;
		create sortie2 from: shape_file_Sortie_camion;
		
		
	}
	
	reflex creation_camion when: every(10){
		create camion number: nbrCamion{
			
			speed <- rnd(speed_max - speed_min);
			location <- one_of(depart);
			but <- point(one_of(stationnement2));
			
		}
		create voiture number: nbrVoiture{
			
			speed <- rnd(speed_max - speed_min);
			location <- one_of(depart);
			but <- point(one_of(stationnement1));
		}
	}
	
}
species route{
	rgb color <- #white;
	aspect basic{ draw shape color: color;}
}
species ligne1{
	rgb color <- #brown;
	aspect basic{draw shape color: color;}
}
species ligne2{
	rgb color <- #yellow;
	aspect basic{draw shape color: color;}
}
species depart{
	
	rgb color <- #gray;
	aspect basic{draw circle(70) color: color;}
}
species sortie1{
	
	rgb color <- #brown;
	aspect basic{draw rectangle(60#m, 50#m) color: color;}
}
species stationnement1{
	rgb color <- #orange;
	aspect basic{draw rectangle(60#m, 50#m) color: color;} 
}
species sortie2{
	
	rgb color <- #brown;
	aspect basic{draw rectangle(75#m, 60#m) color: color;}
}
species stationnement2{
	rgb color <- #orange;
	aspect basic{draw rectangle(70#m, 60#m) color: color;} 
}
species camion skills: [driving]{
	
	rgb color <- #blue;
	point but <- nil;
	float current_speed <- nil;
	int chrono2 <- 1;
	point sortie_camnion<-{709,265};
	
	
	
	reflex time_to_go{	
		do goto target:but;
		if(location=but){
			but<-nil;
		}
	}
	
	reflex go_out when:but=nil{
	 do action:goto target:sortie_camnion;
	 if(cycle=500)
	 {
	 	do action:die;
	 } 
	}
	
	reflex on_stop_camion{

		stationnement2 arret <- stationnement2 with_min_of(each distance_to self);
		float espace <- arret distance_to self;
		
		ask arret{ 
			if((espace/50) <= 1){
				
				myself.speed <- 0.0;
				
				myself.current_speed <- rnd(speed_max - speed_min);
				
				if(myself.speed=0){
					
					myself.chrono2 <- myself.chrono2 + 1;
				}
				if(myself.chrono2 = temps_stationnement){
						
					myself.speed <- myself.current_speed;
					
			}
		}
	}
}
	
	aspect basic{draw circle(30) color: color;}
}
species voiture skills: [driving]{
	
	rgb color <- #red;	
	int chrono1 <- 1;
	point but <- nil;
	float current_speed <- nil;
	point sortie_voiture<-{641,91};
	
	reflex time_to_go{	
		do goto target:but;
		if(location=but){
			but<-nil;
		}
	}
	
	reflex go_out when:but=nil{
	 do action:goto target:sortie_voiture;
	 if(cycle=500)
	 {
	 	do action:die;
	 } 
	}

	reflex on_stop_voiture{

		stationnement1 arret <- stationnement1 with_min_of(each distance_to self);
		float espace <- arret distance_to self;
		
		ask arret{
			if((espace/50) <= 1){
				
				myself.speed <- 0.0;
				
				myself.current_speed <- rnd(speed_max - speed_min);
				
				if(myself.speed=0){
					
					myself.chrono1 <- myself.chrono1 + 1;
				}
				if(myself.chrono1 = temps_stationnement){
						
					myself.speed <- myself.current_speed;
					
			}
		}
	}
	
	}
	aspect basic{
		
		draw circle(20) color: color;
	}
}

experiment model1 type: gui {
	/** Insert here the definition of the input and output of the model */
	 parameter "Nombre des Agents Camions:" var:nbrCamion category: "Camions";
	 parameter "Nombre des Agents Voitures:" var:nbrVoiture category: "Voitures"; 
	
	output {
		display model1_display type:opengl{
			species route aspect:basic;
			species ligne1 aspect:basic;
			species ligne2 aspect:basic;
			species depart aspect:basic;
			species sortie1 aspect:basic;
			species sortie2 aspect:basic;
			species camion aspect:basic;
			species voiture aspect:basic;
			species stationnement1 aspect:basic;
			species stationnement2 aspect:basic;
		
	}
}

}
