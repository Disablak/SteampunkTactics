shader_type canvas_item;

uniform sampler2D img_texture: filter_nearest, repeat_enable;
uniform vec4 img_color: source_color;
uniform float img_scale = 1.0;
uniform vec2 scale_factor = vec2(1.0);


void fragment(){
	vec2 uv = UV * scale_factor / img_scale;
	vec4 base_pixel = texture(TEXTURE, uv);
	vec4 texture_pixel = texture(img_texture, uv);
	
	texture_pixel.rgb = vec3(img_color.rgb);
	
	COLOR.rgb = mix(base_pixel.rgb, texture_pixel.rgb, texture_pixel.a * img_color.a);
}


