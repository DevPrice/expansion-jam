shader_type canvas_item;

#include "sdf.gdshaderinc"

uniform sampler2D voronoi : hint_default_black, repeat_enable;
uniform sampler2D perlin : hint_default_black, repeat_enable;

uniform vec3 tint : source_color = vec3(1.f);
uniform float edge = .5f;
uniform float smoothing = .05f;

uniform vec2 translation_speed = vec2(.1f, .05f);
uniform float shape_spacing = .15f;
uniform float shape_size = .25f;

uniform vec2 shadow_size = vec2(.0f, .04f);

float smooth_sample(vec2 uv, sampler2D tex) {
	return smoothstep(edge - smoothing, edge + smoothing, texture(tex, uv).a);
}

float remap(float value, float inMin, float inMax, float outMin, float outMax) {
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin);
}

float shadow(vec2 uv, sampler2D tex) {
	return smooth_sample(uv + shadow_size, tex) * .5f + .5f;
}

void fragment() {
	float alpha = smoothstep(edge - smoothing, edge + smoothing, texture(TEXTURE, UV).a);
	float s = shadow(UV, TEXTURE);
	vec2 p = vec2(UV.x, -UV.y) - .5f * TIME * translation_speed * vec2(1.f, -1.f);
	vec2 q = p - shape_spacing * round(p / shape_spacing);
	float light_mask = smoothstep(.5f, .75f, s);
	float shape = remap(sign(sdCircle(q, shape_spacing * shape_size) * light_mask), -1.f, 1.f, 1.f, 0.f);;
	COLOR = vec4(tint * s, alpha);
}
