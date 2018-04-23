package;

import flash.Lib;
import flixel.addons.ui.FlxSlider;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

#if (openfl >= "8.0.0")
import openfl8.*;
#else
import openfl3.*;
#end

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	public static var complex:Bool = false;
	public static var offScreen:Bool = false;
	public static var useShaders:Bool = false;
	
	private var _changeAmount:Int = 1000;
	private var _times:Array<Float>;
	private var _collisions:Bool = false;
	
	private var _bunnies:FlxTypedGroup<Bunny>;
	private var _uiOverlay:FlxSpriteGroup;
	private var _complexityButton:FlxButton;
	private var _collisionButton:FlxButton;
	private var _timestepButton:FlxButton;
	private var _offScreenButton:FlxButton;
	private var _bunnyCounter:FlxText;
	private var _fpsCounter:FlxText;
	
	#if shaders_supported
	private var _shaderButton:FlxButton;
	
	private var floodFill = new FloodFill();
	private var invert = new Invert();
	#end
	
	override public function create():Void
	{
		// The grass background
		var bgSize:Int = 32;
		var bgWidth:Int = Math.ceil(FlxG.width / bgSize) * bgSize;
		var bgHeight:Int = Math.ceil(FlxG.height / bgSize) * bgSize;
		
		var useAnimatedBackground = !FlxG.renderBlit;
		#if (!openfl_legacy && openfl <= "4.0.0")
		useAnimatedBackground = false;
		#end

		if (useAnimatedBackground)
		{
			add(new Background());
		}
		else
		{
			var bg = new FlxTileblock(0, 0, bgWidth, bgHeight);
			add(bg.loadTiles("assets/grass.png"));
		}
		
		var initialAmount = _changeAmount;
		var define = haxe.macro.Compiler.getDefine("bunnies");
		if (define != null)
			initialAmount = Std.parseInt(define);

		// Create the bunnies
		_bunnies = new FlxTypedGroup<Bunny>();
		changeBunnyNumber(true, initialAmount);
		add(_bunnies);

		// All the GUI stuff
		_uiOverlay = createOverlay();
		add(_uiOverlay);

		_times = [];
	}

	private function createOverlay():FlxSpriteGroup
	{
		var overlay = new FlxSpriteGroup();

		var uiBackground = new FlxSprite();
		uiBackground.makeGraphic(FlxG.width, 100, FlxColor.WHITE);
		uiBackground.alpha = 0.7;
		overlay.add(uiBackground);
		
		// Left UI
		var amountSlider = new FlxSlider(this, "_changeAmount", 40, 5, 1, _changeAmount * 2);
		amountSlider.nameLabel.text = "Change amount by:";
		amountSlider.decimals = 0;
		overlay.add(amountSlider);
		
		overlay.add(new FlxButton(15, 65, "Remove", function() changeBunnyNumber(false, _changeAmount)));
		overlay.add(new FlxButton(100, 65, "Add", function() changeBunnyNumber(true, _changeAmount)));
		
		// Right UI
		// Column2 1
		var rightButtonX:Float = FlxG.width - 100;
		
		_complexityButton = new FlxButton(rightButtonX, 10, "Simple", onComplexityToggle);
		overlay.add(_complexityButton);
		
		_collisionButton = new FlxButton(rightButtonX, 35, "Collisons: Off", onCollisionToggle);
		overlay.add(_collisionButton);
		
		// Column2
		rightButtonX -= 100;
		
		_timestepButton = new FlxButton(rightButtonX, 10, "Step: Fixed", onTimestepToggle);
		overlay.add(_timestepButton);
		
		_offScreenButton = new FlxButton(rightButtonX, 35, "On-Screen", onOffScreenToggle);
		overlay.add(_offScreenButton);
		
		#if shaders_supported
		_shaderButton = new FlxButton(rightButtonX, 60, "Shaders: Off", onShaderToggle);
		overlay.add(_shaderButton);
		#end
		
		// The texts
		_bunnyCounter = new FlxText(0, 10, FlxG.width, "Bunnies: " + _bunnies.length);
		_bunnyCounter.setFormat(null, 22, FlxColor.BLACK, CENTER);
		overlay.add(_bunnyCounter);
		
		_fpsCounter = new FlxText(0, _bunnyCounter.y + _bunnyCounter.height + 20, FlxG.width, "FPS: " + 30);
		_fpsCounter.setFormat(null, 22, FlxColor.BLACK, CENTER);
		overlay.add(_fpsCounter);
		
		return overlay;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		var time = FlxG.game.ticks;
		
		#if shaders_supported
		var floodFillY = 0.5 * (1.0 + Math.sin(time / 1000));
		#if (openfl >= "8.0.0")
		floodFill.uFloodFillY.value = [floodFillY];
		#else
		floodFill.uFloodFillY = floodFillY;
		#end
		#end
		
		if (_collisions)
			FlxG.collide(_bunnies, _bunnies);
		
		var now:Float = time / 1000;
		_times.push(now);
		
		while (_times[0] < now - 1)
			_times.shift();
		
		_fpsCounter.text = "FPS: " + _times.length + "/" + Lib.current.stage.frameRate;

		if (FlxG.keys.justPressed.SPACE)
			_uiOverlay.visible = !_uiOverlay.visible;
	}

	private function changeBunnyNumber(add:Bool, amount:Int):Void
	{
		for (i in 0...amount)
		{
			if (add)
			{
				var shader = null;
				#if shaders_supported
				shader = (i < _changeAmount / 2) ? floodFill : invert;
				#end

				// It's much slower to recycle objects, but keeps runtime costs of garbage collection low
				_bunnies.add(new Bunny().init(offScreen, useShaders, shader));
			}
			else 
			{
				var bunny:Bunny = _bunnies.getFirstAlive();
				if (bunny != null)
					_bunnies.remove(bunny);
			}
		}
		
		if (_bunnyCounter != null)
		{
			var bunnyAmount:Int = _bunnies.countLiving();
			if (bunnyAmount == -1)
				bunnyAmount = 0;
			_bunnyCounter.text = "Bunnies: " + bunnyAmount;
		}
	}
	
	private function onComplexityToggle():Void
	{
		complex = !complex;
		toggleLabel(_complexityButton, "Complex", "Simple");
		
		for (bunny in _bunnies)
			if (bunny != null)
				bunny.complex = complex;
	}
	
	private function onCollisionToggle():Void
	{
		_collisions = !_collisions;
		toggleLabel(_collisionButton, "Collisions: Off", "Collisions: On");
	}
	
	private function onTimestepToggle():Void
	{
		FlxG.fixedTimestep = !FlxG.fixedTimestep;
		toggleLabel(_timestepButton, "Step: Fixed", "Step: Variable");
	}
	
	private function onOffScreenToggle():Void
	{
		offScreen = !offScreen;
		toggleLabel(_offScreenButton, "On-Screen", "Off-Screen");
		
		for (bunny in _bunnies)
			if (bunny != null)
				bunny.init(offScreen, useShaders);
	}
	
	#if shaders_supported
	private function onShaderToggle():Void
	{
		useShaders = !useShaders;
		toggleLabel(_shaderButton, "Shaders: Off", "Shaders: On");
		
		for (bunny in _bunnies)
			if (bunny != null)
				bunny.useShader = useShaders;
	}
	#end
	
	private function toggleLabel(button:FlxButton, text1:String, text2:String):Void
	{
		button.label.text = if (button.label.text == text1) text2 else text1;
	}
}
