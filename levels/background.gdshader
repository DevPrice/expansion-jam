shader_type canvas_item;

#define GRADIENT_SIZE 3

uniform vec3 gradient_colors[GRADIENT_SIZE] : source_color;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float grid_size = 0.2;
uniform float circle_base = 0.05;
uniform float circle_growth = 0.1;
uniform vec2 circle_speed = vec2(.2f);

uniform float line_width = .25f;
uniform float line_spacing = 1.2f;

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
    return smoothstep(radius, radius - 0.01, dist);
}

float diagonal_cross_mask(vec2 uv, float spacing, float width) {
    float d1 = fract((uv.x + uv.y) / spacing);
    float d2 = fract((uv.x - uv.y) / spacing);

    float line1 = smoothstep(0.0, width, d1) * smoothstep(0.0, width, 1.0 - d1);
    float line2 = smoothstep(0.0, width, d2) * smoothstep(0.0, width, 1.0 - d2);

    return line1 * line2;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec3 bg = diagonal_gradient(uv);
	float circle_mask = circle_mask(uv / pixel_size * .001, SCREEN_PIXEL_SIZE * 1000.f);

	vec3 color = mix(bg * 0.4, bg, circle_mask);
	color = mix(color * .5f, color, diagonal_cross_mask(uv / pixel_size, line_spacing, line_width));
	COLOR = vec4(color, 1.0);
}
