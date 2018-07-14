shader_type canvas_item;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if(c.a < 1.0) {
		COLOR.a = 0.0;
	}
}