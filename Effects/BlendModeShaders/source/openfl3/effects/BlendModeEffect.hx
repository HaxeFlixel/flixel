package openfl3.effects;

import flixel.util.FlxColor;

typedef BlendModeShader =
{
	var uBlendColor(get, set):Array<Float>;
}

class BlendModeEffect
{
	public var shader(default, null):BlendModeShader;
	
	@:isVar
	public var color(default, set):FlxColor;
	
	public function new(shader:BlendModeShader, color:FlxColor):Void
	{
		this.shader = shader;
		this.color = color;
	}
	
	private function set_color(color:FlxColor):FlxColor
	{
		shader.uBlendColor[0] = color.redFloat;
		shader.uBlendColor[1] = color.greenFloat;
		shader.uBlendColor[2] = color.blueFloat;
		shader.uBlendColor[3] = color.alphaFloat;

		return this.color = color;
	}
}
