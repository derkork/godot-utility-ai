shader_type canvas_item;

// an array of a maxium of 10 influence sources, each being described
// by 9 floats.
uniform float[90] sources;
// the current amount of influence sources
uniform int source_count;
// the color we use for drawing influence
uniform vec4 base_color:source_color; 

uniform bool use_point_of_view;
uniform vec2 point_of_view;
uniform float point_of_view_radius;

// stores the world position of the current "pixel"
varying vec4 world_pos;


float linear_contribution(float x, float rise, float offset, float exponent, float midpoint) {
	return rise * (x - midpoint) + offset;
}

float polynomial_contribution(float x, float rise, float offset, float exponent, float midpoint) {
	return rise * pow((x - midpoint), exponent) + offset;
}

float logistics_contribution(float x, float rise, float offset, float exponent, float midpoint) {
	return rise * (1. /(1. + exp(-exponent * (x - midpoint)))) + offset;
}

void vertex() {
	// calculate the world position for later use in the fragment shader
	world_pos = MODEL_MATRIX * vec4(VERTEX, 0. ,1.);
}


void fragment() {
	if (source_count == 0) {
		// a yellowish hue to indicate that there is no data
		COLOR = vec4(1.,1.,0., 0.2);
	}
	else if (use_point_of_view && distance(world_pos.xy, point_of_view) > point_of_view_radius){
		// outside of point of view radius, skip it
		COLOR = vec4(0.);
	}
	else {
			
		float total = 0.;
		// calculate the influence at this place
		for(int i = 0; i < source_count; i++) {
			// extract data from the array
			int source_offset = i * 9;
			float pos_x = sources[source_offset];
			float pos_y = sources[source_offset + 1];
			float max_range = sources[source_offset + 2];
			float multiplier = sources[source_offset + 3];
			
			// check how far we are from the current source
			float distance_to_source = distance(vec2(pos_x, pos_y), world_pos.xy);
			// too far away, skip it
			if (distance_to_source > max_range) {
				continue;
			}
			
			float percentage = distance_to_source / max_range;
			
			// now calculate the actual contribution
			// get the data for the falloff function
			int type = int(sources[source_offset + 4]);
			float rise = sources[source_offset + 5];
			float offset = sources[source_offset + 6];
			float exponent = sources[source_offset + 7];
			float midpoint = sources[source_offset + 8];
		
			float contribution = 0.;
			switch(type) {
				case 0: // linear
					contribution = linear_contribution(percentage, rise, offset, exponent, midpoint); 
					break;	
				case 1: // polynomial
					contribution = polynomial_contribution(percentage, rise, offset, exponent, midpoint);
					break;
				case 2: // logistics	
					contribution = logistics_contribution(percentage, rise, offset, exponent, midpoint);
					break;
				default:
					contribution = 1.;
					break;
			}	
			
			total += multiplier * clamp(contribution, 0., 1.);
		}
		
		// constrain between 0 and 1.
	    total /= float(source_count) * 0.5;
		// use the base color
		COLOR = base_color;
		// use the total influence as alpha for the base color 
		COLOR.a = total;
	}	

}


