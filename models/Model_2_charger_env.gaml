model Model2chargerenv
		
global{
	int nb_birds_init <- 250;
	float bird_speed_min <- 5 #m/#mn;
	float bird_speed_max <- 20 #m/#mn;
			
			
	//ADD Envireonement

	file provinces_shp_file <- file("../includes/TUN_adm/TUN_adm1.shp");
    geometry shape <- envelope(provinces_shp_file);

    //graph the_graph;
				
	init{
	
	create Region from: provinces_shp_file;
    list<Region> residential_region <- list<Region>(Region);

	//Intialition Oiseau 
	create birds number: nb_birds_init{
	location <- any_location_in(one_of(residential_region));
	float speed<-rnd(bird_speed_min,bird_speed_max);

	}
	}
				
					
	
	}
		//espace oiseau
species birds {
			int id;
		    int size <- 8;
		    rgb color <- #yellow  ;

		    aspect base {
    	draw circle(20) color: color border: #red;
		    }
}
		//espace region
species Region {
			rgb mycolor<-#grey;	
			
reflex MigrationBirds {
				
}
		 
		//Phase de transmission
reflex Propgation when : time > 5{ // chaque gouv 
}
				
			
			
aspect default  {
    draw shape color: mycolor border: #black;
    }
		
}
			
experiment WNV type: gui {
parameter "Initial number of brids: " var: nb_birds_init min: 1 max: 100 category: "Brids" ;
parameter "Shapefile for the Tunisie Map:" var: provinces_shp_file category: "GIS" ;
			
output {
layout horizontal([0::5000, 1::5000]) tabs: true editors: false;
				
    display city_display type:opengl {
        species birds ;
        species Region ;
    }
}
}