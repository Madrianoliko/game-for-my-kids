shader_type spatial;
render_mode cull_disabled;
varying float phase;
void vertex() {
	phase = dot(MODEL_MATRIX[3].xz, vec2(1.3,0.9));
	VERTEX.x += sin(TIME*1.7+phase)*0.1*(1.0-UV.y);
}
void fragment() {
	vec2 p = vec2(UV.x,1.0-UV.y);
	float blade = fract(p.x*3.0);
	float height = .58+.39*sin(floor(p.x*3.0)*1.7+phase);
	if (p.y>height || abs(blade-.5-p.y*.14)>.42*(1.0-p.y/height)) discard;
	ALBEDO = mix(vec3(.10,.26,.075),vec3(.51,.68,.20),p.y);
	ROUGHNESS = .95;
}
