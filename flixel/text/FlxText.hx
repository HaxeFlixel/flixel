package flixel.text;

import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.interfaces.IFlxDestroyable;
import flixel.system.FlxAssets;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.loaders.CachedGraphics;
import openfl.Assets;

/**
 * Extends FlxSprite to support rendering text. Can tint, fade, rotate and scale just like a sprite. Doesn't really animate 
 * though, as far as I know. Also does nice pixel-perfect centering on pixel fonts as long as they are only one liners.
 */
class FlxText extends FlxSprite
{
	public static inline var BORDER_NONE:Int = 0;
	/**
	 * A simple shadow to the lower-right
	 */
	public static inline var BORDER_SHADOW:Int = 1;
	/**
	 * Outline on all 8 sides
	 */
	public static inline var BORDER_OUTLINE:Int = 2;
	/**
	 * Outline, optimized using only 4 draw calls. (Might not work for narrow and/or 1-pixel fonts)
	 */
	public static inline var BORDER_OUTLINE_FAST:Int = 3;
	
	/**
	 * The text being displayed.
	 */
	public var text(get, set):String;
	
	/**
	 * The size of the text being displayed.
	 */
	public var size(get, set):Float;
	
	/**
	 * The font used for this text (assuming that it's using embedded font).
	 */
	public var font(get, set):String;
	
	/**
	 * Whether this text field uses embedded font (by default) or not
	 */
	public var embedded(get, null):Bool;
	
	/**
	 * The system font for this text (not embedded).
	 */
	public var systemFont(get, set):String;
	
	/**
	 * Whether to use bold text or not (false by default).
	 */
	public var bold(get, set):Bool;
	
	/**
	 * Whether to use italic text or not (false by default). It only works in Flash.
	 */
	public var italic(get, set):Bool;
	
	/**
	 * Whether to use word wrapping and multiline or not (true by default).
	 */
	public var wordWrap(get, set):Bool;
	
	/**
	 * The alignment of the font ("left", "right", or "center").
	 */
	public var alignment(get, set):String;
	
	/**
	 * Use a border style like FlxText.SHADOW or FlxText.OUTLINE
	 */	
	public var borderStyle(default, set):Int = BORDER_NONE;
	
	/**
	 * The color of the border in 0xRRGGBB format
	 */	
	public var borderColor(default, set):Int = 0x000000;
	
	/**
	 * The size of the border, in pixels.
	 */
	public var borderSize(default, set):Float = 1;
	
	/**
	 * How many iterations do use when drawing the border. 0: only 1 iteration, 1: one iteration for every pixel in borderSize
	 * A value of 1 will have the best quality for large border sizes, but might reduce performance when changing text. 
	 * NOTE: If the borderSize is 1, borderQuality of 0 or 1 will have the exact same effect (and performance).
	 */
	public var borderQuality(default, set):Float = 1;
	
	/**
	 * Internal reference to a Flash TextField object.
	 */
	public var textField(get, never):TextField;
	
	/**
	 * Internal reference to a Flash TextField object.
	 */
	private var _textField:TextField;
	/**
	 * Internal reference to a Flash TextFormat object.
	 */
	private var _defaultFormat:TextFormat;
	/**
	 * Internal reference to another helper Flash TextFormat object.
	 */
	private var _formatAdjusted:TextFormat;
	/**
	 * Internal reference to an Array of FlxTextFormat
	 */
	private var _formats:Array<FlxTextFormat>;
	
	private var _filters:Array<BitmapFilter>;
	private var _widthInc:Int = 0;
	private var _heightInc:Int = 0;
	
	/**
	 * Creates a new FlxText object at the specified position.
	 * 
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 */
	public function new(X:Float, Y:Float, Width:Int, ?Text:String, size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y);
		
		_filters = [];
		
		if (Text == null)
		{
			Text = "";
		}
		
		_textField = new TextField();
		_textField.width = Width;
		_textField.selectable = false;
		_textField.multiline = true;
		_textField.wordWrap = true;
		_defaultFormat = new TextFormat(FlxAssets.FONT_DEFAULT, size, 0xffffff);
		_formatAdjusted = new TextFormat();
		_textField.defaultTextFormat = _defaultFormat;
		_textField.text = Text;
		_textField.embedFonts = EmbeddedFont;
		
		_formats = new Array<FlxTextFormat>();
		
		#if flash
		_textField.sharpness = 100;
		#end
		
		_textField.height = (Text.length <= 0) ? 1 : 10;
		
		allowCollisions = FlxObject.NONE;
		moves = false;
		
		var key:String = FlxG.bitmap.getUniqueKey("text");
		makeGraphic(Width, 1, FlxColor.TRANSPARENT, false, key);
		
		#if flash 
		calcFrame();
		#else
		if (Text != "")
		{
			calcFrame();
		}
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_textField = null;
		_defaultFormat = null;
		_formatAdjusted = null;
		_filters = null;
		for (format in _formats)
		{
			format.destroy();
		}
		_formats = null;
		super.destroy();
	}
	
	/**
	 * Adds another format to this FlxText
	 * 
	 * @param	Format	The format to be added.
	 * @param	Start	(Default=-1) The start index of the string where the format will be applied. If greater than -1, this value will override the format.start value.
	 * @param	End		(Default=-1) The end index of the string where the format will be applied. If greater than -1, this value will override the format.start value.
	 */
	public function addFormat(Format:FlxTextFormat, Start:Int = -1, End:Int = -1):Void
	{
		Format.start = (Start > -1) ? Start : Format.start;
		Format.end = (End > -1) ? End : Format.end;
		_formats.push(Format);
		// sort the array using the start value of the format so we can skip formats that can't be applied to the textField
		_formats.sort(function(left:FlxTextFormat, right:FlxTextFormat) { return left.start < right.start ? -1 : 1; } );
		dirty = true;
	}
	
	/**
	 * Removes a specific FlxTextFormat from this text.
	 */
	public inline function removeFormat(Format:FlxTextFormat):Void
	{
		FlxArrayUtil.fastSplice(_formats, Format);
		dirty = true;
	}
	
	/**
	 * Clears all the formats applied.
	 */
	public function clearFormats():Void
	{
		for (format in _formats)
		{
			format.destroy();
			format = null;
		}
		
		_formats = [];
		
		updateFormat(_defaultFormat);
		dirty = true;
	}
	
	
	/**
	 * You can use this if you have a lot of text parameters
	 * to set instead of the individual properties.
	 * 
	 * @param	Font		The name of the font face for the text display.
	 * @param	Size		The size of the font (in pixels essentially).
	 * @param	Color		The color of the text in traditional flash 0xRRGGBB format.
	 * @param	Alignment	A string representing the desired alignment ("left,"right" or "center").
	 * @param	BorderStyle	FlxText.NONE, SHADOW, OUTLINE, or OUTLINE_FAST (use setBorderFormat
	 * @param	BorderColor Int, color for the border, 0xRRGGBB format
	 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
	 */
	public function setFormat(?Font:String, Size:Float = 8, Color:Int = 0xffffff, ?Alignment:String, BorderStyle:Int = BORDER_NONE, BorderColor:Int = 0x000000, Embedded:Bool = true):FlxText
	{
		if (Embedded)
		{
			if (Font == null)
			{
				_defaultFormat.font = FlxAssets.FONT_DEFAULT;
			}
			else 
			{
				_defaultFormat.font = Assets.getFont(Font).fontName;
			}
		}
		else if (Font != null)
		{
			_defaultFormat.font = Font;
		}
		
		_textField.embedFonts = Embedded;
		
		_defaultFormat.size = Size;
		Color &= 0x00ffffff;
		_defaultFormat.color = Color;
		_defaultFormat.align = convertTextAlignmentFromString(Alignment);
		_textField.defaultTextFormat = _defaultFormat;
		borderStyle = BorderStyle;
		borderColor = BorderColor;
		updateFormat(_defaultFormat);
		dirty = true;
		
		return this;
	}
	
	/**
	 * Set border's style (shadow, outline, etc), color, and size all in one go!
	 * 
	 * @param	Style outline style - FlxText.NONE, SHADOW, OUTLINE, OUTLINE_FAST
	 * @param	Color outline color in flash 0xRRGGBB format
	 * @param	Size outline size in pixels
	 * @param	Quality outline quality - # of iterations to use when drawing. 0:just 1, 1:equal number to BorderSize
	 */
	public inline function setBorderStyle(Style:Int, Color:Int = 0x000000, Size:Float = 1, Quality:Float = 1):Void 
	{
		borderStyle = Style;
		borderColor = Color;
		borderSize = Size;
		borderQuality = Quality;
	}
	
	public function addFilter(filter:BitmapFilter, widthInc:Int = 0, heightInc:Int = 0):Void
	{
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
	
	override public function updateFrameData():Void
	{
		if (cachedGraphics != null)
		{
			framesData = cachedGraphics.tilesheet.getSpriteSheetFrames(region);
			frame = framesData.frames[0];
			frames = 1;
		}
	}
	
	private inline function applyFormats(FormatAdjusted:TextFormat, UseBorderColor:Bool = false):Void
	{
		// Apply the default format
		FormatAdjusted.color = UseBorderColor ? borderColor : _defaultFormat.color;
		updateFormat(FormatAdjusted);
		
		// Apply other formats
		for (format in _formats)
		{
			if (_textField.text.length - 1 < format.start) 
			{
				// we can break safely because the array is ordered by the format start value
				break;
			}
			else 
			{
				FormatAdjusted.font    = format.format.font;
				FormatAdjusted.bold    = format.format.bold;
				FormatAdjusted.italic  = format.format.italic;
				FormatAdjusted.size    = format.format.size;
				FormatAdjusted.color   = UseBorderColor ? format.borderColor : format.format.color;
			}
			
			_textField.setTextFormat(FormatAdjusted, format.start, Std.int(Math.min(format.end, _textField.text.length)));
		}
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
			dirty = true;
		}
		
		return Width;
	}
	
	private function get_text():String
	{
		return _textField.text;
	}
	
	private function set_text(Text:String):String
	{
		var ot:String = _textField.text;
		_textField.text = Text;
		
		if(_textField.text != ot)
		{
			dirty = true;
		}
		
		return _textField.text;
	}
	
	private function get_size():Float
	{
		return _defaultFormat.size;
	}
	
	private function set_size(Size:Float):Float
	{
		_defaultFormat.size = Size;
		_textField.defaultTextFormat = _defaultFormat;
		updateFormat(_defaultFormat);
		dirty = true;
		
		return Size;
	}
	
	/**
	 * The color of the text being displayed.
	 */
	override private function set_color(Color:Int):Int
	{
		Color &= 0x00ffffff;
		if (_defaultFormat.color == Color)
		{
			return Color;
		}
		_defaultFormat.color = Color;
		color = Color;
		_textField.defaultTextFormat = _defaultFormat;
		updateFormat(_defaultFormat);
		dirty = true;
		return Color;
	}
	
	private function get_font():String
	{
		return _defaultFormat.font;
	}
	
	private function set_font(Font:String):String
	{
		_textField.embedFonts = true;
		_defaultFormat.font = Assets.getFont(Font).fontName;
		_textField.defaultTextFormat = _defaultFormat;
		updateFormat(_defaultFormat);
		dirty = true;
		return Font;
	}
	
	private function get_embedded():Bool
	{
		return _textField.embedFonts = true;
	}
	
	private function get_systemFont():String
	{
		return _defaultFormat.font;
	}
	
	private function set_systemFont(Font:String):String
	{
		_textField.embedFonts = false;
		_defaultFormat.font = Font;
		_textField.defaultTextFormat = _defaultFormat;
		updateFormat(_defaultFormat);
		dirty = true;
		return Font;
	}
	
	private inline function get_bold():Bool 
	{ 
		return _defaultFormat.bold; 
	}
	
	private function set_bold(value:Bool):Bool
	{
		if (_defaultFormat.bold != value)
		{
			_defaultFormat.bold = value;
			_textField.defaultTextFormat = _defaultFormat;
			updateFormat(_defaultFormat);
			dirty = true;
		}
		return value;
	}
	
	private inline function get_italic():Bool 
	{ 
		return _defaultFormat.italic; 
	}
	
	private function set_italic(value:Bool):Bool
	{
		if (_defaultFormat.italic != value)
		{
			_defaultFormat.italic = value;
			_textField.defaultTextFormat = _defaultFormat;
			updateFormat(_defaultFormat);
			dirty = true;
		}
		return value;
	}
	
	private inline function get_wordWrap():Bool 
	{ 
		return _textField.wordWrap; 
	}
	
	private function set_wordWrap(value:Bool):Bool
	{
		if (_textField.wordWrap != value)
		{
			_textField.wordWrap = value;
			_textField.multiline = value;
			dirty = true;
		}
		return value;
	}
	
	private inline function get_alignment():String
	{
		return cast(_defaultFormat.align, String);
	}
	
	private function set_alignment(Alignment:String):String
	{
		_defaultFormat.align = convertTextAlignmentFromString(Alignment);
		_textField.defaultTextFormat = _defaultFormat;
		updateFormat(_defaultFormat);
		dirty = true;
		return Alignment;
	}
	
	private function set_borderStyle(style:Int):Int
	{		
		if (style != borderStyle)
		{
			borderStyle = style;
			dirty = true;
		}
		
		return borderStyle;
	}
	
	private function set_borderColor(Color:Int):Int
	{
		Color &= 0x00ffffff;
		
		if (borderColor != Color && borderStyle != BORDER_NONE)
		{
			dirty = true;
		}
		borderColor = Color;
		
		return Color;
	}
	
	private function set_borderSize(Value:Float):Float
	{
		if (Value != borderSize && borderStyle != BORDER_NONE)
		{			
			dirty = true;
		}
		borderSize = Value;
		
		return Value;
	}
	
	private function set_borderQuality(Value:Float):Float
	{
		if (Value < 0)
			Value = 0;
		else if (Value > 1)
			Value = 1;
		
		if (Value != borderQuality && borderStyle != BORDER_NONE)
		{
			dirty = true;
		}
		borderQuality = Value;
		
		return Value;
	}
	
	private function get_textField():TextField 
	{
		return _textField;
	}
	
	override private function set_cachedGraphics(Value:CachedGraphics):CachedGraphics 
	{
		var cached:CachedGraphics = super.set_cachedGraphics(Value);
		
		if (Value != null)
			Value.destroyOnNoUse = true;
		
		return cached;
	}
	
	override private function updateColorTransform():Void
	{
		if (alpha != 1)
		{
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform(1, 1, 1, alpha);
			}
			else
			{
				_colorTransform.alphaMultiplier = alpha;
			}
			useColorTransform = true;
		}
		else
		{
			if (_colorTransform != null)
			{
				_colorTransform.alphaMultiplier = 1;
			}
			
			useColorTransform = false;
		}
		
		dirty = true;
	}
	
	private function regenGraphics():Void
	{
		var oldWidth:Float = cachedGraphics.bitmap.width;
		var oldHeight:Float = cachedGraphics.bitmap.height;
		
		var newWidth:Float = _textField.width + _widthInc;
		// Account for 2px gutter on top and bottom (that's why there is "+ 4")
		var newHeight:Float = _textField.textHeight + _heightInc + 4;
		
		if ((oldWidth != newWidth) || (oldHeight != newHeight))
		{
			// Need to generate a new buffer to store the text graphic
			height = newHeight - _heightInc;
			var key:String = cachedGraphics.key;
			FlxG.bitmap.remove(key);
			
			makeGraphic(Std.int(newWidth), Std.int(newHeight), FlxColor.TRANSPARENT, false, key);
			frameHeight = Std.int(height);
			_textField.height = height * 1.2;
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = newWidth;
			_flashRect.height = newHeight;
		}
		// Else just clear the old buffer before redrawing the text
		else
		{
			cachedGraphics.bitmap.fillRect(_flashRect, FlxColor.TRANSPARENT);
		}
	}
	
	/**
	 * Internal function to update the current animation frame.
	 * 
	 * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
	 */
	override private function calcFrame(RunOnCpp:Bool = false):Void
	{
		if (_textField == null)
		{
			return;
		}
		
		if (_filters != null)
		{
			_textField.filters = _filters;
		}
		
		regenGraphics();
		
		if ((_textField != null) && (_textField.text != null) && (_textField.text.length > 0))
		{
			// Now that we've cleared a buffer, we need to actually render the text to it
			_formatAdjusted.font   = _defaultFormat.font;
			_formatAdjusted.size   = _defaultFormat.size;
			_formatAdjusted.bold   = _defaultFormat.bold;
			_formatAdjusted.italic = _defaultFormat.italic;
			_formatAdjusted.color  = _defaultFormat.color;
			_formatAdjusted.align  = _defaultFormat.align;
			_matrix.identity();
			
			_matrix.translate(Std.int(0.5 * _widthInc), Std.int(0.5 * _heightInc));
			
			// If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
			#if js
			if (_defaultFormat.align == TextFormatAlign.CENTER)
			#else
			if ((_defaultFormat.align == TextFormatAlign.CENTER) && (_textField.numLines == 1))
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
			
			if (borderStyle != BORDER_NONE)
			{
				var iterations:Int = Std.int(borderSize * borderQuality);
				if (iterations <= 0) 
				{ 
					iterations = 1;
				}
				var delta:Float = (borderSize / iterations);
				
				if (borderStyle == BORDER_SHADOW) 
				{
					//Render a shadow beneath the text
					//(do one lower-right offset draw call)
					applyFormats(_formatAdjusted, true);
					
					for (iter in 0...iterations)
					{
						_matrix.translate(delta, delta);
						cachedGraphics.bitmap.draw(_textField, _matrix);
					}
					
					_matrix.translate(-borderSize, -borderSize);
					applyFormats(_formatAdjusted, false);
				}
				else if (borderStyle == BORDER_OUTLINE) 
				{
					//Render an outline around the text
					//(do 8 offset draw calls)
					applyFormats(_formatAdjusted, true);
					
					var itd:Float = delta;
					for (iter in 0...iterations)
					{
						_matrix.translate(-itd, -itd);		//upper-left
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(itd, 0);			//upper-middle
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(itd, 0);			//upper-right
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(0, itd);			//middle-right
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(0, itd);			//lower-right
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(-itd, 0);			//lower-middle
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(-itd, 0);			//lower-left
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(0, -itd);			//middle-left
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(itd, 0);			//return to center
						itd += delta;
					} 
					
					applyFormats(_formatAdjusted, false);
				}
				else if (borderStyle == BORDER_OUTLINE_FAST) 
				{
					//Render an outline around the text
					//(do 4 diagonal offset draw calls)
					//(this method might not work with certain narrow fonts)
					applyFormats(_formatAdjusted, true);
					
					var itd:Float = delta;
					for (iter in 0...iterations)
					{
						_matrix.translate(-itd, -itd);			//upper-left
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(itd*2, 0);			//upper-right
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(0, itd*2);			//lower-right
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(-itd*2, 0);			//lower-left
						cachedGraphics.bitmap.draw(_textField, _matrix);
						_matrix.translate(itd, -itd);			//return to center
						itd += delta;
					}
					
					applyFormats(_formatAdjusted, false);
				}
			}
			else
			{
				applyFormats(_formatAdjusted, false);
			}
			
			//Actually draw the text onto the buffer
			cachedGraphics.bitmap.draw(_textField, _matrix);
		}
		
		dirty = false;
		
		#if !(flash || js)
		if (!RunOnCpp)
		{
			return;
		}
		#end
		
		//Finally, update the visible pixels
		if ((framePixels == null) || (framePixels.width != cachedGraphics.bitmap.width) || (framePixels.height != cachedGraphics.bitmap.height))
		{
			if (framePixels != null)
				framePixels.dispose();
			
			framePixels = new BitmapData(cachedGraphics.bitmap.width, cachedGraphics.bitmap.height, true, 0);
		}
		
		framePixels.copyPixels(cachedGraphics.bitmap, _flashRect, _flashPointZero);
		
		if (useColorTransform) 
		{
			framePixels.colorTransform(_flashRect, _colorTransform);
		}
	}
	
	/**
	 * A helper function for updating the TextField that we use for rendering.
	 * 
	 * @return	A writable copy of TextField.defaultTextFormat.
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
	
	private inline function updateFormat(Format:TextFormat):Void
	{
		#if !flash
		_textField.setTextFormat(Format, 0, _textField.text.length);
		#else
		_textField.setTextFormat(Format);
		#end
	}
}

class FlxTextFormat implements IFlxDestroyable
{
	/**
	 * The border color if FlxText has a shadow or a border
	 */
	public var borderColor:Int;
	
	/**
	 * The start index of the string where the format will be applied
	 */
	public var start:Int = -1;
	/**
	 * The end index of the string where the format will be applied
	 */
	public var end:Int = -1;
	
	/**
	 * Internal TextFormat
	 */
	public var format(default, null):TextFormat;
	
	/**
	 * @param	FontColor	(Optional) Set the font  color. By default, inherits from the default format.
	 * @param	Bold		(Optional) Set the font to bold. The font must support bold. By default, false. 
	 * @param	Italic		(Optional) Set the font to italics. The font must support italics. Only works in Flash. By default, false.  
	 * @param	BorderColor	(Optional) Set the border color. By default, no border (The color is TRANSPARENT)
	 * @param	Start		(Default=-1) The start index of the string where the format will be applied. If not set, the format won't be applied.
	 * @param	End			(Default=-1) The end index of the string where the format will be applied.
	 */
	public function new(?FontColor:Int, ?Bold:Bool, ?Italic:Bool, ?BorderColor:Int, ?Start:Int = -1, ?End:Int = -1)
	{
		if (FontColor != null)
		{
			FontColor &= 0x00ffffff;
		}
		if (BorderColor != null)
		{
			BorderColor &= 0x00ffffff;
		}
		format = new TextFormat(null, null, FontColor, Bold, Italic);
		
		if (Start > -1)
		{
			start = Start;
		}
		if (End > -1)
		{
			end = End;
		}
		
		borderColor = BorderColor == null ? FlxColor.TRANSPARENT : BorderColor;
	}
	
	public function destroy():Void
	{
		format = null;
	}
}