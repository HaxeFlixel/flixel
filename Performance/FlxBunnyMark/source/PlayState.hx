package;

import flash.Lib;
import flixel.addons.ui.FlxSlider;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	public static inline var INITIAL_AMOUNT:Int = 1000;
	
	public static var complex:Bool = false;
	public static var offScreen:Bool = false;
	
	private var _changeAmount:Int = Std.int(INITIAL_AMOUNT / 2);
	private var _times:Array<Float>;
	private var _collisions:Bool = false;
	
	private var _bunnies:FlxTypedGroup<Bunny>;
	private var _pirate:FlxSprite;
	private var _complexityButton:FlxButton;
	private var _pirateButton:FlxButton;
	private var _collisionButton:FlxButton;
	private var _timestepButton:FlxButton;
	private var _offScreenButton:FlxButton;
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
		_pirate = new FlxSprite();
		_pirate.loadGraphic("assets/pirate.png");
		add(_pirate);
		
		// All the GUI stuff
		var uiBackground:FlxSprite = new FlxSprite();
		uiBackground.makeGraphic(FlxG.width, 100, FlxColor.WHITE);
		uiBackground.alpha = 0.7;
		add(uiBackground);
		
		// Left UI
		
		var amountSlider:FlxSlider = new FlxSlider(this, "_changeAmount", 40, 5, 1, INITIAL_AMOUNT);
		amountSlider.nameLabel.text = "Change amount by:";
		amountSlider.decimals = 0;
		add(amountSlider);
		
		var removeButton:FlxButton = new FlxButton(15, 65, "Remove", changeBunnyNumber.bind(false));
		add(removeButton);
		
		var addButton:FlxButton = new FlxButton(100, 65, "Add", changeBunnyNumber.bind(true));
		add(addButton);
		
		// Right UI
		// Column2 1
		var rightButtonX:Float = FlxG.width - 100; 
		
		_complexityButton = new FlxButton(rightButtonX, 10, "Simple", onComplexityToggle);
		add(_complexityButton);
		
		_pirateButton = new FlxButton(rightButtonX, 35, "Pirate: On", onPirateToggle);
		add(_pirateButton);
		
		_collisionButton = new FlxButton(rightButtonX, 60, "Collisons: Off", onCollisionToggle);
		add(_collisionButton);
		
		// Column2
		rightButtonX -= 100;
		
		_timestepButton = new FlxButton(rightButtonX, 10, "Step: Fixed", onTimestepToggle);
		add(_timestepButton);
		
		_offScreenButton = new FlxButton(rightButtonX, 35, "On-Screen", onOffScreenToggle);
		add(_offScreenButton);
		
		// The texts
		_bunnyCounter = new FlxText(0, 10, FlxG.width, "Bunnies: " + _changeAmount);
		_bunnyCounter.setFormat(null, 22, FlxColor.BLACK, CENTER);
		add(_bunnyCounter);
		
		_fpsCounter = new FlxText(0, _bunnyCounter.y + _bunnyCounter.height + 20, FlxG.width, "FPS: " + 30);
		_fpsCounter.setFormat(null, 22, FlxColor.BLACK, CENTER);
		add(_fpsCounter);
		
		_times = [];
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
				// It's much slower to recycle objects, but keeps runtime costs of garbage collection low
				_bunnies.add(new Bunny().init());
			}
		}
		else 
		{
			for (i in 0..._changeAmount) 
			{
				var bunny:Bunny = _bunnies.getFirstAlive();
				
				if (bunny != null) 
				{
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
	
	private function onComplexityToggle():Void
	{
		complex = !complex;
		toggleHelper(_complexityButton, "Complex", "Simple");
		
		// Update the bunnies
		for (bunny in _bunnies)
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
		toggleHelper(_pirateButton, "Pirate: On", "Pirate: Off");
	}
	
	private function onCollisionToggle():Void
	{
		_collisions = !_collisions;
		toggleHelper(_collisionButton, "Collisions: Off", "Collisions: On");
	}
	
	private function onTimestepToggle():Void
	{
		FlxG.fixedTimestep = !FlxG.fixedTimestep;
		toggleHelper(_timestepButton, "Step: Fixed", "Step: Variable");
	}
	
	private function onOffScreenToggle():Void
	{
		offScreen = !offScreen;
		toggleHelper(_offScreenButton, "On-Screen", "Off-Screen");
		
		// Update the bunnies
		for (bunny in _bunnies)
		{
			if (bunny != null)
			{
				bunny.init(offScreen);
			}
		}
	}
	
	/**
	 * Just a little helper function for some toggle button behaviour.
	 */
	private function toggleHelper(Button:FlxButton, Text1:String, Text2:String):Void
	{
		if (Button.label.text == Text1)
		{
			Button.label.text = Text2;
		}
		else 
		{
			Button.label.text = Text1;
		}
	}
}