shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float bayer_amount : hint_range(0.0, 1.0) = 0.25; // How strong the dither effect is
uniform float color_levels : hint_range(2.0, 32.0) = 8.0;   // How many color shades are allowed

const mat4 BAYER4 = mat4(
	vec4(0.0, 12.0, 3.0, 15.0),
	vec4(8.0, 4.0, 11.0, 7.0),
	vec4(2.0, 14.0, 1.0, 13.0),
	vec4(10.0, 6.0, 9.0, 5.0)
);

float bayer4(vec2 pixel) {
	ivec2 p = ivec2(mod(pixel, 4.0));
	return (BAYER4[p.x][p.y] / 16.0) - 0.5; // Center around 0
}

void fragment() {
	vec4 col = texture(screen_texture, SCREEN_UV);
	
	float dither = bayer4(FRAGCOORD.xy) * bayer_amount;
	
	col.rgb += vec3(dither);
	
	col.rgb = floor(col.rgb * color_levels + 0.5) / color_levels;
	
	COLOR = col;
}