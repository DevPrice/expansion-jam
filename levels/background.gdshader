shader_type canvas_item;

#define GRADIENT_SIZE 3

uniform vec3 gradient_colors[GRADIENT_SIZE] : source_color;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float grid_size = 0.2;
uniform float circle_base = 0.05;
uniform float circle_growth = 0.1;
uniform vec2 circle_speed = vec2(.2f);

vec3 diagonal_gradient(vec2 uv) {
	float t = clamp((uv.x + uv.y) * 0.5, 0.0, 1.0);
	float seg = t * float(GRADIENT_SIZE - 1);
	int i = int(floor(seg));
	float local_t = fract(seg);
	i = clamp(i, 0, GRADIENT_SIZE - 2);
	return mix(gradient_colors[i], gradient_colors[i + 1], local_t);
}

float circle_mask(vec2 uv, vec2 pixel_size) {
	vec2 cell_id = floor(uv / grid_size);
	float cell_diag = (cell_id.x + cell_id.y) / 100.0;
	float radius = circle_base + circle_growth * length(uv * pixel_size);

	vec2 grid_uv = fract((uv / grid_size) + TIME * circle_speed) - 0.5;
	float dist = length(grid_uv);
	return smoothstep(radius, radius - (0.2f - .1f * length(uv * pixel_size)), dist);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec3 bg = diagonal_gradient(uv);
	float circle_mask = circle_mask(uv / pixel_size * .001f, SCREEN_PIXEL_SIZE * 1000.f);
	
	ivec2 pixel = ivec2(FRAGCOORD.xy);
	float checker = float((pixel.x / 2 + pixel.y / 2) % 2);

	vec3 color = mix(bg * 0.4, bg, circle_mask);
	color = mix(color * .5f, color, checker);
	COLOR = vec4(color, 1.0);
}
