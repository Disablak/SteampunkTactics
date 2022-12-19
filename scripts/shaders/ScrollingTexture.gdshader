shader_type canvas_item;

uniform vec4 color: source_color;
uniform float scrolling_speed = 1.0;

void fragment() {
	vec2 moving_uv = vec2(UV.x - (TIME * scrolling_speed), UV.y);
	vec4 in_tex = texture(TEXTURE, moving_uv);
	in_tex.rgb = color.rgb;
	COLOR = in_tex;
}
