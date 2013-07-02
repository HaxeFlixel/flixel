package flixel.plugin.photonstorm;

#if !FLX_NO_MOUSE
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flixel.group.FlxSpriteGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxMath;

//TODO: Port to use touch as well

/**
 * A simple button class that calls a function when clicked by the mouse.
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxButtonPlus extends FlxSpriteGroup
{
	inline static public var NORMAL:Int = 0;
	inline static public var HIGHLIGHT:Int = 1;
	inline static public var PRESSED:Int = 2;
	
	public var buttonNormal:FlxExtendedSprite;
	public var buttonHighlight:FlxExtendedSprite;
	
	public var textNormal:FlxText;
	public var textHighlight:FlxText;
	
	/**
	 * The 1px thick border color that is drawn around this button
	 */
	public var borderColor:Int = 0xffffffff;
	/**
	 * The color gradient of the button in its in-active (not hovered over) state
	 */
	public var offColor:Array<Int>;
	/**
	 * The color gradient of the button in its hovered state
	 */
	public var onColor:Array<Int>;
	
	public var width:Int;
	public var height:Int;
	
	/**
	 * Set this to true if you want this button to function even while the game is paused.
	 */
	public var pauseProof:Bool;
	/**
	 * Shows the current state of the button.
	 */
	
	private var _status:Int;
	/**
	 * This function is called when the button is clicked.
	 */
	private var _onClick:Dynamic;
	/**
	 * Tracks whether or not the button is currently pressed.
	 */
	private var _pressed:Bool;
	/**
	 * Whether or not the button has initialized itself yet.
	 */
	private var _initialized:Bool;
	/**
	 * The parameters passed to the _onClick function when the button is clicked
	 */
	private var _onClickParams:Array<Dynamic>;
	/**
	 * This function is called when the button is hovered over
	 */
	private var _enterCallback:Dynamic;
	/**
	 * The parameters passed to the enterCallback function when the button is hovered over
	 */
	private var _enterCallbackParams:Array<Dynamic>;
	/**
	 * This function is called when the mouse leaves a hovered button (but didn't click)
	 */
	private var _leaveCallback:Dynamic;
	/**
	 * The parameters passed to the leaveCallback function when the hovered button is left
	 */
	private var _leaveCallbackParams:Array<Dynamic>;
	
	/**
	 * Creates a new <code>FlxButton</code> object with a gray background
	 * and a callback function on the UI thread.
	 * 
	 * @param	X			The X position of the button.
	 * @param	Y			The Y position of the button.
	 * @param	Callback	The function to call whenever the button is clicked.
	 * @param	Params		An optional array of parameters that will be passed to the Callback function
	 * @param	Label		Text to display on the button
	 * @param	Width		The width of the button.
	 * @param	Height		The height of the button.
	 */
	public function new(X:Int, Y:Int, Callback:Dynamic, ?Params:Array<Dynamic>, ?Label:String, Width:Int = 100, Height:Int = 20)
	{
		offColor = [0xff008000, 0xff00ff00];
		onColor = [0xff800000, 0xffff0000];
		
		super(4);
		
		x = X;
		y = Y;
		width = Width;
		height = Height;
		_onClick = Callback;
		
		buttonNormal = new FlxExtendedSprite(X, Y);
		
		#if flash
		buttonNormal.makeGraphic(Width, Height, borderColor);
		#end
		
		updateInactiveButtonColors(offColor);
		
		buttonNormal.solid = false;
		buttonNormal.scrollFactor.x = 0;
		buttonNormal.scrollFactor.y = 0;
		
		buttonHighlight = new FlxExtendedSprite(X, Y);
		
		#if flash
		buttonHighlight.makeGraphic(Width, Height, borderColor);
		#end
		
		updateActiveButtonColors(onColor);
		
		buttonHighlight.solid = false;
		buttonHighlight.visible = false;
		buttonHighlight.scrollFactor.x = 0;
		buttonHighlight.scrollFactor.y = 0;
		
		add(buttonNormal);
		add(buttonHighlight);
		
		if (Label != null)
		{
			textNormal = new FlxText(X, Y + 3, Width, Label);
			textNormal.setFormat(null, 8, 0xffffff, "center", 0x000000);
			
			textHighlight = new FlxText(X, Y + 3, Width, Label);
			textHighlight.setFormat(null, 8, 0xffffff, "center", 0x000000);
			
			add(textNormal);
			add(textHighlight);
		}

		_status = NORMAL;
		_pressed = false;
		_initialized = false;
		pauseProof = false;
		
		if (Params != null)
		{
			_onClickParams = Params;
		}
		else
		{
			_onClickParams = [];
		}
	}
	
	/**
	 * If you wish to replace the two buttons (normal and hovered-over) with FlxSprites, then pass them here.<br />
	 * Note: The pixel data is extract from the passed FlxSprites and assigned locally, it doesn't actually use the sprites<br />
	 * or keep a reference to them.
	 * 
	 * @param	Normal		The FlxSprite to use when the button is in-active (not hovered over)
	 * @param	Highlight	The FlxSprite to use when the button is hovered-over by the mouse
	 */
	public function loadGraphic(Normal:FlxSprite, Highlight:FlxSprite):Void
	{
		buttonNormal.pixels = Normal.pixels;
		buttonHighlight.pixels = Highlight.pixels;
		
		width = Std.int(buttonNormal.width);
		height = Std.int(buttonNormal.height);

		if (_pressed)
		{
			buttonNormal.visible = false;
		}
		else
		{
			buttonHighlight.visible = false;
		}
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
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_initialized = true;
			}
		}
		
		super.update();
		
		//Basic button logic
		updateButton(); 
	}
	
	/**
	 * Basic button update logic
	 */
	function updateButton():Void
	{
		var prevStatus:Int = _status;
		
		if (buttonNormal.cameras == null)
		{
			buttonNormal.cameras = FlxG.cameras.list;
		}
		
		var c:FlxCamera;
		var i:Int = 0;
		var l:Int = buttonNormal.cameras.length;
		var offAll:Bool = true;
		
		while (i < l)
		{
			c = buttonNormal.cameras[i++];
			
			if (FlxMath.mouseInFlxRect(false, buttonNormal.rect))
			{
				offAll = false;
				
				if (FlxG.mouse.justPressed())
				{
					_status = PRESSED;
				}
				
				if (_status == NORMAL)
				{
					_status = HIGHLIGHT;
				}
			}
		}
		
		if (offAll)
		{
			_status = NORMAL;
		}
		
		if (_status != prevStatus)
		{
			if (_status == NORMAL)
			{
				buttonNormal.visible = true;
				buttonHighlight.visible = false;
				
				if (textNormal != null)
				{
					textNormal.visible = true;
					textHighlight.visible = false;
				}
				
				if (_leaveCallback != null)
				{
					Reflect.callMethod(null, _leaveCallback, _leaveCallbackParams);
				}
			}
			else if (_status == HIGHLIGHT)
			{
				buttonNormal.visible = false;
				buttonHighlight.visible = true;
				
				if (textNormal != null)
				{
					textNormal.visible = false;
					textHighlight.visible = true;
				}
				
				if (_enterCallback != null)
				{
					Reflect.callMethod(null, _enterCallback, _enterCallbackParams);
				}
			}
		}
	}
	
	/**
	 * WARNING: This will remove this object entirely. Use <code>kill()</code> if you 
	 * want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Called by the game state when state is changed (if this object belongs to the state)
	 */
	override public function destroy():Void
	{
		if (FlxG.stage != null)
		{
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		if (buttonNormal != null)
		{
			buttonNormal.destroy();
			buttonNormal = null;
		}
		
		if (buttonHighlight != null)
		{
			buttonHighlight.destroy();
			buttonHighlight = null;
		}
		
		if (textNormal != null)
		{
			textNormal.destroy();
			textNormal = null;
		}
		
		if (textHighlight != null)
		{
			textHighlight.destroy();
			textHighlight = null;
		}
		
		_onClick = null;
		_enterCallback = null;
		_leaveCallback = null;
		
		super.destroy();
	}
	
	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxMisc.openURL()</code>).
	 */
	function onMouseUp(E:MouseEvent):Void
	{
		if (exists && visible && active && (_status == PRESSED) && (_onClick != null) && (pauseProof || !FlxG.paused))
		{
			Reflect.callMethod(this, Reflect.getProperty(this, "_onClick"), _onClickParams);
		}
	}
	
	/**
	 * If you want to change the color of this button in its in-active (not hovered over) state, then pass a new array of color values
	 * 
	 * @param	colors
	 */
	public function updateInactiveButtonColors(Colors:Array<Int>):Void
	{
		offColor = Colors;
		
		#if flash
		buttonNormal.stamp(FlxGradient.createGradientFlxSprite(width - 2, height - 2, offColor), 1, 1);
		#else
		var colA:Int;
		var colRGB:Int;
		
		var normalKey:String = "Gradient: " + width + " x " + height + ", colors: [";
		
		for (col in offColor)
		{
			colA = (col >> 24) & 255;
			colRGB = col & 0x00ffffff;
			
			normalKey = normalKey + colRGB + "_" + colA + ", ";
		}
		
		normalKey = normalKey + "]";
		
		if (FlxG.bitmap._cache.exists(normalKey) == false)
		{
			var normalBitmap:BitmapData = FlxG.bitmap.create(width, height, FlxColor.TRANSPARENT, false, normalKey);
			normalBitmap.fillRect(new Rectangle(0, 0, width, height), borderColor);
			FlxGradient.overlayGradientOnBitmapData(normalBitmap, width - 2, height - 2, offColor, 1, 1);
		}
		
		buttonNormal.pixels = FlxG.bitmap._cache.get(normalKey);
		#end
	}
	
	/**
	 * If you want to change the color of this button in its active (hovered over) state, then pass a new array of color values
	 * 
	 * @param	Colors
	 */
	public function updateActiveButtonColors(Colors:Array<Int>):Void
	{
		onColor = Colors;
		
		#if flash
		buttonHighlight.stamp(FlxGradient.createGradientFlxSprite(width - 2, height - 2, onColor), 1, 1);
		#else
		
		var colA:Int;
		var colRGB:Int;
		
		var highlightKey:String = "Gradient: " + width + " x " + height + ", colors: [";
		
		for (col in onColor)
		{
			colA = (col >> 24) & 255;
			colRGB = col & 0x00ffffff;
			
			highlightKey = highlightKey + colRGB + "_" + colA + ", ";
		}
		
		highlightKey = highlightKey + "]";
		
		if (FlxG.bitmap._cache.exists(highlightKey) == false)
		{
			var highlightBitmap:BitmapData = FlxG.bitmap.create(width, height, FlxColor.TRANSPARENT, false, highlightKey);
			highlightBitmap.fillRect(new Rectangle(0, 0, width, height), borderColor);
			FlxGradient.overlayGradientOnBitmapData(highlightBitmap, width - 2, height - 2, onColor, 1, 1);
		}
		
		buttonHighlight.pixels = FlxG.bitmap._cache.get(highlightKey);
		#end
	}
	
	/**
	 * If this button has text, set this to change the value
	 */
	
	public var text(never, set):String;
	
	public function set_text(NewText:String):String
	{
		if (textNormal != null && textNormal.text != NewText)
		{
			textNormal.text = NewText;
			textHighlight.text = NewText;
		}
		
		return NewText;
	}
	
	/**
	 * Center this button (on the X axis) Uses <code>FlxG.width / 2 - button width / 2</code>
	 * to achieve this. Doesn't take scrolling into consideration.
	 */
	public function screenCenter():Void
	{
		buttonNormal.x = (FlxG.width / 2) - (width / 2);
		buttonHighlight.x = (FlxG.width / 2) - (width / 2);
		
		if (textNormal != null)
		{
			textNormal.x = buttonNormal.x;
			textHighlight.x = buttonHighlight.x;
		}
	}
	
	/**
	 * Sets a callback function for when this button is rolled-over with the mouse
	 * 
	 * @param	Callback	The function to call, will be called once when the mouse enters
	 * @param	Params		An optional array of parameters to pass to the function
	 */
	public function setMouseOverCallback(Callback:Dynamic, ?Params:Array<Dynamic>):Void
	{
		_enterCallback = Callback;
		
		if (Params != null)
		{
			_enterCallbackParams = Params;
		}
		else
		{
			_enterCallbackParams = [];
		}
	}
	
	/**
	 * Sets a callback function for when the mouse rolls-out of this button
	 * 
	 * @param	Callback	The function to call, will be called once when the mouse leaves the button
	 * @param	Params		An optional array of parameters to pass to the function
	 */
	public function setMouseOutCallback(Callback:Dynamic, ?Params:Array<Dynamic>):Void
	{
		_leaveCallback = Callback;
		
		if (Params != null)
		{
			_leaveCallbackParams = Params;
		}
		else
		{
			_leaveCallbackParams = [];
		}
	}
	
	public function setOnClickCallback(Callback:Dynamic, Params:Array<Dynamic> = null):Void
	{
		_onClick = Callback;
		
		if (Params != null)
		{
			_onClickParams = Params;
		}
		else
		{
			_onClickParams = [];
		}
	}
}
#end