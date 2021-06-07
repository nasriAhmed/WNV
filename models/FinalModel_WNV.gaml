/**
* Name: Modele01062021
* Based on the internal empty template. 
* Author: MSI_Nasri
* Tags: 
*/

model FianlModel

global{
	int nb_birds_init <- 100;
	int nb_birds_sain<-0 update:true;
    int nb_birds_infected <- 1 update: birds count (each.is_infected);
    int nb_birds_not_infected <- nb_birds_total - nb_birds_infected update: nb_birds_total - nb_birds_infected;
    float infected_rate update: nb_birds_infected/nb_birds_total;
    int nb_birds_region<- birds count each.my_cell;
   	//bool is_infected <- false;
    int nb_birds_total <-nb_birds_init ;
    int nb_birds_migration<-1;
    
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
	float step <- 60 #mn;
	int regional_time <- 4 ;
	int migration_time <- 2 ;
	date starting_date <- date("2021-06-05-00-00-00");	
	//int charge_time <- 30;
	float alpha<-0.1;  
	 //mosquitoes

	int infectMos_time <- 2 ;
	//int MostiqueGlobal<-10 update:Region count(each.Mostique);
	//int MostiqueGlobalInfected<-1 update: Region count(each.MostiqueI);
	/*int MosquitoesGlobalsain<-0 update: Region count(each.Mostique_sain);*/
	
	float MostiqueGlobal<-10 update:true;
	float MostiqueGlobalInfected<-1.0 update:true;
	int MosquitoesGlobalsain<-0 update:true;
	float t <- step;

  

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
	int BirdsInfected;
    	 //IntraRegionalMouvement// Random movement local of birds       
    	reflex IntraRegionalMouvement{ 
    	  do wander ;//aléatoire
    	  speed<-rnd(bird_speed_min,bird_speed_max); //#km/#h;
    	  posLocal <- any_location_in(shape);
    	  BirdDirection<- point(rnd(1,180));	
    	  do goto(target: posLocal, on:the_graph, speed:speed);  
		}
		//InetrRegionalMouvement
		reflex InetrRegionalMouvement when: every(regional_time #days){
	    nbBirdPropo <- rnd(nb_birds_total);
		//int nbBirdRegion<-nbBirdPropo update: birds count (self.my_cell.idRegion);
    	   // write(nbBirdRegion);
	    do goto(target:my_cell.location,on: shape);
		}
		//Migration 
		reflex migration_in when: every(1 #days){
			nbBirdMigrattion <- rnd(nb_birds_migration);		
			do create;
    	    nb_birds_total<-nb_birds_init + nbBirdMigrattion;
      	    return nb_birds_total;	
    	
    	   
		}
		action create{
			create species(self) number: nbBirdMigrattion {
            location <- my_cell.location;
		}
		}
		reflex migration_out when: every(3 #days){		
			nbBirdMigrattion <- rnd(nb_birds_migration);
			do delete;
    	    nb_birds_total<-nb_birds_total - nbBirdMigrattion;
    	    return nb_birds_total;	
		}
		action delete{
			ask birds {
			  do die;
			}
		}
	
		
		//Infected Birds	
		reflex bird_infected when:every(infectMos_time #days ) {
			if(is_infected = false){
				ask self.my_cell{
					int Moss<-rnd(k_max);
						if(Moss<MostiqueI){	
							if flip(0.02) {
							//write('ici');
								myself.is_infected <- true ;

						}
						
						}
			    }
			}
		}
			aspect base {
		    draw triangle(20) color:is_infected? #red : #green;
			} 
			
			  	    	   
}
		//espace region
species Region {
	int idRegion<- shape['ID_1'];
	string Nomregion<-shape['NAME_1'];
	rgb mycolor<-#grey;	
	int cnt <-0;
	//int Mostiquee;
	float k_max<-10.0;//le nombre max de most par region
	point Mos <- nil;
	image_file mos_icon <- image_file("../includes/mos.png") ;
	float r<-0.1;
	float k<- rnd(200);
	int dt<-rnd(160);
	float Mostique<-10.0 update:true;
	float MostiqueI<-1.0 update:true;
	float Mostique_sain ;
	birds my_Birds <- birds;
	int nb_birds;
	int nb_birds_infected<-2;
	int nb_birds_sain;
		    	
			//Generate 24 Mos
			init{
			int Mostiquee <-Region(any_location_in(one_of(shape)));
		   	Mos <- self.location;	
		   			
		   	//write(my_Birds);
			}
			
			
		   equation MD{
		   diff(Mostique,t) = r*Mostique*(1-Mostique/k);
		   }		 
		   reflex solving{
		   solve MD method: #rk4 step_size: dt;
		   return Mostique;
	
		   }
		    
	    	//Infected Mosquitoes	
		    reflex MostiqueEpidemie when: every(infectMos_time #month) {
			ask Region{
			if(self.MostiqueI < self.Mostique){
			self.Mostique_sain<-self.Mostique-self.MostiqueI;
			self.MostiqueI <-(alpha * self.Mostique_sain * self.nb_birds_infected);

			return self.MostiqueI;
			}
			}
			
		}
    
			

		aspect default{
		    draw shape color: mycolor border: #black;
		    draw Mos  color: #orange;
		    }
    
		
}	
experiment WNV type: gui {
parameter "Total number of brids: " var: nb_birds_total min: 1 max: 250 category: "Toatl Nomber of Brids" ;
parameter "Number of migration brids: " var: nb_birds_migration min: 1 max: 200 category: "Number of migration brids" ;
parameter "Shapefile for the Tunisie Map:" var: provinces_shp_file category: "GIS" ;
parameter "minimal speed" var: bird_speed_min category: "Speed Birds" min: 10 #km/#h ;
parameter "maximal speed" var: bird_speed_max category: "Speed Birds" max: 60 #km/#h;
			
output {	
	monitor "Number of Intial birds" value: nb_birds_init;
	monitor "Number of Total Birds" value: nb_birds_total;
	//monitor "Nombre of Mosquitoes" value: MostiqueGlobal ; //nb_mosquitoes ;
	//monitor "Nombre of Infected Mosquitoes" value: MostiqueGlobalInfected ; //nb_mosquitoes ;
	monitor "Nombre of Mosquitoes" value: Region count (each.Mostique)color: #gray;
	monitor "Number of Infected Birds" value: birds count (each.is_infected) color: #red;
	
	 display info_display  type:opengl{
        species birds ;
        species Region ;
    }
    display chart_display refresh: every(50 #cycles) {
            chart "Disease spreading" type: series {
               //data "Infected Mosquitoes" value: MostiqueGlobalInfected color: #orange;
                data "infected Birds" value: birds count (each.is_infected) color: #red;
            }
           }
    display "Statistic par région" {   
			chart 'Ariana' type: series {
				Region r1 <-first(Region where (each.Nomregion = 'Tunis'));
				Region r2 <-first(Region where (each.Nomregion = 'Ariana'));
				data "Number of Mosquitoes In Ariana" value: r2.Mostique  color: #green marker_shape:  marker_circle;

			}	

}
}
}


