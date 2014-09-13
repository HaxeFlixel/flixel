package;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUICheckBox;
import flixel.effects.postprocess.PostProcess;
import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxAssets;

class PlayState extends FlxState
{
	var shaderNames:Array<String> = [
		"blur",
		"tiltshift",
		"deuteranopia",
		"grain",
		"grayscale",
		"hq2x",
		"invert",
		"protanopia",
		"scanline",
		"tritanopia"];
		
	var fragmentShaders:Array<PostProcess> = [];
	
	override public function create():Void
	{
		var backdrop = new FlxBackdrop(GraphicLogo);
		backdrop.velocity.set(150, 150);
		add(backdrop);
		
		var x = 10;
		var y = 10;
		
		for (i in 0...shaderNames.length)
		{
			fragmentShaders.push(new PostProcess("assets/shaders/" + shaderNames[i] + ".frag"));
			
			createCheckbox(x, y, shaderNames[i], fragmentShaders[i]);
			y += 25;
		}
		
		// some shaders have properties that can be manipulated at runtime
		var blurShader = fragmentShaders[0];
		blurShader.setUniform("diry", 1);
		blurShader.setUniform("dirx", 1);
		blurShader.setUniform("radius", 1);
	}
	
	function createCheckbox(x:Float, y:Float, name:String, shader:PostProcess)
	{
		var checkbox = new FlxUICheckBox(x, y, FlxUIAssets.IMG_CHECK_BOX,  FlxUIAssets.IMG_CHECK_MARK, name);
		add(checkbox);
		
		checkbox.callback = function()
		{
			if (checkbox.checked)
			{
				FlxG.addPostProcess(shader);
			}
			else
			{
				FlxG.removePostProcess(shader);
			}
		}
	}
}
