package;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	private inline static var  GUY_SPEED:Int = 100;	// how fast we want our guy to move
	private var _guy:FlxSprite;	// this is our 'guy' the player will move around
	private var _baseY:Float;	// this is the starting Y position of our guy, we will use this to make the guy float up and down
	private var _flakes:FlxTypedGroup<Flake>; // a group of flakes
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		//FlxG.mouse.visible = false; // don't need the mouse
		
		// build a gradient sky for the background - make it as big as our screen, and, it's going to be stationary
		var sky:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff6dcff6, 0xff333333], 16);
		sky.scrollFactor.set();
		add(sky);
		
		add(spawnCloud(0)); // add a cloud layer to go behind everything else
		
		// we're going to have 6 mountain layers with a cloud layer on top.
		for (i in 0...6)
		{
			
			add(spawnMountain(i));
			
			add(spawnCloud(i));
			
		}
		
		// this is just a solid-gradient to go behind our ground
		var _sprSolid = FlxGradient.createGradientFlxSprite(FlxG.width, 64, [0xff333333, 0xff000000], 8);
		_sprSolid.y = FlxG.height - 64;
		_sprSolid.scrollFactor.set();
		add(_sprSolid);		
		
		// a tileblock of stuff to go between the player and the mountains
		var _spookyStuff = new FlxTileblock(0, FlxG.height - 128, Math.ceil(FlxG.width * 4), 64);
		_spookyStuff.loadTiles("assets/spookystuff.png", 64, 64, 4);
		_spookyStuff.scrollFactor.set(.95, 0);
		add(_spookyStuff);		
		
		
		// a tileblock of ground tiles - will move with the player
		var _ground = new FlxTileblock(0, FlxG.height - 64, FlxG.width * 4, 64);
		_ground.loadTiles("assets/tiles.png", 16, 16, 1);
		add(_ground);
		
		// our guy for the player to move
		_guy = new FlxSprite(0, 0, "assets/guy.png");
		_guy.x = ((FlxG.width * 4) / 2) - (_guy.width / 2);
		_guy.y = FlxG.height - 72 - _guy.height;
		_baseY = _guy.y;
		add(_guy);
		
		
		var txtInst:FlxText = new FlxText(0, FlxG.height - 16, FlxG.width, "Left/Right to Move");
		txtInst.alignment = FlxTextAlign.CENTER;
		txtInst.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xff333333, 1, 1);
		txtInst.scrollFactor.set();
		add(txtInst);
		
		// we're going to have some snow or ash flakes drifting down at different 'levels'. We need a lot of them for the effect to work nicely
		_flakes = new FlxTypedGroup<Flake>();
		add(_flakes);
		
		for (i in 0...1000)
		{
			_flakes.add(new Flake(i % 10));
		}
		
		// Set up our camera to follow the guy, and stay within the confines of our 'world'
		FlxG.camera.follow(_guy);
		FlxG.camera.setScrollBounds(0, FlxG.width * 4, 0, FlxG.height);
		
		// add some tweens to fade the player in and out and to make him 'float' up and down
		FlxTween.num(0, 1, 2, { ease:FlxEase.sineInOut, type:FlxTween.PINGPONG }, guyFloat);
		FlxTween.num(.4, 1, 3, { ease:FlxEase.sineInOut, type:FlxTween.PINGPONG }, guyFade);
		
		super.create();
	}
	
	/**
	 * This function spawns a new Tileblock of clouds which will be positioned near the top of the screen
	 */
	private function spawnCloud(Pos:Int):FlxTileblock
	{
		var rand:FlxRandom = new FlxRandom();
		var clouds:FlxTileblock = new FlxTileblock(0, 0, Math.ceil(FlxG.width * 4), 64);
		clouds.x += Math.floor(rand.float( -8, 8) * 4);
		clouds.y += Math.floor(rand.float( -8, 8) * Pos);
		clouds.loadTiles("assets/clouds.png", 64, 64, Pos * 5);
		clouds.scrollFactor.set(.2 + (Pos * .1) + .05, 0);
		clouds.alpha = (1 - (.2 + (Pos * .1) * .5)); 
		clouds.color = clouds.color.getDarkened(.6 - ( (Pos * .1)));
		return clouds;
	}
	
	/**
	 * This function generates and returns a new FlxTileblock using our mountain sprites.
	 */
	private function spawnMountain(Pos:Int):FlxTileblock
	{
		var mountain:FlxTileblock = new FlxTileblock(0, FlxG.height - (180 + ((5 - Pos) * 16)) , Math.ceil(FlxG.width * 4), 116);
		mountain.loadTiles("assets/mountains.png", 256, 116, 0);
		mountain.scrollFactor.set(.2 + (Pos * .1), 0);
		mountain.color = mountain.color.getDarkened(1 - (.2 + (Pos * .1)));
		return mountain;
	}
	
	
	private function guyFloat(Amt:Float):Void
	{
		_guy.y = _baseY - Amt * 10;
		
	}
	private function guyFade(Amt:Float):Void
	{
		_guy.alpha = Amt;
		
	}
	/**
	 * this is just logic to make the guy move when the player presses left/right and to keep him within the 'world'
	 */
	private function movement():Void
	{
		var _left:Bool = false;
		var _right:Bool = false;
		
		_left = FlxG.keys.anyPressed(["LEFT", "A"]);
		_right = FlxG.keys.anyPressed(["RIGHT", "D"]);
		
		if (_left && _right)
			_left = _right = false;
		
		if (_guy.x < 32)
		{
			_guy.velocity.x = 0;
			_guy.x = 32;
		}
		else if (_guy.x + _guy.width > (FlxG.width * 4 - 32))
		{
			_guy.velocity.x = 0;
			_guy.x = (FlxG.width * 4) - 32 - _guy.width;
		}
		else if (_left)
		{
			_guy.velocity.x = -GUY_SPEED;
		}
		else if (_right)
		{
			_guy.velocity.x = GUY_SPEED;
		}
		else
			_guy.velocity.x = 0;
			
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		
		super.update(elapsed);
		
		movement();
		
	}
}
