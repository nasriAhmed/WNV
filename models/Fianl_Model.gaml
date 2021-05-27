/**
* Name: Model3MovLocal
* Based on the internal empty template. 
* Author: MSI_Nasri
* Tags: 
*/


model FianlModel_Part1

	
global{
	int nb_birds_init <- 100;
	int nb_birds_sain<-0 update:true;
    //int	nb_birds_infected<-0 update:true;
    int nb_birds_infected <- nb_birds_init update: birds count (each.is_infected);
    int nb_birds_region<-0;
    bool is_infected <- false;
    
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
	int regional_time <- 1 ;
	int migration_time <- 8 ;
	date starting_date <- date("2021-05-25-00-00-00");	
	//int charge_time <- 30;
	int alpha<-7;  
	 //mosquitoes
	int nb_mosquitoes<-24;
	int nb_mosquitoes_infecte<-0 update:true;
	int nb_mosquitoes_sain<-0 update:true;
	int infectMos_time <- 2 ;
	

  

			//Initialisation d'Envireonement
	file provinces_shp_file <- file("../includes/TUN_adm/TUN_adm1.shp");
    geometry shape <- envelope(provinces_shp_file);


	init{
			//Intialition Region 
	create Region from: provinces_shp_file;
    list<Region> residential_region <- list<Region>(Region);
	the_graph <- as_edge_graph(Region);

			//Intialition Birds 
	create birds number: nb_birds_init{
	location <- any_location_in(one_of(residential_region));
	speed<-rnd(bird_speed_min,bird_speed_max);
	
	}
	}
			
			//Random Region 
	Region Reg;	
		reflex BirdsInfected when: every(infectMos_time #month) { 
			Reg<-first(Region(any_location_in((shape))));
			
		return Reg;	
		}			
	
}
	//Espace Birds
species birds skills:[moving]{     
	int id;
	rgb color <- #green ;
    bool is_infected <- false;
    Region regionOiseau;
   	Region my_cell <- one_of(Region);
    Region k_Maxx<-self.my_cell.k_max;
	point posLocal<-self.location;
	    	    //write(one_of(self.my_cell.idRegion));
	
    	 //Random movement local of birds Executé           
    	  reflex IntraRegionalMouvement { 
    	    do wander ;//aléatoire
    	    speed<-rnd(bird_speed_min,bird_speed_max); //#km/#h;
    	    posLocal <- any_location_in(shape);
    	    BirdDirection<- point(rnd(1,180));	
    	    do goto(target: posLocal, on:the_graph, speed:speed);  
			}
    		
		//Movement Regional every 5 Month Executé	 
		reflex InetrRegionalMouvement when: every(regional_time #days ) {
			//write(my_cell.location);
		//int reg<-one_of(self.my_cell.idRegion);
	    nbBirdPropo <- rnd(nb_birds_init); 
	    //posRegional<-point(Region(any_location_in(one_of(shape))));
	    do goto(target:my_cell.location,on: shape);
		//write(point(self.my_cell.idRegion));
		}
		
		//Infected Birds	
		reflex bird_infected when: every(infectMos_time #month) {
			if(is_infected=false){
				ask Region{
				int Mos<-rnd(k_max);
				if(Mos<MostiqueI){
					is_infected <- true;
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
	float Mostique<-0.0 ;
	float MostiqueI<-0.0;
	float k_max<-10.0;//le nombre max de most par region
	point Mos <- nil;
	image_file mos_icon <- image_file("../includes/mos.png") ;
	
	//list<Region> IdRegionID <- Region;
		//Migration (every 10 Month)	
		reflex MigrationMouvement when: every(migration_time #month ) {	
    	    nbBirdMigrattion <- rnd(nb_birds_init);
    	    //speed<-rnd(bird_speed_min,bird_speed_max);
    	    //BirdDirection<- point(rnd(1,180));
    	    //Localisation hors the graph
    	    //do goto(target: Reg.location, on: the_graph,speed:speed);
    	    return nbBirdMigrattion;
		    }
		    	
				//Generate Mosquitoes: Depend nomber of Region
		    reflex MostiqueDemo{	
			//int Mostique <-Region(any_location_in(one_of(shape)));
			//Mos <- Mostique.location;
			}

	aspect default{
	    draw shape color: mycolor border: #black;
	    draw Mos  color: #brown;
	    
	    }
	    
	    	//Infected Mosquitoes	
		reflex MostiqueEpidemie when: every(infectMos_time #month) {
			
			ask Reg{
				float Mostique_sain<-Mostique-MostiqueI;
				float nb_birds_infected;
			nb_mosquitoes_infecte <- (alpha * Mostique_sain * nb_birds_infected);
			//write(nb_mosquitoes_infecte);

			}
			return nb_mosquitoes_infecte;
		}
    
    
		
}
			
experiment WNV type: gui {
parameter "Initial number of brids: " var: nb_birds_init min: 1 max: 150 category: "Nombre of Brids" ;
parameter "Shapefile for the Tunisie Map:" var: provinces_shp_file category: "GIS" ;
parameter "minimal speed" var: bird_speed_min category: "Speed Birds" min: 10 #km/#h ;
parameter "maximal speed" var: bird_speed_max category: "Speed Birds" max: 60 #km/#h;
			
output {	
	monitor "Nombre of birds" value: nb_birds_init;
	monitor "Nombre of regioanl birds" value: nbBirdPropo;
	monitor "Nombre of migration birds" value: nbBirdMigrattion;
	monitor "Nombre of Mosquitoes" value: nb_mosquitoes ;
	monitor "Nombre of Infected Birds" value: nb_birds_infected ;
	
    display info_display  type:opengl {
        species birds ;
        species Region ;
    }
    
}
}

