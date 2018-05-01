package;

import flixel.addons.util.FlxAsyncLoop;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var _grpProgress:FlxGroup;
	var _grpFinished:FlxGroup;
	var _loopOne:FlxAsyncLoop;
	var _maxItems:Int = 5000;
	var _bar:FlxBar;
	var _barText:FlxText;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		// set up our groups - one will show a progress bar, the other will hold all the things we're loading
		_grpProgress = new FlxGroup();
		_grpFinished = new FlxGroup(_maxItems);
		
		// setup our loop
		_loopOne = new FlxAsyncLoop(_maxItems, addItem, 100);
		
		// create a fancy progress bar
		_bar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width - 50, 50, null, "", 0, 100, true);
		_bar.value = 0;
		_bar.screenCenter();
		_grpProgress.add(_bar);
		
		// some text for the bar
		_barText = new FlxText(0, 0, FlxG.width, "Loading... 0 / " + _maxItems);
		_barText.setFormat(null, 28, FlxColor.WHITE, CENTER, OUTLINE);
		_barText.screenCenter();
		_grpProgress.add(_barText);
		
		// only our progress bar group should be getting draw() and update() called on it until the loop is done...
		_grpFinished.visible = false;
		_grpFinished.active = false;
		
		add(_grpProgress);
		add(_grpFinished);
		
		// add our loop, so that it gets updated
		add(_loopOne);
		
		super.create();
	}
	
	public function addItem():Void
	{	
		// each iteration of our loop, we just create a 10x10 FlxSprite in a random x, y position and random color
		var sprite = new FlxSprite(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
		sprite.makeGraphic(10, 10, FlxG.random.color(0, 255, 255));
		_grpFinished.add(sprite);
		
		// then we update our progress bar and progress bar text
		_bar.value = (_grpFinished.members.length / _maxItems) * 100;
		_barText.text = "Loading... " + _grpFinished.members.length + " / " + _maxItems;
		_barText.screenCenter();
	}

	override public function update(elapsed:Float):Void
	{
		// If my loop hasn't started yet, start it
		if (!_loopOne.started)
		{
			_loopOne.start();
		}
		else
		{
			// if the loop has been started, and is finished, then we swich which groups are active
			if (_loopOne.finished)
			{
				_grpFinished.visible = true;
				_grpProgress.visible = false;
				_grpFinished.active = true;
				_grpProgress.active = false;
				
				//clean up our loop
				_loopOne.kill();
				_loopOne.destroy();
			}
		}
		
		super.update(elapsed);
	}
}