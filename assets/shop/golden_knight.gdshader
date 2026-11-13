shader_type canvas_item;
uniform bool animate_shine = true;

// Recolor the existing neutral metal/stone pixels; retain alpha and silhouette.
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float hi = max(c.r, max(c.g, c.b));
	float lo = min(c.r, min(c.g, c.b));
	bool neutral = hi - lo < 0.16 && hi > 0.25;
	// Cool silver highlights are slightly blue in the original art.
	bool silver = c.b >= c.r && c.b - c.r < 0.25 && c.g > 0.28 && c.r > 0.23;
	if (neutral || silver) {
		float v = dot(c.rgb, vec3(0.299, 0.587, 0.114));
		c.rgb = vec3(min(1.0, v * 1.12 + 0.12), v * 0.72 + 0.12, v * 0.12);
		// A short glint crosses the surface occasionally, without changing the image bounds.
		float sweep = fract(TIME / 4.0) * 2.0 - 0.5;
		float gleam = 1.0 - smoothstep(0.0, 0.035, abs(UV.x + UV.y * 0.22 - sweep));
		c.rgb = mix(c.rgb, vec3(1.0, 0.96, 0.68), gleam * 0.8 * float(animate_shine));
		// A restrained four-point twinkle, clipped to the original artwork.
		vec2 d = abs(UV - vec2(0.30, 0.28));
		float star = max((1.0 - smoothstep(0.0, 0.010, d.x)) * (1.0 - smoothstep(0.015, 0.045, d.y)), (1.0 - smoothstep(0.0, 0.010, d.y)) * (1.0 - smoothstep(0.015, 0.045, d.x)));
		float pulse = pow(max(0.0, sin(TIME * 2.1)), 8.0);
		c.rgb = mix(c.rgb, vec3(1.0, 1.0, 0.88), star * pulse * float(animate_shine));
	}
	COLOR = c;
}
