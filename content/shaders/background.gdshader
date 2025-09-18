shader_type canvas_item;

#define GRADIENT_SIZE 3
#define SQRT2 1.41421356237f

uniform vec3 gradient_colors[GRADIENT_SIZE] : source_color;

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
	float radius = mix(circle_base, circle_growth, length(uv) / SQRT2);
	vec2 grid_pos = (uv / pixel_size) / grid_size;
	vec2 grid_uv = fract(grid_pos + TIME * circle_speed) - 0.5f;
	float dist = length(grid_uv) / SQRT2;
	return smoothstep(radius, radius - (0.25f - .15f * length(uv)), dist);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec3 bg = diagonal_gradient(uv);
	float circle_mask = circle_mask(uv, pixel_size);
	
	ivec2 pixel = ivec2(FRAGCOORD.xy);
	float checker = float((pixel.x / 2 + pixel.y / 2) % 2);

	vec3 color = mix(bg * 0.4, bg, circle_mask);
	color = mix(color * .5f, color, checker);
	COLOR = vec4(color, 1.0);
}
