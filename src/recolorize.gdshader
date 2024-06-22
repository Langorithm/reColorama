shader_type canvas_item;

uniform bool activated = true;
uniform bool show_untouched = true;
uniform float epsilon: hint_range(0.0, 0.1, 0.0001) = .004;
uniform vec4 s0: source_color = vec4(0.);
uniform vec3 t0: source_color = vec3(0.);
uniform vec4 s1: source_color = vec4(0.);
uniform vec3 t1: source_color = vec3(0.);
uniform vec4 s2: source_color = vec4(0.);
uniform vec3 t2: source_color = vec3(0.);
uniform vec4 s3: source_color = vec4(0.);
uniform vec3 t3: source_color = vec3(0.);
uniform vec4 s4: source_color = vec4(0.);
uniform vec3 t4: source_color = vec3(0.);
uniform vec4 s5: source_color = vec4(0.);
uniform vec3 t5: source_color = vec3(0.);
uniform vec4 s6: source_color = vec4(0.);
uniform vec3 t6: source_color = vec3(0.);
uniform vec4 s7: source_color = vec4(0.);
uniform vec3 t7: source_color = vec3(0.);


void fragment() {
	bool recolored = false;
	if (activated){
		vec4[] sources = {s0,s1,s2,s3,s4,s5,s6,s7};
		vec3[] targets = {t0,t1,t2,t3,t4,t5,t6,t7};
		for (int i=0; i<(sources.length()) && !recolored; i++){
			bool same_color = length(COLOR.rgb - sources[i].rgb) < epsilon;
			bool source_valid = sources[i].a > 0.;
			if (same_color && source_valid){
				COLOR.rgb = targets[i];
				recolored = true;
			}
		}
		if (!recolored && show_untouched) COLOR.a = min(0.5, COLOR.a);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
