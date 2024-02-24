shader_type canvas_item;

uniform float outline_width : hint_range(0, 10) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 fill_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D screen_texture: hint_default_black;

void fragment() {
    // Calculate the alpha based on the distance to the edge
    float dist = texture(TEXTURE, UV).a;
    float alpha = smoothstep(0.5 - outline_width, 0.5, dist) - smoothstep(0.5, 0.5 + outline_width, dist);
    
    // Determine the final color based on whether we're in the outline or not
    COLOR = mix(fill_color, outline_color, alpha);
    COLOR.a = dist; // Use the original alpha
}
