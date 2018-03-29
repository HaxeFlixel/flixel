package flixel.graphics.tile;

#if FLX_DRAW_QUADS
import openfl.display.GraphicsShader;

class FlxGraphicsShader extends GraphicsShader
{
	@:glVertexSource("
		#pragma header
		
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
		
		void main(void)
		{
			#pragma body
			
			openfl_Alphav = openfl_Alpha * alpha;
			
			if (hasColorTransform)
			{
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}"
	)
	
	@:glFragmentSource("
		#pragma header
		
		uniform bool hasColorTransform;
		
		void main(void)
		{
			vec4 color = texture2D(bitmap, openfl_TexCoordv);
			
			if (color.a == 0.0)
			{
				gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
			}
			else if (hasColorTransform)
			{
				color = vec4(color.rgb / color.a, color.a);
				
				mat4 colorMultiplier = mat4(0);
				colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
				colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
				colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
				colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
				
				color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
				
				if (color.a > 0.0)
					gl_FragColor = vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
				else
					gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
			}
			else
			{
				gl_FragColor = color * openfl_Alphav;
			}
		}"
	)
	
	public function new ()
	{
		super ();
	}
}
#end
