package org.flixel;

#if (cpp || neko)

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.text.TextFieldAutoSize;
import org.flixel.FlxSprite;


/**
 * Extends <code>FlxText</code> for better support rendering text on cpp target.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 */
class FlxTextField extends FlxText
{
	
	/**
	 * Internal reference to array of Flash <code>TextField</code> objects.
	 */
	private var _textFields:Array<TextField>;
	
	private var _selectable:Bool;
	private var _multiline:Bool;
	private var _wordWrap:Bool;
	
	private var _textFormat:TextFormat;
	
	private var _text:String;
	
	/**
	 * Creates a new <code>FlxText</code> object at the specified position.
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or nto
	 */
	public function new(X:Float, Y:Float, Width:Int, ?Text:String = null, ?EmbeddedFont:Bool = true)
	{
		_textFields = new Array<TextField>();
		width = Width;
		
		super(X, Y, Width);
		
		if (Text == null)
		{
			Text = "";
		}
		_text = Text;
		
		_selectable = false;
		_multiline = true;
		_wordWrap = true;
		#if neko
		_textFormat = new TextFormat(FlxAssets.nokiaFont, 8, 0xffffff);
		#else
		_textFormat = new TextFormat(FlxAssets.nokiaFont, 8, 0xffffffff);
		#end
		
		allowCollisions = FlxObject.NONE;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		for (tf in _textFields)
		{
			if (tf != null && tf.parent != null)
			{
				tf.parent.removeChild(tf);
				tf = null;
			}
		}
		_textFields = null;
		_textFormat = null;
		
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
	override public function setFormat(?Font:String = null, ?Size:Float = 8, ?Color:Int = 0xffffff, ?Alignment:String = null, ?ShadowColor:Int = 0):FlxText
	{
		if (Font == null)
		{
			Font = FlxAssets.nokiaFont;
		}
		_textFormat.font = Font;
		_textFormat.size = Size;
		_textFormat.color = Color;
		_textFormat.align = Alignment;
		updateTextFields();
		_shadow = ShadowColor;
		return this;
	}
	
	/**
	 * The text being displayed.
	 */
	override public function getText():String
	{
		return _text;
	}
	
	/**
	 * @private
	 */
	override public function setText(Text:String):String
	{
		_text = Text;
		updateTextFields();
		return text;
	}
	
	/**
	 * The size of the text being displayed.
	 */
	override public function getSize():Float
	{
		return _textFormat.size;
	}
	
	/**
	 * @private
	 */
	override public function setSize(Size:Float):Float
	{
		_textFormat.size = Size;
		updateTextFields();
		return Size;
	}
	
	/**
	 * The color of the text being displayed.
	 */
	override public function getColor():BitmapInt32
	{
		#if neko
		return { rgb: Std.int(_textFormat.color), a: 0xff };
		#else
		return Std.int(_textFormat.color);
		#end
	}
	
	/**
	 * @private
	 */
	override public function setColor(Color:BitmapInt32):BitmapInt32
	{
		#if neko
		_textFormat.color = Color.rgb;
		#else
		_textFormat.color = Color;
		#end
		updateTextFields();
		return Color;
	}
	
	/**
	 * The font used for this text.
	 */
	override public function getFont():String
	{
		return Std.string(_textFormat.font);
	}
	
	/**
	 * @private
	 */
	override public function setFont(Font:String):String
	{
		_textFormat.font = Font;
		updateTextFields();
		return Font;
	}
	
	/**
	 * The alignment of the font ("left", "right", or "center").
	 */
	override public function getAlignment():String
	{
		return cast(_textFormat.align, String);
	}
	
	/**
	 * @private
	 */
	override public function setAlignment(Alignment:String):String
	{
		_textFormat.align = Alignment;
		updateTextFields();
		return Alignment;
	}
	
	/**
	 * The color of the text shadow in 0xAARRGGBB hex format.
	 */
	override public function getShadow():Int
	{
		// shadows are not supported
		return 0;
	}
	
	/**
	 * @private
	 */
	override public function setShadow(Color:Int):Int
	{
		// shadows are not supported
		return 0;
	}
	
	override public function stamp(Brush:FlxSprite, ?X:Int = 0, Y:Int = 0):Void 
	{
		// this class doesn't support this operation
	}
	
	override public function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:BitmapInt32, ?Thickness:Int = 1):Void 
	{
		// this class doesn't support this operation
	}
	
	override public function getSimpleRender():Bool
	{ 
		return true;
	}
	
	override public function pixelsOverlapPoint(point:FlxPoint, ?Mask:Int = 0xFF, ?Camera:FlxCamera = null):Bool 
	{
		// this class doesn't support this operation
		return false;
	}
	
	/**
	 * Set <code>pixels</code> to any <code>BitmapData</code> object.
	 * Automatically adjust graphic size and render helpers.
	 */
	override public function getPixels():BitmapData
	{
		calcFrame(true);
		return _pixels;
	}
	
	/**
	 * @private
	 */
	override public function setPixels(Pixels:BitmapData):BitmapData
	{
		// this class doesn't support this operation
		return _pixels;
	}
	
	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
	 */
	override public function getAlpha():Float
	{
		return _alpha;
	}
	
	/**
	 * @private
	 */
	override public function setAlpha(Alpha:Float):Float
	{
		if (Alpha > 1)
		{
			Alpha = 1;
		}
		if (Alpha < 0)
		{
			Alpha = 0;
		}
		_alpha = Alpha;
		updateTextFields();
		return _alpha;
	}
	
	private function updateTextFields():Void
	{
		
		for (tf in _textFields)
		{
			if (tf != null)
			{
				tf.width = width;
				tf.defaultTextFormat = _textFormat;
				tf.setTextFormat(_textFormat);
				tf.selectable = _selectable;
				tf.wordWrap = _wordWrap;
				tf.multiline = _multiline;
				tf.text = _text;
				height = tf.textHeight;
				height += 4;
				tf.height = 1.2 * height;
				tf.alpha = _alpha;
			}
		}
	}
	
	public function setVisibility(visible:Bool):Void
	{
		this.visible = visible;
		for (tf in _textFields)
		{
			if (tf != null)
			{
				tf.visible = visible;
			}
		}
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
		if (visible == false)
		{
			setVisibility(false);
			return;
		}
		
		if(_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker) return;
		}
		
		if (cameras == null) cameras = FlxG.cameras;
		
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		var tf:TextField;
		
		while(i < l)
		{
			camera = cameras[i++];
			tf = _textFields[i - 1];
			
			if (tf == null)
			{
				tf = new TextField();
				_textFields[i - 1] = tf;
				updateTextFields();
				camera._canvas.addChild(tf);
			}
			
			if (!onScreen(camera))
			{
				tf.visible = false;
				continue;
			}
			else
			{
				tf.visible = true;
			}
			
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			// Simple render
			tf.x = _point.x;
			tf.y = _point.y;
			
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	
	/**
	 * Internal function to update the current animation frame.
	 */
	override private function calcFrame(?AreYouSure:Bool = false):Void
	{
		if (AreYouSure)
		{
			var tf:TextField = _textFields[0];
			if (tf != null)
			{
				#if !neko
				_pixels = new BitmapData(Std.int(width), Std.int(height), true, 0);
				#else
				_pixels = new BitmapData(Std.int(width), Std.int(height), true, {rgb: 0, a:0});
				#end
				frameHeight = Std.int(height);
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = width;
				_flashRect.height = height;
				
				if((tf.text != null) && (tf.text.length > 0))
				{
					//Now that we've cleared a buffer, we need to actually render the text to it
					_textField.width = width;
					_textField.defaultTextFormat = _textFormat;
					_textField.setTextFormat(_textFormat);
					_textField.selectable = _selectable;
					_textField.wordWrap = _wordWrap;
					_textField.multiline = _multiline;
					_textField.text = _text;
					_textField.height = 1.2 * height;
					_textField.alpha = _alpha;
					
					var format:TextFormat = dtfCopy();
					var formatAdjusted:TextFormat = format;
					_matrix.identity();
					
					//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
					if ((format.align == TextFormatAlign.CENTER) && (tf.numLines == 1))
					{
						formatAdjusted = new TextFormat(format.font, format.size, format.color);
						formatAdjusted.align = TextFormatAlign.LEFT;
						_textField.setTextFormat(formatAdjusted);				
						_matrix.translate(Math.floor((width - _textField.textWidth) / 2), 0);
					}
					//Render a single pixel shadow beneath the text
					if(_shadow > 0)
					{
						_textField.setTextFormat(new TextFormat(formatAdjusted.font, formatAdjusted.size, _shadow, null, null, null, null, null, formatAdjusted.align));
						_matrix.translate(1, 1);
						_pixels.draw(_textField, _matrix, _colorTransform);
						_matrix.translate( -1, -1);
						_textField.setTextFormat(new TextFormat(formatAdjusted.font, formatAdjusted.size, formatAdjusted.color, null, null, null, null, null, formatAdjusted.align));
					}
					//Actually draw the text onto the buffer
					_pixels.draw(_textField, _matrix, _colorTransform);
					_textField.setTextFormat(new TextFormat(format.font, format.size, format.color, null, null, null, null, null, format.align));
				}
				
				//Finally, update the visible pixels
				if ((framePixels == null) || (framePixels.width != _pixels.width) || (framePixels.height != _pixels.height))
				{
					#if !neko
					framePixels = new BitmapData(_pixels.width, _pixels.height, true, 0);
					#else
					framePixels = new BitmapData(_pixels.width, _pixels.height, true, { rgb: 0, a:0 } );
					#end
				}
				framePixels.copyPixels(_pixels, _flashRect, _flashPointZero);
				
			}
		}
	}
}
#end