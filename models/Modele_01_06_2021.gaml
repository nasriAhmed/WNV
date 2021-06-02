/**
* Name: Modele01062021
* Based on the internal empty template. 
* Author: MSI_Nasri
* Tags: 
*/

model FianlModel_Part1

global{
	int nb_birds_init <- 100;
	int nb_birds_sain<-0 update:true;
    int nb_birds_infected <- 1 update: birds count (each.is_infected);
    int nb_birds_not_infected <- nb_birds_total - nb_birds_infected update: nb_birds_total - nb_birds_infected;
    float infected_rate update: nb_birds_infected/nb_birds_total;
    int nb_birds_region<- birds count each.my_cell;
   	//bool is_infected <- false;
    int nb_birds_total <-nb_birds_init ;
    
    //Parameters birds
	float bird_speed_min <- 1#km / #h;
	float bird_speed_max <- 10 #km / #h;
	point BirdDirection;
	float speed;
	int nbBirdPropo<-0;	
	int nbBirdMigrattion<-0;
	point posRegional<-nil ;
	
	 //Parameters Environement
	graph the_graph;		
	float step <- 10 #mn;
	int regional_time <- 4 ;
	int migration_time <- 2 ;
	date starting_date <- date("2021-06-01-00-00-00");	
	//int charge_time <- 30;
	float alpha<-0.1;  
	 //mosquitoes
	int nb_mosquitoes<-24;
	//int nb_mosquitoes_infecte<-0 update:true;
	int nb_mosquitoes_sain<-0 update:true;
	int infectMos_time <- 2 ;
	float Mostique<-10.0;
	float MostiqueI<-1.0;
	
	float t <- step;
	float r<-0.1;
	float k<- 200;
  

			//Initialisation d'Envireonement
	file provinces_shp_file <- file("../includes/TUN_adm/TUN_adm1.shp");
    geometry shape <- envelope(provinces_shp_file);


	init{
			//Intialition Region 
	create Region from: provinces_shp_file;
    list<Region> residential_region <- list<Region>(Region);
	the_graph <- as_edge_graph(Region);

			//Intialition Birds 
	create birds number: nb_birds_total{
	location <- any_location_in(one_of(residential_region));
	is_infected <- false;
	speed<-rnd(bird_speed_min,bird_speed_max);
	
	}
	}
			
		//Random Region 
	/*Region Reg;	
		reflex BirdsInfected when: every(infectMos_time #month) { 
		Reg<-first(Region(any_location_in((shape))));
		return Reg;	
		}		*/	
	
}
	//Espace Birds
species birds skills:[moving]{     
	int id;
	rgb color <- #green ;
    bool is_infected <- false;
    Region regionOiseau;
   	Region my_cell <- one_of(Region);
    //Region k_Maxx<-self.my_cell.k_max;
	point posLocal<-self.location;
	float k_max<-10.0;

    	 //IntraRegionalMouvement// Random movement local of birds       
    	reflex IntraRegionalMouvement{ 
    	  do wander ;//aléatoire
    	    speed<-rnd(bird_speed_min,bird_speed_max); //#km/#h;
    	    posLocal <- any_location_in(shape);
    	    BirdDirection<- point(rnd(1,180));	
    	    do goto(target: posLocal, on:the_graph, speed:speed);  
		}
    		
		//InetrRegionalMouvement
		reflex InetrRegionalMouvement when: every(regional_time #month){
	    nbBirdPropo <- rnd(nb_birds_total);
		//int nbBirdRegion<-nbBirdPropo update: birds count (self.my_cell.idRegion);
    	   // write(nbBirdRegion);
	    do goto(target:my_cell.location,on: shape);
	      	
		}
		//Migration 
		/*reflex migration_in when: every(3 #month){
			nbBirdMigrattion <- rnd(nb_birds_init);		
			do create;
    	    nb_birds_total<-nb_birds_init + nbBirdMigrattion;
      	    return nb_birds_total;	
    	
    	   
		}
		action create{
			create species(self) number: nbBirdMigrattion {
            location <- my_cell.location;
		}
		}
		reflex migration_out when: every(8 #month){		
			nbBirdMigrattion <- rnd(nb_birds_init);
			do delete;
    	    nb_birds_total<-nb_birds_total - nbBirdMigrattion;
    	   
    	    return nb_birds_total;	
		}
		action delete{
			ask birds {
			  do die;
			}
		}*/
	
		
		//Infected Birds	
		reflex bird_infected when:every(infectMos_time #days ) {
			if(is_infected = false){
				ask Region{
					int Moss<-rnd(k_max);
						if(Moss<MostiqueI){	
							write('ici');
								myself.is_infected <- true;
						}
			    }
			}
		}
			aspect base {
		    draw circle(20) color:is_infected ? #red : #green;
			} 
			
			  	    	   
}
		//espace region
species Region {
	int idRegion<- shape['ID_1'];
	rgb mycolor<-#grey;	
	int cnt <-0;
	//int Mostiquee;
	float k_max<-10.0;//le nombre max de most par region
	point Mos <- nil;
	image_file mos_icon <- image_file("../includes/mos.png") ;

		    	
			//Generate 24 Mos
			init{
			int Mostiquee <-Region(any_location_in(one_of(shape)));
		   	Mos <- self.location;	
			}
		   equation MD{
		   diff(Mostique,t) = r*Mostique*(1-Mostique/k);
		   }
		 
		   reflex solving{
		   solve MD method: #rk4 step_size: 39;
		    return Mostique;
		   }

			

		aspect default{
		    draw shape color: mycolor border: #black;
		    draw Mos  color: #orange;
		    }
		    
	    	//Infected Mosquitoes	
		    reflex MostiqueEpidemie when: every(infectMos_time #month) {
			ask Region{
			if(MostiqueI < Mostique){
			float Mostique_sain<-Mostique-MostiqueI;
			MostiqueI <-(alpha * Mostique_sain * nb_birds_infected);

			return MostiqueI;
			}
			}
			
		
		}
    
    
		
}	
experiment WNV type: gui {
parameter "Initial number of brids: " var: nb_birds_init min: 1 max: 150 category: "Nombre of Brids" ;
parameter "Total number of brids: " var: nb_birds_total min: 1 max: 250 category: "Toatl Nomber of Brids" ;

parameter "Shapefile for the Tunisie Map:" var: provinces_shp_file category: "GIS" ;
parameter "minimal speed" var: bird_speed_min category: "Speed Birds" min: 10 #km/#h ;
parameter "maximal speed" var: bird_speed_max category: "Speed Birds" max: 60 #km/#h;
			
output {	
	monitor "Nombre of Intial birds" value: nb_birds_init;
	monitor "Nombre of Mosquitoes" value: Mostique ; //nb_mosquitoes ;
	monitor "Nombre of Infected Mosquitoes" value: MostiqueI ; //nb_mosquitoes ;
	monitor "Nombre of Infected Birds" value: birds count (each.is_infected) ;
	monitor "Nombre of Total Birds" value: nb_birds_total;
	
	
    display info_display  type:opengl {
        species birds ;
        species Region ;
    }
    display chart_display refresh: every(50 #cycles) {
            chart "Disease spreading" type: series {
                data "Infected Mosquitoes" value: MostiqueI color: #orange;
                data "infected Birds" value: nb_birds_infected color: #red;
            }
    
}

}
}

