package flixel.ui;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;
import flixel.FlxCamera;
#if !FLX_NO_SOUND_SYSTEM
import flash.media.Sound;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
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
	public var status(default, set):Int;
	
	public function set_status(i:Int):Int {
		/*Update label's alpha whenever status is changed, so we don't have to expensively do it in update()*/
		status = i;
		if (status < status_alphas.length) {
			if (label != null) {
				label.alpha = status_alphas[status];
			}
		}
		return status;
	}
	
	/**
	 * Customizable values for what alpha the label should be at for each button state
	 * default is = [0.8, 1.0, 0.5], for Normal, Hilight, Pressed
	 */
	public var status_alphas:Array<Float>;
	
	#if !FLX_NO_SOUND_SYSTEM
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
	#end
	
	/**
	 * This function is called when the button is released. We recommend assigning your 
	 * main button behavior to this function via the <code>FlxButton</code> constructor.
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
	
	private var _touchPointID:Int;
	
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
		
		loadGraphic(FlxAssets.IMG_BUTTON, true, false, 80, 20);
		
		_onUp = OnClick;
		_onDown = null;
		_onOut = null;
		_onOver = null;
		
		_onUpParams = [];
		_onDownParams = [];
		_onOutParams = [];
		_onOverParams = [];
		
		#if !FLX_NO_SOUND_SYSTEM
		soundOver = null;
		soundOut = null;
		soundDown = null;
		soundUp = null;
		#end
		
		status = FlxButton.NORMAL;
		status_alphas = [0.8, 1.0, 0.5]
		
		_pressed = false;
		_initialized = false;
		
		scrollFactor.x = 0;
		scrollFactor.y = 0;
		
		_touchPointID = -1;
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
		
		#if !FLX_NO_SOUND_SYSTEM
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
		#end
		
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
		
		/*switch (status)
		{
			case FlxButton.HIGHLIGHT:
				label.alpha = 1.0;
			case FlxButton.PRESSED:
				label.alpha = 0.5;
				label.y++;
			default:
				label.alpha = 0.8;
		}*/
	}
	
	/**
	 * Basic button update logic
	 */
	function updateButton():Void
	{
		// Need to update this if at least mouse or touch input is enabled
		#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
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
					offAll = (updateButtonStatus(_point, camera, FlxG.mouse.justPressed, 1) == false) ? false : offAll;
				#end
				#if !FLX_NO_TOUCH
					for (touch in FlxG.touches.list)
					{
						if (_touchPointID == -1)
						{
							if (touch.justPressed)
							{
								touch.getWorldPosition(camera, _point);
								offAll = (updateButtonStatus(_point, camera, touch.justPressed, touch.touchPointID) == false) ? false : offAll;
							}
						}
						else if (touch.touchPointID == _touchPointID)
						{
							touch.getWorldPosition(camera, _point);
							offAll = false;
							
							if (touch.justReleased || !overlapsPoint(_point, true, camera))
							{
								offAll = true;
								onMouseUp(null);
							}
						}
					}
				#end
				
				if (!offAll)
				{
					break;
				}
			}
			if (offAll)
			{
				if (status != FlxButton.NORMAL)
				{
					if (_onOut != null)
					{
						Reflect.callMethod(null, _onOut, _onOutParams);
					}
					#if !FLX_NO_SOUND_SYSTEM
					if (soundOut != null)
					{
						soundOut.play(true);
					}
					#end
				}
				
				status = FlxButton.NORMAL;
			}
		#end
		
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
		
		frame = framesData.frames[status];
	}
	
	/**
	 * Updates status and handles the onDown and onOver logic (callback functions + playing sounds).
	 */
	private function updateButtonStatus(Point:FlxPoint, Camera:FlxCamera, JustPressed:Bool, TouchID:Int):Bool
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
				#if !FLX_NO_SOUND_SYSTEM
				if (soundDown != null)
				{
					soundDown.play(true);
				}
				#end
				_touchPointID = TouchID;
			}
			if (status == FlxButton.NORMAL)
			{
				#if !mobile
					status = FlxButton.HIGHLIGHT;
				#end
				if (_onOver != null)
				{
					Reflect.callMethod(null, _onOver, _onOverParams);
				}
				#if !FLX_NO_SOUND_SYSTEM
				if (soundOver != null)
				{
					soundOver.play(true);
				}
				#end
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
	
	#if !FLX_NO_SOUND_SYSTEM
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
	#end
	
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
		#if !FLX_NO_SOUND_SYSTEM
		if (soundUp != null)
		{
			soundUp.play(true);
		}
		#end
		_touchPointID = -1;
		status = FlxButton.NORMAL;
	}
}