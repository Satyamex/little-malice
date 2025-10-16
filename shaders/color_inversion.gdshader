shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() 
{
    vec4 base_color = texture(TEXTURE, UV);
    vec3 inverted = vec3(1.0) - base_color.rgb;
    base_color.rgb = mix(base_color.rgb, inverted, intensity);
    COLOR = base_color;
}
