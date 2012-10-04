package org.flixel;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.TouchEvent;
import nme.media.Sound;
import nme.media.Sound;
import org.flixel.system.input.Touch;
import org.flixel.system.tileSheet.TileSheetManager;

import org.flixel.FlxSprite;

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxButton extends FlxSprite
{
	/**
	 * Use this to toggle checkbox-style behavior.
	 */
	public var on(default, default):Bool;
	
	/**
	 * Used with public variable <code>status</code>, means not highlighted or pressed.
	 */
	static public inline var NORMAL:Int = 0;
	/**
	 * Used with public variable <code>status</code>, means highlighted (usually from mouse over).
	 */
	static public inline var HIGHLIGHT:Int = 1;
	/**
	 * Used with public variable <code>status</code>, means pressed (usually from mouse click).
	 */
	static public inline var PRESSED:Int = 2;
	/**
	 * The text that appears on the button.
	 */
	public var label:FlxText;
	/**
	 * Controls the offset (from top left) of the text from the button.
	 */
	public var labelOffset:FlxPoint;
	/**
	 * This function is called when the button is released.
	 * We recommend assigning your main button behavior to this function
	 * via the <code>FlxButton</code> constructor.
	 */
	public var onUp:Void->Void;
	/**
	 * This function is called when the button is pressed down.
	 */
	public var onDown:Void->Void;
	/**
	 * This function is called when the mouse goes over the button.
	 */
	public var onOver:Void->Void;
	/**
	 * This function is called when the mouse leaves the button area.
	 */
	public var onOut:Void->Void;
	/**
	 * Shows the current state of the button.
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
	 * Tracks whether or not the button is currently pressed.
	 */
	private var _pressed:Bool;
	/**
	 * Whether or not the button has initialized itself yet.
	 */
	private var _initialized:Bool;
	
	/**
	 * Creates a new <code>FlxButton</code> object with a gray background
	 * and a callback function on the UI thread.
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Label		The text that you want to appear on the button.
	 * @param	OnClick		The function to call whenever the button is clicked.
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, ?Label:String = null, ?OnClick:Void->Void = null)
	{
		super(X, Y);
		if(Label != null)
		{
			label = new FlxText(0, 0, 80, Label);
			label.setFormat(null, 8, 0x333333, "center");
			labelOffset = new FlxPoint( -1, 3);
		}
		loadGraphic(FlxAssets.imgDefaultButton, true, false, 80, 20);
		
		onUp = OnClick;
		onDown = null;
		onOut = null;
		onOver = null;
		
		soundOver = null;
		soundOut = null;
		soundDown = null;
		soundUp = null;

		status = NORMAL;
		on = false;
		_pressed = false;
		_initialized = false;
	}
	
	override public function loadGraphic(Graphic:Dynamic, ?Animated:Bool = false, ?Reverse:Bool = false, Width:Int = 0, ?Height:Int = 0, ?Unique:Bool = false, ?Key:String = null):FlxSprite 
	{
		var tempSprite:FlxSprite = super.loadGraphic(Graphic, Animated, Reverse, FlxU.fromIntToUInt(Width), FlxU.fromIntToUInt(Height), Unique, Key);
		swapTileSheets();
		return tempSprite;
	}
	
	/**
	 * Called by the game state when state is changed (if this object belongs to the state)
	 */
	override public function destroy():Void
	{
		if (FlxG.stage != null)
		{
			if (!FlxG.supportsTouchEvents)
			{
				#if (flash || js)
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				#else
				FlxGame.clickableArea.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				#end
			}
			else
			{
				#if (flash || js)
				FlxG.stage.removeEventListener(TouchEvent.TOUCH_END, onMouseUp);
				#else
				FlxGame.clickableArea.removeEventListener(TouchEvent.TOUCH_END, onMouseUp);
				#end
			}
		}
		if (label != null)
		{
			label.destroy();
			label = null;
		}
		onUp = null;
		onDown = null;
		onOut = null;
		onOver = null;
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
	 * Since button uses its own mouse handler for thread reasons,
	 * we run a little pre-check here to make sure that we only add
	 * the mouse handler when it is actually safe to do so.
	 */
	override public function preUpdate():Void
	{
		super.preUpdate();
		
		if (!_initialized)
		{
			if (FlxG.stage != null)
			{
				if (!FlxG.supportsTouchEvents)
				{
					#if (flash || js)
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					#else
					FlxGame.clickableArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					#end
				}
				else
				{
					#if (flash || js)
					FlxG.stage.addEventListener(TouchEvent.TOUCH_END, onMouseUp);
					#else
					FlxGame.clickableArea.addEventListener(TouchEvent.TOUCH_END, onMouseUp);
					#end
				}
				_initialized = true;
			}
		}
	}
	
	/**
	 * Called by the game loop automatically, handles mouseover and click detection.
	 */
	override public function update():Void
	{
		updateButton(); //Basic button logic

		//Default button appearance is to simply update
		// the label appearance based on animation frame.
		if (label == null)
		{
			return;
		}
		switch (frame)
		{
			case HIGHLIGHT:	//Extra behavior to accomodate checkbox logic.
				label.alpha = 1.0;
			case PRESSED:
				label.alpha = 0.5;
				label.y++;
			//case NORMAL:
			default:
				label.alpha = 0.8;
		}
	}
	
	/**
	 * Basic button update logic
	 */
	function updateButton():Void
	{
		//Figure out if the button is highlighted or pressed or what
		// (ignore checkbox behavior for now).
		if (FlxG.mouse.visible || FlxG.supportsTouchEvents)
		{
			if (cameras == null)
			{
				cameras = FlxG.cameras;
			}
			var camera:FlxCamera;
			var i:Int = 0;
			var l:Int = cameras.length;
			var offAll:Bool = true;
			while (i < l)
			{
				camera = cameras[i++];
				if (!FlxG.supportsTouchEvents)
				{
					FlxG.mouse.getWorldPosition(camera, _point);
					offAll = (updateButtonStatus(_point, camera, FlxG.mouse.justPressed()) == false) ? false : offAll;
				}
				else
				{
					for (j in 0...FlxG.touchManager.touches.length)
					{
						var touch:Touch = FlxG.touchManager.touches[j];
						touch.getWorldPosition(camera, _point);
						offAll = (updateButtonStatus(_point, camera, touch.justPressed()) == false) ? false : offAll;
					}
				}
			}
			if (offAll)
			{
				if (status != NORMAL)
				{
					if (onOut != null)
					{
						onOut();
					}
					if (soundOut != null)
					{
						soundOut.play(true);
					}
				}
				status = NORMAL;
			}
		}
	
		//Then if the label and/or the label offset exist,
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
		
		//Then pick the appropriate frame of animation
		if ((status == HIGHLIGHT) && on)
		{
			frame = NORMAL;
		}
		else
		{
			frame = status;
		}
	}
	
	private function updateButtonStatus(Point:FlxPoint, Camera:FlxCamera, JustPressed:Bool):Bool
	{
		var offAll:Bool = true;
		if (overlapsPoint(Point, true, Camera))
		{
			offAll = false;
			if (JustPressed)
			{
				status = PRESSED;
				if (onDown != null)
				{
					onDown();
				}
				if (soundDown != null)
				{
					soundDown.play(true);
				}
			}
			if (status == NORMAL)
			{
				status = HIGHLIGHT;
				if (onOver != null)
				{
					onOver();
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
	
	#if flash 
	override public function makeGraphic(Width:UInt, Height:UInt, ?Color:UInt = 0xffffffff, ?Unique:Bool = false, ?Key:String = null):FlxSprite
	#else
	override public function makeGraphic(Width:Int, Height:Int, ?Color:BitmapInt32, ?Unique:Bool = false, ?Key:String = null):FlxSprite
	#end
	{
		#if !flash
		if (Color == null)
		{
			#if (cpp || js)
			Color = 0xffffffff;
			#elseif neko
			Color = { rgb: 0xffffff, a: 0xff };
			#end
		}
		#end
		
		var result:FlxSprite = super.makeGraphic(Width, Height, Color, Unique, Key);
		swapTileSheets();
		return result;
	}
	
	/**
	 * Helper function for changing draw order of button's background and label.
	 */
	private function swapTileSheets():Void
	{
		#if (cpp || neko)
		if (label != null)
		{
			var labelIndex:Int = label.getTileSheetIndex();
			var bgIndex:Int = this.getTileSheetIndex();
			if (bgIndex > labelIndex)
			{
				TileSheetManager.swapTileSheets(labelIndex, bgIndex);
			}
		}
		#end
	}
	
	/**
	 * Updates the size of the text field to match the button.
	 */
	override private function resetHelpers():Void
	{
		super.resetHelpers();
		if (label != null)
		{
			label.width = label.frameWidth = Std.int(width);
			label.size = label.size;
		}
	}
	
	// TODO: Return from Sound -> Class<Sound>
	/**
	 * Set sounds to play during mouse-button interactions.
	 * These operations can be done manually as well, and the public
	 * sound variables can be used after this for more fine-tuning,
	 * such as positional audio, etc.
	 * @param SoundOver			What embedded sound effect to play when the mouse goes over the button. Default is null, or no sound.
	 * @param SoundOverVolume	How load the that sound should be.
	 * @param SoundOut			What embedded sound effect to play when the mouse leaves the button area. Default is null, or no sound.
	 * @param SoundOutVolume	How load the that sound should be.
	 * @param SoundDown			What embedded sound effect to play when the mouse presses the button down. Default is null, or no sound.
	 * @param SoundDownVolume	How load the that sound should be.
	 * @param SoundUp			What embedded sound effect to play when the mouse releases the button. Default is null, or no sound.
	 * @param SoundUpVolume		How load the that sound should be.
	 */
	public function setSounds(?SoundOver:Sound = null, ?SoundOverVolume:Float = 1.0, ?SoundOut:Sound = null, ?SoundOutVolume:Float = 1.0, ?SoundDown:Sound = null, ?SoundDownVolume:Float = 1.0, ?SoundUp:Sound = null, ?SoundUpVolume:Float = 1.0):Void
	{
		if (SoundOver != null)
		{
			soundOver = FlxG.loadSound(SoundOver, SoundOverVolume);
		}
		if (SoundOut != null)
		{
			soundOut = FlxG.loadSound(SoundOut, SoundOutVolume);
		}
		if (SoundDown != null)
		{
			soundDown = FlxG.loadSound(SoundDown, SoundDownVolume);
		}
		if (SoundUp != null)
		{
			soundUp = FlxG.loadSound(SoundUp, SoundUpVolume);
		}
	}
	
	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
	 */
	private function onMouseUp(event:Event):Void
	{
		if (!exists || !visible || !active || (status != PRESSED))
		{
			return;
		}
		if (onUp != null)
		{
			onUp();
		}
		if (soundUp != null)
		{
			soundUp.play(true);
		}
		status = NORMAL;
	}
}