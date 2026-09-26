// Example: expanding circle from mouse position revealing the new workspace.
// Recommended setting: duration-ms 300
vec4 circle_reveal(vec3 coords_geo, vec3 size_geo) {
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex_from, coords_tex.st);

    // Use the mouse position as the circle center, or the screen center
    // if the cursor is off this output (sentinel value -1, -1).
    vec2 center = (niri_mouse_pos.x < 0.0)
        ? vec2(0.5)
        : niri_mouse_pos / size_geo.xy;

    // Correct for aspect ratio so the reveal is a circle, not an ellipse.
    vec2 aspect = size_geo.xy / length(size_geo.xy);
    vec2 delta = (coords_geo.xy - center) * aspect;
    float dist = length(delta);

    // The circle expands with progress. Scale by ~1.5 to ensure
    // it covers the full screen even when starting from a corner.
    float radius = niri_clamped_progress * 1.5;

    // Pixels inside the expanding circle become transparent (new workspace),
    // pixels outside stay opaque (old workspace).
    float alpha = smoothstep(radius - 0.05, radius, dist);

    return color * alpha;
}

// This is the function that you must define.
vec4 screen_transition_color(vec3 coords_geo, vec3 size_geo) {
    // You can pick one of the example functions or write your own.
    return circle_reveal(coords_geo, size_geo);
}
