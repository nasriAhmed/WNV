/**
* Name: Model3MovLocal
* Based on the internal empty template. 
* Author: MSI_Nasri
* Tags: 
*/


model Model3MovLocal

	
global{
	int nb_birds_init <- 100;
	float bird_speed_min <- 1#km / #h;
	float bird_speed_max <- 5 #km / #h;
	point BirdDirection;
	float speed;
	graph the_graph;		
	float step <- 10 #mn;
	int regional_time <- 4 ;
	int migration_time <- 10 ;
	int nbBirdPropo<-0;	
	int nbBirdMigrattion<-0;
	point posRegional;
	date starting_date <- date("2021-05-20-00-00-00");	
	int charge_time <- 30;
	
				//ADD Envireonement
	file provinces_shp_file <- file("../includes/TUN_adm/TUN_adm1.shp");
    geometry shape <- envelope(provinces_shp_file);

			//Initialisation 
init{
			//Intialition Region 
	create Region from: provinces_shp_file;
    list<Region> residential_region <- list<Region>(Region);
	the_graph <- as_edge_graph(Region);
	
			//Intialition Oiseau 
	create birds number: nb_birds_init{
	location <- any_location_in(one_of(residential_region));
	speed<-rnd(bird_speed_min,bird_speed_max);

	}
	}
			
			
			//Movement Regional every 10 Month	
	reflex RegionalMouvement when: every(regional_time #month ) {	
    nbBirdPropo <- rnd(nb_birds_init);
    speed<-10 + rnd(bird_speed_min,bird_speed_max);
    //BirdDirection<- point(rnd(1,360));
    posRegional <-point(the_graph);
	}			
	
}
		//espace Birds
species birds skills:[moving]{     
	int id;
	rgb color <- #green ;
 	float speed<-rnd(bird_speed_min,bird_speed_max); //#km/#h;
	point posLocal<-self.location;
    	
    	  
    	 //Random movement local of birds           
    	  reflex move { 
    	  		ask birds {
    	    do wander ;
    	    //location <- any_location_in(one_of(residential_region));
    	    posLocal <-point(the_graph) ;
    	    //BirdDirection<- point(rnd(1,360));
				}
			
			}
	aspect base {
    draw circle(10) color: color  border: #green;
	}   	    	   
}
		//espace region
species Region {
	rgb mycolor<-#gray;	
			
		//Migration (every 10 Month)	
		reflex MigrationMouvement when: every(migration_time #month ) {	
    	    nbBirdMigrattion <- rnd(nb_birds_init);
    	    speed<-15 + rnd(bird_speed_min,bird_speed_max);
    	    //BirdDirection<- point(rnd(1,360));
		    }
		    	
		//Mosquito population 	
		reflex MosquitoGeneration{ 
		    }
		    
		    
	/*reflex start_simulation when: current_date != starting_date {
			charge_time <- charge_time + 1;
	}*/
	aspect default{
    draw shape color: mycolor border: #black;
    }
		
}
			
experiment WNV type: gui {
parameter "Initial number of brids: " var: nb_birds_init min: 1 max: 150 category: "Nombre of Brids" ;
parameter "Shapefile for the Tunisie Map:" var: provinces_shp_file category: "GIS" ;
parameter "minimal speed" var: bird_speed_min category: "Speed Birds" min: 1 #km/#h ;
parameter "maximal speed" var: bird_speed_max category: "Speed Birds" max: 5 #km/#h;
			
output {		
	monitor "Nombre of regioanl birds" value: nbBirdPropo;
	monitor "Nombre of migration birds" value: nbBirdMigrattion;
    display city_display type:opengl {
        species birds ;
        species Region ;
    }
}
}

