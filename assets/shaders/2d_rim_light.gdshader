shader_type canvas_item;

uniform bool rim_light = false;
uniform float rim_thickness : hint_range(0, 40) = 5.0;
uniform float rim_intense : hint_range(0, 1) = 1.0;
uniform vec4 rim_color : source_color = vec4(1, 1, 1, 1);
uniform bool rim_extra_thick = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;

    if (rim_light) {
        vec2 size = TEXTURE_PIXEL_SIZE * rim_thickness;
        float outline = 0.0;
        
        // Calculate an outline effect based on surrounding alpha values
        outline += texture(TEXTURE, UV + vec2(-size.x, 0)).a;
        outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
        outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
        outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
        
        if (rim_extra_thick) {
            outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
            outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
            outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
            outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
        }
        
        outline /= rim_extra_thick ? 8.0 : 4.0; // Average the outline contribution
        outline = 1.0 - outline; // Invert the outline effect
        outline = clamp(outline, 0.0, 1.0); // Ensure outline is within valid range

        // Apply the rim effect to the texture color
        vec4 rim_effect_color = mix(tex_color, rim_color, outline * rim_intense);
        rim_effect_color.a = alpha; // Preserve the original alpha of the texture
        COLOR = rim_effect_color;
    } else {
        COLOR = tex_color;
    }
}
