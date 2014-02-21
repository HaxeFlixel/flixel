//
// Deuteranopia color blindness simulation
// Simple passthrough fragment shader
//
uniform sampler2D uImage0;
varying vec2 vTexCoord;

const mat4 mDeuteranopia = mat4( 0.43 ,  0.72 , -0.15 ,  0.0 ,
                                 0.34 ,  0.57 ,  0.09 ,  0.0 ,
                                -0.02 ,  0.03 ,  1.00 ,  0.0 ,
                                 0.0  ,  0.0  ,  0.0  ,  1.0 );

void main()
{
    gl_FragColor = mDeuteranopia * texture2D(uImage0, vTexCoord);
}
