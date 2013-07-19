package;

import flash.Lib;
import flash.ui.Mouse;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxBitmapTextField;
import flixel.text.FlxText;
import flixel.text.pxText.PxBitmapFont;
import flixel.text.pxText.PxTextAlign;
import flixel.tile.FlxTileblock;
import flixel.ui.FlxButton;
import flixel.ui.FlxSlider;
import flixel.util.FlxColor;
import openfl.Assets;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{	
	static public var complex:Bool = false;
	
	private var _changeAmount:Int = 30000;
	private var _times:Array<Float>;
	private var _collisions:Bool = false;
	
	private var _bunnies:FlxTypedGroup<Bunny>;
	private var _pirate:FlxSprite;
	private var _complexityButton:FlxButton;
	private var _pirateButton:FlxButton;
	private var _collisionButton:FlxButton;
	private var _bunnyCounter:FlxText;
	private var _fpsCounter:FlxText;

	override public function create():Void
	{
		// The grass background
		var bgSize:Int = 32;
		var bgWidth:Int = Math.ceil(FlxG.width / bgSize) * bgSize;
		var bgHeight:Int = Math.ceil(FlxG.height / bgSize) * bgSize;
		
		var bg:FlxTileblock = new FlxTileblock(0, 0, bgWidth, bgHeight);
		bg.loadTiles("assets/grass.png");
		add(bg);
		
		// Create the bunnies
		_bunnies = new FlxTypedGroup<Bunny>();
		changeBunnyNumber(true);
		add(_bunnies);
		
		// Add a jumping pirate
		//_pirate = new FlxSprite();
		//_pirate.loadGraphic("assets/pirate.png");
		//add(_pirate);
		
		// All the GUI stuff
		var uiBackground:FlxSprite = new FlxSprite();
		uiBackground.makeGraphic(FlxG.width, 100, FlxColor.WHITE);
		uiBackground.alpha = 0.7;
		add(uiBackground);
		
		var amountSlider:FlxSlider = new FlxSlider(this, "_changeAmount", 40, 5, 1, 500);
		amountSlider.nameLabel.text = "Change amount by:";
		add(amountSlider);
		
		var addButton:FlxButton = new FlxButton(15, 65, "Add");
		addButton.setOnDownCallback(changeBunnyNumber, [true]);
		add(addButton);
		
		var removeButton:FlxButton = new FlxButton(100, 65, "Remove");
		removeButton.setOnDownCallback(changeBunnyNumber, [false]);
		add(removeButton);
		
		var rightButtonX:Float = FlxG.width - 100; 
		
		_complexityButton = new FlxButton(rightButtonX, 10, "Simple", onComplexityChange);
		add(_complexityButton);
		
		_pirateButton = new FlxButton(rightButtonX, 35, "Pirate: On", onPirateToggle);
		add(_pirateButton);
		
		_collisionButton = new FlxButton(rightButtonX, 60, "Collisons: Off", onCollisionToggle);
		add(_collisionButton);
		
		// The texts
		_bunnyCounter = new FlxText(0, 10, FlxG.width, "Bunnies: " + _changeAmount);
		_bunnyCounter.setFormat(null, 22, 0x000000, "center");
		add(_bunnyCounter);
		
		_fpsCounter = new FlxText(0, _bunnyCounter.y + _bunnyCounter.height + 20, FlxG.width, "FPS: " + 30);
		_fpsCounter.setFormat(null, 22, 0x000000, "center");
		add(_fpsCounter);
		
		_times = [];
		
		Mouse.hide();
		
		#if !mobile
		FlxG.mouse.show();
		#end
		
		// Profile code - disable <haxedef name="profile_cpp" if="target_cpp" /> before ship
		#if (profile_cpp && !neko)
		cpp.vm.Profiler.start("perf.txt");
		#end
	}
	
	override public function update():Void
	{
		super.update();
		
		var t = Lib.getTimer();
		
		_pirate.x = Std.int((FlxG.width - _pirate.width) * (0.5 + 0.5 * Math.sin(t / 3000)));
		_pirate.y = Std.int(FlxG.height - 1.3 * _pirate.height + 70 - 30 * Math.sin(t / 100));
		
		if (_collisions)
		{
			FlxG.collide(_bunnies, _bunnies);
		}
		
		var now:Float = t / 1000;
		_times.push(now);
		
		while (_times[0] < now - 1)
		{
			_times.shift();
		}
		
		_fpsCounter.text = "FPS: " + _times.length + "/" + Lib.current.stage.frameRate;
	}

	private function changeBunnyNumber(Add:Bool):Void
	{
		if (Add)
		{
			for (i in 0..._changeAmount)
			{
				var bunny:Bunny = _bunnies.recycle(Bunny);
				bunny.init();
				_bunnies.add(bunny);
			}
		}
		else 
		{
			for (i in 0..._changeAmount) 
			{
				var bunny:Bunny = _bunnies.getFirstAlive();
				
				if (bunny != null) 
				{
					bunny.destroy();
					_bunnies.remove(bunny);
				}
			}
		}
		
		// Update the bunny counter
		if (_bunnyCounter != null)
		{
			var bunnyAmount:Int = _bunnies.countLiving();
			
			if (bunnyAmount == -1) 
			{
				bunnyAmount = 0;
			}
			
			_bunnyCounter.text = "Bunnies: " + bunnyAmount;
		}
	}
	
	private function onComplexityChange():Void
	{
		complex = !complex;
		
		if (_complexityButton.label.text == "Complex")
		{
			_complexityButton.label.text = "Simple";
		}
		else 
		{
			_complexityButton.label.text = "Complex";
		}
		
		// Update the bunnies
		for (bunny in _bunnies.members)
		{
			if (bunny != null)
			{
				bunny.complex = complex;
			}
		}
	}
	
	private function onPirateToggle():Void
	{
		_pirate.visible = !_pirate.visible;
		
		if (_pirateButton.label.text == "Pirate: On")
		{
			_pirateButton.label.text = "Pirate: Off";
		}
		else 
		{
			_pirateButton.label.text = "Pirate: On";
		}
	}
	
	private function onCollisionToggle():Void
	{
		_collisions = !_collisions;
		
		if (_collisionButton.label.text == "Collisions: Off")
		{
			_collisionButton.label.text = "Collisions: On";
		}
		else 
		{
			_collisionButton.label.text = "Collisions: Off";
		}
	}
}