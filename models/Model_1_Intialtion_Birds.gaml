/**
* Name: Model1IntialtionBirds
* Based on the internal empty template. 
* Author: MSI
* Tags: 
*/


model Model1IntialtionBirds

global {
    int nb_birds_init <- 20;
    float bird_speed_min <- 5 #m/#mn;
	float bird_speed_max <- 20 #m/#mn;
	
    init {
    create birds number: nb_birds_init ;
    }
}

species birds {
	int id;
    float size <- 0.5 ;
    rgb color <- #green;   
    aspect base {
    draw circle(size) color: color ;
    }
} 

experiment wnv type: gui {
    parameter "Initial number of brids: " var: nb_birds_init min: 1 max: 100 category: "Brids" ;
    output {
    display main_display {
        species birds aspect: base ;
    }
    }
}
