shader_type canvas_item;

uniform sampler2D gradient;
uniform float x : hint_range(0.0, 1.0);

void fragment()
{
	COLOR = texture(gradient, vec2(x, 0.0)).rgba * texture(TEXTURE, UV).rgba;
}