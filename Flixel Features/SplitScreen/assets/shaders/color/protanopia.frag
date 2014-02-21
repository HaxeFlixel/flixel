//
// Protanopia color blindness simulation
// Simple passthrough fragment shader
//
uniform sampler2D uImage0;
varying vec2 vTexCoord;

const mat4 mProtanopia = mat4( 0.20 ,  0.99 , -0.19 ,  0.0 ,
                               0.16 ,  0.79 ,  0.04 ,  0.0 ,
                               0.01 , -0.01 ,  1.00 ,  0.0 ,
                               0.0  ,  0.0  ,  0.0  ,  1.0 );

void main()
{
    gl_FragColor = mProtanopia * texture2D(uImage0, vTexCoord);
}
