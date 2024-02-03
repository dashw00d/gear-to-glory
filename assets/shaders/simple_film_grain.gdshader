shader_type canvas_item;

// Uniforms
uniform sampler2D screen_texture : hint_screen_texture;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05; // Adjust the amount of grain
uniform float grain_size : hint_range(0.1, 10.0) = 1.0; // Adjust the size of the grain
uniform vec3 grain_tint : source_color = vec3(.8, .8, .8); // The color of the grain

void fragment() {
    // Sample the original screen texture
    vec4 original_color = texture(screen_texture, SCREEN_UV);

    // Generate random noise with animation
    vec2 animatedUV = UV + vec2(TIME * 0.05, TIME * 0.05); // Adjust for animation speed
    float noise = fract(sin(dot(animatedUV, vec2(12.9898, 78.233))) * 43758.5453);

    // Normalize the noise to -1 to 1 range
    noise = (noise - 0.5) *  2.0;

    // Scale down the noise and tint influence
    vec3 colored_noise = noise * grain_tint * .99; // The 0.5 factor reduces the intensity

    // Add colored noise to the original color
    original_color.rgb += colored_noise * grain_amount * grain_size;

    // Clamp the final color to make sure it stays in the valid range
    COLOR = clamp(original_color, 0.0, 1.0);
}
