package ;
 
import openfl.display.Shader;

/**
 * A classic mosaic effect, just like in the old days!
 * 
 * Usage notes:
 * - The effect will be applied to the whole screen.
 * - Set the x/y-values on the 'uBlocksize' vector to the desired size (setting this to 0 will make the screen go black)
 */
class MosaicShader extends Shader
{
    @fragment var code = '
    
    uniform vec2 uBlocksize;

    void main()
	{
        vec2 blocks = ${Shader.uTextureSize} / uBlocksize;
		gl_FragColor = texture2D(${Shader.uSampler}, floor(${Shader.vTexCoord} * blocks) / blocks);
    }
    ';
    
    public function new()
    {
        super();
    }
}