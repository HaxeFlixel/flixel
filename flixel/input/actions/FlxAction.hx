package flixel.input.actions;
import flixel.util.FlxArrayUtil;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputAnalog;
import flixel.input.actions.FlxActionInputDigital;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

using flixel.util.FlxArrayUtil;

/**
 * A digital action is a binary on/off event like "jump" or "fire". 
 * FlxActions let you attach multiple inputs to a single in-game action, 
 * so "jump" could be performed by a keyboard press, a mouse click,
 * or a gamepad button press.
 */
class FlxActionDigital extends FlxAction
{
	
	/**
	 * Function to call when this action occurs
	 */
	 public var callback(default, null):FlxActionDigital->Void;
	
	/**
	 * Create a new digital action
	 * @param	Name	name of the action
	 * @param	Callback	function to call when this action occurs
	 */
	public function new(Name:String, ?Callback:FlxActionDigital->Void)
	{
		super(FlxInputType.DIGITAL, Name);
		callback = Callback;
	}
	
	/**
	 * Add a digital input that will trigger this action
	 * @param	input
	 * @return
	 */
	public function addInput(input:FlxActionInputDigital):FlxActionDigital
	{
		addGenericInput(input);
		return this;
	}
	
	override public function destroy():Void 
	{
		callback = null;
		super.destroy();
	}
	
	override public function check():Bool 
	{
		var val = super.check();
		if (val && callback != null)
		{
			callback(this);
		}
		return val;
	}
}

/**
 * Analog actions are events with continuous (floating-point) values, and up
 * to two axes (x,y). This is for events like "move" and "accelerate" where the
 * event is not simply on or off.
 * 
 * FlxActions let you attach multiple inputs to a single in-game action, 
 * so "move" could be performed by a gamepad joystick, a mouse movement, etc.
 */
class FlxActionAnalog extends FlxAction
{
	/**
	 * Function to call when this action occurs
	 */
	public var callback(default, null):FlxActionAnalog->Void;
	
	/**
	 * X axis value, or the value of a single-axis analog input.
	 */
	public var x(get, null):Float;
	 
	/**
	 * Y axis value. (If action only has single-axis input this is always == 0)
	 */
	public var y(get, null):Float;
	
	/**
	 * Create a new analog action
	 * @param	Name	name of the action
	 * @param	Callback	function to call when this action occurs
	 */
	public function new(Name:String, ?Callback:FlxActionAnalog->Void)
	{
		super(FlxInputType.ANALOG, Name);
		callback = Callback;
	}
	
	/**
	 * Add an analog input that will trigger this action
	 * @param	input
	 * @return
	 */
	public function addInput(input:FlxActionInputAnalog):FlxActionAnalog
	{
		addGenericInput(input);
		return this;
	}
	
	override public function update():Void 
	{
		_x = null;
		_y = null;
		super.update();
	}
	
	override public function destroy():Void 
	{
		callback = null;
		super.destroy();
	}
	
	override public function toString():String 
	{
		return "FlxAction(" + type + ") name:" + name + " x/y:" + _x + "," + _y;
	}
	
	override public function check():Bool 
	{
		var val = super.check();
		if (val && callback != null)
		{
			callback(this);
		}
		return val;
	}
	
	private function get_x():Float
	{
		(_x != null) ? return _x : return 0;
	}
	
	private function get_y():Float 
	{
		(_y != null) ? return _y : return 0;
	}
}

@:allow(flixel.input.actions.FlxActionDigital, flixel.input.actions.FlxActionAnalog, flixel.input.actions.FlxActionSet)
class FlxAction implements IFlxDestroyable
{
	/**
	 * Digital or Analog
	 */
	public var type(default, null):FlxInputType;
	
	/**
	 * The name of the action, "jump", "fire", "move", etc.
	 */
	public var name(default, null):String;
	
	/**
	 * This action's numeric handle for the Steam API (ignored if not using Steam)
	 */
	private var steamHandle(default, null):Int = -1;
	
	/**
	 * If true, this action has just been triggered
	 */
	public var fire(default, null):Bool = false;
	
	/**
	 * The inputs attached to this action
	 */
	public var inputs:Array<FlxActionInput>;
	
	private var _x:Null<Float> = null;
	private var _y:Null<Float> = null;
	
	private var _timestamp:Int = 0;
	private var _check:Bool = false;
	
	private function new(InputType:FlxInputType, Name:String)
	{
		type = InputType;
		name = Name;
		inputs = [];
	}
	
	public function removeInput(Input:FlxActionInput, Destroy:Bool = false):Void
	{
		inputs.remove(Input);
		if (Destroy)
		{
			Input.destroy();
		}
	}
	
	public function toString():String
	{
		return("FlxAction(" + type + ") name:" + name);
	}
	
	/**
	 * See if this action has just been triggered
	 * @return
	 */
	@:access(FlxG.game)
	public function check():Bool
	{
		_x = null;
		_y = null;
		
		if (_timestamp == FlxG.game._total)
		{
			fire = _check;
			return _check;	//run no more than once per frame
		}
		
		_timestamp = FlxG.game._total;
		_check = false;
		
		var len = inputs.length;
		for (i in -(len - 1)...0)
		{
			var j = -i;
			var input = inputs[j];
			
			if (input.destroyed)
			{
				inputs.splice(j, 1);
				continue;
			}
			
			input.update();
			
			if (input.check(this))
			{
				_check = true;
			}
		}
		
		fire = _check;
		return _check;
	}
	
	/**
	 * Check input states & fire callbacks if anything is triggered
	 */
	public function update():Void
	{
		check();
	}
	
	public function destroy():Void
	{
		FlxDestroyUtil.destroyArray(inputs);
		inputs = null;
	}
	
	public function match(other:FlxAction):Bool
	{
		return name == other.name && steamHandle == other.steamHandle;
	}
	
	private function addGenericInput(input:FlxActionInput):FlxAction
	{
		if (!checkExists(input)) inputs.push(input);
		
		return this;
	}
	
	private function checkExists(input:FlxActionInput):Bool
	{
		return inputs.contains(input);
	}
}