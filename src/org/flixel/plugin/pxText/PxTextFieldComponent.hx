package org.flixel.plugin.pxText;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import org.flixel.plugin.pxText.PxBitmapFont;

/**
 * Renders a text field.
 * @author Johan Peitz
 */
class PxTextFieldComponent extends Sprite 
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
	private var _fontScale:Float;
	
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
		_fontScale = 1;
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
		#end
	}
	
	/**
	 * Sets which text to display.
	 * @param pText	Text to display.
	 */
	public var text(null, set_text):String;
	
	public function set_text(pText:String):String 
	{
		_text = pText;
		_text = _text.split("\\n").join("\n");
		_pendingTextChange = true;
		update();
		return _text;
	}
	
	private function updateBitmapData():Void 
	{
		if (_font == null)
		{
			return;
		}
		if (_text == "")
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
		while (++i < lines.length) 
		{
			lineComplete = false;
			var words:Array<String> = lines[i].split(" ");
			if (words.length > 0) 
			{
				var wordPos:Int = 0;
				var txt:String = "";
				while (!lineComplete) 
				{
					var changed:Bool = false;
					
					var currentRow:String = txt + words[wordPos] + " ";
					
					if (_multiLine) 
					{
						if (_font.getTextWidth(currentRow) * _fontScale > _fieldWidth) 
						{
							rows.push(txt.substr(0, txt.length - 1));
							txt = "";
							changed = true;
						}
					}
					
					txt += words[wordPos] + " ";
					wordPos++;
					
					if (wordPos >= words.length) 
					{
						if (!changed) 
						{
							var subText:String = txt.substr(0, txt.length - 1);
							calcFieldWidth = Math.floor(Math.max(calcFieldWidth, _font.getTextWidth(subText) * _fontScale));
							rows.push(subText);
						}
						lineComplete = true;
					}
				}
			}
		}
		
		var finalWidth:Int = calcFieldWidth + _padding * 2 + (_outline ? 2 : 0);
		#if (flash || js)
		var finalHeight:Int = Math.floor(_padding * 2 + Math.max(1, (rows.length * fontHeight + (_shadow ? 1 : 0)) + (_outline ? 2 : 0))) + _lineSpacing * (rows.length - 1);
		#else
		var finalHeight:Int = Math.floor(_padding * 2 + Math.max(1, (rows.length * fontHeight * _fontScale + (_shadow ? 1 : 0)) + (_outline ? 2 : 0))) + _lineSpacing * (rows.length - 1);
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
				ox = Math.floor((_fieldWidth - _font.getTextWidth(t) * _fontScale / 2) - _fieldWidth / 2);
			}
			if (alignment == PxTextAlign.RIGHT) 
			{
				ox = _fieldWidth - Math.floor(_font.getTextWidth(t) * _fontScale / 2);
			}
			if (_outline) 
			{
				for (py in 0...(2 + 1)) 
				{
					for (px in 0...(2 + 1)) 
					{
						#if (flash || js)
						_font.render(bitmapData, _preparedOutlineGlyphs, t, _outlineColor, px + ox + _padding, py + row * (fontHeight + _lineSpacing) + _padding, _fontScale);
						#else
						_font.render(_drawData, t, _outlineColor, _alpha, px + ox + _padding, py + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding, _fontScale);
						#end
					}
				}
				ox += 1;
				oy += 1;
			}
			if (_shadow) 
			{
				#if (flash || js)
				_font.render(bitmapData, _preparedShadowGlyphs, t, _shadowColor, 1 + ox + _padding, 1 + oy + row * (fontHeight + _lineSpacing) + _padding, _fontScale);
				#else
				_font.render(_drawData, t, _shadowColor, _alpha, 1 + ox + _padding, 1 + oy + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding, _fontScale);
				#end
			}
			#if (flash || js)
			_font.render(bitmapData, _preparedTextGlyphs, t, _color, ox + _padding, oy + row * (fontHeight + _lineSpacing) + _padding, _fontScale);
			#else
			_font.render(_drawData, t, _color, _alpha, ox + _padding, oy + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding, _fontScale);
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
	 * @param	pDT
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
	
	public var background(null, set_background):Bool;
	
	public function set_background(value:Bool):Bool 
	{
		_background = value;
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Specifies the color of the text field background.
	 */
	
	public var backgroundColor(null, set_backgroundColor):Int;
	
	public function set_backgroundColor(value:Int):Int
	{
		_backgroundColor = value;
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Specifies whether the text should have a shadow.
	 */
	
	public var shadow(null, set_shadow):Bool;
	
	public function set_shadow(value:Bool):Bool
	{
		_shadow = value;
		
		if (_shadow) 
		{
			_outline = false;
			updateGlyphs(false, _shadow, false);
		}
		
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	
	public var shadowColor(null, set_shadowColor):Int;
	
	public function set_shadowColor(value:Int):Int 
	{
		_shadowColor = value;
		updateGlyphs(false, _shadow, false);
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Sets the padding of the text field. This is the distance between the text and the border of the background (if any).
	 */
	
	public var padding(null, set_padding):Int;
	
	public function set_padding(value:Int):Int 
	{
		_padding = value;
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Sets the color of the text.
	 */
	public var color(null, set_color):Int;
	
	public function set_color(value:Int):Int 
	{
		_color = value;
		updateGlyphs(true, false, false);
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	public function setWidth(pWidth:Int):Int 
	{
		_fieldWidth = pWidth;
		if (_fieldWidth < 1) 
		{
			_fieldWidth = 1;
		}
		_pendingTextChange = true;
		update();
		return pWidth;
	}
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	
	public var alignment(null, set_alignment):Int;
	
	public function set_alignment(pAlignment:Int):Int 
	{
		_alignment = pAlignment;
		_pendingTextChange = true;
		update();
		return pAlignment;
	}
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	
	public var multiLine(null, set_multiLine):Bool;
	
	public function set_multiLine(pMultiLine:Bool):Bool 
	{
		_multiLine = pMultiLine;
		_pendingTextChange = true;
		update();
		return pMultiLine;
	}
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	
	public var outline(null, set_outline):Bool;
	
	public function set_outline(value:Bool):Bool 
	{
		_outline = value;
		if (_outline) 
		{
			_shadow = false;
			updateGlyphs(false, false, true);
		}
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Specifies whether color of the text outline.
	 */
	
	public var outlineColor(null, set_outlineColor):Int;
	
	public function set_outlineColor(value:Int):Int 
	{
		_outlineColor = value;
		updateGlyphs(false, false, _outline);
		_pendingTextChange = true;
		update();
		return value;
	}
	
	/**
	 * Sets which font to use for rendering.
	 */
	
	public var font(null, set_font):PxBitmapFont;
	
	public function set_font(pFont:PxBitmapFont):PxBitmapFont 
	{
		_font = pFont;
		updateGlyphs(true, _shadow, _outline);
		_pendingTextChange = true;
		update();
		return pFont;
	}
	
	public var lineSpacing(get_lineSpacing, set_lineSpacing):Int;
	
	public function get_lineSpacing():Int
	{
		return _lineSpacing;
	}
	
	public function set_lineSpacing(pSpacing:Int):Int
	{
		_lineSpacing = Math.floor(Math.abs(pSpacing));
		_pendingTextChange = true;
		update();
		return pSpacing;
	}
	
	public function setAlpha(pAlpha:Float):Float
	{
		_alpha = pAlpha;
		#if (flash || js)
		_bitmap.alpha = _alpha;
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
	
	public var fontScale(get_fontScale, set_fontScale):Float;
	
	public function get_fontScale():Float
	{
		return _fontScale;
	}
	
	public function set_fontScale(pScale:Float):Float
	{
		_fontScale = Math.abs(pScale);
		updateGlyphs(true, _shadow, _outline);
		_pendingTextChange = true;
		update();
		return pScale;
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