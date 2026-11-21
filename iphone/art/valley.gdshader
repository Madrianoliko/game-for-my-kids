shader_type spatial;
varying vec3 ground;
float hash(vec2 p){return fract(sin(dot(p,vec2(27.1,61.7)))*43758.5453);}
float noise2(vec2 p){
	vec2 c=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
	return mix(mix(hash(c),hash(c+vec2(1,0)),f.x),mix(hash(c+vec2(0,1)),hash(c+vec2(1)),f.x),f.y);
}
void vertex(){ground=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
	float patch=noise2(ground.xz*.75)*.68+noise2(ground.xz*4.0)*.32;
	float underfoot=1.0-smoothstep(.2,1.1,ground.y);
	float mottling=mix(1.0,.72+.52*patch,underfoot);
	vec3 c=COLOR.rgb;
	if(!OUTPUT_IS_SRGB){c=mix(pow((c+vec3(.055))/1.055,vec3(2.4)),c/12.92,lessThanEqual(c,vec3(.04045)));}
	ALBEDO=c*mottling;
	ROUGHNESS=.93;
}
