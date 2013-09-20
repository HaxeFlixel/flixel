package flixel.ui;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;
<<<<<<< HEAD
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.FlxPoint;

/**
 * A lightweight trim-down of the button class, for invisible click areas
 */
class FlxClickArea extends FlxObject
{
	/**
	 * Shows the current state of the button, either <code>NORMAL</code>, 
	 * <code>HIGHLIGHT</code> or <code>PRESSED</code>
	 */
	public var status:Int;
		
=======
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.util.FlxPoint;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxClickArea extends FlxSprite
{
	public var status:Int;
	
>>>>>>> larsiusprime/dev
	/**
	 * This function is called when the button is released.
	 * We recommend assigning your main button behavior to this function
	 * via the <code>FlxButton</code> constructor.
	 */
	private var _onUp:Dynamic;
<<<<<<< HEAD
	
=======
	/**
	 * This function is called when the button is pressed down.
	 */
	private var _onDown:Dynamic;
	/**
	 * This function is called when the mouse goes over the button.
	 */
	private var _onOver:Dynamic;
	/**
	 * This function is called when the mouse leaves the button area.
	 */
	private var _onOut:Dynamic;
>>>>>>> larsiusprime/dev
	/**
	 * The params to pass to the <code>_onUp</code> function
	 */
	private var _onUpParams:Array<Dynamic>;
<<<<<<< HEAD
	
=======
	/**
	 * The params to pass to the <code>_onDown</code> function
	 */
	private var _onDownParams:Array<Dynamic>;
	/**
	 * The params to pass to the <code>_onOver</code> function
	 */
	private var _onOverParams:Array<Dynamic>;
	/**
	 * The params to pass to the <code>_onOut</code> function
	 */
	private var _onOutParams:Array<Dynamic>;
>>>>>>> larsiusprime/dev
	/**
	 * Tracks whether or not the button is currently pressed.
	 */
	private var _pressed:Bool;
<<<<<<< HEAD
	
=======
>>>>>>> larsiusprime/dev
	/**
	 * Whether or not the button has initialized itself yet.
	 */
	private var _initialized:Bool;
	
<<<<<<< HEAD
	
	/**
	 * Creates a new FlxClickArea object
=======
	// TODO: Implement checkbox-style behaviour.
	
	/**
	 * Creates a new <code>FlxTypedButton</code> object with a gray background
>>>>>>> larsiusprime/dev
	 * and a callback function on the UI thread.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
<<<<<<< HEAD
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic)
	{
		super(X, Y, 80, 20);
		
		//loadGraphic(FlxAssets.IMG_BUTTON, true, false, 80, 20);
		
		_onUp = OnClick;
		
		_onUpParams = [];
				
=======
	 * @param	W			The width of the area
	 * @param	H 			The height of the area
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, W:Int=80, H:Int=20, ?OnClick:Dynamic)
	{
		super(X, Y);
		
		makeGraphic(W, H);
		
		_onUp = OnClick;
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = [];
		_onDownParams = [];
		_onOutParams = [];
		_onOverParams = [];
		
>>>>>>> larsiusprime/dev
		status = FlxButton.NORMAL;
		_pressed = false;
		_initialized = false;
		
		scrollFactor.x = 0;
		scrollFactor.y = 0;
	}
	
	/**
	 * Called by the game state when state is changed (if this object belongs to the state)
	 */
	override public function destroy():Void
	{
		if (FlxG.stage != null)
		{
			#if !FLX_NO_MOUSE
				Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			#end
			
			#if !FLX_NO_TOUCH
				Lib.current.stage.removeEventListener(TouchEvent.TOUCH_END, onMouseUp);
			#end
		}
		
		_onUp = null;
<<<<<<< HEAD
		
		_onUpParams = null;
		
=======
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = null;
		_onDownParams = null;
		_onOutParams = null;
		_onOverParams = null;
	
>>>>>>> larsiusprime/dev
		super.destroy();
	}
	
	/**
	 * Called by the game loop automatically, handles mouseover and click detection.
	 */
	override public function update():Void
	{
		if (!_initialized)
		{
			if (FlxG.stage != null)
			{
				#if !FLX_NO_MOUSE
					Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				#end
				#if !FLX_NO_TOUCH
					Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onMouseUp);
				#end
				_initialized = true;
			}
		}
<<<<<<< HEAD
		super.update();
		
=======
		super.update();		
>>>>>>> larsiusprime/dev
		updateButton(); //Basic button logic
	}
	
	/**
	 * Basic button update logic
	 */
	function updateButton():Void
	{
		// Figure out if the button is highlighted or pressed or what
		var continueUpdate = false;
		
		#if !FLX_NO_MOUSE
			continueUpdate = true;
		#end
		
		#if !FLX_NO_TOUCH
			continueUpdate = true;
		#end
		
		if (continueUpdate)
		{
			if (cameras == null)
			{
				cameras = FlxG.cameras.list;
			}
			var camera:FlxCamera;
			var i:Int = 0;
			var l:Int = cameras.length;
			var offAll:Bool = true;
			while (i < l)
			{
				camera = cameras[i++];
				#if !FLX_NO_MOUSE
					FlxG.mouse.getWorldPosition(camera, _point);
					offAll = (updateButtonStatus(_point, camera, FlxG.mouse.justPressed) == false) ? false : offAll;
				#end
				#if !FLX_NO_TOUCH
					for (touch in FlxG.touches.list)
					{
						touch.getWorldPosition(camera, _point);
						offAll = (updateButtonStatus(_point, camera, touch.justPressed) == false) ? false : offAll;
					}
				#end
				
				if (!offAll)
				{
					break;
				}
			}
			if (offAll)
			{
<<<<<<< HEAD
				status = FlxButton.NORMAL;
			}
		}		
	}
	
	/**
	 * Updates status and handles the onDown and onOver logic (callback functions + playing sounds).
=======
				if (status != FlxButton.NORMAL)
				{
					if (_onOut != null)
					{
						Reflect.callMethod(null, _onOut, _onOutParams);
					}
					
				}
				status = FlxButton.NORMAL;
			}
		}
			
		// Then pick the appropriate frame of animation
		frame = status;
	}
	
	/**
	 * Updates status and handles the onDown and onOver logic (callback functions)
>>>>>>> larsiusprime/dev
	 */
	private function updateButtonStatus(Point:FlxPoint, Camera:FlxCamera, JustPressed:Bool):Bool
	{
		var offAll:Bool = true;
		
		if (overlapsPoint(Point, true, Camera))
		{
			offAll = false;
			
			if (JustPressed)
			{
				status = FlxButton.PRESSED;
<<<<<<< HEAD
=======
				if (_onDown != null)
				{
					Reflect.callMethod(null, _onDown, _onDownParams);
				}
>>>>>>> larsiusprime/dev
			}
			if (status == FlxButton.NORMAL)
			{
				status = FlxButton.HIGHLIGHT;
<<<<<<< HEAD
=======
				if (_onOver != null)
				{
					Reflect.callMethod(null, _onOver, _onOverParams);
				}
>>>>>>> larsiusprime/dev
			}
		}
		
		return offAll;
	}
	
<<<<<<< HEAD
=======
	override public function draw():Void {
		//do nothing! 
		//don't draw this stupid thing
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Helper function to draw the debug graphic for the label as well.
	 */
	override public function drawDebug():Void 
	{
		super.drawDebug();		
	}
	#end
	
	
>>>>>>> larsiusprime/dev
	/**
	 * Set the callback function for when the button is released.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnUpCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onUp = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onUpParams = Params;
	}
	
	/**
<<<<<<< HEAD
=======
	 * Set the callback function for when the button is being pressed on.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnDownCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onDown = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onDownParams = Params;
	}
	
	/**
	 * Set the callback function for when the button is being hovered over.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnOverCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onOver = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onOverParams = Params;
	}
	
	/**
	 * Set the callback function for when the button mouse leaves the button area.
	 * 
	 * @param	Callback	The callback function.
	 * @param	Params		Any params you want to pass to the function. Optional!
	 */
	inline public function setOnOutCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onOut = Callback;
		
		if (Params == null)
		{
			Params = [];
		}
		
		_onOutParams = Params;
	}
	
	/**
>>>>>>> larsiusprime/dev
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxMisc.openURL()</code>).
	 */
	private function onMouseUp(event:Event):Void
	{
		if (!exists || !visible || !active || (status != FlxButton.PRESSED))
		{
			return;
		}
		if (_onUp != null)
		{
			Reflect.callMethod(null, _onUp, _onUpParams);
		}
<<<<<<< HEAD
=======
		
>>>>>>> larsiusprime/dev
		status = FlxButton.NORMAL;
	}
}