package org.flixel;

import nme.Assets;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.text.TextField;
import nme.text.TextFieldType;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.text.TextFieldAutoSize;
import org.flixel.FlxAssets;
import org.flixel.FlxBasic;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxText;
import org.flixel.system.layer.Atlas;

/**
 * Extends <code>FlxText</code> for better support rendering text on cpp target.
 * Doesn't have multicamera support.
 * Displays over all other objects.
 */
class FlxTextField extends FlxText
{
	private var _selectable:Bool;
	private var _multiline:Bool;
	private var _wordWrap:Bool;
	
	private var _text:String;
	
	private var _camera:FlxCamera;
	private var _addedToDisplay:Bool;
	
	private var _type:TextFieldType;
	private var _border:Bool;
	private var _borderColor:Int;
	private var _bgColor:Int;
	private var _background:Bool;
	private var _autosize:TextFieldAutoSize;
	
	/**
	 * Creates a new <code>FlxText</code> object at the specified position.
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @param	Camera			Camera to display. FlxG.camera is used by default (if you pass null)
	 */
	public function new(X:Float, Y:Float, Width:Int, Text:String = null, EmbeddedFont:Bool = true, Camera:FlxCamera = null)
	{
		super(X, Y, Width);
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		_addedToDisplay = false;
		width = Width;
		
		if (Text == null)
		{
			Text = "";
		}
		_text = Text;
		
		_textField.embedFonts = EmbeddedFont;
		#if flash
		_textField.sharpness = 100;
		#end
		
		_selectable = false;
		_multiline = true;
		_wordWrap = true;
		
		_type = TextFieldType.DYNAMIC;
		_border = false;
		_borderColor = 0x000000;
		_background = false;
		_bgColor = 0xffffff;
		_autosize = TextFieldAutoSize.NONE;
		
		_camera = Camera;
		dirty = false;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_textField.parent != null)
		{
			_textField.parent.removeChild(_textField);
		}
		_type = null;
		_camera = null;
		super.destroy();
	}
	
	/**
	 * You can use this if you have a lot of text parameters
	 * to set instead of the individual properties.
	 * @param	Font		The name of the font face for the text display.
	 * @param	Size		The size of the font (in pixels essentially).
	 * @param	Color		The color of the text in traditional flash 0xRRGGBB format.
	 * @param	Alignment	A string representing the desired alignment ("left,"right" or "center").
	 * @param	ShadowColor	A uint representing the desired text shadow color in flash 0xRRGGBB format.
	 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
	 */
	#if flash
	override public function setFormat(Font:String = null, Size:Float = 8, Color:UInt = 0xffffff, Alignment:String = null, ShadowColor:UInt = 0, UseShadow:Bool = false):FlxText
	#else
	override public function setFormat(Font:String = null, Size:Float = 8, Color:Int = 0xffffff, Alignment:String = null, ShadowColor:Int = 0, UseShadow:Bool = false):FlxText
	#end
	{
		if (Font == null)
		{
			Font = Assets.getFont(FlxAssets.defaultFont).fontName;
		}
		_format.font = Font;
		_format.size = Size;
		_format.color = Color;
		_format.align = convertTextAlignmentFromString(Alignment);
		updateTextField();
		return this;
	}
	
	/**
	 * The text being displayed.
	 */
	override private function get_text():String
	{
		return _text;
	}
	
	/**
	 * @private
	 */
	override private function set_text(Text:String):String
	{
		_text = Text;
		updateTextField();
		return text;
	}
	
	/**
	 * @private
	 */
	override private function set_size(Size:Float):Float
	{
		_format.size = Size;
		updateTextField();
		return Size;
	}
	
	/**
	 * @private
	 */
	#if flash
	override private function set_color(Color:UInt):UInt
	#else
	override private function set_color(Color:BitmapInt32):BitmapInt32
	#end
	{
		#if neko
		_format.color = Color.rgb;
		#else
		_format.color = Color;
		#end
		updateTextField();
		return Color;
	}
	
	override private function set_useShadow(value:Bool):Bool
	{
		return value;
	}
	
	/**
	 * @private
	 */
	override private function set_font(Font:String):String
	{
		_format.font = Assets.getFont(Font).fontName;
		updateTextField();
		return Font;
	}
	
	/**
	 * @private
	 */
	override private function set_alignment(Alignment:String):String
	{
		_format.align = convertTextAlignmentFromString(Alignment);
		updateTextField();
		return Alignment;
	}
	
	/**
	 * The color of the text shadow in 0xAARRGGBB hex format.
	 */
	#if flash
	override private function get_shadow():UInt
	#else
	override private function get_shadow():Int
	#end
	{
		// shadows are not supported
		return 0;
	}
	
	/**
	 * @private
	 */
	#if flash
	override private function set_shadow(Color:UInt):UInt
	#else
	override private function set_shadow(Color:Int):Int
	#end
	{
		// shadows are not supported
		return 0;
	}
	
	override public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void 
	{
		// this class doesn't support this operation
	}
	
	#if flash
	override public function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:UInt, Thickness:UInt = 1):Void
	#else
	override public function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:BitmapInt32, Thickness:Int = 1):Void
	#end
	{
		// this class doesn't support this operation
	}
	
	override private function get_simpleRender():Bool
	{ 
		return true;
	}
	
	#if flash
	override public function pixelsOverlapPoint(point:FlxPoint, Mask:UInt = 0xFF, Camera:FlxCamera = null):Bool
	#else
	override public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, Camera:FlxCamera = null):Bool
	#end
	{
		// this class doesn't support this operation
		return false;
	}
	
	/**
	 * Set <code>pixels</code> to any <code>BitmapData</code> object.
	 * Automatically adjust graphic size and render helpers.
	 */
	override private function get_pixels():BitmapData
	{
		#if !flash
		calcFrame(true);
		#else
		calcFrame();
		#end
		return _pixels;
	}
	
	/**
	 * @private
	 */
	override private function set_pixels(Pixels:BitmapData):BitmapData
	{
		// this class doesn't support this operation
		return _pixels;
	}
	
	/**
	 * @private
	 */
	override private function set_alpha(Alpha:Float):Float
	{
		if (Alpha > 1)
		{
			Alpha = 1;
		}
		if (Alpha < 0)
		{
			Alpha = 0;
		}
		alpha = Alpha;
		updateTextField();
		return Alpha;
	}
	
	private function updateTextField():Void
	{
		if (_addedToDisplay)
		{
			_textField.type = _type;
			_textField.autoSize = _autosize;
			_textField.selectable = _selectable;
			_textField.border = _border;
			_textField.borderColor = _borderColor;
			_textField.background = _background;
			_textField.backgroundColor = _bgColor;
			_textField.width = width;
			_textField.defaultTextFormat = _format;
			_textField.setTextFormat(_format);
			_textField.selectable = _selectable;
			_textField.wordWrap = _wordWrap;
			_textField.multiline = _multiline;
			_textField.text = _text;
			height = _textField.textHeight;
			height += 4;
			_textField.height = height;
			_textField.alpha = alpha;
		}
	}
	
	public function setVisibility(visible:Bool):Void
	{
		this.visible = visible;
		_textField.visible = visible;
	}
	
	public function getVisibility():Bool
	{
		return visible;
	}
	
	override public function kill():Void 
	{
		setVisibility(false);
		super.kill();
	}
	
	override public function revive():Void 
	{
		setVisibility(true);
		super.revive();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		if (_camera == null)	return;
		
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker) return;
		}
		
		if (!_addedToDisplay)
		{
			#if !flash
			_camera._canvas.addChild(_textField);
			#else
			_camera._flashSprite.addChild(_textField);
			#end
			_addedToDisplay = true;
			updateTextField();
		}
		
		if (_type == TextFieldType.INPUT && _text != _textField.text)
		{
			_text = _textField.text;
			updateTextField();
		}
		
		if (visible == false)
		{
			setVisibility(false);
			return;
		}
		
		if (!onScreenSprite(_camera) || !_camera.visible || !_camera.exists)
		{
			_textField.visible = false;
		}
		else
		{
			_textField.visible = true;
		}
		
		_point.x = x - (_camera.scroll.x * scrollFactor.x) - (offset.x);
		_point.y = y - (_camera.scroll.y * scrollFactor.y) - (offset.y);
		
		// Simple render
		#if !flash
		_textField.x = _point.x;
		_textField.y = _point.y;
		#else
		_textField.x = _point.x - FlxG.camera.width * 0.5;
		_textField.y = _point.y - FlxG.camera.height * 0.5;
		#end
		
		FlxBasic._VISIBLECOUNT++;
		#if !FLX_NO_DEBUG
		if (FlxG.visualDebug && !ignoreDrawDebug)
		{
			drawDebug(_camera);
		}
		#end
	}
	
	/**
	 * Internal function to update the current animation frame.
	 */
	#if !flash
	override private function calcFrame(AreYouSure:Bool = false):Void
	#else
	override private function calcFrame():Void
	#end
	{
		#if !flash
		if (AreYouSure && _addedToDisplay)
		{
		#end
			_pixels = new BitmapData(Std.int(width), Std.int(height), true, FlxG.TRANSPARENT);
			frameHeight = Std.int(height);
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = width;
			_flashRect.height = height;
			
			if ((_textField.text != null) && (_textField.text.length > 0))
			{
				//Now that we've cleared a buffer, we need to actually render the text to it
				updateTextField();
				_formatAdjusted.font = _format.font;
				_formatAdjusted.size = _format.size;
				_formatAdjusted.color = _format.color;
				_formatAdjusted.align = _format.align;
				_matrix.identity();
				
				//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
				if ((_format.align == TextFormatAlign.CENTER) && (_textField.numLines == 1))
				{
					_formatAdjusted.align = TextFormatAlign.LEFT;
					_textField.setTextFormat(_formatAdjusted);
					_matrix.translate(Math.floor((width - _textField.textWidth) / 2), 0);
				}
				//Actually draw the text onto the buffer
				_pixels.draw(_textField, _matrix, _colorTransform);
				_textField.setTextFormat(_format);
			}
		#if !flash
		}
		#end
	}
	
	/**
	 * Camera on which this text will be displayed. Default is FlxG.camera.
	 */
	public var camera(get_camera, set_camera):FlxCamera;
	
	private function get_camera():FlxCamera 
	{
		return _camera;
	}
	
	private function set_camera(value:FlxCamera):FlxCamera 
	{
		if (_camera != value)
		{
			if (value != null)
			{
				#if !flash
				value._canvas.addChild(_textField);
				#else
				value._flashSprite.addChild(_textField);
				#end
				_addedToDisplay = true;
				updateTextField();
			}
			else
			{
				if (_camera != null)
				{
					_textField.parent.removeChild(_textField);
				}
				_addedToDisplay = false;
			}
			
			_camera = value;
		}
		return value;
	}
	
	/**
	 * Type of text field. Can be TextFieldType.DYNAMIC or TextFieldType.INPUT. Default is TextFieldType.DYNAMIC.
	 */
	public var type(get_type, set_type):TextFieldType;
	
	private function get_type():TextFieldType 
	{
		return _type;
	}
	
	private function set_type(value:TextFieldType):TextFieldType 
	{
		_type = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines whether this text field is selectable or not. Default is false.
	 */
	public var selectable(get_selectable, set_selectable):Bool;
	
	private function get_selectable():Bool 
	{
		return _selectable;
	}
	
	private function set_selectable(value:Bool):Bool 
	{
		_selectable = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines whether to show border around text field or not. Default is false.
	 */
	public var border(get_border, set_border):Bool;
	
	private function get_border():Bool 
	{
		return _border;
	}
	
	private function set_border(value:Bool):Bool 
	{
		_border = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines the color of border around text field. Default is 0x000000 (black).
	 */
	public var borderColor(get_borderColor, set_borderColor):Int;
	
	private function get_borderColor():Int 
	{
		return _textField.borderColor;
	}
	
	private function set_borderColor(value:Int):Int 
	{
		_borderColor = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines whether this text field is multiline or not. Default is true.
	 */
	public var multiline(get_multiline, set_multiline):Bool;
	
	private function get_multiline():Bool 
	{
		return _multiline;
	}
	
	private function set_multiline(value:Bool):Bool 
	{
		_multiline = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines background color for this text field. Default is 0xffffff (white).
	 */
	public var bgColor(get_bgColor, set_bgColor):Int;
	
	private function get_bgColor():Int 
	{
		return _bgColor;
	}
	
	private function set_bgColor(value:Int):Int 
	{
		_bgColor = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines whether to show background of this text field or not. Default is false.
	 */
	public var background(get_background, set_background):Bool;
	
	private function get_background():Bool 
	{
		return _background;
	}
	
	private function set_background(value:Bool):Bool 
	{
		_background = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines whether this text field is using word wrap. Default is true
	 */
	public var wordWrap(get_wordWrap, set_wordWrap):Bool;
	
	private function get_wordWrap():Bool 
	{
		return _wordWrap;
	}
	
	private function set_wordWrap(value:Bool):Bool 
	{
		_wordWrap = value;
		updateTextField();
		return value;
	}
	
	/**
	 * Defines textfield's autosize behavior. Default is TextFieldAutoSize.NONE
	 */
	public var autosize(get_autosize, set_autosize):TextFieldAutoSize;
	
	private function get_autosize():TextFieldAutoSize 
	{
		return _autosize;
	}
	
	private function set_autosize(value:TextFieldAutoSize):TextFieldAutoSize 
	{
		_autosize = value;
		updateTextField();
		return value;
	}
	
	public var textField(get_textField, null):TextField;
	
	private function get_textField():TextField 
	{
		return _textField;
	}
	
	#if !flash
	override private function set_atlas(value:Atlas):Atlas 
	{
		return value;
	}
	#end
}