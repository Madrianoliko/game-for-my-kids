shader_type spatial;
varying vec2 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xz;}
void fragment(){
	float r=sin(world.x*2.3+world.y*6.0-TIME*1.6+sin(world.y*4.1+TIME*.7));
	float edge=smoothstep(.82,1.0,abs(UV.y*2.0-1.0));
	ALBEDO=mix(vec3(.045,.35,.42),vec3(.32,.66,.62),edge+.16*r);
	ALBEDO+=vec3(.25,.37,.34)*smoothstep(.94,1.0,r)*(.5+.5*sin(world.x*2.7+world.y));
	ROUGHNESS=.33;
}
