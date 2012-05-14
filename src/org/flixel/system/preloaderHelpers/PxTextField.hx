package org.flixel.system.preloaderHelpers;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import org.flixel.system.preloaderHelpers.PxBitmapFont;
import org.flixel.plugin.pxText.PxTextAlign;

/**
 * Renders a text field.
 * @author Johan Peitz
 */
class PxTextField extends Sprite 
{
	private var _font:PxBitmapFont;
	private var _text:String;
	private var _color:Int;
	private var _outline:Bool;
	private var _outlineColor:Int;
	private var _shadow:Bool;
	private var _shadowColor:Int;
	private var _background:Bool;
	private var _backgroundColor:Int;
	private var _alignment:Int;
	private var _padding:Int;
	
	private var _lineSpacing:Int;
	private var _letterSpacing:Int;
	private var _fontScale:Float;
	private var _autoUpperCase:Bool;
	private var _wordWrap:Bool;
	private var _fixedWidth:Bool;
	
	private var _pendingTextChange:Bool;
	private var _fieldWidth:Int;
	private var _multiLine:Bool;
	
	private var _alpha:Float;
	
	#if (flash || js)
	public var bitmapData:BitmapData;
	private var _bitmap:Bitmap;
	
	private var _preparedTextGlyphs:Array<BitmapData>;
	private var _preparedShadowGlyphs:Array<BitmapData>;
	private var _preparedOutlineGlyphs:Array<BitmapData>;
	#else
	private var _drawData:Array<Float>;
	#end
	
	/**
	 * Constructs a new text field component.
	 * @param pFont	optional parameter for component's font prop
	 */
	public function new(?pFont:PxBitmapFont = null) 
	{
		_text = "";
		_color = 0x0;
		_outline = false;
		_outlineColor = 0x0;
		_shadow = false;
		_shadowColor = 0x0;
		_background = false;
		_backgroundColor = 0xFFFFFF;
		_alignment = PxTextAlign.LEFT;
		_padding = 0;
		_pendingTextChange = false;
		_fieldWidth = 1;
		_multiLine = false;
		
		_lineSpacing = 0;
		_letterSpacing = 0;
		_fontScale = 1;
		_autoUpperCase = false;
		_fixedWidth = true;
		_wordWrap = true;
		_alpha = 1;
		
		super();
		
		if (pFont == null)
		{
			if (PxBitmapFont.fetch("default") == null)
			{
				PxDefaultFontGenerator.generateAndStoreDefaultFont();
			}
			_font = PxBitmapFont.fetch("default");
		}
		else
		{
			_font = pFont;
		}
		
		#if (flash || js)
		updateGlyphs(true, _shadow, _outline);
		
		bitmapData = new BitmapData(1, 1, true);
		_bitmap = new Bitmap(bitmapData);
		this.addChild(_bitmap);
		#else
		_drawData = [];
		#end
		
		_pendingTextChange = true;
		update();
	}
	
	/**
	 * Clears all resources used.
	 */
	public function destroy():Void 
	{
		_font = null;
		#if (flash || js)
		removeChild(_bitmap);
		_bitmap = null;
		bitmapData.dispose();
		bitmapData = null;
		
		clearPreparedGlyphs(_preparedTextGlyphs);
		clearPreparedGlyphs(_preparedShadowGlyphs);
		clearPreparedGlyphs(_preparedOutlineGlyphs);
		#else
		_drawData = null;
		#end
	}
	
	/**
	 * Text to display.
	 */
	public var text(get_text, set_text):String;
	
	public function get_text():String
	{
		return _text;
	}
	
	public function set_text(pText:String):String 
	{
		var tmp:String = pText;
		tmp = tmp.split("\\n").join("\n");
		if (tmp != _text)
		{
			_text = pText;
			_text = _text.split("\\n").join("\n");
			if (_autoUpperCase)
			{
				_text = _text.toUpperCase();
			}
			_pendingTextChange = true;
			update();
		}
		return _text;
	}
	
	/**
	 * Internal method for updating the view of the text component
	 */
	private function updateBitmapData():Void 
	{
		if (_font == null)
		{
			return;
		}
		
		var calcFieldWidth:Int = _fieldWidth;
		var rows:Array<String> = [];
		#if (flash || js)
		var fontHeight:Int = Math.floor(_font.getFontHeight() * _fontScale);
		#else
		var fontHeight:Int = _font.getFontHeight();
		#end
		var alignment:Int = _alignment;
		
		// cut text into pices
		var lineComplete:Bool;
		
		// get words
		var lines:Array<String> = _text.split("\n");
		var i:Int = -1;
		var j:Int = -1;
		if (!_multiLine)
		{
			lines = [lines[0]];
		}
		
		var wordLength:Int;
		var word:String;
		var tempStr:String;
		while (++i < lines.length) 
		{
			if (_fixedWidth)
			{
				lineComplete = false;
				var words:Array<String> = lines[i].split(" ");
				
				if (words.length > 0) 
				{
					var wordPos:Int = 0;
					var txt:String = "";
					while (!lineComplete) 
					{
						word = words[wordPos];
						var currentRow:String = txt + word + " ";
						var changed:Bool = false;
						
						if (_wordWrap)
						{
							if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > _fieldWidth) 
							{
								if (txt == "")
								{
									words.splice(0, 1);
								}
								else
								{
									rows.push(txt.substr(0, txt.length - 1));
								}
								
								txt = "";
								if (_multiLine)
								{
									words.splice(0, wordPos);
								}
								else
								{
									words.splice(0, words.length);
								}
								wordPos = 0;
								changed = true;
							}
							else
							{
								txt += word + " ";
								wordPos++;
							}
							
						}
						else
						{
							if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > _fieldWidth) 
							{
								j = 0;
								tempStr = "";
								wordLength = word.length;
								while (j < wordLength)
								{
									currentRow = txt + word.charAt(j);
									if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > _fieldWidth) 
									{
										rows.push(txt.substr(0, txt.length - 1));
										txt = "";
										word = "";
										wordPos = words.length;
										j = wordLength;
										changed = true;
									}
									else
									{
										txt += word.charAt(j);
									}
									j++;
								}
							}
							else
							{
								txt += word + " ";
								wordPos++;
							}
						}
						
						if (wordPos >= words.length) 
						{
							if (!changed) 
							{
								var subText:String = txt.substr(0, txt.length - 1);
								calcFieldWidth = Math.floor(Math.max(calcFieldWidth, _font.getTextWidth(subText, _letterSpacing, _fontScale)));
								rows.push(subText);
							}
							lineComplete = true;
						}
					}
				}
				else
				{
					rows.push("");
				}
			}
			else
			{
				calcFieldWidth = Math.floor(Math.max(calcFieldWidth, _font.getTextWidth(lines[i], _letterSpacing, _fontScale)));
				rows.push(lines[i]);
			}
		}
		
		var finalWidth:Int = calcFieldWidth + _padding * 2 + (_outline ? 2 : 0);
		#if (flash || js)
		var finalHeight:Int = Math.floor(_padding * 2 + Math.max(1, (rows.length * fontHeight + (_shadow ? 1 : 0)) + (_outline ? 2 : 0))) + ((rows.length >= 1) ? _lineSpacing * (rows.length - 1) : 0);
		#else
		var finalHeight:Int = Math.floor(_padding * 2 + Math.max(1, (rows.length * fontHeight * _fontScale + (_shadow ? 1 : 0)) + (_outline ? 2 : 0))) + ((rows.length >= 1) ? _lineSpacing * (rows.length - 1) : 0);
		#end
		
		#if (flash || js)
		if (bitmapData != null) 
		{
			if (finalWidth != bitmapData.width || finalHeight != bitmapData.height) 
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
		if (bitmapData == null) 
		{
			bitmapData = new BitmapData(finalWidth, finalHeight, !_background, _backgroundColor);
		} 
		else 
		{
			bitmapData.fillRect(bitmapData.rect, _backgroundColor);
		}
		bitmapData.lock();
		#else
		graphics.clear();
		if (_background == true)
		{
			graphics.beginFill(_backgroundColor, _alpha);
			graphics.drawRect(0, 0, finalWidth, finalHeight);
			graphics.endFill();
		}
		_drawData.splice(0, _drawData.length);
		#end
		
		// render text
		var row:Int = 0;
		
		for (t in rows) 
		{
			var ox:Int = 0; // LEFT
			var oy:Int = 0;
			if (alignment == PxTextAlign.CENTER) 
			{
				if (_fixedWidth)
				{
					ox = Math.floor((_fieldWidth - _font.getTextWidth(t, _letterSpacing, _fontScale)) / 2);
				}
				else
				{
					ox = Math.floor((finalWidth - _font.getTextWidth(t, _letterSpacing, _fontScale)) / 2);
				}
			}
			if (alignment == PxTextAlign.RIGHT) 
			{
				if (_fixedWidth)
				{
					ox = _fieldWidth - Math.floor(_font.getTextWidth(t, _letterSpacing, _fontScale));
				}
				else
				{
					ox = finalWidth - Math.floor(_font.getTextWidth(t, _letterSpacing, _fontScale)) - 2 * padding;
				}
			}
			if (_outline) 
			{
				for (py in 0...(2 + 1)) 
				{
					for (px in 0...(2 + 1)) 
					{
						#if (flash || js)
						_font.render(bitmapData, _preparedOutlineGlyphs, t, _outlineColor, px + ox + _padding, py + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
						#else
						_font.render(_drawData, t, _outlineColor, _alpha, px + ox + _padding, py + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding, _letterSpacing, _fontScale);
						#end
					}
				}
				ox += 1;
				oy += 1;
			}
			if (_shadow) 
			{
				#if (flash || js)
				_font.render(bitmapData, _preparedShadowGlyphs, t, _shadowColor, 1 + ox + _padding, 1 + oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
				#else
				_font.render(_drawData, t, _shadowColor, _alpha, 1 + ox + _padding, 1 + oy + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding, _letterSpacing, _fontScale);
				#end
			}
			#if (flash || js)
			_font.render(bitmapData, _preparedTextGlyphs, t, _color, ox + _padding, oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
			#else
			_font.render(_drawData, t, _color, _alpha, ox + _padding, oy + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding, _letterSpacing, _fontScale);
			#end
			row++;
		}
		#if (flash || js)
		bitmapData.unlock();
		#else
		_font.drawText(this.graphics, _drawData);
		#end
		
		_pendingTextChange = false;
	}
	
	/**
	 * Updates the bitmap data for the text field if any changes has been made.
	 */
	public function update():Void 
	{
		if (_pendingTextChange) 
		{
			updateBitmapData();
			#if (flash || js)
			_bitmap.bitmapData = bitmapData;
			#end
		}
	}
	
	/**
	 * Specifies whether the text field should have a filled background.
	 */
	public var background(get_background, set_background):Bool;
	
	public function get_background():Bool
	{
		return _background;
	}
	
	public function set_background(value:Bool):Bool 
	{
		if (_background != value)
		{
			_background = value;
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Specifies the color of the text field background.
	 */
	public var backgroundColor(get_backgroundColor, set_backgroundColor):Int;
	
	public function get_backgroundColor():Int
	{
		return _backgroundColor;
	}
	
	public function set_backgroundColor(value:Int):Int
	{
		if (_backgroundColor != value)
		{
			_backgroundColor = value;
			if (_background)
			{
				_pendingTextChange = true;
				update();
			}
		}
		return value;
	}
	
	/**
	 * Specifies whether the text should have a shadow.
	 */
	public var shadow(get_shadow, set_shadow):Bool;
	
	public function get_shadow():Bool
	{
		return _shadow;
	}
	
	public function set_shadow(value:Bool):Bool
	{
		if (_shadow != value)
		{
			_shadow = value;
			_outline = false;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
			update();
		}
		
		return value;
	}
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	public var shadowColor(get_shadowColor, set_shadowColor):Int;
	
	public function get_shadowColor():Int
	{
		return _shadowColor;
	}
	
	public function set_shadowColor(value:Int):Int 
	{
		if (_shadowColor != value)
		{
			_shadowColor = value;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
			update();
		}
		
		return value;
	}
	
	/**
	 * Sets the padding of the text field. This is the distance between the text and the border of the background (if any).
	 */
	public var padding(get_padding, set_padding):Int;
	
	public function get_padding():Int
	{
		return _padding;
	}
	
	public function set_padding(value:Int):Int 
	{
		if (_padding != value)
		{
			_padding = value;
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Sets the color of the text.
	 */
	public var color(get_color, set_color):Int;
	
	public function get_color():Int
	{
		return _color;
	}
	
	public function set_color(value:Int):Int 
	{
		if (_color != value)
		{
			_color = value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	public function setWidth(pWidth:Int):Int 
	{
		if (pWidth < 1) 
		{
			pWidth = 1;
		}
		if (pWidth != _fieldWidth)
		{
			_fieldWidth = pWidth;
			_pendingTextChange = true;
			update();
		}
		
		return pWidth;
	}
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	public var alignment(get_alignment, set_alignment):Int;
	
	public function get_alignment():Int
	{
		return _alignment;
	}
	
	public function set_alignment(pAlignment:Int):Int 
	{
		if (_alignment != pAlignment)
		{
			_alignment = pAlignment;
			_pendingTextChange = true;
			update();
		}
		return pAlignment;
	}
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine(get_multiLine, set_multiLine):Bool;
	
	public function get_multiLine():Bool
	{
		return _multiLine;
	}
	
	public function set_multiLine(pMultiLine:Bool):Bool 
	{
		if (_multiLine != pMultiLine)
		{
			_multiLine = pMultiLine;
			_pendingTextChange = true;
			update();
		}
		return pMultiLine;
	}
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	public var outline(get_outline, set_outline):Bool;
	
	public function get_outline():Bool
	{
		return _outline;
	}
	
	public function set_outline(value:Bool):Bool 
	{
		if (_outline != value)
		{
			_outline = value;
			_shadow = false;
			updateGlyphs(false, false, true);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Specifies whether color of the text outline.
	 */
	public var outlineColor(get_outlineColor, set_outlineColor):Int;
	
	public function get_outlineColor():Int
	{
		return _outlineColor;
	}
	
	public function set_outlineColor(value:Int):Int 
	{
		if (_outlineColor != value)
		{
			_outlineColor = value;
			updateGlyphs(false, false, _outline);
			_pendingTextChange = true;
			update();
		}
		return value;
	}
	
	/**
	 * Sets which font to use for rendering.
	 */
	public var font(get_font, set_font):PxBitmapFont;
	
	public function get_font():PxBitmapFont
	{
		return _font;
	}
	
	public function set_font(pFont:PxBitmapFont):PxBitmapFont 
	{
		if (_font != pFont)
		{
			_font = pFont;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			update();
		}
		return pFont;
	}
	
	/**
	 * Sets the distance between lines
	 */
	public var lineSpacing(get_lineSpacing, set_lineSpacing):Int;
	
	public function get_lineSpacing():Int
	{
		return _lineSpacing;
	}
	
	public function set_lineSpacing(pSpacing:Int):Int
	{
		if (_lineSpacing != pSpacing)
		{
			_lineSpacing = Math.floor(Math.abs(pSpacing));
			_pendingTextChange = true;
			update();
		}
		return pSpacing;
	}
	
	public function setAlpha(pAlpha:Float):Float
	{
		_alpha = pAlpha;
		#if (flash || js)
		this.alpha = _alpha;
		#else
		_pendingTextChange = true;
		update();
		#end
		return pAlpha;
	}
	
	public function getAlpha():Float
	{
		return _alpha;
	}
	
	/**
	 * Sets the "font size" of the text
	 */
	public var fontScale(get_fontScale, set_fontScale):Float;
	
	public function get_fontScale():Float
	{
		return _fontScale;
	}
	
	public function set_fontScale(pScale:Float):Float
	{
		var tmp:Float = Math.abs(pScale);
		if (tmp != _fontScale)
		{
			_fontScale = tmp;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			update();
		}
		return pScale;
	}
	
	public var letterSpacing(get_letterSpacing, set_letterSpacing):Int;
	
	public function get_letterSpacing():Int
	{
		return _letterSpacing;
	}
	
	public function set_letterSpacing(pSpacing:Int):Int
	{
		var tmp:Int = Math.floor(Math.abs(pSpacing));
		if (tmp != _letterSpacing)
		{
			_letterSpacing = tmp;
			_pendingTextChange = true;
			update();
		}
		return _letterSpacing;
	}
	
	public var autoUpperCase(get_autoUpperCase, set_autoUpperCase):Bool;
	
	private function get_autoUpperCase():Bool 
	{
		return _autoUpperCase;
	}
	
	private function set_autoUpperCase(value:Bool):Bool 
	{
		if (_autoUpperCase != value)
		{
			_autoUpperCase = value;
			if (_autoUpperCase)
			{
				text = _text.toUpperCase();
			}
		}
		return _autoUpperCase;
	}
	
	public var wordWrap(get_wordWrap, set_wordWrap):Bool;
	
	private function get_wordWrap():Bool 
	{
		return _wordWrap;
	}
	
	private function set_wordWrap(value:Bool):Bool 
	{
		if (_wordWrap != value)
		{
			_wordWrap = value;
			_pendingTextChange = true;
			update();
		}
		return _wordWrap;
	}
	
	public var fixedWidth(get_fixedWidth, set_fixedWidth):Bool;
	
	private function get_fixedWidth():Bool 
	{
		return _fixedWidth;
	}
	
	private function set_fixedWidth(value:Bool):Bool 
	{
		if (_fixedWidth != value)
		{
			_fixedWidth = value;
			_pendingTextChange = true;
			update();
		}
		return _fixedWidth;
	}
	
	private function updateGlyphs(?textGlyphs:Bool = false, ?shadowGlyphs:Bool = false, ?outlineGlyphs:Bool = false):Void
	{
		#if (flash || js)
		if (textGlyphs)
		{
			clearPreparedGlyphs(_preparedTextGlyphs);
			_preparedTextGlyphs = _font.getPreparedGlyphs(_fontScale, _color);
		}
		
		if (shadowGlyphs)
		{
			clearPreparedGlyphs(_preparedShadowGlyphs);
			_preparedShadowGlyphs = _font.getPreparedGlyphs(_fontScale, _shadowColor);
		}
		
		if (outlineGlyphs)
		{
			clearPreparedGlyphs(_preparedOutlineGlyphs);
			_preparedOutlineGlyphs = _font.getPreparedGlyphs(_fontScale, _outlineColor);
		}
		#end
	}
	
	#if (flash || js)
	private function clearPreparedGlyphs(pGlyphs:Array<BitmapData>):Void
	{
		if (pGlyphs != null)
		{
			for (bmd in pGlyphs)
			{
				if (bmd != null)
				{
					bmd.dispose();
				}
			}
			pGlyphs = null;
		}
	}
	#end


}