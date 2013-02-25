package org.flixel.plugin.pxText;

import nme.display.BitmapData;
import nme.display.BitmapInt32;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.system.layer.DrawStackItem;

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
	private var _useTextColor:Bool;
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
	
	private var _numSpacesInTab:Int;
	private var _tabSpaces:String;
	
	private var _pendingTextChange:Bool;
	private var _fieldWidth:Int;
	private var _multiLine:Bool;
	
	#if flash
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
	public function new(pFont:PxBitmapFont = null) 
	{
		super();
		
		_text = "";
		_textColor = 0x0;
		_useTextColor = true;
		_outline = false;
		_outlineColor = 0x0;
		_shadow = false;
		_shadowColor = 0x0;
		_background = false;
		_backgroundColor = 0xFFFFFF;
		_alignment = PxTextAlign.LEFT;
		_padding = 0;
		_pendingTextChange = false;
		_fieldWidth = 2;
		_multiLine = false;
		
		_lineSpacing = 0;
		_letterSpacing = 0;
		_fontScale = 1;
		_autoUpperCase = false;
		_fixedWidth = true;
		_wordWrap = true;
		alpha = 1;
		
		_numSpacesInTab = 4;
		_tabSpaces = "    ";
		
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
		
		#if flash
		updateGlyphs(true, _shadow, _outline);
		_pixels = new BitmapData(1, 1, true);
		#else
		pixels = _font.pixels;
		_drawData = [];
		_bgDrawData = [];
		#end
		
		_pendingTextChange = true;
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function destroy():Void 
	{
		_font = null;
		#if flash
		clearPreparedGlyphs(_preparedTextGlyphs);
		clearPreparedGlyphs(_preparedShadowGlyphs);
		clearPreparedGlyphs(_preparedOutlineGlyphs);
		#else
		_drawData = null;
		_bgDrawData = null;
		#end
		
		super.destroy();
	}
	
	override public function update():Void 
	{
		if (_pendingTextChange)
		{
			updateBitmapData();
		}
		super.update();
	}
	
	public var numSpacesInTab(get_numSpacesInTab, set_numSpacesInTab):Int;
	
	private function get_numSpacesInTab():Int 
	{
		return _numSpacesInTab;
	}
	
	private function set_numSpacesInTab(value:Int):Int 
	{
		if (_numSpacesInTab != value && value > 0)
		{
			_numSpacesInTab = value;
			_tabSpaces = "";
			for (i in 0...value)
			{
				_tabSpaces += " ";
			}
			_pendingTextChange = true;
		}
		return value;
	}
	
	#if !flash
	override private function set_color(Color:BitmapInt32):BitmapInt32
	{
		super.set_color(Color);
		_pendingTextChange = true;
		return _color;
	}
	
	override public function draw():Void 
	{
		if (_atlas == null)
		{
			return;
		}
		
		if (_flickerTimer != 0)
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
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var textLength:Int = Std.int(_drawData.length / 6);
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
		
		#if js
		var useAlpha:Bool = (alpha < 1);
		#end
		
		var camID:Int;
		
		while(i < l)
		{
			camera = cameras[i++];
			#if !js
			drawItem = camera.getDrawStackItem(_atlas, true, _blendInt);
			var isColoredCamera:Bool = camera.isColored();
			#else
			drawItem = camera.getDrawStackItem(_atlas, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			_point.x = (x - (camera.scroll.x * scrollFactor.x) - (offset.x)) + origin.x;
			_point.y = (y - (camera.scroll.y * scrollFactor.y) - (offset.y)) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
			
			if (simpleRenderSprite())
			{	
				if (_background)
				{
					currDrawData[currIndex++] = _point.x + _bgDrawData[1];
					currDrawData[currIndex++] = _point.y + _bgDrawData[2];
					
					currDrawData[currIndex++] = _bgDrawData[0];
					
					currDrawData[currIndex++] = width;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = height;
					
					#if !js
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
					currDrawData[currIndex++] = alpha;
					#else
					if (useAlpha)
					{
						currDrawData[currIndex++] = alpha;
					}
					#end
				}
				
				//Simple render
				while (j < textLength)
				{
					currPosInArr = j * 6;
					currTileID = _drawData[currPosInArr];
					currTileX = _drawData[currPosInArr + 1];
					currTileY = _drawData[currPosInArr + 2];
					currTileRed = _drawData[currPosInArr + 3];
					currTileGreen = _drawData[currPosInArr + 4];
					currTileBlue = _drawData[currPosInArr + 5];
					
					currDrawData[currIndex++] = _point.x + currTileX;
					currDrawData[currIndex++] = _point.y + currTileY;
					
					currDrawData[currIndex++] = currTileID;
					
					currDrawData[currIndex++] = _fontScale;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = _fontScale;
					
					#if !js
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
					currDrawData[currIndex++] = alpha;
					#else
					if (useAlpha)
					{
						currDrawData[currIndex++] = alpha;
					}
					#end
					j++;
				}
			}
			else
			{	//Advanced render
				radians = angle * FlxG.RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				var csx:Float = cos * scale.x;
				var ssy:Float = sin * scale.y;
				var ssx:Float = sin * scale.x;
				var csy:Float = cos * scale.y;
				
				var x1:Float = (origin.x - _halfWidth);
				var y1:Float = (origin.y - _halfHeight);
				
				if (_background)
				{
					currTileX = _bgDrawData[1] - x1;
					currTileY = _bgDrawData[2] - y1;
					
					relativeX = (currTileX * csx - currTileY * ssy);
					relativeY = (currTileX * ssx + currTileY * csy);
					
					currDrawData[currIndex++] = _point.x + relativeX;
					currDrawData[currIndex++] = _point.y + relativeY;
					
					currDrawData[currIndex++] = _bgDrawData[0];
					
					currDrawData[currIndex++] = csx * width;
					currDrawData[currIndex++] = -ssy * height;
					currDrawData[currIndex++] = ssx * width;
					currDrawData[currIndex++] = csy * height;
					
					#if !js
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
					currDrawData[currIndex++] = alpha;
					#else
					if (useAlpha)
					{
						currDrawData[currIndex++] = alpha;
					}
					#end
				}
				
				while (j < textLength)
				{
					currPosInArr = j * 6;
					currTileID = _drawData[currPosInArr];
					currTileX = _drawData[currPosInArr + 1] - x1;
					currTileY = _drawData[currPosInArr + 2] - y1;
					currTileRed = _drawData[currPosInArr + 3];
					currTileGreen = _drawData[currPosInArr + 4];
					currTileBlue = _drawData[currPosInArr + 5];
					
					relativeX = (currTileX * csx - currTileY * ssy);
					relativeY = (currTileX * ssx + currTileY * csy);
					
					currDrawData[currIndex++] = _point.x + relativeX;
					currDrawData[currIndex++] = _point.y + relativeY;
					
					currDrawData[currIndex++] = currTileID;
					
					currDrawData[currIndex++] = csx * _fontScale;
					currDrawData[currIndex++] = -ssy * _fontScale;
					currDrawData[currIndex++] = ssx * _fontScale;
					currDrawData[currIndex++] = csy * _fontScale;
					
					#if !js
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
					currDrawData[currIndex++] = alpha;
					#else
					if (useAlpha)
					{
						currDrawData[currIndex++] = alpha;
					}
					#end
					j++;
				}
			}
			
			drawItem.position = currIndex;
			
			FlxBasic._VISIBLECOUNT++;
			
			#if !FLX_NO_DEBUG
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
			#end
		}
	}
	#end
	
	/**
	 * Sets the color of the text.
	 */
	public var textColor(get_textColor, set_textColor):Int;
	
	private function get_textColor():Int
	{
		return _textColor;
	}
	
	private function set_textColor(value:Int):Int 
	{
		if (_textColor != value)
		{
			_textColor = value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
		}
		return value;
	}
	
	public var useTextColor(get_useTextColor, set_useTextColor):Bool;
	
	private function get_useTextColor():Bool 
	{
		return _useTextColor;
	}
	
	private function set_useTextColor(value:Bool):Bool 
	{
		if (_useTextColor != value)
		{
			_useTextColor = value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
		}
		return value;
	}
	
	override private function set_alpha(pAlpha:Float):Float
	{
		#if flash
		super.set_alpha(pAlpha);
		#else
		alpha = pAlpha;
		_pendingTextChange = true;
		#end
		return pAlpha;
	}
	
	// TODO: override calcFrame (maybe)
	
	/**
	 * Text to display.
	 */
	public var text(get_text, set_text):String;
	
	private function get_text():String
	{
		return _text;
	}
	
	private function set_text(pText:String):String 
	{
		if (pText != _text)
		{
			_text = pText;
			_pendingTextChange = true;
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
		
		var preparedText:String = (_autoUpperCase) ? _text.toUpperCase() : _text;
		var calcFieldWidth:Int = _fieldWidth;
		var rows:Array<String> = [];
		#if flash
		var fontHeight:Int = Math.floor(_font.getFontHeight() * _fontScale);
		#else
		var fontHeight:Int = _font.getFontHeight();
		#end
		var alignment:Int = _alignment;
		
		// cut text into pices
		var lineComplete:Bool;
		
		// get words
		var lines:Array<String> = preparedText.split("\n");
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
				var words:Array<String> = [];
				if (!wordWrap)
				{
					words = lines[i].split("\t").join(_tabSpaces).split(" ");
				}
				else
				{
					words = lines[i].split("\t").join(" \t ").split(" ");
				}
				
				if (words.length > 0) 
				{
					var wordPos:Int = 0;
					var txt:String = "";
					while (!lineComplete) 
					{
						word = words[wordPos];
						var changed:Bool = false;
						var currentRow:String = txt + word;
						
						if (_wordWrap)
						{
							var prevWord:String = (wordPos > 0) ? words[wordPos - 1] : "";
							var nextWord:String = (wordPos < words.length) ? words[wordPos + 1] : "";
							if (prevWord != "\t") currentRow += " ";
							
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
									if (word == "\t" && (wordPos < words.length))
									{
										words.splice(0, wordPos + 1);
									}
									else
									{
										words.splice(0, wordPos);
									}
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
								if (word == "\t")
								{
									txt += _tabSpaces;
								}
								if (nextWord == "\t" || prevWord == "\t")
								{
									txt += word;
								}
								else
								{
									txt += word + " ";
								}
								wordPos++;
							}
						}
						else
						{
							if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > _fieldWidth) 
							{
								if (word != "")
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
									changed = false;
									wordPos = words.length;
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
								calcFieldWidth = Std.int(Math.max(calcFieldWidth, _font.getTextWidth(txt, _letterSpacing, _fontScale)));
								rows.push(txt);
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
				var lineWithoutTabs:String = lines[i].split("\t").join(_tabSpaces);
				calcFieldWidth = Std.int(Math.max(calcFieldWidth, _font.getTextWidth(lineWithoutTabs, _letterSpacing, _fontScale)));
				rows.push(lineWithoutTabs);
			}
		}
		
		var finalWidth:Int = calcFieldWidth + _padding * 2 + (_outline ? 2 : 0);
		#if flash
		var finalHeight:Int = Std.int(_padding * 2 + Math.max(1, (rows.length * fontHeight + (_shadow ? 1 : 0)) + (_outline ? 2 : 0))) + ((rows.length >= 1) ? _lineSpacing * (rows.length - 1) : 0);
		#else
		var finalHeight:Int = Std.int(_padding * 2 + Math.max(1, (rows.length * fontHeight * _fontScale + (_shadow ? 1 : 0)) + (_outline ? 2 : 0))) + ((rows.length >= 1) ? _lineSpacing * (rows.length - 1) : 0);
		
		width = frameWidth = finalWidth;
		height = frameHeight = finalHeight;
		frames = 1;
		origin.x = width * 0.5;
		origin.y = height * 0.5;
		
		_halfWidth = origin.x;
		_halfHeight = origin.y;
		#end
		
		#if flash
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
		#else
		_drawData.splice(0, _drawData.length);
		_bgDrawData.splice(0, _bgDrawData.length);
		
		if (_node == null || _node.atlas == null)
		{
			return;
		}
		var nodeName:String = _node.atlas.name;
		
		// draw background
		if (_background)
		{
			_bgDrawData.push(_font.bgTileID(nodeName));		// tile_ID
			_bgDrawData.push( -_halfWidth);
			_bgDrawData.push( -_halfHeight);
			
			#if !flash
			var colorMultiplier:Float = 1 / (255 * 255);
			
			var red:Float = (_backgroundColor >> 16) * colorMultiplier;
			var green:Float = (_backgroundColor >> 8 & 0xff) * colorMultiplier;
			var blue:Float = (_backgroundColor & 0xff) * colorMultiplier;
			#end
			
			#if (cpp || js)
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
		
		if (_fontScale > 0)
		{
			#if flash
			_pixels.lock();
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
						ox = Std.int((_fieldWidth - _font.getTextWidth(t, _letterSpacing, _fontScale)) / 2);
					}
					else
					{
						ox = Std.int((finalWidth - _font.getTextWidth(t, _letterSpacing, _fontScale)) / 2);
					}
				}
				if (alignment == PxTextAlign.RIGHT) 
				{
					if (_fixedWidth)
					{
						ox = _fieldWidth - Std.int(_font.getTextWidth(t, _letterSpacing, _fontScale));
					}
					else
					{
						ox = finalWidth - Std.int(_font.getTextWidth(t, _letterSpacing, _fontScale)) - 2 * padding;
					}
				}
				if (_outline) 
				{
					for (py in 0...(2 + 1)) 
					{
						for (px in 0...(2 + 1)) 
						{
							#if flash
							_font.render(_pixels, _preparedOutlineGlyphs, t, _outlineColor, px + ox + _padding, py + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
							#else
							_font.render(nodeName, _drawData, t, _outlineColor, _color, alpha, px + ox + _padding - _halfWidth, py + row * (fontHeight * _fontScale + _lineSpacing) + _padding - _halfHeight, _letterSpacing, _fontScale);
							#end
						}
					}
					ox += 1;
					oy += 1;
				}
				if (_shadow) 
				{
					#if flash
					_font.render(_pixels, _preparedShadowGlyphs, t, _shadowColor, 1 + ox + _padding, 1 + oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
					#else
					_font.render(nodeName, _drawData, t, _shadowColor, _color, alpha, 1 + ox + _padding - _halfWidth, 1 + oy + row * (fontHeight * _fontScale + _lineSpacing) + _padding - _halfHeight, _letterSpacing, _fontScale);
					#end
				}
				#if flash
				_font.render(_pixels, _preparedTextGlyphs, t, _textColor, ox + _padding, oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
				#else
				_font.render(nodeName, _drawData, t, _textColor, _color, alpha, ox + _padding - _halfWidth, oy + row * (fontHeight * _fontScale + _lineSpacing) + _padding - _halfHeight, _letterSpacing, _fontScale, _useTextColor);
				#end
				row++;
			}
			#if flash
			_pixels.unlock();
			pixels = _pixels;
			#end
		}
		
		_pendingTextChange = false;
	}
	
	/**
	 * Specifies whether the text field should have a filled background.
	 */
	public var background(get_background, set_background):Bool;
	
	private function get_background():Bool
	{
		return _background;
	}
	
	private function set_background(value:Bool):Bool 
	{
		if (_background != value)
		{
			_background = value;
			_pendingTextChange = true;
		}
		return _background;
	}
	
	/**
	 * Specifies the color of the text field background.
	 */
	public var backgroundColor(get_backgroundColor, set_backgroundColor):Int;
	
	private function get_backgroundColor():Int
	{
		return _backgroundColor;
	}
	
	private function set_backgroundColor(value:Int):Int
	{
		if (_backgroundColor != value)
		{
			_backgroundColor = value;
			if (_background)
			{
				_pendingTextChange = true;
			}
		}
		return _backgroundColor;
	}
	
	/**
	 * Specifies whether the text should have a shadow.
	 */
	public var shadow(get_shadow, set_shadow):Bool;
	
	private function get_shadow():Bool
	{
		return _shadow;
	}
	
	private function set_shadow(value:Bool):Bool
	{
		if (_shadow != value)
		{
			_shadow = value;
			_outline = false;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	public var shadowColor(get_shadowColor, set_shadowColor):Int;
	
	private function get_shadowColor():Int
	{
		return _shadowColor;
	}
	
	private function set_shadowColor(value:Int):Int 
	{
		if (_shadowColor != value)
		{
			_shadowColor = value;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
		}
		
		return value;
	}
	
	/**
	 * Sets the padding of the text field. This is the distance between the text and the border of the background (if any).
	 */
	public var padding(get_padding, set_padding):Int;
	
	private function get_padding():Int
	{
		return _padding;
	}
	
	private function set_padding(value:Int):Int 
	{
		if (_padding != value)
		{
			_padding = value;
			_pendingTextChange = true;
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
		}
		
		return pWidth;
	}
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	public var alignment(get_alignment, set_alignment):Int;
	
	private function get_alignment():Int
	{
		return _alignment;
	}
	
	private function set_alignment(pAlignment:Int):Int 
	{
		if (_alignment != pAlignment)
		{
			_alignment = pAlignment;
			_pendingTextChange = true;
		}
		return pAlignment;
	}
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine(get_multiLine, set_multiLine):Bool;
	
	private function get_multiLine():Bool
	{
		return _multiLine;
	}
	
	private function set_multiLine(pMultiLine:Bool):Bool 
	{
		if (_multiLine != pMultiLine)
		{
			_multiLine = pMultiLine;
			_pendingTextChange = true;
		}
		return pMultiLine;
	}
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	public var outline(get_outline, set_outline):Bool;
	
	private function get_outline():Bool
	{
		return _outline;
	}
	
	private function set_outline(value:Bool):Bool 
	{
		if (_outline != value)
		{
			_outline = value;
			_shadow = false;
			updateGlyphs(false, false, true);
			_pendingTextChange = true;
		}
		return value;
	}
	
	/**
	 * Specifies whether color of the text outline.
	 */
	public var outlineColor(get_outlineColor, set_outlineColor):Int;
	
	private function get_outlineColor():Int
	{
		return _outlineColor;
	}
	
	private function set_outlineColor(value:Int):Int 
	{
		if (_outlineColor != value)
		{
			_outlineColor = value;
			updateGlyphs(false, false, _outline);
			_pendingTextChange = true;
		}
		return value;
	}
	
	/**
	 * Sets which font to use for rendering.
	 */
	public var font(get_font, set_font):PxBitmapFont;
	
	private function get_font():PxBitmapFont
	{
		return _font;
	}
	
	private function set_font(pFont:PxBitmapFont):PxBitmapFont 
	{
		if (_font != pFont)
		{
			_font = pFont;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			
			#if !flash
			pixels = _font.pixels;
			#end
		}
		return pFont;
	}
	
	/**
	 * Sets the distance between lines
	 */
	public var lineSpacing(get_lineSpacing, set_lineSpacing):Int;
	
	private function get_lineSpacing():Int
	{
		return _lineSpacing;
	}
	
	private function set_lineSpacing(pSpacing:Int):Int
	{
		if (_lineSpacing != pSpacing)
		{
			_lineSpacing = Std.int(Math.abs(pSpacing));
			_pendingTextChange = true;
		}
		return pSpacing;
	}
	
	/**
	 * Sets the "font size" of the text
	 */
	public var fontScale(get_fontScale, set_fontScale):Float;
	
	private function get_fontScale():Float
	{
		return _fontScale;
	}
	
	private function set_fontScale(pScale:Float):Float
	{
		var tmp:Float = Math.abs(pScale);
		if (tmp != _fontScale)
		{
			_fontScale = tmp;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
		}
		return pScale;
	}
	
	public var letterSpacing(get_letterSpacing, set_letterSpacing):Int;
	
	private function get_letterSpacing():Int
	{
		return _letterSpacing;
	}
	
	private function set_letterSpacing(pSpacing:Int):Int
	{
		var tmp:Int = Std.int(Math.abs(pSpacing));
		if (tmp != _letterSpacing)
		{
			_letterSpacing = tmp;
			_pendingTextChange = true;
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
			_pendingTextChange = true;
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
		}
		return _fixedWidth;
	}
	
	private function updateGlyphs(textGlyphs:Bool = false, shadowGlyphs:Bool = false, outlineGlyphs:Bool = false):Void
	{
		#if flash
		if (textGlyphs)
		{
			clearPreparedGlyphs(_preparedTextGlyphs);
			_preparedTextGlyphs = _font.getPreparedGlyphs(_fontScale, _textColor, _useTextColor);
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
	
	#if flash
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
	
	override public function updateFrameData():Void
	{
	#if !flash
		if (_node != null && _font != null)
		{
			_font.updateGlyphData(_node);
		}
	#end
	}
}