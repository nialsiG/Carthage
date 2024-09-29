shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	if(UV.x <= 0.02 || UV.x >= 0.98 || UV.y <= 0.02 || UV.y >= 0.98)
	{
		ALBEDO = vec3(0.0, 0.0, 0.0);
	}
	else
	{
		ALPHA = 0.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
