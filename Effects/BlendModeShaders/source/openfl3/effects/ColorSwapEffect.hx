package openfl3.effects;

import flixel.util.FlxColor;
import openfl.display.Shader;

class ColorSwapEffect
{
	/**
	 * The instance of the actual shader class
	 */
	public var shader(default, null):ColorSwapShader;

	/**
	 * The color to replace with another
	 */
	public var colorToReplace(default, set):FlxColor;

	/**
	 * The desired new color
	 */
	public var newColor(default, set):FlxColor;

	/**
	 * Activates/Deactivates the shader
	 */
	public var isShaderActive(default, set):Bool;

	public function new():Void
	{
		shader = new ColorSwapShader();
		shader.shaderIsActive = true;
	}

	function set_isShaderActive(value:Bool):Bool
	{
		isShaderActive = value;
		shader.shaderIsActive = value;
		return value;
	}

	function set_colorToReplace(color:FlxColor):FlxColor
	{
		colorToReplace = color;

		shader.colorOld[0] = color.red;
		shader.colorOld[1] = color.green;
		shader.colorOld[2] = color.blue;

		return color;
	}

	function set_newColor(color:FlxColor):FlxColor
	{
		newColor = color;

		shader.colorNew[0] = color.red;
		shader.colorNew[1] = color.green;
		shader.colorNew[2] = color.blue;

		return color;
	}
}

class ColorSwapShader extends Shader
{
	@fragment var code = '
		uniform vec3 colorOld;
		uniform vec3 colorNew;
		uniform bool shaderIsActive;

		/**
		 * Helper method that normalizes an RGB value (in the 0-255 range) to a value between 0-1.
		 */
		vec3 normalizeColor(vec3 color)
		{
			return vec3(
				color[0] / 255.0,
				color[1] / 255.0,
				color[2] / 255.0
			);
		}

		void main()
		{
			vec4 pixel = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});

			if (!shaderIsActive)
			{
				gl_FragColor = pixel;
				return;
			}

			/**
			 * Used to create some leeway when comparing the colors.
			 * Smaller values = smaller leeway.
			 */
			vec3 eps = vec3(0.009, 0.009, 0.009);

			vec3 colorOldNormalized = normalizeColor(colorOld);
			vec3 colorNewNormalized = normalizeColor(colorNew);

			if (all(greaterThanEqual(pixel, vec4(colorOldNormalized - eps, 1.0)) ) &&
				all(lessThanEqual(pixel, vec4(colorOldNormalized + eps, 1.0)) )
			)
			{
				pixel = vec4(colorNewNormalized, 1.0);
			}

			gl_FragColor = pixel;
		}';

	public function new()
	{
		super();
	}
}
