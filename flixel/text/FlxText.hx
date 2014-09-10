package flixel.text;

import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxRange;
import flixel.util.loaders.CachedGraphics;
import openfl.Assets;
using StringTools;

/**
 * Extends FlxSprite to support rendering text. Can tint, fade, rotate and scale just like a sprite. Doesn't really animate 
 * though, as far as I know. Also does nice pixel-perfect centering on pixel fonts as long as they are only one liners.
 */
class FlxText extends FlxSprite
{
	/**
	 * The text being displayed.
	 */
	public var text(get, set):String;
	
	/**
	 * The size of the text being displayed in pixels.
	 */
	public var size(get, set):Float;
	
	/**
	 * The font used for this text (assuming that it's using embedded font).
	 */
	public var font(get, set):String;
	
	/**
	 * Whether this text field uses an embedded font (by default) or not. 
	 * Read-only - use systemFont to specify a system font to use, which then automatically sets this to false.
	 */
	public var embedded(get, never):Bool;
	
	/**
	 * The system font for this text (not embedded). Setting this sets embedded to false.
	 * Passing an invalid font name (like "" or null) causes a default font to be used. 
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
	 * The alignment of the font (LEFT, RIGHT, CENTER or JUSTIFY).
	 */
	public var alignment(get, set):FlxTextAlign;
	
	/**
	 * Use a border style
	 */	
	public var borderStyle(default, set):FlxTextBorderStyle = NONE;
	
	/**
	 * The color of the border in 0xRRGGBB format
	 */	
	public var borderColor(default, set):FlxColor = FlxColor.TRANSPARENT;
	
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
	public var textField(default, null):TextField;
	
	/**
	 * The width of the TextField object used for bitmap generation for this FlxText object.
	 * Use it when you want to change the visible width of text. Enables autoSize if <= 0.
	 */
	public var fieldWidth(get, set):Float;
	
	/**
	 * Whether the fieldWidth should be determined automatically. Requires wordWrap to be false.
	 */
	public var autoSize(get, set):Bool;
	
	/**
	 * Offset that is applied to the shadow border style, if active. 
	 * x and y are multiplied by borderSize. Default is (1, 1), or lower-right corner.
	 */
	public var shadowOffset(default, null):FlxPoint;
	
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
	private var _formatRanges:Array<FlxTextFormatRange> = [];
	
	private var _filters:Array<BitmapFilter>;
	private var _widthInc:Int = 0;
	private var _heightInc:Int = 0;
	
	private var _font:String;
	
	/**
	 * Creates a new FlxText object at the specified position.
	 * 
	 * @param   X              The X position of the text.
	 * @param   Y              The Y position of the text.
	 * @param   FieldWidth     The width of the text object. Enables autoSize if <= 0.
	 *                         (height is determined automatically).
	 * @param   Text           The actual text you would like to display initially.
	 * @param   Size           The font size for this text object.
	 * @param   EmbeddedFont   Whether this text field uses embedded fonts or not.
	 */
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Float = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y);
		
		_filters = [];
		
		var setTextEmpty:Bool = false;
		if (Text == null || Text == "")
		{
			// empty texts have a textHeight of 0, need to
			// prevent initialiazing with "" before the first calcFrame() call
			#if flash
			Text = " ";
			#else
			Text = "";
			#end
			setTextEmpty = true;
		}
		
		textField = new TextField();
		textField.selectable = false;
		textField.multiline = true;
		textField.wordWrap = true;
		_defaultFormat = new TextFormat(null, Size, 0xffffff);
		font = FlxAssets.FONT_DEFAULT;
		_formatAdjusted = new TextFormat();
		textField.defaultTextFormat = _defaultFormat;
		textField.text = Text;
		fieldWidth = FieldWidth;
		textField.embedFonts = EmbeddedFont;
		
		#if flash
		textField.sharpness = 100;
		#end
		
		textField.height = (Text.length <= 0) ? 1 : 10;
		
		allowCollisions = FlxObject.NONE;
		moves = false;
		
		var key:String = FlxG.bitmap.getUniqueKey("text");
		var graphicWidth:Int = (FieldWidth <= 0) ? 1 : Std.int(FieldWidth);
		makeGraphic(graphicWidth, 1, FlxColor.TRANSPARENT, false, key);
		
		#if FLX_RENDER_BLIT 
		calcFrame();
		if (setTextEmpty)
		{
			text = "";
		}
		#else
		if (Text != "")
		{
			calcFrame();
		}
		#end
		
		shadowOffset = FlxPoint.get(1, 1);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		textField = null;
		_font = null;
		_defaultFormat = null;
		_formatAdjusted = null;
		_filters = null;
		shadowOffset = FlxDestroyUtil.put(shadowOffset);
		super.destroy();
	}
	
	/**
	 * Applies formats to text between marker strings, then removes those markers.
	 * NOTE: This will clear all FlxTextFormats and return to the default format.
	 * 
	 * Usage: 
	 * 
	 *    t.applyMarkup("show $green text$ between dollar-signs", [new FlxTextFormatMarkerPair(greenFormat, "$")]);
	 * 
	 * Even works for complex nested formats like this:
	 * 
	 *    yellow = new FlxTextFormatMarkerPair(yellowFormat, "@");
	 *    green = new FlxTextFormatMarkerPair(greenFormat, "$");
	 *    t.applyMarkup("HEY_BUDDY_@WHAT@_$IS_$_GOING@ON$?$@", [yellow, green]);
	 * 
	 * @param   input   The text you want to format
	 * @param   rules   FlxTextFormats to selectively apply, paired with marker strings such as "@" or "$"
	 */
	public function applyMarkup(input:String, rules:Array<FlxTextFormatMarkerPair>):Void
	{
		if (rules == null || rules.length == 0)
		{
			return;   //there's no point in running the big loop
		}
		
		clearFormats();   //start with default formatting
		
		var rangeStarts:Array<Int> = [];
		var rangeEnds:Array<Int> = [];
		var rulesToApply:Array<FlxTextFormatMarkerPair> = [];
		
		var i:Int = 0;
		for (rule in rules)
		{
			if (rule.marker != null && rule.format != null)
			{
				var start:Bool = false;
				if (input.indexOf(rule.marker) != -1)   //if this marker is present
				{
					for (charIndex in 0...input.length)   //inspect each character
					{
						var char:String = input.charAt(charIndex);
						if (char == rule.marker)   //it's one of the markers
						{
							if (!start)   //we're outside of a format block
							{ 
								start = true;   //start a format block
								rangeStarts.push(charIndex);
								rulesToApply.push(rule);
							}
							else
							{
								start = false;
								rangeEnds.push(charIndex); //end a format block
							}
						}
					}
					if (start)
					{
						//we ended with an unclosed block, mark it as infinite
						rangeEnds.push(-1);
					}
				}
				i++;
			}
		}
		
		//Remove all of the markers in the string
		for (rule in rules)
		{
			while (input.indexOf(rule.marker) != -1)
			{
				input = input.replace(rule.marker, "");
			}
		}
		
		//Adjust all the ranges to reflect the removed markers
		for (i in 0...rangeStarts.length)
		{
			//Consider each range start
			var delIndex:Int = rangeStarts[i];
			
			var markerLength:Int = rulesToApply[i].marker.length;
			
			//Any start or end index that is HIGHER than this must be subtracted by one markerLength
			for (j in 0...rangeStarts.length)
			{
				if (rangeStarts[j] > delIndex)
				{
					rangeStarts[j] -= markerLength;
				}
				if (rangeEnds[j] > delIndex)
				{
					rangeEnds[j] -= markerLength;
				}
			}
			
			//Consider each range end
			delIndex = rangeEnds[i];
			
			//Any start or end index that is HIGHER than this must be subtracted by one markerLength
			for (j in 0...rangeStarts.length)
			{
				if (rangeStarts[j] > delIndex)
				{
					rangeStarts[j] -= markerLength;
				}
				if (rangeEnds[j] > delIndex)
				{
					rangeEnds[j] -= markerLength;
				}
			}
		}
		
		//Apply the new text
		text = input;
		
		//Apply each format selectively to the given range
		for (i in 0...rangeStarts.length)
		{
			addFormat(rulesToApply[i].format, rangeStarts[i], rangeEnds[i]);
		}
	}
	
	/**
	 * Adds another format to this FlxText
	 * 
	 * @param	Format	The format to be added.
	 * @param	Start	(Default = -1) The start index of the string where the format will be applied.
	 * @param	End		(Default = -1) The end index of the string where the format will be applied.
	 */
	public function addFormat(Format:FlxTextFormat, Start:Int = -1, End:Int = -1):Void
	{
		_formatRanges.push(new FlxTextFormatRange(Format, Start, End));
		// sort the array using the start value of the format so we can skip formats that can't be applied to the textField
		_formatRanges.sort(function(left, right)
		{ 
			return left.range.start < right.range.start ? -1 : 1;
		});
		dirty = true;
	}
	
	/**
	 * Removes a specific FlxTextFormat from this text.
	 * If a range is specified, this only removes the format when it touches that range.
	 */
	public inline function removeFormat(Format:FlxTextFormat, ?Start:Int, ?End:Int):Void
	{
		for (formatRange in _formatRanges)
		{
			if (formatRange.format == Format)
			{
				if (Start != null && End != null &&
					(Start > formatRange.range.end || End < formatRange.range.start))
				{
					continue;
				}
				
				_formatRanges.remove(formatRange);
			}
		}
		dirty = true;
	}
	
	/**
	 * Clears all the formats applied.
	 */
	public function clearFormats():Void
	{
		_formatRanges = [];
		updateDefaultFormat();
	}
	
	/**
	 * You can use this if you have a lot of text parameters
	 * to set instead of the individual properties.
	 * 
	 * @param	Font			The name of the font face for the text display.
	 * @param	Size			The size of the font (in pixels essentially).
	 * @param	Color			The color of the text in traditional flash 0xRRGGBB format.
	 * @param	Alignment		The desired alignment
	 * @param	BorderStyle		NONE, SHADOW, OUTLINE, or OUTLINE_FAST (use setBorderFormat)
	 * @param	BorderColor 	Int, color for the border, 0xRRGGBB format
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
	 */
	public function setFormat(?Font:String, Size:Float = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, 
		?BorderStyle:FlxTextBorderStyle, BorderColor:FlxColor = FlxColor.TRANSPARENT, Embedded:Bool = true):FlxText
	{
		if (BorderStyle == null)
		{
			BorderStyle = NONE;
		}
		
		if (Embedded)
		{
			font = Font;
		}
		else if (Font != null)
		{
			systemFont = Font;
		}
		
		size = Size;
		color = Color;
		alignment = Alignment;
		setBorderStyle(BorderStyle, BorderColor);
		
		updateDefaultFormat();
		
		return this;
	}
	
	/**
	 * Set border's style (shadow, outline, etc), color, and size all in one go!
	 * 
	 * @param	Style outline style
	 * @param	Color outline color in flash 0xRRGGBB format
	 * @param	Size outline size in pixels
	 * @param	Quality outline quality - # of iterations to use when drawing. 0:just 1, 1:equal number to BorderSize
	 */
	public inline function setBorderStyle(Style:FlxTextBorderStyle, Color:FlxColor = 0, Size:Float = 1, Quality:Float = 1):Void 
	{
		borderStyle = Style;
		borderColor = Color;
		borderSize = Size;
		borderQuality = Quality;
	}
	
	public inline function addFilter(filter:BitmapFilter, widthInc:Int = 0, heightInc:Int = 0):Void
	{
		_filters.push(filter);
		_widthInc = widthInc;
		_heightInc = heightInc;
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
	
	private function set_fieldWidth(value:Float):Float
	{
		if (textField != null)
		{
			if (value <= 0)
			{
				wordWrap = false;
				autoSize = true;
			}
			else
			{
				textField.width = value;
			}
			
			dirty = true;
		}
		
		return value;
	}
	
	private function get_fieldWidth():Float
	{
		return (textField != null) ? textField.width : 0;
	}
	
	private function set_autoSize(value:Bool):Bool
	{
		if (textField != null)
		{
			textField.autoSize = (value) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			dirty = true;
		}
		
		return value;
	}
	
	private function get_autoSize():Bool
	{
		return (textField != null) ? (textField.autoSize != TextFieldAutoSize.NONE) : false;
	}
	
	private inline function get_text():String
	{
		return textField.text;
	}
	
	private function set_text(Text:String):String
	{
		var ot:String = textField.text;
		textField.text = Text;
		
		if (textField.text != ot)
		{
			dirty = true;
		}
		
		return textField.text;
	}
	
	private inline function get_size():Float
	{
		return _defaultFormat.size;
	}
	
	private function set_size(Size:Float):Float
	{
		_defaultFormat.size = Size;
		updateDefaultFormat();
		return Size;
	}
	
	override private function set_color(Color:FlxColor):Int
	{
		if (_defaultFormat.color == Color.to24Bit())
		{
			return Color;
		}
		_defaultFormat.color = Color.to24Bit();
		color = Color;
		updateDefaultFormat();
		return Color;
	}
	
	private inline function get_font():String
	{
		return _font;
	}
	
	private function set_font(Font:String):String
	{
		textField.embedFonts = true;
		
		if (Font != null)
		{
			var newFontName:String = Font;
			if (Assets.exists(Font, AssetType.FONT))
			{
				newFontName = Assets.getFont(Font).fontName;
			}
			
			_defaultFormat.font = newFontName;
		}
		else
		{
			_defaultFormat.font = FlxAssets.FONT_DEFAULT;
		}
		
		updateDefaultFormat();
		return _font = _defaultFormat.font;
	}
	
	private inline function get_embedded():Bool
	{
		return textField.embedFonts = true;
	}
	
	private inline function get_systemFont():String
	{
		return _defaultFormat.font;
	}
	
	private function set_systemFont(Font:String):String
	{
		textField.embedFonts = false;
		_defaultFormat.font = Font;
		updateDefaultFormat();
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
			updateDefaultFormat();
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
			updateDefaultFormat();
		}
		return value;
	}
	
	private inline function get_wordWrap():Bool 
	{ 
		return textField.wordWrap; 
	}
	
	private function set_wordWrap(value:Bool):Bool
	{
		if (textField.wordWrap != value)
		{
			textField.wordWrap = value;
			dirty = true;
		}
		return value;
	}
	
	private inline function get_alignment():FlxTextAlign
	{
		return cast(_defaultFormat.align, String);
	}
	
	private function set_alignment(Alignment:FlxTextAlign):FlxTextAlign
	{
		_defaultFormat.align = convertTextAlignmentFromString(Alignment);
		updateDefaultFormat();
		return Alignment;
	}
	
	private function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{		
		if (style != borderStyle)
		{
			borderStyle = style;
			dirty = true;
		}
		
		return borderStyle;
	}
	
	private function set_borderColor(Color:FlxColor):FlxColor
	{
		if (borderColor.to24Bit() != Color.to24Bit() && borderStyle != NONE)
		{
			dirty = true;
		}
		borderColor = Color;
		return Color;
	}
	
	private function set_borderSize(Value:Float):Float
	{
		if (Value != borderSize && borderStyle != NONE)
		{			
			dirty = true;
		}
		borderSize = Value;
		
		return Value;
	}
	
	private function set_borderQuality(Value:Float):Float
	{
		Value = FlxMath.bound(Value, 0, 1);
		
		if (Value != borderQuality && borderStyle != NONE)
		{
			dirty = true;
		}
		borderQuality = Value;
		
		return Value;
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
			if (colorTransform == null)
			{
				colorTransform = new ColorTransform(1, 1, 1, alpha);
			}
			else
			{
				colorTransform.alphaMultiplier = alpha;
			}
			useColorTransform = true;
		}
		else
		{
			if (colorTransform != null)
			{
				colorTransform.alphaMultiplier = 1;
			}
			
			useColorTransform = false;
		}
		
		dirty = true;
	}
	
	private function regenGraphics():Void
	{
		var oldWidth:Float = cachedGraphics.bitmap.width;
		var oldHeight:Float = cachedGraphics.bitmap.height;
		
		var newWidth:Float = textField.width + _widthInc;
		// Account for 2px gutter on top and bottom (that's why there is "+ 4")
		var newHeight:Float = textField.textHeight + _heightInc + 4;
		
		// prevent text height from shrinking on flash if text == ""
		if (textField.textHeight == 0) 
		{
			newHeight = oldHeight;
		}
		
		if (oldWidth != newWidth || oldHeight != newHeight)
		{
			// Need to generate a new buffer to store the text graphic
			height = newHeight - _heightInc;
			var key:String = cachedGraphics.key;
			FlxG.bitmap.remove(key);
			
			makeGraphic(Std.int(newWidth), Std.int(newHeight), FlxColor.TRANSPARENT, false, key);
			frameHeight = Std.int(height);
			textField.height = height * 1.2;
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = newWidth;
			_flashRect.height = newHeight;
		}
		else // Else just clear the old buffer before redrawing the text
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
		if (textField == null)
		{
			return;
		}
		
		if (_filters != null)
		{
			textField.filters = _filters;
		}
		
		regenGraphics();
		
		if (textField != null && textField.text != null && textField.text.length > 0)
		{
			// Now that we've cleared a buffer, we need to actually render the text to it
			copyTextFormat(_defaultFormat, _formatAdjusted);
			
			_matrix.identity();
			_matrix.translate(Std.int(0.5 * _widthInc), Std.int(0.5 * _heightInc));
			
			// If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
			if (_defaultFormat.align == TextFormatAlign.CENTER && textField.numLines == 1)
			{
				_formatAdjusted.align = TextFormatAlign.LEFT;
				textField.setTextFormat(_formatAdjusted);
				
				#if bitfive
					var textWidth = textField.textWidth;
				#else
					var textWidth = textField.getLineMetrics(0).width;
				#end
				if (textField.textWidth <= textField.width)
					_matrix.translate(Math.floor((width - textWidth) / 2), 0);
			}
			
			applyBorderStyle();
			applyFormats(_formatAdjusted, false);

			cachedGraphics.bitmap.draw(textField, _matrix);
		}
		
		dirty = false;
		
		#if FLX_RENDER_TILE
		if (!RunOnCpp)
		{
			return;
		}
		#end
		
		//Finally, update the visible pixels
		if (framePixels == null || framePixels.width != cachedGraphics.bitmap.width || framePixels.height != cachedGraphics.bitmap.height)
		{
			framePixels = FlxDestroyUtil.dispose(framePixels);
			framePixels = new BitmapData(cachedGraphics.bitmap.width, cachedGraphics.bitmap.height, true, 0);
		}
		
		framePixels.copyPixels(cachedGraphics.bitmap, _flashRect, _flashPointZero);
		
		if (useColorTransform) 
		{
			framePixels.colorTransform(_flashRect, colorTransform);
		}
	}
	
	private function applyBorderStyle():Void
	{
		var iterations:Int = Std.int(borderSize * borderQuality);
		if (iterations <= 0) 
		{ 
			iterations = 1;
		}
		var delta:Float = (borderSize / iterations);
		
		switch (borderStyle)
		{
			case SHADOW:
				//Render a shadow beneath the text
				//(do one lower-right offset draw call)
				applyFormats(_formatAdjusted, true);
				
				for (i in 0...iterations)
				{
					copyTextWithOffset(delta, delta);
				}
				
				_matrix.translate( -shadowOffset.x * borderSize, -shadowOffset.y * borderSize);
				
			case OUTLINE:
				//Render an outline around the text
				//(do 8 offset draw calls)
				applyFormats(_formatAdjusted, true);
				
				var curDelta:Float = delta;
				for (i in 0...iterations)
				{
					copyTextWithOffset( -curDelta, -curDelta); //upper-left
					copyTextWithOffset(curDelta, 0);           //upper-middle
					copyTextWithOffset(curDelta, 0);           //upper-right
					copyTextWithOffset(0, curDelta);           //middle-right
					copyTextWithOffset(0, curDelta);           //lower-right
					copyTextWithOffset( -curDelta, 0);         //lower-middle
					copyTextWithOffset( -curDelta, 0);         //lower-left
					copyTextWithOffset(0, -curDelta);          //lower-left
					
					_matrix.translate(curDelta, 0);            //return to center
					curDelta += delta;
				}
				
			case OUTLINE_FAST:
				//Render an outline around the text
				//(do 4 diagonal offset draw calls)
				//(this method might not work with certain narrow fonts)
				applyFormats(_formatAdjusted, true);
				
				var curDelta:Float = delta;
				for (i in 0...iterations)
				{
					copyTextWithOffset( -curDelta, -curDelta); //upper-left
					copyTextWithOffset(curDelta * 2, 0);       //upper-right
					copyTextWithOffset(0, curDelta * 2);       //lower-right
					copyTextWithOffset( -curDelta * 2, 0);     //lower-left
					
					_matrix.translate(curDelta, -curDelta);    //return to center
					curDelta += delta;
				}
				
			case NONE:
		}
	}
	
	/**
	 * Helper function for applyBorderStyle()
	 */
	private inline function copyTextWithOffset(x:Float, y:Float)
	{
		_matrix.translate(x, y);
		cachedGraphics.bitmap.draw(textField, _matrix);
	}
	
	private inline function applyFormats(FormatAdjusted:TextFormat, UseBorderColor:Bool = false):Void
	{
		// Apply the default format
		copyTextFormat(_defaultFormat, FormatAdjusted, false);
		FormatAdjusted.color = UseBorderColor ? borderColor.to24Bit() : _defaultFormat.color;
		textField.setTextFormat(FormatAdjusted);
		
		// Apply other formats
		for (formatRange in _formatRanges)
		{
			if (textField.text.length - 1 < formatRange.range.start) 
			{
				// we can break safely because the array is ordered by the format start value
				break;
			}
			else 
			{
				var textFormat:TextFormat = formatRange.format.format;
				copyTextFormat(textFormat, FormatAdjusted, false);
				FormatAdjusted.color = UseBorderColor ? formatRange.format.borderColor.to24Bit() : textFormat.color;
			}
			
			textField.setTextFormat(FormatAdjusted, formatRange.range.start,
				Std.int(Math.min(formatRange.range.end, textField.text.length)));
		}
	}
	
	private function copyTextFormat(from:TextFormat, to:TextFormat, withAlign:Bool = true):Void
	{
		to.font = from.font;
		to.bold = from.bold;
		to.italic = from.italic;
		to.size = from.size;
		to.color = from.color;
		if(withAlign) to.align = from.align;
	}
	
	/**
	 * A helper function for updating the TextField that we use for rendering.
	 * 
	 * @return	A writable copy of TextField.defaultTextFormat.
	 */
	private function dtfCopy():TextFormat
	{
		var dtf:TextFormat = textField.defaultTextFormat;
		return new TextFormat(dtf.font, dtf.size, dtf.color, dtf.bold, dtf.italic, dtf.underline, dtf.url, dtf.target, dtf.align);
	}
	
	/**
	 * Method for converting string to TextFormatAlign
	 */
	private function convertTextAlignmentFromString(StrAlign:FlxTextAlign)
	{
		return switch (StrAlign)
		{
			case LEFT:
				TextFormatAlign.LEFT;
			case CENTER:
				TextFormatAlign.CENTER;
			case RIGHT:
				TextFormatAlign.RIGHT;
			case JUSTIFY:
				TextFormatAlign.JUSTIFY;
		}
	}
	
	private inline function updateDefaultFormat():Void
	{
		textField.defaultTextFormat = _defaultFormat;
		textField.setTextFormat(_defaultFormat);
		dirty = true;
	}
}

@:allow(flixel)
class FlxTextFormat
{
	/**
	 * The border color if FlxText has a shadow or a border
	 */
	private var borderColor:FlxColor;
	private var format(default, null):TextFormat;
	
	/**
	 * @param   FontColor     Set the font color. By default, inherits from the default format.
	 * @param   Bold          Set the font to bold. The font must support bold. By default, false. 
	 * @param   Italic        Set the font to italics. The font must support italics. Only works in Flash. By default, false.  
	 * @param   BorderColor   Set the border color. By default, no border (null / transparent).
	 */
	public function new(?FontColor:FlxColor, ?Bold:Bool, ?Italic:Bool, ?BorderColor:FlxColor)
	{
		format = new TextFormat(null, null, FontColor, Bold, Italic);
		borderColor = BorderColor == null ? FlxColor.TRANSPARENT : BorderColor;
	}
}

@:allow(flixel)
private class FlxTextFormatRange
{
	public var range(default, null):FlxRange<Int>;
	public var format(default, null):FlxTextFormat;
	
	public function new(format:FlxTextFormat, start:Int, end:Int)
	{
		range = new FlxRange<Int>(start, end);
		this.format = format;
	}
}

class FlxTextFormatMarkerPair
{
	public var format:FlxTextFormat;
	public var marker:String;
	
	public function new(format:FlxTextFormat, marker:String)
	{
		this.format = format;
		this.marker = marker;
	}
}

enum FlxTextBorderStyle
{
	NONE;
	/**
	 * A simple shadow to the lower-right
	 */
	SHADOW;
	/**
	 * Outline on all 8 sides
	 */
	OUTLINE;
	/**
	 * Outline, optimized using only 4 draw calls. (Might not work for narrow and/or 1-pixel fonts)
	 */
	OUTLINE_FAST;
}

@:enum
abstract FlxTextAlign(String) from String
{
	var LEFT = "left";
	var CENTER = "center";
	var RIGHT = "right";
	var JUSTIFY = "justify";
}