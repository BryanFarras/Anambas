shader_type canvas_item;

// In the Godot Inspector, assign a New NoiseTexture2D here.
// Make sure to enable "Seamless" in the Noise settings!
uniform sampler2D noise_texture : repeat_enable, filter_linear;

// How fast the lighting moves over the water
uniform vec2 scroll_speed = vec2(0.02, 0.01);
// The scale mapping of the noise
uniform float noise_scale = 1.0;

// The primary colors for lighter parts and darker parts
uniform vec4 light_color : source_color = vec4(1.2, 1.2, 1.25, 1.0);
uniform vec4 dark_color : source_color = vec4(0.7, 0.75, 0.8, 1.0);

// The secondary colors to alternate to
uniform vec4 light_color_2 : source_color = vec4(1.25, 1.1, 1.1, 1.0); // example slight red/warm tint
uniform vec4 dark_color_2 : source_color = vec4(0.6, 0.65, 0.75, 1.0);

// How fast it alternates between the primary and secondary colors
uniform float alternate_speed = 1.0;

// Blend strength of the noise lighting
uniform float effect_intensity : hint_range(0.0, 1.0) = 1.0;

// Variable to pass continuous coordinates from vertex to fragment
varying vec2 world_pos;

void vertex() {
	// We use the model matrix to get global/world coordinates.
	// This ensures the noise looks continuous across multiple grid tiles.
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Original tile's color and alpha
	vec4 base_color = texture(TEXTURE, UV);
	
	// We scale down the world position so it doesn't repeat as often
	// Change 0.002 to a smaller number if you still see patterns!
	vec2 base_uv = world_pos * 0.002 * noise_scale;
	
	// Sample 1: Main noise layer scrolling naturally
	vec2 uv1 = base_uv + (TIME * scroll_speed);
	float n1 = texture(noise_texture, uv1).r;
	
	// Sample 2: Secondary noise layer scaled, offset, and moving slower
	// Layering a second oddly-scaled noise completely breaks up the visible repeating grid!
	vec2 uv2 = (base_uv * 1.5) + vec2(0.34, 0.78) - (TIME * scroll_speed * 0.6);
	float n2 = texture(noise_texture, uv2).r;
	
	// Combine the two layers together
	float noise_value = (n1 + n2) * 0.5;
	
	// Calculate how much we blend between color pair 1 and color pair 2
	// A sine wave goes from -1 to 1. We map it to 0 to 1 for smoothing transitioning!
	float color_mix = (sin(TIME * alternate_speed) + 1.0) * 0.5;
	
	// Get the current target light and dark colors for this exact moment in time
	vec3 current_light_color = mix(light_color.rgb, light_color_2.rgb, color_mix);
	vec3 current_dark_color = mix(dark_color.rgb, dark_color_2.rgb, color_mix);
	
	// Multiplier trick to increase the contrast of the combined noise if you want
	// noise_value = smoothstep(0.2, 0.8, noise_value);
	
	// Mix our dark and light lighting colors based on the new combined noise value
	vec3 noise_lighting = mix(current_dark_color, current_light_color, noise_value);
	
	// Apply the lighting
	COLOR.rgb = base_color.rgb * mix(vec3(1.0), noise_lighting, effect_intensity);
	
	// Keep the original tile's transparency
	COLOR.a = base_color.a;
}
