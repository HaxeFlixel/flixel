//
// Tritanopia color blindness simulation
// Simple passthrough fragment shader
//
uniform sampler2D uImage0;
varying vec2 vTexCoord;

const mat4 mTritanopia = mat4( 0.97 ,  0.11 , -0.08 ,  0.0 ,
                               0.02 ,  0.82 ,  0.16 ,  0.0 ,
                              -0.06 ,  0.88 ,  0.18 ,  0.0 ,
                               0.0  ,  0.0  ,  0.0  ,  1.0 );

void main()
{
    gl_FragColor = mTritanopia * texture2D(uImage0, vTexCoord);
}
