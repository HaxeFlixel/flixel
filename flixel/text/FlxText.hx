package flixel.text;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxRange;
import openfl.Assets;
import haxe.Utf8;
using flixel.util.FlxStringUtil;
using StringTools;

// TODO: think about filters and text

/**
 * Extends FlxSprite to support rendering text. Can tint, fade, rotate and scale just like a sprite. Doesn't really animate 
 * though, as far as I know. Also does nice pixel-perfect centering on pixel fonts as long as they are only one liners.
 */
class FlxText extends FlxSprite
{
	/**
	 * 2px gutter on both top and bottom
	 */
	private static inline var VERTICAL_GUTTER:Int = 4;

	/**
	 * The text being displayed.
	 */
	public var text(default, set):String = "";
	
	/**
	 * The size of the text being displayed in pixels.
	 */
	public var size(get, set):Int;
	
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
	 * Note: 'autoSize' must be set to false or alignment won't show any visual differences.
	 */
	public var alignment(get, set):FlxTextAlign;
	
	/**
	 * Use a border style
	 */	
	public var borderStyle(default, set):FlxTextBorderStyle = NONE;
	
	/**
	 * The color of the border in 0xAARRGGBB format
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
	
	private var _font:String;
	
	/**
	 * Helper boolean which tells whether to update graphic of this text object or not.
	 */
	private var _regen:Bool = true;
	
	/**
	 * Helper vars to draw border styles with transparency.
	 */
	private var _borderPixels:BitmapData;
	
	private var _borderColorTransform:ColorTransform;
	
	private var _hasBorderAlpha = false;
	
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
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y);
		
		if (Text == null || Text == "")
		{
			// empty texts have a textHeight of 0, need to
			// prevent initialiazing with "" before the first calcFrame() call
			text = "";
			Text = " ";
		}
		else
		{
			text = Text;
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
		
		drawFrame();
		
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
		shadowOffset = FlxDestroyUtil.put(shadowOffset);
		super.destroy();
	}
	
	override public function drawFrame(Force:Bool = false):Void 
	{
		_regen = _regen || Force;
		super.drawFrame(_regen);
	}
	
	/**
	 * Stamps text onto specified atlas object and loads graphic from this atlas.
	 * WARNING: Changing text after stamping it on the atlas will break the atlas, 
	 * so do it only for static texts and only after making all the text customizing (like size, align, color, etc.)
	 * 
	 * @param	atlas	atlas to stamp graphic to.
	 * @return	true - if text's graphic is stamped on atlas successfully, false - in other case.
	 */
	public function stampOnAtlas(atlas:FlxAtlas):Bool
	{
		regenGraphic();
		
		var node:FlxNode = atlas.addNode(graphic.bitmap, graphic.key);
		var result:Bool = (node != null);
		
		if (node != null)
		{
			frames = node.getImageFrame();
		}
		
		return result;
	}
	
	/**
	 * Applies formats to text between marker characters, then removes those markers.
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
	 * @param   rules   FlxTextFormats to selectively apply, paired with marker characters such as "@" or "$"
	 */
	public function applyMarkup(input:String, rules:Array<FlxTextFormatMarkerPair>):FlxText
	{
		if (rules == null || rules.length == 0)
		{
			return this;   //there's no point in running the big loop
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
					for (charIndex in 0...Utf8.length(input))   //inspect each character
					{
						var charCode = Utf8.charCodeAt(input, charIndex);
						if (charCode == rule.marker.charCodeAt(0))   //it's one of the markers
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
				input = input.remove(rule.marker);
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
		
		return this;
	}
	
	/**
	 * Adds another format to this FlxText
	 * 
	 * @param	Format	The format to be added.
	 * @param	Start	(Default = -1) The start index of the string where the format will be applied.
	 * @param	End		(Default = -1) The end index of the string where the format will be applied.
	 */
	public function addFormat(Format:FlxTextFormat, Start:Int = -1, End:Int = -1):FlxText
	{
		_formatRanges.push(new FlxTextFormatRange(Format, Start, End));
		// sort the array using the start value of the format so we can skip formats that can't be applied to the textField
		_formatRanges.sort(function(left, right)
		{ 
			return left.range.start < right.range.start ? -1 : 1;
		});
		_regen = true;
		
		return this;
	}
	
	/**
	 * Removes a specific FlxTextFormat from this text.
	 * If a range is specified, this only removes the format when it touches that range.
	 */
	public inline function removeFormat(Format:FlxTextFormat, ?Start:Int, ?End:Int):FlxText
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
		_regen = true;
		
		return this;
	}
	
	/**
	 * Clears all the formats applied.
	 */
	public function clearFormats():FlxText
	{
		_formatRanges = [];
		updateDefaultFormat();
		
		return this;
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
	 * @param	BorderColor 	Int, color for the border, 0xAARRGGBB format
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
	 */
	public function setFormat(?Font:String, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, 
		?BorderStyle:FlxTextBorderStyle, BorderColor:FlxColor = FlxColor.TRANSPARENT, Embedded:Bool = true):FlxText
	{
		BorderStyle = (BorderStyle == null) ? NONE : BorderStyle;
		
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
		if (Alignment != null)
			alignment = Alignment;
		setBorderStyle(BorderStyle, BorderColor);
		
		updateDefaultFormat();
		
		return this;
	}
	
	/**
	 * Set border's style (shadow, outline, etc), color, and size all in one go!
	 * 
	 * @param	Style outline style
	 * @param	Color outline color in 0xAARRGGBB format
	 * @param	Size outline size in pixels
	 * @param	Quality outline quality - # of iterations to use when drawing. 0:just 1, 1:equal number to BorderSize
	 */
	public inline function setBorderStyle(Style:FlxTextBorderStyle, Color:FlxColor = 0, Size:Float = 1, Quality:Float = 1):FlxText 
	{
		borderStyle = Style;
		borderColor = Color;
		borderSize = Size;
		borderQuality = Quality;
		
		return this;
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
				autoSize = false;
				wordWrap = true;
				textField.width = value;
			}
			
			_regen = true;
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
			textField.autoSize = value ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			_regen = true;
		}
		
		return value;
	}
	
	private function get_autoSize():Bool
	{
		return (textField != null) ? (textField.autoSize != TextFieldAutoSize.NONE) : false;
	}
	
	private function set_text(Text:String):String
	{
		text = Text;
		if (textField != null)
		{
			var ot:String = textField.text;
			textField.text = Text;
			_regen = (textField.text != ot) || _regen;
		}
		return Text;
	}
	
	private inline function get_size():Int
	{
		return Std.int(_defaultFormat.size);
	}
	
	private function set_size(Size:Int):Int
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
			_regen = true;
		}
		return value;
	}
	
	private inline function get_alignment():FlxTextAlign
	{
		return FlxTextAlign.fromOpenFL(_defaultFormat.align);
	}
	
	private function set_alignment(Alignment:FlxTextAlign):FlxTextAlign
	{
		_defaultFormat.align = FlxTextAlign.toOpenFL(Alignment);
		updateDefaultFormat();
		return Alignment;
	}
	
	private function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{		
		if (style != borderStyle)
			_regen = true;
		
		return borderStyle = style;
	}
	
	private function set_borderColor(Color:FlxColor):FlxColor
	{
		if (borderColor != Color && borderStyle != NONE)
			_regen = true;
		_hasBorderAlpha = Color.alphaFloat < 1;
		return borderColor = Color;
	}
	
	private function set_borderSize(Value:Float):Float
	{
		if (Value != borderSize && borderStyle != NONE)		
			_regen = true;
		
		return borderSize = Value;
	}
	
	private function set_borderQuality(Value:Float):Float
	{
		Value = FlxMath.bound(Value, 0, 1);
		if (Value != borderQuality && borderStyle != NONE)
			_regen = true;
		
		return borderQuality = Value;
	}
	
	override private function set_graphic(Value:FlxGraphic):FlxGraphic 
	{
		var oldGraphic:FlxGraphic = graphic;
		var graph:FlxGraphic = super.set_graphic(Value);
		FlxG.bitmap.removeIfNoUse(oldGraphic);
		return graph;
	}
	
	override private function get_width():Float 
	{
		regenGraphic();
		return super.get_width();
	}
	
	override private function get_height():Float 
	{
		regenGraphic();
		return super.get_height();
	}
	
	override private function updateColorTransform():Void
	{
		if (colorTransform == null)
			colorTransform = new ColorTransform();
		
		if (alpha != 1)
		{
			colorTransform.alphaMultiplier = alpha;
			useColorTransform = true;
		}
		else
		{
			colorTransform.alphaMultiplier = 1;
			useColorTransform = false;
		}
		
		dirty = true;
	}
	
	private function regenGraphic():Void
	{
		if (textField == null || _regen == false)
			return;
		
		var oldWidth:Int = 0;
		var oldHeight:Int = VERTICAL_GUTTER;
		
		if (graphic != null)
		{
			oldWidth = graphic.width;
			oldHeight = graphic.height;
		}
		
		var newWidth:Float = textField.width;
		// Account for gutter
		var newHeight:Float = textField.textHeight + VERTICAL_GUTTER;
		
		// prevent text height from shrinking on flash if text == ""
		if (textField.textHeight == 0) 
		{
			newHeight = oldHeight;
		}
		
		if (oldWidth != newWidth || oldHeight != newHeight)
		{
			// Need to generate a new buffer to store the text graphic
			height = newHeight;
			var key:String = FlxG.bitmap.getUniqueKey("text");
			
			makeGraphic(Std.int(newWidth), Std.int(newHeight), FlxColor.TRANSPARENT, false, key);
			if (_hasBorderAlpha)
				_borderPixels = graphic.bitmap.clone();
			frameHeight = Std.int(height);
			textField.height = height * 1.2;
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = newWidth;
			_flashRect.height = newHeight;
		}
		else // Else just clear the old buffer before redrawing the text
		{
			graphic.bitmap.fillRect(_flashRect, FlxColor.TRANSPARENT);
			if (_hasBorderAlpha)
			{
				if (_borderPixels == null)
					_borderPixels = new BitmapData(frameWidth, frameHeight, true);
				else
					_borderPixels.fillRect(_flashRect, FlxColor.TRANSPARENT);
			}
		}
		
		if (textField != null && textField.text != null && textField.text.length > 0)
		{
			// Now that we've cleared a buffer, we need to actually render the text to it
			copyTextFormat(_defaultFormat, _formatAdjusted);
			
			_matrix.identity();
			
			avoidSingleLineBlur();
			
			applyBorderStyle();
			applyBorderTransparency();
			applyFormats(_formatAdjusted, false);
			
			graphic.bitmap.draw(textField, _matrix);
		}
		
		_regen = false;
		resetFrame();
	}
	
	private function avoidSingleLineBlur():Void
	{
		#if flash
		// If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
		if (textField.numLines > 1 || alignment != FlxTextAlign.CENTER)
			return;
		
		_formatAdjusted.align = TextFormatAlign.LEFT;
		textField.setTextFormat(_formatAdjusted);
		
		var textWidth = textField.getLineMetrics(0).width;
		if (textWidth <= textField.width)
			_matrix.translate(Math.floor((textField.width - textWidth) / 2), 0);
		#end
	}
	
	override public function draw():Void 
	{
		regenGraphic();
		super.draw();
	}
	
	/**
	 * Internal function to update the current animation frame.
	 * 
	 * @param	RunOnCpp	Whether the frame should also be recalculated if we're on a non-flash target
	 */
	override private function calcFrame(RunOnCpp:Bool = false):Void
	{
		if (textField == null)
			return;
		
		if (FlxG.renderTile && !RunOnCpp)
			return;
		
		regenGraphic();
		super.calcFrame(RunOnCpp);
	}
	
	private function applyBorderStyle():Void
	{
		var iterations:Int = Std.int(borderSize * borderQuality);
		if (iterations <= 0) 
		{ 
			iterations = 1;
		}
		var delta:Float = borderSize / iterations;
		
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
	
	private inline function applyBorderTransparency()
	{
		if (!_hasBorderAlpha)
			return;
		
		if (_borderColorTransform == null)
			_borderColorTransform = new ColorTransform();
			
		_borderColorTransform.alphaMultiplier = borderColor.alphaFloat;
		_borderPixels.colorTransform(_borderPixels.rect, _borderColorTransform);
		graphic.bitmap.draw(_borderPixels);
	}
	
	/**
	 * Helper function for applyBorderStyle()
	 */
	private inline function copyTextWithOffset(x:Float, y:Float)
	{
		var graphic:BitmapData = _hasBorderAlpha ? _borderPixels : graphic.bitmap;
		_matrix.translate(x, y);
		graphic.draw(textField, _matrix);
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
		if (withAlign)
			to.align = from.align;
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
	
	private inline function updateDefaultFormat():Void
	{
		textField.defaultTextFormat = _defaultFormat;
		textField.setTextFormat(_defaultFormat);
		_regen = true;
	}
	
	override function set_frames(Frames:FlxFramesCollection):FlxFramesCollection 
	{
		super.set_frames(Frames);
		_regen = false;
		return Frames;
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
	
	public static function fromOpenFL(align:AlignType):FlxTextAlign
	{
		return switch (align)
		{
			case TextFormatAlign.LEFT: LEFT;
			case TextFormatAlign.CENTER: CENTER;
			case TextFormatAlign.RIGHT: RIGHT;
			case TextFormatAlign.JUSTIFY: JUSTIFY;
			default: LEFT;
		}
	}
	
	public static function toOpenFL(align:FlxTextAlign):AlignType
	{
		return switch (align)
		{
			case LEFT: TextFormatAlign.LEFT;
			case CENTER: TextFormatAlign.CENTER;
			case RIGHT: TextFormatAlign.RIGHT;
			case JUSTIFY: TextFormatAlign.JUSTIFY;
			default: TextFormatAlign.LEFT;
		}
	}
}

private typedef AlignType = #if openfl_legacy String #else TextFormatAlign #end
