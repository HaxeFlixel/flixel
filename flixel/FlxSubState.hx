package flixel;

<<<<<<< HEAD:src/org/flixel/FlxSubState.hx
import nme.display.BitmapData;
import org.flixel.system.BGSprite;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.DrawStackItem;
import org.flixel.system.layer.TileSheetData;
=======
import flixel.system.BGSprite;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSubState.hx

/**
 * This is the basic game "state" object - e.g. in a simple game
 * you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup.
 * And really, it's not even that fancy.
 */
class FlxSubState extends FlxState
{
	public var _parentState:FlxState;
	
	public var closeCallback:Void->Void;
	
	#if !flash
	private var _bgSprite:BGSprite;
	#end
	
<<<<<<< HEAD:src/org/flixel/FlxSubState.hx
	public function new()
=======
	/**
	 * Internal helper for substates which can be reused
	 */
	private var _initialized:Bool = false;
	
	public var initialized(get_initialized, null):Bool;
	
	private function get_initialized():Bool { return _initialized; }
	
	/**
	 * Internal helper method
	 */
	public function initialize():Void { _initialized = true; }
	
	/**
	 * Substate constructor
	 * @param	bgColor		background color for this substate
	 * @param	useMouse	whether to show mouse pointer or not
	 */
	public function new(bgColor:Int = 0x00000000, useMouse:Bool = false)
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSubState.hx
	{
		super();
		
		_bgColor = FlxG.TRANSPARENT;
		closeCallback = null;
		
		#if !flash
		_bgSprite = new BGSprite();
		#end
	}
	
	override private function get_bgColor():Int 
	{
		return _bgColor;
	}
	
<<<<<<< HEAD:src/org/flixel/FlxSubState.hx
	override private function set_bgColor(value:Int):Int 
=======
	override private function set_bgColor(value:Int):Int
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/FlxSubState.hx
	{
		_bgColor = value;
		#if !flash
		_bgSprite.pixels.setPixel32(0, 0, _bgColor);
		#end
		return value;
	}
	
	override public function draw():Void
	{
		//Draw background
		#if flash
		if(cameras == null) { cameras = FlxG.cameras.list; }
		var i:Int = 0;
		var l:Int = cameras.length;
		while (i < l)
		{
			var camera:FlxCamera = cameras[i++];
			camera.fill(this.bgColor);
		}
		#else
		_bgSprite.draw();
		#end

		//Now draw all children
		super.draw();
	}
	
	public function close():Void
	{
		if (_parentState != null) 
		{ 
			_parentState.subStateCloseHandler(); 
		}
		else 
		{ 
			/* Missing parent from this state! Do something!!" */ 
		}
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_parentState = null;
		closeCallback = null;
	}

}