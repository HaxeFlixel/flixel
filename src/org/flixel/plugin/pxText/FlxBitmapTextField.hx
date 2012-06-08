package org.flixel.plugin.pxText;

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import org.flixel.FlxSprite;

#if (cpp || neko)
import org.flixel.tileSheetManager.TileSheetManager;
#end

/**
 * Extends <code>FlxSprite</code> to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 * Also does nice pixel-perfect centering on pixel fonts
 * as long as they are only one liners.
 */
class FlxBitmapTextField extends FlxSprite
{
	
	private var _font:PxBitmapFont;
	private var _text:String;
	private var _textColor:Int;
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
	
	#if (flash || js)
	private var _preparedTextGlyphs:Array<BitmapData>;
	private var _preparedShadowGlyphs:Array<BitmapData>;
	private var _preparedOutlineGlyphs:Array<BitmapData>;
	#else
	private var _drawData:Array<Float>;
	private var _bgDrawData:Array<Float>;
	#end
	
	/**
	 * Constructs a new text field component.
	 * @param pFont	optional parameter for component's font prop
	 */
	public function new(?pFont:PxBitmapFont = null) 
	{
		_text = "";
		_textColor = 0x0;
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
		_pixels = new BitmapData(1, 1, true);
		#else
		_tileSheetData = _font.tileSheetData;
		_drawData = [];
		_bgDrawData = [];
		#end
		
		_pendingTextChange = true;
		updateBitmapData();
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function destroy():Void 
	{
		_font = null;
		#if (flash || js)
		clearPreparedGlyphs(_preparedTextGlyphs);
		clearPreparedGlyphs(_preparedShadowGlyphs);
		clearPreparedGlyphs(_preparedOutlineGlyphs);
		#else
		_drawData = null;
		_bgDrawData = null;
		#end
		
		super.destroy();
	}
	
	#if (cpp || neko)
	override public function setColor(Color:BitmapInt32):BitmapInt32
	{
		super.setColor(Color);
		
		_pendingTextChange = true;
		updateBitmapData();
		
		return _color;
	}
	
	override public function draw():Void 
	{
		if(_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var textLength:Int = Math.floor(_drawData.length / 6);
		var currPosInArr:Int;
		var currTileID:Float;
		var currTileX:Float;
		var currTileY:Float;
		var currTileRed:Float;
		var currTileGreen:Float;
		var currTileBlue:Float;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		var relativeX:Float;
		var relativeY:Float;
		
		var camID:Int;
		
		while(i < l)
		{
			camera = cameras[i++];
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			
			var isColoredCamera:Bool = camera.isColored;
			
			if (!onScreen(camera))
			{
				continue;
			}
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			if (simpleRender)
			{	
				if (_background)
				{
					currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + _bgDrawData[1];
					currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + _bgDrawData[2];
					
					currDrawData[currIndex++] = _bgDrawData[0];
					
					currDrawData[currIndex++] = width;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = height;
					
					if (isColoredCamera)
					{
						currDrawData[currIndex++] = _bgDrawData[3] * camera.red; 
						currDrawData[currIndex++] = _bgDrawData[4] * camera.green;
						currDrawData[currIndex++] = _bgDrawData[5] * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _bgDrawData[3]; 
						currDrawData[currIndex++] = _bgDrawData[4];
						currDrawData[currIndex++] = _bgDrawData[5];
					}
					
					
					currDrawData[currIndex++] = _alpha;
				}
				
				//Simple render
				while (j < textLength)
				{
					if (_tileSheetData != null)
					{
						currPosInArr = j * 6;
						currTileID = _drawData[currPosInArr];
						currTileX = _drawData[currPosInArr + 1];
						currTileY = _drawData[currPosInArr + 2];
						currTileRed = _drawData[currPosInArr + 3];
						currTileGreen = _drawData[currPosInArr + 4];
						currTileBlue = _drawData[currPosInArr + 5];
						
						currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + currTileX;
						currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + currTileY;
						
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = _fontScale;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = _fontScale;
						
						if (isColoredCamera)
						{
							currDrawData[currIndex++] = currTileRed * camera.red; 
							currDrawData[currIndex++] = currTileGreen * camera.green;
							currDrawData[currIndex++] = currTileBlue * camera.blue;
						}
						else
						{
							currDrawData[currIndex++] = currTileRed; 
							currDrawData[currIndex++] = currTileGreen;
							currDrawData[currIndex++] = currTileBlue;
						}
						currDrawData[currIndex++] = _alpha;
					}
					
					j++;
				}
			}
			else
			{	//Advanced render
				radians = angle * 0.017453293;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				if (_background)
				{
					currTileX = _bgDrawData[1];
					currTileY = _bgDrawData[2];
					
					relativeX = (currTileX * cos * scale.x - currTileY * sin * scale.y);
					relativeY = (currTileX * sin * scale.x + currTileY * cos * scale.y);
					
					currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + relativeX;
					currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + relativeY;
					
					currDrawData[currIndex++] = _bgDrawData[0];
					
					currDrawData[currIndex++] = cos * scale.x * width * _fontScale;
					currDrawData[currIndex++] = -sin * scale.y * height * _fontScale;
					currDrawData[currIndex++] = sin * scale.x * width * _fontScale;
					currDrawData[currIndex++] = cos * scale.y * height * _fontScale;
					
					if (isColoredCamera)
					{
						currDrawData[currIndex++] = _bgDrawData[3] * camera.red; 
						currDrawData[currIndex++] = _bgDrawData[4] * camera.green;
						currDrawData[currIndex++] = _bgDrawData[5] * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _bgDrawData[3]; 
						currDrawData[currIndex++] = _bgDrawData[4];
						currDrawData[currIndex++] = _bgDrawData[5];
					}
					
					currDrawData[currIndex++] = _alpha;
				}
				
				while (j < textLength)
				{
					if (_tileSheetData != null)
					{
						currPosInArr = j * 6;
						currTileID = _drawData[currPosInArr];
						currTileX = _drawData[currPosInArr + 1];
						currTileY = _drawData[currPosInArr + 2];
						currTileRed = _drawData[currPosInArr + 3];
						currTileGreen = _drawData[currPosInArr + 4];
						currTileBlue = _drawData[currPosInArr + 5];
						
						relativeX = (currTileX * cos * scale.x - currTileY * sin * scale.y);
						relativeY = (currTileX * sin * scale.x + currTileY * cos * scale.y);
						
						currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + relativeX;
						currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + relativeY;
						
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = cos * scale.x * _fontScale;
						currDrawData[currIndex++] = -sin * scale.y * _fontScale;
						currDrawData[currIndex++] = sin * scale.x * _fontScale;
						currDrawData[currIndex++] = cos * scale.y * _fontScale;
						
						if (isColoredCamera)
						{
							currDrawData[currIndex++] = currTileRed * camera.red; 
							currDrawData[currIndex++] = currTileGreen * camera.green;
							currDrawData[currIndex++] = currTileBlue * camera.blue;
						}
						else
						{
							currDrawData[currIndex++] = currTileRed; 
							currDrawData[currIndex++] = currTileGreen;
							currDrawData[currIndex++] = currTileBlue;
						}
						currDrawData[currIndex++] = _alpha;
					}
					
					j++;
				}
			}
			
			_tileSheetData.positionData[camera.ID] = currIndex;
			
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	#end
	
	override public function updateTileSheet():Void
	{
		
	}
	
	#if (cpp || neko)
	override public function setAntialiasing(val:Bool):Bool
	{
		if (_font != null)
		{
			_font.antialiasing = val;
		}
		return val;
	}
	
	override public function getAntialiasing():Bool
	{
		if (_font != null)
		{
			return _font.antialiasing;
		}
		
		return false;
	}
	
	/**
	 * Gets FlxSprite's TileSheetData index in TileSheetManager
	 */
	override public function getTileSheetIndex():Int
	{
		if (_font != null)
		{
			return _font.getTileSheetIndex();
		}
		
		return -1;
	}
	#end
	
	/**
	 * Sets the color of the text.
	 */
	public var textColor(get_textColor, set_textColor):Int;
	
	public function get_textColor():Int
	{
		return _textColor;
	}
	
	public function set_textColor(value:Int):Int 
	{
		if (_textColor != value)
		{
			_textColor = value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
			updateBitmapData();
		}
		return value;
	}
	
	override public function setAlpha(pAlpha:Float):Float
	{
		#if (flash || js)
		super.setAlpha(pAlpha);
		#else
		_alpha = pAlpha;
		_pendingTextChange = true;
		updateBitmapData();
		#end
		return pAlpha;
	}
	
	// TODO: override calcFrame (maybe)
	
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
			updateBitmapData();
		}
		return _text;
	}
	
	/**
	 * Internal method for updating the view of the text component
	 */
	private function updateBitmapData():Void 
	{
		if (!_pendingTextChange) 
		{
			return;
		}
		
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
		
		width = frameWidth = finalWidth;
		height = frameHeight = finalHeight;
		frames = 1;
		origin.x = width * 0.5;
		origin.y = height * 0.5;
		
		var halfWidth:Int = Math.floor(origin.x);
		var halfHeight:Int = Math.floor(origin.y);
		#end
		
		#if (flash || js)
		if (_pixels != null) 
		{
			if (finalWidth != _pixels.width || finalHeight != _pixels.height) 
			{
				_pixels.dispose();
				_pixels = null;
			}
		}
		
		if (_pixels == null) 
		{
			_pixels = new BitmapData(finalWidth, finalHeight, !_background, _backgroundColor);
		} 
		else 
		{
			_pixels.fillRect(_pixels.rect, _backgroundColor);
		}
		_pixels.lock();
		#else
		_drawData.splice(0, _drawData.length);
		_bgDrawData.splice(0, _bgDrawData.length);
		
		// TODO: draw background
		if (_background)
		{
			_bgDrawData.push(_font.bgTileID);		// tile_ID
			_bgDrawData.push( -halfWidth);
			_bgDrawData.push( -halfHeight);
			
			#if (cpp || neko)
			var colorMultiplier:Float = 0.00392 * 0.00392;
			
			var red:Float = (_backgroundColor >> 16) * colorMultiplier;
			var green:Float = (_backgroundColor >> 8 & 0xff) * colorMultiplier;
			var blue:Float = (_backgroundColor & 0xff) * colorMultiplier;
			#end
			
			#if cpp
			red *= (_color >> 16);
			green *= (_color >> 8 & 0xff);
			blue *= (_color & 0xff);
			#elseif neko
			red *= (_color.rgb >> 16);
			green *= (_color.rgb >> 8 & 0xff);
			blue *= (_color.rgb & 0xff);
			#end
			
			_bgDrawData.push(red);
			_bgDrawData.push(green);
			_bgDrawData.push(blue);
		}
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
						_font.render(_pixels, _preparedOutlineGlyphs, t, _outlineColor, px + ox + _padding, py + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
						#else
						_font.render(_drawData, t, _outlineColor, _color, _alpha, px + ox + _padding - halfWidth, py + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding - halfHeight, _letterSpacing, _fontScale);
						#end
					}
				}
				ox += 1;
				oy += 1;
			}
			if (_shadow) 
			{
				#if (flash || js)
				_font.render(_pixels, _preparedShadowGlyphs, t, _shadowColor, 1 + ox + _padding, 1 + oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
				#else
				_font.render(_drawData, t, _shadowColor, _color, _alpha, 1 + ox + _padding - halfWidth, 1 + oy + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding - halfHeight, _letterSpacing, _fontScale);
				#end
			}
			#if (flash || js)
			_font.render(_pixels, _preparedTextGlyphs, t, _textColor, ox + _padding, oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
			#else
			_font.render(_drawData, t, _textColor, _color, _alpha, ox + _padding - halfWidth, oy + row * (Math.floor(fontHeight * _fontScale) + _lineSpacing) + _padding - halfHeight, _letterSpacing, _fontScale);
			#end
			row++;
		}
		#if (flash || js)
		_pixels.unlock();
		pixels = _pixels;
		#end
		
		_pendingTextChange = false;
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
			updateBitmapData();
		}
		return _background;
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
				updateBitmapData();
			}
		}
		return _backgroundColor;
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
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
			updateBitmapData();
			
			#if (cpp || neko)
			_tileSheetData = _font.tileSheetData;
			#end
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
			updateBitmapData();
		}
		return pSpacing;
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
			updateBitmapData();
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
			updateBitmapData();
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
			_preparedTextGlyphs = _font.getPreparedGlyphs(_fontScale, _textColor);
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