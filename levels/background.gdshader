shader_type canvas_item;

uniform vec3 primary_color : source_color = vec3(1.f);

void fragment() {
	COLOR = vec4(primary_color, 1.f);
}
