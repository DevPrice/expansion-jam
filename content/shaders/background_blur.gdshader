shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform vec4 tint : source_color = vec4(1.f);
uniform float blur_level : hint_range(0.0, 10.0, 0.1) = 2.f;

void fragment() {
	vec4 blur_screen = textureLod(screen_texture, SCREEN_UV, blur_level);
	vec4 tex_color = texture(TEXTURE, UV) * tint;
	vec3 color = mix(blur_screen.rgb, tex_color.rgb, tex_color.a);
	COLOR = vec4(color, 1.f);
}
