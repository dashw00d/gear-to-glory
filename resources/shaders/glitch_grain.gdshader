shader_type canvas_item;

// Uniforms
uniform vec2 iResolution; // Screen resolution
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Function to generate random value
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 fragCoord = FRAGCOORD.xy;
    vec2 uv = fragCoord / iResolution;

    // Reduced the intensity of UV manipulation
    if (mod(TIME, 2.0) > 1.9)
        uv.x += cos(TIME * 5.0 + uv.y * 50.0) * 0.005;

    if (mod(TIME, 5.0) > 3.75)
        uv += 1.0 / 128.0 * (2.0 * vec2(rand(floor(uv * 32.0) + vec2(32.05,236.0)), rand(floor(uv.y * 32.0) + vec2(-62.05,-36.0))) - 1.0);

    vec4 fragColor = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Raised the threshold to reduce the frequency of the color effect
    if (rand(vec2(TIME)) > 0.80)
        fragColor = vec4(dot(fragColor.rgb, vec3(0.25, 0.5, 0.25)));

    // Reduced the strength of the additional random color offset
    fragColor.rgb += 0.15 * vec3(rand(TIME + fragCoord / vec2(-213, 5.53)), rand(TIME - fragCoord / vec2(213, -5.53)), rand(TIME + fragCoord / vec2(213, 5.53))) - 0.075;

    COLOR = fragColor;
}
