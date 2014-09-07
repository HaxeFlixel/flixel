#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform sampler2D uImage0;

void main(void)
{
    vec4 color = texture2D(uImage0, vTexCoord);
    gl_FragColor = vec4(vec3(1.0, 1.0, 1.0) - color.rgb, color.a);
}
