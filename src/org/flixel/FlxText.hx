package org.flixel;

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import org.flixel.system.layer.Atlas;

/**
 * Extends <code>FlxSprite</code> to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 * Also does nice pixel-perfect centering on pixel fonts
 * as long as they are only one liners.
 */
class FlxText extends FlxSprite
{
	#if flash
	public var shadow(getShadow, setShadow):UInt;
	#else
	public var shadow(getShadow, setShadow):Int;
	#end
	
	/**
	 * Whether to draw shadow or not
	 */
	public var useShadow(get_useShadow, set_useShadow):Bool;
	
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
	private var _regen:Bool;
	/**
	 * Internal tracker for the text shadow color, default is clear/transparent.
	 */
	#if flash
	private var _shadow:UInt;
	#else
	private var _shadow:Int;
	#end
	/**
	 * Internal tracker for shadow usage, default is false
	 */
	private var _useShadow:Bool;
	
	/**
	 * Creates a new <code>FlxText</code> object at the specified position.
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 */
	public function new(X:Float, Y:Float, Width:Int, Text:String = null, EmbeddedFont:Bool = true)
	{
		super(X, Y);
		
		var key:String = FlxG.getUniqueBitmapKey("text");
		#if !neko
		makeGraphic(Width, 1, 0, false, key);
		#else
		makeGraphic(Width, 1, {rgb: 0, a: 0}, false, key);
		#end
		
		if (Text == null)
		{
			Text = "";
		}
		_textField = new TextField();
		_textField.width = Width;
		_textField.selectable = false;
		_textField.multiline = true;
		_textField.wordWrap = true;
		_format = new TextFormat(FlxAssets.nokiaFont, 8, 0xffffff);
		_formatAdjusted = new TextFormat();
		_textField.defaultTextFormat = _format;
		_textField.text = Text;
		#if flash
		_textField.embedFonts = EmbeddedFont;
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
		
		_regen = true;
		_shadow = 0;
		_useShadow = false;
		allowCollisions = FlxObject.NONE;
		moves = false;
		#if (flash || js)
		calcFrame();
		#else
		if (Text != "")
		{
			calcFrame(true);
		}
		#end
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (_pixels != null)
		{
			_pixels.dispose();
		}
		_textField = null;
		_format = null;
		_formatAdjusted = null;
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
	public function setFormat(Font:String = null, Size:Float = 8, Color:UInt = 0xffffff, Alignment:String = null, ShadowColor:UInt = 0, UseShadow:Bool = false):FlxText
	#else
	public function setFormat(Font:String = null, Size:Float = 8, Color:Int = 0xffffff, Alignment:String = null, ShadowColor:Int = 0, UseShadow:Bool = false):FlxText
	#end
	{
		if (Font == null)
		{
			#if (flash || js)
			Font = "";
			#else
			Font = FlxAssets.nokiaFont;
			#end
		}
		_format.font = Font;
		_format.size = Size;
		_format.color = Color;
		_format.align = convertTextAlignmentFromString(Alignment);
		_textField.defaultTextFormat = _format;
		_textField.setTextFormat(_format);
		_shadow = ShadowColor;
		_useShadow = UseShadow;
		_regen = true;
		#if (flash || js)
		calcFrame();
		#else
		calcFrame(true);
		#end
		return this;
	}
	
	public var text(getText, setText):String;
	
	/**
	 * The text being displayed.
	 */
	public function getText():String
	{
		return _textField.text;
	}
	
	/**
	 * @private
	 */
	public function setText(Text:String):String
	{
		var ot:String = _textField.text;
		_textField.text = Text;
		if(_textField.text != ot)
		{
			_regen = true;
			#if (flash || js)
			calcFrame();
			#else
			calcFrame(true);
			#end
		}
		return _textField.text;
	}
	
	public var size(getSize, setSize):Float;
	
	/**
	 * The size of the text being displayed.
	 */
	public function getSize():Float
	{
		return _format.size;
	}
	
	/**
	 * @private
	 */
	public function setSize(Size:Float):Float
	{
		_format.size = Size;
		_textField.defaultTextFormat = _format;
		_textField.setTextFormat(_format);
		_regen = true;
		#if (flash || js)
		calcFrame();
		#else
		calcFrame(true);
		#end
		return Size;
	}
	
	/**
	 * The color of the text being displayed.
	 */
	#if flash
	override public function getColor():UInt
	{
		return _format.color;
	}
	#else
	override public function getColor():BitmapInt32
	{
		#if (cpp || js)
		return _format.color;
		#elseif neko
		return { rgb: _format.color, a: 0xff };
		#end
	}
	#end
	
	/**
	 * @private
	 */
	#if flash
	override public function setColor(Color:UInt):UInt
	#else
	override public function setColor(Color:BitmapInt32):BitmapInt32
	#end
	{
		#if neko
		_format.color = Color.rgb;
		#else
		_format.color = Color;
		#end
		_textField.defaultTextFormat = _format;
		_textField.setTextFormat(_format);
		_regen = true;
		#if (flash || js)
		calcFrame();
		#else
		calcFrame(true);
		#end
		return Color;
	}
	
	public var font(getFont, setFont):String;
	
	/**
	 * The font used for this text.
	 */
	public function getFont():String
	{
		return _format.font;
	}
	
	/**
	 * @private
	 */
	public function setFont(Font:String):String
	{
		_format.font = Font;
		_textField.defaultTextFormat = _format;
		_textField.setTextFormat(_format);
		_regen = true;
		#if (flash || js)
		calcFrame();
		#else
		calcFrame(true);
		#end
		return Font;
	}
	
	public var alignment(getAlignment, setAlignment):String;
	
	/**
	 * The alignment of the font ("left", "right", or "center").
	 */
	public function getAlignment():String
	{
		return cast(_format.align, String);
	}
	
	/**
	 * @private
	 */
	public function setAlignment(Alignment:String):String
	{
		_format.align = convertTextAlignmentFromString(Alignment);
		_textField.defaultTextFormat = _format;
		_textField.setTextFormat(_format);
		#if (flash || js)
		calcFrame();
		#else
		calcFrame(true);
		#end
		return Alignment;
	}
	
	/**
	 * The color of the text shadow in 0xAARRGGBB hex format.
	 */
	#if flash
	public function getShadow():UInt
	#else
	public function getShadow():Int
	#end
	{
		return _shadow;
	}
	
	/**
	 * @private
	 */
	#if flash
	public function setShadow(Color:UInt):UInt
	#else
	public function setShadow(Color:Int):Int
	#end
	{
		_shadow = Color;
		#if (flash || js)
		calcFrame();
		#else
		calcFrame(true);
		#end
		return Color;
	}
	
	private function get_useShadow():Bool
	{
		return _useShadow;
	}
	
	private function set_useShadow(value:Bool):Bool
	{
		if (value != _useShadow)
		{
			_useShadow = value;
			#if (flash || js)
			calcFrame();
			#else
			calcFrame(true);
			#end
		}
		return _useShadow;
	}
	
	/**
	 * Internal function to update the current animation frame.
	 */
	#if (flash || js)
	override private function calcFrame():Void
	#else
	override private function calcFrame(AreYouSure:Bool = false):Void
	#end
	{
		#if (cpp || neko)
		if (AreYouSure)
		{
			_regen = true;
		#end
			if (_regen)
			{
				//Need to generate a new buffer to store the text graphic
				height = _textField.textHeight;
				height += 4; //account for 2px gutter on top and bottom
				#if !neko
				_pixels = new BitmapData(Std.int(width), Std.int(height), true, 0);
				#else
				_pixels = new BitmapData(Std.int(width), Std.int(height), true, {rgb: 0, a: 0});
				#end
				frameHeight = Std.int(height);
				_textField.height = height * 1.2;
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = width;
				_flashRect.height = height;
				_regen = false;
			}
			else	//Else just clear the old buffer before redrawing the text
			{
				#if !neko
				_pixels.fillRect(_flashRect, 0);
				#else
				_pixels.fillRect(_flashRect, {rgb: 0, a: 0});
				#end
			}
			
			if ((_textField != null) && (_textField.text != null) && (_textField.text.length > 0))
			{
				//Now that we've cleared a buffer, we need to actually render the text to it
				_formatAdjusted.font = _format.font;
				_formatAdjusted.size = _format.size;
				_formatAdjusted.color = _format.color;
				_formatAdjusted.align = _format.align;
				_matrix.identity();
				//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
				#if js
				if (_format.align == TextFormatAlign.CENTER)
				#else
				if ((_format.align == TextFormatAlign.CENTER) && (_textField.numLines == 1))
				#end
				{
					_formatAdjusted.align = TextFormatAlign.LEFT;
					_textField.setTextFormat(_formatAdjusted);				
					#if flash
					_matrix.translate(Math.floor((width - _textField.getLineMetrics(0).width) / 2), 0);
					#else
					_matrix.translate(Math.floor((width - _textField.textWidth) / 2), 0);
					#end
				}
				//Render a single pixel shadow beneath the text
				if (_useShadow)
				{
					_formatAdjusted.color = _shadow;
					_textField.setTextFormat(_formatAdjusted);
					_matrix.translate(1, 1);
					_pixels.draw(_textField, _matrix, _colorTransform);
					_matrix.translate( -1, -1);
					_formatAdjusted.color = _format.color;
					_textField.setTextFormat(_formatAdjusted);
				}
				//Actually draw the text onto the buffer
				_pixels.draw(_textField, _matrix, _colorTransform);
				_textField.setTextFormat(_format);
			}
			#if (cpp || neko)
			updateAtlasInfo();
			#else
			//Finally, update the visible pixels
			if ((framePixels == null) || (framePixels.width != _pixels.width) || (framePixels.height != _pixels.height))
			{
				framePixels = new BitmapData(_pixels.width, _pixels.height, true, 0);
			}
			framePixels.copyPixels(_pixels, _flashRect, _flashPointZero);
			#end
			
		#if (cpp || neko)
			origin.make(frameWidth * 0.5, frameHeight * 0.5);
		}
		#end
	}
	
	/**
	 * A helper function for updating the <code>TextField</code> that we use for rendering.
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
	private function convertTextAlignmentFromString(strAlign:String):TextFormatAlign
	{
		if (strAlign == "right")
		{
			return TextFormatAlign.RIGHT;
		}
		else if (strAlign == "center")
		{
			return TextFormatAlign.CENTER;
		}
		else if (strAlign == "justify")
		{
			return TextFormatAlign.JUSTIFY;
		}
		else
		{
			return TextFormatAlign.LEFT;
		}
	}
	#else
	private function convertTextAlignmentFromString(strAlign:String):String
	{
		return strAlign;
	}
	#end
	
	/**
	 * FlxText objects can't be added on any level. They create their own atlases
	 */
	#if (cpp || neko)
	override private function set_atlas(value:Atlas):Atlas 
	{
		return value;
	}
	#end
	
	override public function updateAtlasInfo(updateAtlas:Bool = false):Void
	{
		#if (cpp || neko)
		_atlas = FlxG.state.getAtlasFor(_bitmapDataKey);
		var cachedBmd:BitmapData = FlxG._cache.get(_bitmapDataKey);
		if (cachedBmd != _pixels)
		{
			cachedBmd.dispose();
			FlxG._cache.set(_bitmapDataKey, _pixels);
			_atlas.clearAndFillWith(_pixels);
		}
		_node = _atlas.getNodeByKey(_bitmapDataKey);
		updateFrameData();
		#end
	}
	
	override public function updateFrameData():Void
	{
	#if (cpp || neko)
		if (_node != null && frameWidth >= 1 && frameHeight >= 1)
		{
			_framesData = _node.addSpriteFramesData(Math.floor(width), Math.floor(height));
			_frameID = _framesData.frameIDs[0];
		}
	#end
	}
}