package flixel.ui;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;
import flash.media.Sound;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.system.input.FlxTouch;
import flixel.system.layer.Atlas;
import flixel.util.FlxPoint;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxTypedButton<T:FlxSprite> extends FlxSprite
{
	/**
	 * The text that appears on the button.
	 */
	public var label:T;
	/**
	 * Controls the offset (from top left) of the text from the button.
	 */
	public var labelOffset:FlxPoint;
	/**
	 * Shows the current state of the button, either <code>NORMAL</code>, 
	 * <code>HIGHLIGHT</code> or <code>PRESSED</code>
	 */
	public var status:Int;
	/**
	 * Set this to play a sound when the mouse goes over the button.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundOver:FlxSound;
	/**
	 * Set this to play a sound when the mouse leaves the button.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundOut:FlxSound;
	/**
	 * Set this to play a sound when the button is pressed down.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundDown:FlxSound;
	/**
	 * Set this to play a sound when the button is released.
	 * We recommend using the helper function setSounds()!
	 */
	public var soundUp:FlxSound;
	
	/**
	 * This function is called when the button is released.
	 * We recommend assigning your main button behavior to this function
	 * via the <code>FlxButton</code> constructor.
	 */
	private var _onUp:Dynamic;
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
	/**
	 * The params to pass to the <code>_onUp</code> function
	 */
	private var _onUpParams:Array<Dynamic>;
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
	/**
	 * Tracks whether or not the button is currently pressed.
	 */
	private var _pressed:Bool;
	/**
	 * Whether or not the button has initialized itself yet.
	 */
	private var _initialized:Bool;
	
	// TODO: Implement checkbox-style behaviour.
	
	/**
	 * Creates a new <code>FlxTypedButton</code> object with a gray background
	 * and a callback function on the UI thread.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Dynamic)
	{
		super(X, Y);
		
		loadGraphic(FlxAssets.imgDefaultButton, true, false, 80, 20);
		
		_onUp = OnClick;
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = [];
		_onDownParams = [];
		_onOutParams = [];
		_onOverParams = [];
		
		soundOver = null;
		soundOut = null;
		soundDown = null;
		soundUp = null;
		
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
		if (label != null)
		{
			label.destroy();
			label = null;
		}
		
		_onUp = null;
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = null;
		_onDownParams = null;
		_onOutParams = null;
		_onOverParams = null;
		
		if (soundOver != null)
		{
			soundOver.destroy();
		}
		if (soundOut != null)
		{
			soundOut.destroy();
		}
		if (soundDown != null)
		{
			soundDown.destroy();
		}
		if (soundUp != null)
		{
			soundUp.destroy();
		}
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
		super.update();
		
		updateButton(); //Basic button logic

		// Default button appearance is to simply update
		// the label appearance based on animation frame.
		if (label == null)
		{
			return;
		}
		switch (frame)
		{
			case FlxButton.HIGHLIGHT:
				label.alpha = 1.0;
			case FlxButton.PRESSED:
				label.alpha = 0.5;
				label.y++;
			default:
				label.alpha = 0.8;
		}
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
					offAll = (updateButtonStatus(_point, camera, FlxG.mouse.justPressed()) == false) ? false : offAll;
				#end
				#if !FLX_NO_TOUCH
					for (j in 0...FlxG.touchManager.touches.length)
					{
						var touch:FlxTouch = FlxG.touchManager.touches[j];
						touch.getWorldPosition(camera, _point);
						offAll = (updateButtonStatus(_point, camera, touch.justPressed()) == false) ? false : offAll;
					}
				#end
			}
			if (offAll)
			{
				if (status != FlxButton.NORMAL)
				{
					if (_onOut != null)
					{
						Reflect.callMethod(null, _onOut, _onOutParams);
					}
					if (soundOut != null)
					{
						soundOut.play(true);
					}
				}
				status = FlxButton.NORMAL;
			}
		}
	
		// Then if the label and/or the label offset exist,
		// position them to match the button.
		if (label != null)
		{
			label.x = x;
			label.y = y;
			
			if (labelOffset != null)
			{	
				label.x += labelOffset.x;
				label.y += labelOffset.y;
			}
			
			label.scrollFactor = scrollFactor;
		}
		
		// Then pick the appropriate frame of animation
		frame = status;
	}
	
	/**
	 * Updates status and handles the onDown and onOver logic (callback functions + playing sounds).
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
				if (_onDown != null)
				{
					Reflect.callMethod(null, _onDown, _onDownParams);
				}
				if (soundDown != null)
				{
					soundDown.play(true);
				}
			}
			if (status == FlxButton.NORMAL)
			{
				status = FlxButton.HIGHLIGHT;
				if (_onOver != null)
				{
					Reflect.callMethod(null, _onOver, _onOverParams);
				}
				if (soundOver != null)
				{
					soundOver.play(true);
				}
			}
		}
		
		return offAll;
	}
	
	/**
	 * Just draws the button graphic and text label to the screen.
	 */
	override public function draw():Void
	{
		super.draw();
		
		if (label != null)
		{
			label.cameras = cameras;
			label.draw();
		}
	}
	
	#if !FLX_NO_DEBUG
	/**
	 * Helper function to draw the debug graphic for the label as well.
	 */
	override public function drawDebug():Void 
	{
		super.drawDebug();
		
		if (label != null)
		{
			label.drawDebug();
		}
	}
	#end
	
	// TODO: Return from Sound -> Class<Sound>
	/**
	 * Set sounds to play during mouse-button interactions.
	 * These operations can be done manually as well, and the public
	 * sound variables can be used after this for more fine-tuning,
	 * such as positional audio, etc.
	 * 
	 * @param	SoundOver			What embedded sound effect to play when the mouse goes over the button. Default is null, or no sound.
	 * @param 	SoundOverVolume		How load the that sound should be.
	 * @param 	SoundOut			What embedded sound effect to play when the mouse leaves the button area. Default is null, or no sound.
	 * @param 	SoundOutVolume		How load the that sound should be.
	 * @param 	SoundDown			What embedded sound effect to play when the mouse presses the button down. Default is null, or no sound.
	 * @param 	SoundDownVolume		How load the that sound should be.
	 * @param 	SoundUp				What embedded sound effect to play when the mouse releases the button. Default is null, or no sound.
	 * @param 	SoundUpVolume		How load the that sound should be.
	 */
	public function setSounds(?SoundOver:Sound, SoundOverVolume:Float = 1, ?SoundOut:Sound, SoundOutVolume:Float = 1, ?SoundDown:Sound, SoundDownVolume:Float = 1, ?SoundUp:Sound, SoundUpVolume:Float = 1):Void
	{
		if (SoundOver != null)
		{
			soundOver = FlxG.sound.load(SoundOver, SoundOverVolume);
		}
		if (SoundOut != null)
		{
			soundOut = FlxG.sound.load(SoundOut, SoundOutVolume);
		}
		if (SoundDown != null)
		{
			soundDown = FlxG.sound.load(SoundDown, SoundDownVolume);
		}
		if (SoundUp != null)
		{
			soundUp = FlxG.sound.load(SoundUp, SoundUpVolume);
		}
	}
	
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
		if (soundUp != null)
		{
			soundUp.play(true);
		}
		status = FlxButton.NORMAL;
	}
	
	#if !flash
	override private function set_atlas(value:Atlas):Atlas 
	{
		var atl:Atlas = super.set_atlas(value);
		if (atl == value && label != null)
		{
			// Maybe there is enough place for font image
			label.atlas = value;
		}
		return value;
	}
	#end
}