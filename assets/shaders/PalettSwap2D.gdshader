shader_type canvas_item;

uniform sampler2D palette;
uniform float palette_count = 1.0;
uniform float palette_index = 0.0;

void fragment() {
    float increment = 1.0 / palette_count;
    float y = increment * palette_index + (increment * 0.5);
    vec4 original_color = texture(TEXTURE, UV);
    
    // Check if the original alpha is above a threshold before applying palette swap.
    if(original_color.a > 0.00392) { // Adjust threshold as needed, close to 0 to include very faint pixels
        vec4 new_color = texture(palette, vec2(original_color.r, y));
        new_color.a = original_color.a; // Preserve original alpha
        COLOR = new_color;
    } else {
        // For fully transparent pixels, keep original color to avoid filling alpha
        COLOR = original_color;
    }
}
