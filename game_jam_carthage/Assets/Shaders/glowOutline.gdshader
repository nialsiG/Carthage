// largely inspired from https://godotshaders.com/shader/outline-and-glow-shader-sprite-3d/
shader_type spatial;
render_mode depth_draw_opaque, depth_prepass_alpha;
 
// uniforms
uniform bool enabled = true; // enable/disable
uniform sampler2D sprite_texture : source_color, filter_nearest; // has to be set with the AnimatedSprite
uniform vec4 color : source_color = vec4(1.0, 3.0, 0.0, 0.2); // outline rgba
uniform float line_thickness : hint_range(0.0, 20.0) = 15.0;

// outline mechanics
const float mn = 1.4;
const float mx = 1.4;
// this is what allows to hug the monkey's contour
const vec2 OFFSETS[12] = {
    vec2(0, 1), vec2(0, -1), vec2(1, 0), vec2(-1, 0),
    vec2(mn, mx),  vec2(mn, -mx), vec2 (-mn, mx), vec2 (-mn, -mx),
    vec2(mx, mn),  vec2(mx, -mn), vec2(-mx, mn), vec2(-mx,-mn)
};
 
void vertex() {
    vec2 texture_size = vec2(textureSize(sprite_texture,0));
    vec2 texture_pixel_size = 1.0 / texture_size;
    VERTEX.xy += (UV * 2.0 - 1.0) * vec2(line_thickness, -line_thickness) * texture_pixel_size;
}
 
void fragment() {
    // For drawing the regular sprite
    vec2 uv = UV;
    vec4 tex = texture(sprite_texture, uv);
    if (enabled) {
        //For drawing the initial scale
        vec2 texture_size = vec2(textureSize(sprite_texture,0));
        vec2 texture_pixel_size = 1.0 / texture_size;
        vec2 line_size = texture_pixel_size * line_thickness;
        uv = (UV - line_size) * texture_size / (texture_size - line_size) + line_size;
        tex = texture(sprite_texture, uv);
        float outline = 0.0;
        for (int i = 0; i < OFFSETS.length(); i++) {
            vec2 coordinate_offset = uv + line_size * OFFSETS[i];
            outline += texture(sprite_texture, coordinate_offset).a;
        }
        outline = min(outline, 1.0);
        tex = mix(tex, color, outline - ceil(tex.a)); //ceil(tex.a) to affect semi-transparent pixels
    }
    ALBEDO = tex.rgb;
    ALPHA = tex.a;

    }