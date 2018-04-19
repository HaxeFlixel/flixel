package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

#if shaders_supported
#if (openfl >= "8.0.0")
import openfl8.blends.*;
import openfl8.effects.*;
import openfl8.effects.WiggleEffect.WiggleEffectType;
import openfl8.effects.BlendModeEffect.BlendModeShader;
#else
import openfl3.blends.*;
import openfl3.effects.*;
import openfl3.effects.WiggleEffect.WiggleEffectType;
import openfl3.effects.BlendModeEffect.BlendModeShader;
#end
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import openfl.filters.ShaderFilter;
#else
import flixel.text.FlxText;
#end
@:enum abstract LogoColor(FlxColor) to FlxColor
{
	static var LIST(default, null) = [RED, BLUE, YELLOW, CYAN, GREEN];

	var RED = 0xff3366;
	var BLUE = 0x3333ff;
	var YELLOW = 0xffcc33;
	var CYAN = 0x00ccff;
	var GREEN = 0x00cc33;

	public static function getRandom():LogoColor
	{
		return LIST[FlxG.random.int(0, LIST.length - 1)];
	}
}

class PlayState extends FlxState
{
	var backdrop:FlxSprite;

	#if shaders_supported
	var wiggleEffect:WiggleEffect;

	var effects:Map<String, BlendModeShader> = [
		"ColorBurn" => new ColorBurnShader(),
		"HardMix" => new HardMixShader(),
		"Lighten" => new LightenShader(),
		"LinearDodge" => new LinearDodgeShader(),
		"Multiply" => new MultiplyShader(),
		"VividLight" => new VividLightShader()
	];
	#end

	override public function create():Void
	{
		super.create();

		backdrop = new FlxSprite(0, 0, AssetPaths.backdrop__png);
		add(backdrop);

		#if !shaders_supported
		add(createText(0, 0, "Not supported on this target!", 16).screenCenter());
		#else
		var logo = new FlxSprite(0, 0, AssetPaths.logo__png);
		logo.screenCenter();
		add(logo);
		
		wiggleEffect = new WiggleEffect();
		wiggleEffect.effectType = WiggleEffectType.DREAMY;
		wiggleEffect.waveAmplitude = 0.2;
		wiggleEffect.waveFrequency = 7;
		wiggleEffect.waveSpeed = 1;
		backdrop.shader = wiggleEffect.shader;
		
		var colorSwap = new ColorSwapEffect();
		logo.shader = colorSwap.shader;
		
		new FlxTimer().start(0.2, function(timer)
		{
			colorSwap.colorToReplace = LogoColor.getRandom();
			colorSwap.newColor = LogoColor.getRandom();
		}, 0);

		selectBlendEffect(effects.keys().next());
		createShutterEffect();
		createUI();
		#end
	}

	private function createText(x, y, label, size = 8):FlxText
	{
		var text = new FlxText(x, y, 0, label, size);
		text.color = FlxColor.BLACK;
		return text;
	}

	#if shaders_supported
	private function createUI()
	{
		var dropDownWidth = 155;

		add(createText(4, 38, "Wiggle Effect:"));

		var wiggleEffects = FlxUIDropDownMenu.makeStrIdLabelArray(WiggleEffectType.getConstructors());
		add(new FlxUIDropDownMenu(80, 34, wiggleEffects, function(type)
		{
			wiggleEffect.effectType = WiggleEffectType.createByName(type);
		}, new FlxUIDropDownHeader(dropDownWidth)));

		add(createText(4, 8, "Blend Mode:"));

		var blendModes = FlxUIDropDownMenu.makeStrIdLabelArray([for (name in effects.keys()) name]);
		add(new FlxUIDropDownMenu(80, 4, blendModes, selectBlendEffect, new FlxUIDropDownHeader(dropDownWidth)));
	}

	private function selectBlendEffect(blendEffect:String)
	{
		var color = FlxG.random.color();
		color.alphaFloat = 0.5;

		var effect = new BlendModeEffect(effects[blendEffect], color);
		#if filters_supported
		FlxG.camera.setFilters([new ShaderFilter(cast effect.shader)]);
		#else
		backdrop.shader = cast effect.shader;
		#end
	}
	
	private function createShutterEffect():Void
	{
		var shutter = new ShutterEffect();
		var shutterCanvas = new FlxSprite();
		shutterCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		shutterCanvas.shader = shutter.shader;
		add(shutterCanvas);

		FlxTween.tween(shutter, { radius: 450 }, 1.5, { ease: FlxEase.quintOut, startDelay: 0.2 });
	}

	override public function update(elapsed:Float):Void
	{
		wiggleEffect.update(elapsed);
		super.update(elapsed);
	}
	#end
}
