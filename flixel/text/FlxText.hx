package flixel.text;

import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxRange;
import openfl.Assets;

using flixel.util.FlxStringUtil;
using flixel.util.FlxUnicodeUtil;

#if flash
import openfl.geom.Rectangle;
#end
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end

// TODO: think about filters and text

/**
 * Extends FlxSprite to support rendering text. Can tint, fade, rotate and scale just like a sprite. Doesn't really animate
 * though. Also does nice pixel-perfect centering on pixel fonts as long as they are only one-liners.
 */
class FlxText extends FlxSprite
{
	/**
	 * 2px gutter on both top and bottom
	 */
	static inline var VERTICAL_GUTTER:Int = 4;

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
	 * Read-only - use `systemFont` to specify a system font to use, which then automatically sets this to `false`.
	 */
	public var embedded(get, never):Bool;

	/**
	 * The system font for this text (not embedded). Setting this sets `embedded` to `false`.
	 * Passing an invalid font name (like `""` or `null`) causes a default font to be used.
	 */
	public var systemFont(get, set):String;

	/**
	 * Whether to use bold text or not (`false` by default).
	 */
	public var bold(get, set):Bool;

	/**
	 * Whether to use italic text or not (`false` by default). Only works on Flash.
	 */
	public var italic(get, set):Bool;

	/**
	 * Whether to use word wrapping and multiline or not (`true` by default).
	 */
	public var wordWrap(get, set):Bool;

	/**
	 * The alignment of the font. Note: `autoSize` must be set to
	 * `false` or `alignment` won't show any visual differences.
	 */
	public var alignment(get, set):FlxTextAlign;

	/**
	 * The border style to use
	 */
	public var borderStyle(default, set):FlxTextBorderStyle = NONE;

	/**
	 * The color of the border in `0xAARRGGBB` format
	 */
	public var borderColor(default, set):FlxColor = FlxColor.TRANSPARENT;

	/**
	 * The size of the border, in pixels.
	 */
	public var borderSize(default, set):Float = 1;

	/**
	 * How many iterations do use when drawing the border. `0`: only 1 iteration, `1`: one iteration for every pixel in `borderSize`
	 * A value of `1` will have the best quality for large border sizes, but might reduce performance when changing text.
	 * NOTE: If the `borderSize` is `1`, `borderQuality` of `0` or `1` will have the exact same effect (and performance).
	 */
	public var borderQuality(default, set):Float = 1;

	/**
	 * Reference to a `TextField` object used internally for rendering -
	 * be sure to know what you're doing if messing with its properties!
	 */
	public var textField(default, null):TextField;

	/**
	 * The width of the `TextField` object used for bitmap generation for this `FlxText` object.
	 * Use it when you want to change the visible width of text. Enables `autoSize` if `<= 0`.
	 */
	public var fieldWidth(get, set):Float;

	/**
	 * Whether the `fieldWidth` should be determined automatically. Requires `wordWrap` to be `false`.
	 */
	public var autoSize(get, set):Bool;

	/**
	 * Offset that is applied to the shadow border style, if active.
	 * `x` and `y` are multiplied by `borderSize`. Default is `(1, 1)`, or lower-right corner.
	 */
	public var shadowOffset(default, null):FlxPoint;

	var _defaultFormat:TextFormat;
	var _formatAdjusted:TextFormat;
	var _formatRanges:Array<FlxTextFormatRange> = [];
	var _font:String;

	/**
	 * Helper boolean which tells whether to update graphic of this text object or not.
	 */
	var _regen:Bool = true;

	/**
	 * Helper vars to draw border styles with transparency.
	 */
	var _borderPixels:BitmapData;

	var _borderColorTransform:ColorTransform;

	var _hasBorderAlpha = false;

	#if flash
	/**
	 * Helper to draw line by line used at `drawTextFieldTo()`.
	 */
	var _textFieldRect:Rectangle = new Rectangle();
	#end

	/**
	 * Creates a new `FlxText` object at the specified position.
	 *
	 * @param   X              The x position of the text.
	 * @param   Y              The y position of the text.
	 * @param   FieldWidth     The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
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
			// prevent initializing with "" before the first calcFrame() call
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
		textField.sharpness = 100;
		textField.height = (Text.length <= 0) ? 1 : 10;

		allowCollisions = NONE;
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
	 * WARNING: Changing text after stamping it on the atlas will break the atlas, so do it only for
	 * static texts and only after making all the text customizing (like `size`, `alignment`, `color`, etc.)
	 *
	 * @param	atlas	atlas to stamp graphic to.
	 * @return	whether the graphic was stamped on the atlas successfully
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
	 * NOTE: this will clear all `FlxTextFormat`s and return to the default format.
	 *
	 * Usage:
	 *
	 * ```haxe
	 * text.applyMarkup(
	 * 	"show $green text$ between dollar-signs",
	 * 	[new FlxTextFormatMarkerPair(greenFormat, "$")]
	 * );
	 * ```
	 *
	 * Even works for complex nested formats like this:
	 *
	 * ```haxe
	 * var yellow = new FlxTextFormatMarkerPair(yellowFormat, "@");
	 * var green = new FlxTextFormatMarkerPair(greenFormat, "<g>");
	 * text.applyMarkup("Hey @Buddy@, what <g>is<g> going @on<g>?<g>@", [yellow, green]);
	 * ```
	 *
	 * @param   input   The text you want to format
	 * @param   rules   `FlxTextFormat`s to selectively apply, paired with marker strings
	 */
	public function applyMarkup(input:String, rules:Array<FlxTextFormatMarkerPair>):FlxText
	{
		if (rules == null || rules.length == 0)
			return this; // there's no point in running the big loop

		clearFormats(); // start with default formatting

		var rangeStarts:Array<Int> = [];
		var rangeEnds:Array<Int> = [];
		var rulesToApply:Array<FlxTextFormatMarkerPair> = [];

		var i:Int = 0;
		for (rule in rules)
		{
			if (rule.marker == null || rule.format == null)
				continue;

			var start:Bool = false;
			var markerLength:Int = rule.marker.uLength();

			if (!input.contains(rule.marker))
				continue; // marker not present

			// inspect each character
			for (charIndex in 0...input.uLength())
			{
				if (!input.uSub(charIndex, markerLength).uEquals(rule.marker))
					continue; // it's not one of the markers

				if (start)
				{
					start = false;
					rangeEnds.push(charIndex); // end a format block
				}
				else // we're outside of a format block
				{
					start = true; // start a format block
					rangeStarts.push(charIndex);
					rulesToApply.push(rule);
				}
			}

			if (start)
			{
				// we ended with an unclosed block, mark it as infinite
				rangeEnds.push(-1);
			}

			i++;
		}

		// Remove all of the markers in the string
		for (rule in rules)
			input = input.remove(rule.marker);

		// Adjust all the ranges to reflect the removed markers
		for (i in 0...rangeStarts.length)
		{
			// Consider each range start
			var delIndex:Int = rangeStarts[i];
			var markerLength:Int = rulesToApply[i].marker.uLength();

			// Any start or end index that is HIGHER than this must be subtracted by one markerLength
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

			// Consider each range end
			delIndex = rangeEnds[i];

			// Any start or end index that is HIGHER than this must be subtracted by one markerLength
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

		// Apply the new text
		text = input;

		// Apply each format selectively to the given range
		for (i in 0...rangeStarts.length)
			addFormat(rulesToApply[i].format, rangeStarts[i], rangeEnds[i]);

		return this;
	}

	/**
	 * Adds another format to this `FlxText`
	 *
	 * @param	Format	The format to be added.
	 * @param	Start	The start index of the string where the format will be applied.
	 * @param	End		The end index of the string where the format will be applied.
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
	 * Removes a specific `FlxTextFormat` from this text.
	 * If a range is specified, this only removes the format when it touches that range.
	 */
	public function removeFormat(Format:FlxTextFormat, ?Start:Int, ?End:Int):FlxText
	{
		var i = _formatRanges.length;
		while (i-- > 0)
		{
			var formatRange = _formatRanges[i];
			if (formatRange.format != Format)
				continue;

			if (Start != null && End != null)
			{
				var range = formatRange.range;
				if (Start >= range.end || End <= range.start)
					continue;

				if (Start > range.start && End < range.end)
				{
					addFormat(formatRange.format, End + 1, range.end);
					range.end = Start;
					continue;
				}

				if (Start <= range.start && End < range.end)
				{
					range.start = End;
					continue;
				}

				if (Start > range.start && End >= range.end)
				{
					range.end = Start;
					continue;
				}
			}

			_formatRanges.remove(formatRange);
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
	 * You can use this if you have a lot of text parameters to set instead of the individual properties.
	 *
	 * @param	Font			The name of the font face for the text display.
	 * @param	Size			The size of the font (in pixels essentially).
	 * @param	Color			The color of the text in `0xRRGGBB` format.
	 * @param	Alignment		The desired alignment
	 * @param	BorderStyle		Which border style to use
	 * @param	BorderColor 	Color for the border, `0xAARRGGBB` format
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @return	This `FlxText` instance (nice for chaining stuff together, if you're into that).
	 */
	public function setFormat(?Font:String, Size:Int = 8, Color:FlxColor = FlxColor.WHITE, ?Alignment:FlxTextAlign, ?BorderStyle:FlxTextBorderStyle,
			BorderColor:FlxColor = FlxColor.TRANSPARENT, EmbeddedFont:Bool = true):FlxText
	{
		BorderStyle = (BorderStyle == null) ? NONE : BorderStyle;

		if (EmbeddedFont)
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
	 * @param	Color outline color in `0xAARRGGBB` format
	 * @param	Size outline size in pixels
	 * @param	Quality outline quality - # of iterations to use when drawing. `0`: just 1, `1`: equal number to `Size`
	 */
	public inline function setBorderStyle(Style:FlxTextBorderStyle, Color:FlxColor = 0, Size:Float = 1, Quality:Float = 1):FlxText
	{
		borderStyle = Style;
		borderColor = Color;
		borderSize = Size;
		borderQuality = Quality;

		return this;
	}

	override function updateHitbox()
	{
		regenGraphic();
		super.updateHitbox();
	}

	function set_fieldWidth(value:Float):Float
	{
		if (textField == null)
			return value;

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
		return value;
	}

	function get_fieldWidth():Float
	{
		return (textField != null) ? textField.width : 0;
	}

	function set_autoSize(value:Bool):Bool
	{
		if (textField != null)
		{
			textField.autoSize = value ? TextFieldAutoSize.LEFT : TextFieldAutoSize.NONE;
			_regen = true;
		}

		return value;
	}

	function get_autoSize():Bool
	{
		return (textField != null) ? (textField.autoSize != TextFieldAutoSize.NONE) : false;
	}

	function set_text(Text:String):String
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

	inline function get_size():Int
	{
		return Std.int(_defaultFormat.size);
	}

	function set_size(Size:Int):Int
	{
		_defaultFormat.size = Size;
		updateDefaultFormat();
		return Size;
	}

	override function set_color(Color:FlxColor):Int
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

	inline function get_font():String
	{
		return _font;
	}

	function set_font(Font:String):String
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

	inline function get_embedded():Bool
	{
		return textField.embedFonts = true;
	}

	inline function get_systemFont():String
	{
		return _defaultFormat.font;
	}

	function set_systemFont(Font:String):String
	{
		textField.embedFonts = false;
		_defaultFormat.font = Font;
		updateDefaultFormat();
		return Font;
	}

	inline function get_bold():Bool
	{
		return _defaultFormat.bold;
	}

	function set_bold(value:Bool):Bool
	{
		if (_defaultFormat.bold != value)
		{
			_defaultFormat.bold = value;
			updateDefaultFormat();
		}
		return value;
	}

	inline function get_italic():Bool
	{
		return _defaultFormat.italic;
	}

	function set_italic(value:Bool):Bool
	{
		if (_defaultFormat.italic != value)
		{
			_defaultFormat.italic = value;
			updateDefaultFormat();
		}
		return value;
	}

	inline function get_wordWrap():Bool
	{
		return textField.wordWrap;
	}

	function set_wordWrap(value:Bool):Bool
	{
		if (textField.wordWrap != value)
		{
			textField.wordWrap = value;
			_regen = true;
		}
		return value;
	}

	inline function get_alignment():FlxTextAlign
	{
		return FlxTextAlign.fromOpenFL(_defaultFormat.align);
	}

	function set_alignment(Alignment:FlxTextAlign):FlxTextAlign
	{
		_defaultFormat.align = FlxTextAlign.toOpenFL(Alignment);
		updateDefaultFormat();
		return Alignment;
	}

	function set_borderStyle(style:FlxTextBorderStyle):FlxTextBorderStyle
	{
		if (style != borderStyle)
			_regen = true;

		return borderStyle = style;
	}

	function set_borderColor(Color:FlxColor):FlxColor
	{
		if (borderColor != Color && borderStyle != NONE)
			_regen = true;
		_hasBorderAlpha = Color.alphaFloat < 1;
		return borderColor = Color;
	}

	function set_borderSize(Value:Float):Float
	{
		if (Value != borderSize && borderStyle != NONE)
			_regen = true;

		return borderSize = Value;
	}

	function set_borderQuality(Value:Float):Float
	{
		Value = FlxMath.bound(Value, 0, 1);
		if (Value != borderQuality && borderStyle != NONE)
			_regen = true;

		return borderQuality = Value;
	}

	override function set_graphic(Value:FlxGraphic):FlxGraphic
	{
		var oldGraphic:FlxGraphic = graphic;
		var graph:FlxGraphic = super.set_graphic(Value);
		FlxG.bitmap.removeIfNoUse(oldGraphic);
		return graph;
	}

	override function get_width():Float
	{
		regenGraphic();
		return super.get_width();
	}

	override function get_height():Float
	{
		regenGraphic();
		return super.get_height();
	}

	override function updateColorTransform():Void
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

	function regenGraphic():Void
	{
		if (textField == null || !_regen)
			return;

		var oldWidth:Int = 0;
		var oldHeight:Int = VERTICAL_GUTTER;

		if (graphic != null)
		{
			oldWidth = graphic.width;
			oldHeight = graphic.height;
		}

		var newWidth:Int = Math.ceil(textField.width);
		// Account for gutter
		var newHeight:Int = Math.ceil(textField.textHeight) + VERTICAL_GUTTER;

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
			makeGraphic(newWidth, newHeight, FlxColor.TRANSPARENT, false, key);

			if (_hasBorderAlpha)
				_borderPixels = graphic.bitmap.clone();
			frameHeight = newHeight;
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

			applyBorderStyle();
			applyBorderTransparency();
			applyFormats(_formatAdjusted, false);

			drawTextFieldTo(graphic.bitmap);
		}

		_regen = false;
		resetFrame();
	}

	/**
	 * Internal function to draw textField to a BitmapData, if flash it calculates every line x to avoid blurry lines.
	 */
	function drawTextFieldTo(graphic:BitmapData):Void
	{
		#if flash
		if (alignment == FlxTextAlign.CENTER && isTextBlurry())
		{
			var h:Int = 0;
			var tx:Float = _matrix.tx;
			for (i in 0...textField.numLines)
			{
				var lineMetrics = textField.getLineMetrics(i);

				// Workaround for blurry lines caused by non-integer x positions on flash
				var diff:Float = lineMetrics.x - Std.int(lineMetrics.x);
				if (diff != 0)
				{
					_matrix.tx = tx + diff;
				}
				_textFieldRect.setTo(0, h, textField.width, lineMetrics.height + lineMetrics.descent);

				graphic.draw(textField, _matrix, null, null, _textFieldRect, false);

				_matrix.tx = tx;
				h += Std.int(lineMetrics.height);
			}

			return;
		}
		#elseif !web
		// Fix to render desktop and mobile text in the same visual location as web
		_matrix.translate(-1, -1); // left and up
		graphic.draw(textField, _matrix);
		_matrix.translate(1, 1); // return to center
		return;
		#end

		graphic.draw(textField, _matrix);
	}

	#if flash
	/**
	 * Helper function for `drawTextFieldTo()`, this checks if thw workaround is needed to prevent blurry lines.
	 */
	function isTextBlurry():Bool
	{
		for (i in 0...textField.numLines)
		{
			var lineMetricsX = textField.getLineMetrics(i).x;
			if (lineMetricsX - Std.int(lineMetricsX) != 0)
			{
				return true;
			}
		}
		return false;
	}
	#end

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
	override function calcFrame(RunOnCpp:Bool = false):Void
	{
		if (textField == null)
			return;

		if (FlxG.renderTile && !RunOnCpp)
			return;

		regenGraphic();
		super.calcFrame(RunOnCpp);
	}

	function applyBorderStyle():Void
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
				// Render a shadow beneath the text
				// (do one lower-right offset draw call)
				applyFormats(_formatAdjusted, true);

				for (i in 0...iterations)
				{
					copyTextWithOffset(delta, delta);
				}

				_matrix.translate(-shadowOffset.x * borderSize, -shadowOffset.y * borderSize);

			case OUTLINE:
				// Render an outline around the text
				// (do 8 offset draw calls)
				applyFormats(_formatAdjusted, true);

				var curDelta:Float = delta;
				for (i in 0...iterations)
				{
					copyTextWithOffset(-curDelta, -curDelta); // upper-left
					copyTextWithOffset(curDelta, 0); // upper-middle
					copyTextWithOffset(curDelta, 0); // upper-right
					copyTextWithOffset(0, curDelta); // middle-right
					copyTextWithOffset(0, curDelta); // lower-right
					copyTextWithOffset(-curDelta, 0); // lower-middle
					copyTextWithOffset(-curDelta, 0); // lower-left
					copyTextWithOffset(0, -curDelta); // lower-left

					_matrix.translate(curDelta, 0); // return to center
					curDelta += delta;
				}

			case OUTLINE_FAST:
				// Render an outline around the text
				// (do 4 diagonal offset draw calls)
				// (this method might not work with certain narrow fonts)
				applyFormats(_formatAdjusted, true);

				var curDelta:Float = delta;
				for (i in 0...iterations)
				{
					copyTextWithOffset(-curDelta, -curDelta); // upper-left
					copyTextWithOffset(curDelta * 2, 0); // upper-right
					copyTextWithOffset(0, curDelta * 2); // lower-right
					copyTextWithOffset(-curDelta * 2, 0); // lower-left

					_matrix.translate(curDelta, -curDelta); // return to center
					curDelta += delta;
				}

			case NONE:
		}
	}

	inline function applyBorderTransparency()
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
	 * Helper function for `applyBorderStyle()`
	 */
	inline function copyTextWithOffset(x:Float, y:Float)
	{
		var graphic:BitmapData = _hasBorderAlpha ? _borderPixels : graphic.bitmap;
		_matrix.translate(x, y);
		drawTextFieldTo(graphic);
	}

	function applyFormats(FormatAdjusted:TextFormat, UseBorderColor:Bool = false):Void
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

			textField.setTextFormat(FormatAdjusted, formatRange.range.start, Std.int(Math.min(formatRange.range.end, textField.text.length)));
		}
	}

	function copyTextFormat(from:TextFormat, to:TextFormat, withAlign:Bool = true):Void
	{
		to.font = from.font;
		to.bold = from.bold;
		to.italic = from.italic;
		to.size = from.size;
		to.color = from.color;
		to.leading = from.leading;
		if (withAlign)
			to.align = from.align;
	}

	/**
	 * A helper function for updating the TextField that we use for rendering.
	 *
	 * @return	A writable copy of `TextField.defaultTextFormat`.
	 */
	function dtfCopy():TextFormat
	{
		var dtf:TextFormat = textField.defaultTextFormat;
		return new TextFormat(dtf.font, dtf.size, dtf.color, dtf.bold, dtf.italic, dtf.underline, dtf.url, dtf.target, dtf.align);
	}

	inline function updateDefaultFormat():Void
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

@:allow(flixel.text.FlxText.applyFormats)
class FlxTextFormat
{
	/**
	 * The leading (vertical space between lines) of the text.
	 * @since 4.10.0
	 */
	public var leading(default, set):Int;

	/**
	 * The border color if the text has a shadow or a border
	 */
	var borderColor:FlxColor;

	var format(default, null):TextFormat;

	/**
	 * @param   FontColor     Font color, in `0xRRGGBB` format. Inherits from the default format by default.
	 * @param   Bold          Whether the text should be bold (must be supported by the font). `false` by default.
	 * @param   Italic        Whether the text should be in italics (must be supported by the font). Only works on Flash. `false` by default.
	 * @param   BorderColor   Border color, in `0xAARRGGBB` format. By default, no border (`null` / transparent).
	 */
	public function new(?FontColor:FlxColor, ?Bold:Bool, ?Italic:Bool, ?BorderColor:FlxColor)
	{
		format = new TextFormat(null, null, FontColor, Bold, Italic);
		borderColor = BorderColor == null ? FlxColor.TRANSPARENT : BorderColor;
	}

	function set_leading(value:Int):Int
	{
		format.leading = value;
		return value;
	}
}

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
	 * A simple shadow to the lower-right.
	 * Use `FlxText.shadowOffset` for custom placement.
	 */
	SHADOW;

	/**
	 * Outline on all 8 sides
	 */
	OUTLINE;

	/**
	 * Outline, optimized using only 4 draw calls (might not work for narrow and/or 1-pixel fonts)
	 */
	OUTLINE_FAST;
}

@:enum
abstract FlxTextAlign(String) from String
{
	var LEFT = "left";

	/**
	 * Warning: on Flash, this can have a negative impact on performance
	 * of multiline texts that are frequently regenerated (especially with
	 * `borderStyle == OUTLINE`) due to a workaround for blurry rendering.
	 */
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

private typedef AlignType = #if openfl_legacy String #else TextFormatAlign #end;
