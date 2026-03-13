shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;

uniform vec2 scroll1 = vec2(0.05, 0.05);
uniform vec2 scroll2 = vec2(0.05, 0.05);
uniform vec4 tone_color : source_color = vec4(1.0);
uniform vec4 top_color : source_color = vec4(1.0);

uniform float distortion_strengh : hint_range(-1,1) = 0.2;
uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float light_start : hint_range(0.0, 1.0) = 0.275;
uniform float light_end : hint_range(0.0, 1.0) = 0.4;

uniform float surface_distortion_mult : hint_range(1.0, 50.0) = 10.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment() {
	float depth1 = texture(noise1, UV + scroll1 * TIME).r;
	
	// Shrink the screen UV slightly towards the center to create a safe margin.
	// This prevents the distortion from ever sampling outside the screen bounds!
	vec2 safe_uv = (SCREEN_UV - vec2(0.5)) * (1.0 - abs(distortion_strengh)) + vec2(0.5);
	
	vec4 screen_col = textureLod(SCREEN_TEXTURE, safe_uv + distortion_strengh * vec2(depth1 - 0.5), blur_amount);
	
	// Use the distorted depth vector to distort the surface noise
	float depth2 = texture(noise2, UV + scroll2 * TIME + (distortion_strengh * surface_distortion_mult * vec2(depth1 - 0.5))).r;
	float final_depth = depth1 * depth2;
	
	// Scale the light thresholds based on the distortion strength so the highlights don't vanish or overexpose
	float distort_scale = 1.0 + abs(distortion_strengh);
	vec4 top_light = smoothstep(light_start * distort_scale, light_end * distort_scale, final_depth) * top_color;
	COLOR.rgb = mix(screen_col.rgb * tone_color.rgb, top_light.rgb, top_light.a);
	COLOR.a = screen_col.a * tone_color.a;
}
