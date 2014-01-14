package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public var wind(default, null):Float = 0.0;
	
	private var _sky:FlxSprite;
	private var _trunk:FlxSprite;
	private var _tree:FlxTypedGroup<Branch>;
	private var _mist:FlxSprite;
	private var _crazy:FlxSprite;
	private var _ground:FlxSprite;
	private var _leaves:FlxTypedGroup<Leaf>;
	private var _ghosts:FlxTypedGroup<Ghost>;
	private var _jacks:FlxTypedGroup<Jack>;
	private var _wispsBG:FlxTypedGroup<Wisp>;
	private var _wispsFG:FlxTypedGroup<Wisp>;
	private var _collidables:FlxGroup;
	
	private var _goal:Float = 0.0;
	private var _crazyMode:Bool = false;
	private var _timer:Float = 0.0;
	
	inline static private var VER:String = "2.2";
	inline static private var WIND_MAX:Int = 10;
	inline static private var WIND_MAX_CRAZY:Int = 15;
	inline static private var TIMER_FREQ:Float = 0.2;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff000000;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
		
		Reg.PS = this;
		
		_sky = new FlxSprite();
		_sky.pixels = FlxGradient.createGradientBitmapData( FlxG.width, FlxG.height, [ 0xff15001E, 0xff21002E, 0xff2B003D, 0xff8C4422, 0xffFB9201 ] );
		
		_leaves = new FlxTypedGroup<Leaf>( 2000 );
		
		// Cover the ground in leaves
		
		var xPos:Int = 0;
		var yPos:Int = FlxG.height - 6;
		
		while ( yPos > FlxG.height - 10 )
		{
			while ( xPos < FlxG.width )
			{
				// There is an 80% chance a leaf will be placed at this ( xPos, yPos )
				
				if ( FlxRandom.chanceRoll( 80 ) )
				{
					var leaf:Leaf = new Leaf( xPos, yPos, FlxRandom.intRanged( 0,2 ) );
					leaf.solid = true;
					_leaves.add( leaf );
				}
				
				xPos++;
			}
			
			xPos = 0;
			yPos--;
		}
		
		// Make the tree
		
		var halfWidth:Int = Std.int( FlxG.width / 2 );
		
		_trunk = new FlxSprite( halfWidth - 2, FlxG.height - 25 );
		_trunk.makeGraphic( 4, 20, FlxColor.BLACK );
		
		_tree = new FlxTypedGroup<Branch>( 500 );
		
		areaFill( halfWidth - 10, halfWidth + 10, FlxG.height - 25, FlxG.height - 20, 30, 0, [ 4, 6 ] );
		areaFill( halfWidth - 6, halfWidth + 6, FlxG.height - 36, FlxG.height - 25, 60, 0, [ 6, 8 ] );
		areaFill( halfWidth - 18, halfWidth - 6, FlxG.height - 36, FlxG.height - 23, 25, 0, [ 4, 6 ] );
		areaFill( halfWidth + 6, halfWidth + 18, FlxG.height - 36, FlxG.height - 23, 25, 0, [ 4, 6 ] );
		areaFill( halfWidth - 14, halfWidth + 14, FlxG.height - 47, FlxG.height - 36, 40, 0, [ 3, 5 ] );
		areaFill( halfWidth - 8, halfWidth + 8, FlxG.height - 52, FlxG.height - 47, 20, 0, [ 2, 4 ] );
		
		// Put leaves on the tree
		
		areaFill( halfWidth - 12, halfWidth + 12, FlxG.height - 25, FlxG.height - 18, 20, 0, [ 1, 2 ], false );
		areaFill( halfWidth - 6, halfWidth + 6, FlxG.height - 36, FlxG.height - 25, 35, 0, [ 1, 2 ], false );
		areaFill( halfWidth - 20, halfWidth - 6, FlxG.height - 38, FlxG.height - 21, 18, 0, [ 1, 2 ], false );
		areaFill( halfWidth + 6, halfWidth + 20, FlxG.height - 38, FlxG.height - 21, 18, 0, [ 1, 2 ], false );
		areaFill( halfWidth - 16, halfWidth + 16, FlxG.height - 47, FlxG.height - 36, 25, 0, [ 1, 2 ], false );
		areaFill( halfWidth - 10, halfWidth + 10, FlxG.height - 54, FlxG.height - 47, 15, 0, [ 1, 2 ], false );
		
		_crazy = new FlxSprite( 0, 0, "images/crazy.png" );
		
		#if flash
		_crazy.blend = BlendMode.SCREEN;
		#end
		
		_crazy.alpha = 0;
		
		_ghosts = new FlxTypedGroup<Ghost>( 10 );
		_jacks = new FlxTypedGroup<Jack>( 10 );
		_wispsBG = new FlxTypedGroup<Wisp>( 10 );
		_wispsFG = new FlxTypedGroup<Wisp>( 10 );
		
		_mist = new FlxSprite( -210, 25, "images/mist.png" );
		_mist.moves = true;
		_mist.solid = false;
		_mist.alpha = 0.88;
		
		#if flash
		_mist.blend = BlendMode.OVERLAY;
		#end
		
		_ground = new FlxSprite( 0, FlxG.height - 5 );
		_ground.makeGraphic( FlxG.width, 5, FlxColor.BLACK );
		_ground.immovable = true;
		_ground.moves = false;
		_ground.solid = true;
		
		add( _sky );
		add( _wispsBG );
		add( _ground );
		add( _trunk );
		add( _tree );
		add( _leaves );
		add( _ghosts );
		add( _crazy );
		add( _mist );
		add( _jacks );
		add( _wispsFG );
		
		_collidables = new FlxGroup();
		_collidables.add( _leaves );
		_collidables.add( _ground );
		_collidables.add( _jacks );
		
		wind = FlxRandom.floatRanged( -WIND_MAX, WIND_MAX );
		_goal = FlxRandom.floatRanged( -WIND_MAX, WIND_MAX );
		
		super.create();
	}
	
	override public function update():Void
	{
		FlxG.collide( _collidables );
		// TODO: Collide leaves with jacks, call leafSplat
		
		if ( Math.abs( wind ) > Math.abs( _goal ) )
		{
			if ( _crazyMode )
			{
				_goal = FlxRandom.floatRanged( -WIND_MAX_CRAZY, WIND_MAX_CRAZY );
			}
			else
			{
				_goal = FlxRandom.floatRanged( -WIND_MAX, WIND_MAX );
			}
		}
		
		_mist.velocity.x = wind;
		
		if ( _mist.x < -500 + FlxG.width )
		{
			_mist.x = -500 + FlxG.width;
		}
		else if ( _mist.x > 0 )
		{
			_mist.x = 0;
		}
		
		if ( FlxRandom.chanceRoll( _crazyMode ? 10 : 5 ) )
		{
			var wisp = _wispsBG.recycle( Wisp );
			wisp.init( ( wind <= 0 ) ? FlxG.width + 1 : -1, FlxRandom.intRanged( -1, FlxG.height - 4 ) );
		}
		
		if ( FlxRandom.chanceRoll( _crazyMode ? 1 : 0.5 ) )
		{
			var wisp = _wispsFG.recycle( Wisp );
			wisp.init( ( wind <= 0 ) ? FlxG.width + 1 : -1, FlxRandom.intRanged( -1, FlxG.height - 4 ) );
		}
		
		if ( FlxRandom.chanceRoll( _crazyMode ? 20 : 0.1 ) )
		{
			var ghost = _ghosts.recycle( Ghost );
			ghost.init( FlxRandom.intRanged( 0, FlxG.width ), FlxG.height );
		}
		
		if ( _crazyMode && FlxRandom.chanceRoll( 0.5 ) )
		{
			var jack = _jacks.recycle( Jack );
			jack.init( ( wind > 0 ) ? -1 : FlxG.width + 1, FlxRandom.intRanged( -16, FlxG.height - 16 ) );
		}
		
		if ( _timer <= 0 )
		{
			_timer = TIMER_FREQ;
			wind += FlxRandom.floatRanged( 1, 3 ) * ( _goal / Math.abs( _goal ) ); 
			
			for ( branch in _tree.members )
			{
				branch.push( wind );
			}
			
			for ( leaf in _leaves.members )
			{
				leaf.push( wind );
			}
		}
		else
		{
			_timer -= FlxG.elapsed;
		}
		
		if ( FlxRandom.chanceRoll( 50 ) )
		{
			var newLeaf:Leaf = _leaves.recycle( Leaf );
			var posX:Int = ( wind > 0 ) ? -1 : FlxG.width + 1;
			var posY:Int = FlxRandom.intRanged( 0, FlxG.height ) - 16;
			newLeaf.reset( posX, posY );
		}
		
		#if !FLX_NO_KEYBOARD
		if ( FlxG.keys.justPressed.ONE )
		{
			_crazyMode = !_crazyMode;
			
			if ( _crazyMode )
			{
				FlxTween.multiVar( _crazy, { alpha: 0.66 }, 0.5 );
			}
			else
			{
				FlxTween.multiVar( _crazy, { alpha: 0 }, 0.5 );
			}
		}
		
		if ( FlxG.keys.justPressed.R )
		{
			FlxG.resetState();
		}
		
		if ( FlxG.keys.justPressed.F )
		{
			trace( "fps: " + Std.int( 1 / FlxG.elapsed ) );
		}
		#end
		
		super.update();
	}
	
	private function areaFill( MinX:Int, MaxX:Int, MinY:Int, MaxY:Int, Chance:Int, Weight:Int = 0, ?WeightArray:Array<Int>, IsBranch:Bool = true ):Void
	{
		var xPos:Int = MinX;
		var yPos:Int = MinY;
		
		while ( yPos < MaxY )
		{
			while ( xPos < MaxX )
			{
				if ( FlxRandom.chanceRoll( Chance ) )
				{
					var weight:Int = 0;
					
					if ( Weight == 0 )
					{
						weight = FlxRandom.intRanged( WeightArray[0], WeightArray[1] );
					} else {
						weight = Weight;
					}
					
					if ( IsBranch )
					{
						_tree.add( new Branch( xPos, yPos, weight ) );
					} else {
						_leaves.add( new Leaf( xPos, yPos, weight ) );
					}
				}
				
				xPos ++;
			}
			
			xPos = MinX;
			yPos ++;
		}
	}
	
	private function leafSplat( Pumpkin:Jack, OneLeaf:Leaf ):Void
	{
		if ( OneLeaf.landed )
		{
			OneLeaf.acceleration.y = OneLeaf.weight * 10;
			OneLeaf.velocity.y = -( 10 / OneLeaf.weight ) * FlxRandom.floatRanged( 0.8, 1.5 );
			OneLeaf.velocity.x = FlxRandom.floatRanged( -50, 50 );
			OneLeaf.falling = true;
			OneLeaf.landed = false;
		}
	}
}