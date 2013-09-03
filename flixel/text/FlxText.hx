package flixel.text;

import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Assets;

/**
 * Extends <code>FlxSprite</code> to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 * Also does nice pixel-perfect centering on pixel fonts
 * as long as they are only one liners.
 */
class FlxText extends FlxSprite
{			
	/**
	 * Internal reference to a Flash <code>TextField</code> object.
	 */
	private var _textField:TextField;
	/**
	 * Internal reference to a Flash <code>TextFormat</code> object.
	 */
	private var _format:TextFormat;
	/**
	 * Internal reference to another helper Flash <code>TextFormat</code> object.
	 */
	private var _formatAdjusted:TextFormat;
	/**
	 * Whether the actual text field needs to be regenerated and stamped again.
	 * This is NOT the same thing as <code>FlxSprite.dirty</code>.
	 */
	private var _regen:Bool = true;
	/**
	 * Internal tracker for the text shadow color, default is clear/transparent.
	 */
	private var _shadow:Int = 0;
	/**
	 * Internal tracker for shadow usage, default is false
	 */
	private var _useShadow:Bool = false;
	
	private var _outline:Int = 0;	
	private var _useOutline:Bool = false;
	
	private var _borderStyle:Int = 0;
	private var _borderColor:Int = 0;
	private var _borderSize:Float = 0;

	/**
	 * No border style
	 */	
	public static inline var NONE:Int = 0;				
	
	/**
	 * A simple shadow to the lower-right
	 */
	public static inline var SHADOW:Int = 1;			
	
	/**
	 * Outline on all 8 sides
	 */
	public static inline var OUTLINE:Int = 2;			
	
	/**
	 * Outline, optimized using only 4 draw calls. (Might not work for narrow and/or 1-pixel fonts)
	 */
	public static inline var OUTLINE_FAST:Int = 3;		
		
	private var _isStatic:Bool = false;
	
	/**
	 * Creates a new <code>FlxText</code> object at the specified position.
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @param	IsStatic		Whether this text field can't be changed (text or appearance)
	 */
	public function new(X:Float, Y:Float, Width:Int, ?Text:String, size:Int = 8, EmbeddedFont:Bool = true, IsStatic:Bool = false)
	{
		super(X, Y);
		
		_filters = [];
		
		var key:String = FlxG.bitmap.getUniqueKey("text");
		makeGraphic(Width, 1, FlxColor.TRANSPARENT, false, key);
		
		if (Text == null)
		{
			Text = "";
		}
		
		_textField = new TextField();
		_textField.width = Width;
		_textField.selectable = false;
		_textField.multiline = true;
		_textField.wordWrap = true;
		_format = new TextFormat(FlxAssets.FONT_DEFAULT, size, 0xffffff);
		_formatAdjusted = new TextFormat();
		_textField.defaultTextFormat = _format;
		_textField.text = Text;
		_textField.embedFonts = EmbeddedFont;
		
		#if flash
		_textField.sharpness = 100;
		#end
		
		if (Text.length <= 0)
		{
			_textField.height = 1;
		}
		else
		{
			_textField.height = 10;
		}
		
		allowCollisions = FlxObject.NONE;
		moves = false;
		
		#if flash
		calcFrame();
		#else
		if (Text != "")
		{
			calcFrame(true);
		}
		#end
		
		_isStatic = IsStatic;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_textField = null;
		_format = null;
		_formatAdjusted = null;
		_filters = null;
		
		super.destroy();
	}
	
	/**
	 * You can use this if you have a lot of text parameters
	 * to set instead of the individual properties.
	 * 
	 * @param	Font		The name of the font face for the text display.
	 * @param	Size		The size of the font (in pixels essentially).
	 * @param	Color		The color of the text in traditional flash 0xRRGGBB format.
	 * @param	Alignment	A string representing the desired alignment ("left,"right" or "center").
	 * @param	BorderStyle	An int representing the desired text border stle - FlxText.NONE, SHADOW, OUTLINE, or OUTLINE_FAST
	 * @param   BorderColor An int representing the desired text border color in flash 0xRRGGBB format.
	 * @param 	BorderSize	The size of the text border, in pixels.
	 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
	 */
	public function setFormat(?Font:String, Size:Float = 8, Color:Int = 0xffffff, ?Alignment:String, BorderStyle:Int=NONE, BorderColor:Int=0, BorderSize:Int=1):FlxText
	{
		if (_isStatic)
		{
			return this;
		}
		
		if (Font == null)
		{
			_format.font = FlxAssets.FONT_DEFAULT;
		}
		else 
		{
			_format.font = Assets.getFont(Font).fontName;
		}
		
		_format.size = Size;
		Color &= 0x00ffffff;
		_format.color = Color;
		_format.align = convertTextAlignmentFromString(Alignment);
		_textField.defaultTextFormat = _format;
		updateFormat(_format);
		setBorderStyle(BorderStyle, BorderColor, BorderSize);
		_regen = true;
		
		return this;
	}
	
	override private function set_width(Width:Float):Float
	{
		if (Width != width)
		{
			var newWidth:Float = super.set_width(Width);
			if (_textField != null)
			{
				_textField.width = newWidth;
			}
			_regen = true;
		}
		
		return Width;
	}
	
	/**
	 * The text being displayed.
	 */
	public var text(get, set):String;
	
	private function get_text():String
	{
		return _textField.text;
	}
	
	private function set_text(Text:String):String
	{
		if (_isStatic)
		{
			return Text;
		}
		
		var ot:String = _textField.text;
		_textField.text = Text;
		
		if(_textField.text != ot)
		{
			_regen = true;
		}
		
		return _textField.text;
	}
	
	/**
	 * The size of the text being displayed.
	 */
	public var size(get, set):Float;
	
	private function get_size():Float
	{
		return _format.size;
	}
	
	private function set_size(Size:Float):Float
	{
		if (_isStatic)
		{
			return Size;
		}
		
		_format.size = Size;
		_textField.defaultTextFormat = _format;
		updateFormat(_format);
		_regen = true;
		
		return Size;
	}
	
	/**
	 * The color of the text being displayed.
	 */
	override private function set_color(Color:Int):Int
	{
		if (_isStatic)
		{
			return Color;
		}
		
		Color &= 0x00ffffff;
		_format.color = Color;
		color = Color;
		_textField.defaultTextFormat = _format;
		updateFormat(_format);
		_regen = true;
		
		return Color;
	}
	
	/**
	 * The font used for this text.
	 */
	public var font(get, set):String;
	
	private function get_font():String
	{
		return _format.font;
	}
	
	private function set_font(Font:String):String
	{
		if (_isStatic)
		{
			return Font;
		}
		
		_format.font = Assets.getFont(Font).fontName;
		_textField.defaultTextFormat = _format;
		updateFormat(_format);
		_regen = true;
		
		return Font;
	}
	
	/**
	 * The alignment of the font ("left", "right", or "center").
	 */
	public var alignment(get, set):String;
	
	private function get_alignment():String
	{
		return cast(_format.align, String);
	}
	
	private function set_alignment(Alignment:String):String
	{
		if (_isStatic)
		{
			return Alignment;
		}
		
		_format.align = convertTextAlignmentFromString(Alignment);
		_textField.defaultTextFormat = _format;
		updateFormat(_format);
		dirty = true;
		_regen = true;
		
		return Alignment;
	}
	
	/**
	 * Set border's style (shadow, outline, etc), color, and size all in one go!
	 * @param	Style outline style - FlxText.NONE, SHADOW, OUTLINE, OUTLINE_FAST
	 * @param	Color outline color in flash 0xRRGGBB format
	 * @param	Size outline size in pixels
	 */
	
	public function setBorderStyle(Style:Int, Color:Int, Size:Float = 1):Void {
		borderStyle = Style;
		borderColor = Color;
		borderSize = Size;
	}
	
	/**
	 * Use a border style like FlxText.SHADOW or FlxText.OUTLINE
	 */	
	public var borderStyle(default, set):Int;
	
	private function set_borderStyle(style:Int):Int 
	{		
		if (_isStatic)
		{
			return style;
		}
		
		if (style != _borderStyle)
		{
			_borderStyle = style;
			dirty = true;
		}
		
		return _borderStyle;
	}
	
	public var borderColor(default, set):Int;
	
	private function set_borderColor(Color:Int):Int 
	{
		if (_isStatic) {
			return Color;
		}
		
		Color &= 0x00ffffff;
		
		if (_shadow != Color && _borderStyle != NONE)
		{
			dirty = true;
		}
		_borderColor = Color;
		
		return Color;
	}
	
	public var borderSize(default, set):Float;
		
	private function set_borderSize(Value:Float):Float
	{
		if (_isStatic)
		{
			return Value;
		}
		if (Value != _borderSize && _borderStyle != NONE)
		{
			dirty = true;
		}
		_borderSize = Value;
		
		return Value;
	}
	
	/**
	 * The color of the text shadow in 0xAARRGGBB hex format.
	 */
	public var shadow(get, set):Int;
	
	private function get_shadow():Int
	{
		return _shadow;
	}
	
	private function set_shadow(Color:Int):Int
	{
		if (_isStatic)
		{
			return Color;
		}
		
		Color &= 0x00ffffff;
		
		if (_shadow != Color && useShadow == true)
		{
			dirty = true;
		}
		_shadow = Color;
		
		return Color;
	}
	
	/**
	 * Whether to draw shadow or not
	 */
	public var useShadow(get, set):Bool;
	
	private function get_useShadow():Bool
	{
		return _useShadow;
	}
	
	private function set_useShadow(value:Bool):Bool
	{
		if (_isStatic)
		{
			return value;
		}
		
		if (value != _useShadow)
		{
			_useShadow = value;
			dirty = true;
		}
		
		return _useShadow;
	}
	
	/**
	 * The color of the text outline in 0xAARRGGBB hex format.
	 */	
	public var outline(get, set):Int;
	
	private function get_outline():Int
	{
		return _outline;
	}
	
	/**
	 * @private
	 */
	// TODO: implement this
	private function set_outline(Color:Int):Int
	{
		return Color;
		/*if (_isStatic)
		{
			return Color;
		}
		
		Color &= 0x00ffffff;
		
		if (_outline != Color && useOutline == true)
		{
			dirty = true;
		}
		_outline = Color;
		
		return Color;*/
	}
	
	public var useOutline(get, set):Bool;
	
	private function get_useOutline():Bool
	{
		return _useOutline;
	}
	
	private function set_useOutline(value:Bool):Bool
	{
		return value;
		/*if (_isStatic)
		{
			return value;
		}
		
		if (value != _useOutline)
		{
			_useOutline = value;
			dirty = true;
		}
		
		return _useOutline;*/
	}
	
	/**
	 * Whether this text field can be changed (text or appearance).
	 * Once set to true it can't be changed anymore.
	 * Maybe usefull for cpp and neko targets, 
	 * since if you set it to true then you can insert text's image into other atlas.
	 */
	public var isStatic(get, set):Bool;
	
	private function get_isStatic():Bool 
	{
		return _isStatic;
	}
	
	private function set_isStatic(Value:Bool):Bool 
	{
		if (_isStatic)
		{
			return Value;
		}
		
		return _isStatic = Value;
	}
	
	/**
	 * Internal function to update the current animation frame.
	 */
	#if flash
	override private function calcFrame():Void
	#else
	override private function calcFrame(AreYouSure:Bool = false):Void
	#end
	{
		#if !flash
		if (AreYouSure)
		{
			_regen = true;
		#end
			
			if (_filters != null)
			{
				_textField.filters = _filters;
			}
		
			if (_regen)
			{
				// Need to generate a new buffer to store the text graphic
				height = _textField.textHeight;
				// Account for 2px gutter on top and bottom
				height += 4;
				var key:String = _cachedGraphics.key;
				FlxG.bitmap.remove(key);
				makeGraphic(Std.int(width + _widthInc), Std.int(height + _heightInc), FlxColor.TRANSPARENT, false, key);
				frameHeight = Std.int(height);
				_textField.height = height * 1.2;
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = width + _widthInc;
				_flashRect.height = height + _heightInc;
				_regen = false;
			}
			// Else just clear the old buffer before redrawing the text
			else	
			{
				_cachedGraphics.bitmap.fillRect(_flashRect, FlxColor.TRANSPARENT);
			}
			
			if ((_textField != null) && (_textField.text != null) && (_textField.text.length > 0))
			{
				// Now that we've cleared a buffer, we need to actually render the text to it
				_formatAdjusted.font = _format.font;
				_formatAdjusted.size = _format.size;
				_formatAdjusted.color = _format.color;
				_formatAdjusted.align = _format.align;
				_matrix.identity();
				
				_matrix.translate(Std.int(0.5 * _widthInc), Std.int(0.5 * _heightInc));
				
				// If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
				#if js
				if (_format.align == TextFormatAlign.CENTER)
				#else
				if ((_format.align == TextFormatAlign.CENTER) && (_textField.numLines == 1))
				#end
				{
					_formatAdjusted.align = TextFormatAlign.LEFT;
					updateFormat(_formatAdjusted);	
					
					#if flash
					_matrix.translate(Math.floor((width - _textField.getLineMetrics(0).width) / 2), 0);
					#else
					_matrix.translate(Math.floor((width - _textField.textWidth) / 2), 0);
					#end
				}
				
				if (_borderStyle != NONE)
				{				
					if (_borderStyle == SHADOW) 
					{
						//Render a shadow beneath the text
						//(do one lower-right offset draw call)
						_formatAdjusted.color = _borderColor;
						updateFormat(_formatAdjusted);
						_matrix.translate(_borderSize, _borderSize);
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate( -_borderSize, -_borderSize);
						_formatAdjusted.color = _format.color;
						updateFormat(_formatAdjusted);
					}
					else if (_borderStyle == OUTLINE) 
					{
						//Render an outline around the text
						//(do 8 offset draw calls)
						_formatAdjusted.color = _borderColor;
						updateFormat(_formatAdjusted);
						_matrix.translate( -borderSize, -borderSize);	//upper-left
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(borderSize, 0);				//upper-middle
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(borderSize, 0);				//upper-right
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(0, borderSize);				//middle-right
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(0, borderSize);				//lower-right
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(-borderSize, 0);			//lower-middle
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(-borderSize, 0);			//lower-left
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(0, -borderSize);			//middle-left
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(borderSize, 0);				//return to center
						_formatAdjusted.color = _format.color;
						updateFormat(_formatAdjusted);			
					}
					else if (_borderStyle == OUTLINE_FAST) 
					{
						//Render an outline around the text
						//(do 4 diagonal offset draw calls)
						//(this method might not work with certain narrow fonts)
					    _formatAdjusted.color = _borderColor;						
						updateFormat(_formatAdjusted);
						_matrix.translate( -borderSize, -borderSize);		//upper-left
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate( borderSize*2, 0);				//upper-right
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate( 0,borderSize*2);					//lower-right
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(-borderSize*2, 0);				//lower-left
						_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
						_matrix.translate(borderSize, -borderSize);			//return to center
						_formatAdjusted.color = _format.color;
						updateFormat(_formatAdjusted);
					}
				}
				
				//Actually draw the text onto the buffer
				_cachedGraphics.bitmap.draw(_textField, _matrix, _colorTransform);
				updateFormat(_format);
			}
			
			//Finally, update the visible pixels
			if ((framePixels == null) || (framePixels.width != _cachedGraphics.bitmap.width) || (framePixels.height != _cachedGraphics.bitmap.height))
			{
				if (framePixels != null)
					framePixels.dispose();
				
				framePixels = new BitmapData(_cachedGraphics.bitmap.width, _cachedGraphics.bitmap.height, true, 0);
			}
			
			framePixels.copyPixels(_cachedGraphics.bitmap, _flashRect, _flashPointZero);
			
			if (useColorTransform) 
			{
				framePixels.colorTransform(_flashRect, _colorTransform);
			}
		#if !flash
			origin.set(frameWidth * 0.5, frameHeight * 0.5);
		}
		#end
		
		dirty = false;
	}
	
	/**
	 * A helper function for updating the <code>TextField</code> that we use for rendering.
	 * 
	 * @return	A writable copy of <code>TextField.defaultTextFormat</code>.
	 */
	private function dtfCopy():TextFormat
	{
		var defaultTextFormat:TextFormat = _textField.defaultTextFormat;
		
		return new TextFormat(defaultTextFormat.font, defaultTextFormat.size, defaultTextFormat.color, defaultTextFormat.bold, defaultTextFormat.italic, defaultTextFormat.underline, defaultTextFormat.url, defaultTextFormat.target, defaultTextFormat.align);
	}
	
	/**
	 * Method for converting string to TextFormatAlign
	 */
	#if (flash || js)
	private function convertTextAlignmentFromString(StrAlign:String):TextFormatAlign
	{
		if (StrAlign == "right")
		{
			return TextFormatAlign.RIGHT;
		}
		else if (StrAlign == "center")
		{
			return TextFormatAlign.CENTER;
		}
		else if (StrAlign == "justify")
		{
			return TextFormatAlign.JUSTIFY;
		}
		else
		{
			return TextFormatAlign.LEFT;
		}
	}
	#else
	private function convertTextAlignmentFromString(StrAlign:String):String
	{
		return StrAlign;
	}
	#end
	
	override public function updateFrameData():Void
	{
		if (_cachedGraphics != null)
		{
			_framesData = _cachedGraphics.tilesheet.getSpriteSheetFrames(_region);
			_flxFrame = _framesData.frames[0];
		}
	}
	
	override public function draw():Void 
	{
		// Rarely
		if (_regen)		
		{
			#if !flash
			calcFrame(true);
			#else
			calcFrame();
			#end
		}
		
		super.draw();
	}
	
	inline private function updateFormat(Format:TextFormat):Void
	{
		#if !flash
		_textField.setTextFormat(Format, 0, _textField.text.length);
		#else
		_textField.setTextFormat(Format);
		#end
	}
	
	private var _filters:Array<BitmapFilter>;
	
	private var _widthInc:Int = 0;
	private var _heightInc:Int = 0;
	
	public function addFilter(filter:BitmapFilter, widthInc:Int = 0, heightInc:Int = 0):Void
	{
		if (_widthInc != widthInc || _heightInc != heightInc)
		{
			_regen = true;
		}
		
		_filters.push(filter);
		dirty = true;
	}
	
	public function removeFilter(filter:BitmapFilter):Void
	{
		var removed:Bool = _filters.remove(filter);
		if (removed)
		{
			dirty = true;
		}
	}
	
	public function clearFilters():Void
	{
		if (_filters.length > 0)
		{
			dirty = true;
		}
		_filters = [];
	}
}