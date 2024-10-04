shader_type spatial;

void vertex() {

}

void fragment() {
	 ALBEDO = vec3(0.85 + sin(TIME*8.0+UV.x)*0.02,0.7+cos(TIME *5.0+UV.y) *0.02,(UV.x*sin(TIME*5.0)) / 8.0 + (UV.y*cos(TIME*5.0))/8.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
