package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.text.pxText.PxBitmapFont;
import flixel.text.pxText.PxDefaultFontGenerator;
import flixel.text.pxText.PxTextAlign;
import flixel.util.FlxAngle;

/**
 * Extends FlxSprite to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 * Also does nice pixel-perfect centering on pixel fonts
 * as long as they are only one liners.
 */
class FlxBitmapTextField extends FlxSprite
{
	private var _font:PxBitmapFont;
	private var _text:String = "";
	private var _textColor:Int = 0x0;
	private var _useTextColor:Bool = true;
	private var _outline:Bool = false;
	private var _outlineColor:Int = 0x0;
	private var _shadow:Bool = false;
	private var _shadowColor:Int = 0x0;
	private var _background:Bool = false;
	private var _backgroundColor:Int = 0xFFFFFF;
	private var _alignment:Int = 1;
	private var _padding:Int = 0;
	
	private var _lineSpacing:Int = 0;
	private var _letterSpacing:Int = 0;
	private var _fontScale:Float = 1;
	private var _autoUpperCase:Bool = false;
	private var _wordWrap:Bool = true;
	private var _fixedWidth:Bool;
	
	private var _numSpacesInTab:Int = 4;
	private var _tabSpaces:String = "    ";
	
	private var _pendingTextChange:Bool = false;
	private var _multiLine:Bool = false;
	
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
	 * @param 	PxFont	Optional parameter for component's font prop
	 */
	public function new(?PxFont:PxBitmapFont) 
	{
		super();
		
		width = 2;
		alpha = 1;
		
		if (PxFont == null)
		{
			if (PxBitmapFont.fetch("default") == null)
			{
				PxDefaultFontGenerator.generateAndStoreDefaultFont();
			}
			
			_font = PxBitmapFont.fetch("default");
		}
		else
		{
			_font = PxFont;
		}
		
		#if flash
		updateGlyphs(true, _shadow, _outline);
		pixels = new BitmapData(1, 1, true);
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
	
	public var numSpacesInTab(get, set):Int;
	
	private function get_numSpacesInTab():Int 
	{
		return _numSpacesInTab;
	}
	
	private function set_numSpacesInTab(Value:Int):Int 
	{
		if (_numSpacesInTab != Value && Value > 0)
		{
			_numSpacesInTab = Value;
			_tabSpaces = "";
			
			for (i in 0...Value)
			{
				_tabSpaces += " ";
			}
			
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	#if flash
	override public function draw():Void 
	{
		if (_pendingTextChange)
		{
			updateBitmapData();
		}
		
		super.draw();
	}
	#else
	override public function draw():Void 
	{
		if (_pendingTextChange)
		{
			updateBitmapData();
		}
		
		var bgDrawItem:DrawStackItem = null;
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		
		var j:Int = 0;
		var textLength:Int = Std.int(_drawData.length / 6);
		var currPosInArr:Int;
		var currTileID:Float;
		var currTileX:Float;
		var currTileY:Float;
		var currTileRed:Float;
		var currTileGreen:Float;
		var currTileBlue:Float;
		
		var relativeX:Float;
		var relativeY:Float;
		
		#if js
		var useAlpha:Bool = (alpha < 1);
		#end
		
		var camID:Int;
		
		for (camera in cameras)
		{
			if (_background)
			{
				#if !js
				bgDrawItem = camera.getDrawStackItem(FlxG.bitmap.whitePixel, true, _blendInt, antialiasing);
				#else
				bgDrawItem = camera.getDrawStackItem(FlxG.bitmap.whitePixel, useAlpha);
				#end
			}
			
			#if !js
			drawItem = camera.getDrawStackItem(cachedGraphics, true, _blendInt, antialiasing);
			#else
			drawItem = camera.getDrawStackItem(cachedGraphics, useAlpha);
			#end
			
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
			{
				continue;
			}
			
			_point.x = (x - (camera.scroll.x * scrollFactor.x) - (offset.x)) + origin.x;
			_point.y = (y - (camera.scroll.y * scrollFactor.y) - (offset.y)) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end

			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			var x1:Float = 0;
			var y1:Float = 0;

			if (!isSimpleRender())
			{
				if (_angleChanged)
				{
					var radians:Float = angle * FlxAngle.TO_RAD;
					_sinAngle = Math.sin(radians);
					_cosAngle = Math.cos(radians);
					_angleChanged = false;
				}
				
				csx = _cosAngle * scale.x;
				ssy = _sinAngle * scale.y;
				ssx = _sinAngle * scale.x;
				csy = _cosAngle * scale.y;
				
				x1 = (origin.x - _halfWidth);
				y1 = (origin.y - _halfHeight);
			}

			if (_background)
			{
				currDrawData = bgDrawItem.drawData;
				currIndex = bgDrawItem.position;
				
				currTileX = _bgDrawData[1] - x1;
				currTileY = _bgDrawData[2] - y1;
				
				relativeX = (currTileX * csx - currTileY * ssy);
				relativeY = (currTileX * ssx + currTileY * csy);
				
				currDrawData[currIndex++] = _point.x + relativeX;
				currDrawData[currIndex++] = _point.y + relativeY;
				
				currDrawData[currIndex++] = _bgDrawData[0];
				
				currDrawData[currIndex++] = csx * width;
				currDrawData[currIndex++] = ssx * width;
				currDrawData[currIndex++] = -ssy * height;
				currDrawData[currIndex++] = csy * height;
				
				#if !js
				currDrawData[currIndex++] = _bgDrawData[3];
				currDrawData[currIndex++] = _bgDrawData[4];
				currDrawData[currIndex++] = _bgDrawData[5];
				currDrawData[currIndex++] = alpha;
				#else
				if (useAlpha)
				{
					currDrawData[currIndex++] = alpha;
				}
				#end
				
				bgDrawItem.position = currIndex;
			}
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
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
				currDrawData[currIndex++] = ssx * _fontScale;
				currDrawData[currIndex++] = -ssy * _fontScale;
				currDrawData[currIndex++] = csy * _fontScale;
				
				#if !js
				currDrawData[currIndex++] = currTileRed;
				currDrawData[currIndex++] = currTileGreen;
				currDrawData[currIndex++] = currTileBlue;
				currDrawData[currIndex++] = alpha;
				#else
				if (useAlpha)
				{
					currDrawData[currIndex++] = alpha;
				}
				#end
				j++;
			}
			
			drawItem.position = currIndex;
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
			#end
		}
	}
	
	override private function set_color(Color:Int):Int
	{
		super.set_color(Color);
		_pendingTextChange = true;
		
		return color;
	}
	#end
	
	/**
	 * Sets the color of the text.
	 */
	public var textColor(get, set):Int;
	
	private function get_textColor():Int
	{
		return _textColor;
	}
	
	private function set_textColor(Value:Int):Int 
	{
		if (_textColor != Value)
		{
			_textColor = Value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	public var useTextColor(get, set):Bool;
	
	private function get_useTextColor():Bool 
	{
		return _useTextColor;
	}
	
	private function set_useTextColor(Value:Bool):Bool 
	{
		if (_useTextColor != Value)
		{
			_useTextColor = Value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	override private function set_alpha(PxAlpha:Float):Float
	{
		#if flash
		super.set_alpha(PxAlpha);
		#else
		alpha = PxAlpha;
		_pendingTextChange = true;
		#end
		
		return PxAlpha;
	}
	
	// TODO: override calcFrame (maybe)
	
	/**
	 * Text to display.
	 */
	public var text(get, set):String;
	
	private function get_text():String
	{
		return _text;
	}
	
	private function set_text(PxText:String):String 
	{
		if (PxText != _text)
		{
			_text = PxText;
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
		var calcFieldWidth:Int = Std.int(width);
		var rows:Array<String> = [];
		
		#if flash
		var fontHeight:Int = Math.floor(_font.getFontHeight() * _fontScale);
		#else
		var fontHeight:Int = _font.getFontHeight();
		#end
		
		var alignment:Int = _alignment;
		
		// Cut text into pices
		var lineComplete:Bool;
		
		// Get words
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
							
							if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > width) 
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
							if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > width) 
							{
								if (word != "")
								{
									j = 0;
									tempStr = "";
									wordLength = word.length;
									while (j < wordLength)
									{
										currentRow = txt + word.charAt(j);
										
										if (_font.getTextWidth(currentRow, _letterSpacing, _fontScale) > width) 
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
		if (cachedGraphics != null) 
		{
			if (finalWidth != cachedGraphics.bitmap.width || finalHeight != cachedGraphics.bitmap.height) 
			{
				cachedGraphics.bitmap.dispose();
			}
		}
		
		if (cachedGraphics.bitmap == null) 
		{
			cachedGraphics.bitmap = new BitmapData(finalWidth, finalHeight, !_background, _backgroundColor);
		} 
		else 
		{
			cachedGraphics.bitmap.fillRect(cachedGraphics.bitmap.rect, _backgroundColor);
		}
		#else
		_drawData.splice(0, _drawData.length);
		_bgDrawData.splice(0, _bgDrawData.length);
		
		if (cachedGraphics == null)
		{
			return;
		}
		
		// Draw background
		if (_background)
		{
			// Tile_ID
			_bgDrawData.push(_font.bgTileID);		
			_bgDrawData.push( -_halfWidth);
			_bgDrawData.push( -_halfHeight);
			
			#if !flash
			var colorMultiplier:Float = 1 / (255 * 255);
			
			var red:Float = (_backgroundColor >> 16) * colorMultiplier;
			var green:Float = (_backgroundColor >> 8 & 0xff) * colorMultiplier;
			var blue:Float = (_backgroundColor & 0xff) * colorMultiplier;
			
			red *= (color >> 16);
			green *= (color >> 8 & 0xff);
			blue *= (color & 0xff);
			#end
			
			_bgDrawData.push(red);
			_bgDrawData.push(green);
			_bgDrawData.push(blue);
		}
		#end
		
		if (_fontScale > 0)
		{
			#if flash
			cachedGraphics.bitmap.lock();
			#end
			
			// Render text
			var row:Int = 0;
			
			for (t in rows) 
			{
				// LEFT
				var ox:Int = 0;
				var oy:Int = 0;
				
				if (alignment == PxTextAlign.CENTER) 
				{
					if (_fixedWidth)
					{
						ox = Std.int((width - _font.getTextWidth(t, _letterSpacing, _fontScale)) / 2);
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
						ox = Std.int(width) - Std.int(_font.getTextWidth(t, _letterSpacing, _fontScale));
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
							_font.render(cachedGraphics.bitmap, _preparedOutlineGlyphs, t, _outlineColor, px + ox + _padding, py + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
							#else
							_font.render(_drawData, t, _outlineColor, color, alpha, px + ox + _padding - _halfWidth, py + row * (fontHeight * _fontScale + _lineSpacing) + _padding - _halfHeight, _letterSpacing, _fontScale);
							#end
						}
					}
					ox += 1;
					oy += 1;
				}
				if (_shadow) 
				{
					#if flash
					_font.render(cachedGraphics.bitmap, _preparedShadowGlyphs, t, _shadowColor, 1 + ox + _padding, 1 + oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
					#else
					_font.render(_drawData, t, _shadowColor, color, alpha, 1 + ox + _padding - _halfWidth, 1 + oy + row * (fontHeight * _fontScale + _lineSpacing) + _padding - _halfHeight, _letterSpacing, _fontScale);
					#end
				}
				
				#if flash
				_font.render(cachedGraphics.bitmap, _preparedTextGlyphs, t, _textColor, ox + _padding, oy + row * (fontHeight + _lineSpacing) + _padding, _letterSpacing);
				#else
				_font.render(_drawData, t, _textColor, color, alpha, ox + _padding - _halfWidth, oy + row * (fontHeight * _fontScale + _lineSpacing) + _padding - _halfHeight, _letterSpacing, _fontScale, _useTextColor);
				#end
				row++;
			}
			
			#if flash
			cachedGraphics.bitmap.unlock();
		//	pixels = _pixels;
			dirty = true;
			#end
		}
		
		_pendingTextChange = false;
	}
	
	/**
	 * Specifies whether the text field should have a filled background.
	 */
	public var background(get, set):Bool;
	
	private function get_background():Bool
	{
		return _background;
	}
	
	private function set_background(Value:Bool):Bool 
	{
		if (_background != Value)
		{
			_background = Value;
			_pendingTextChange = true;
		}
		
		return _background;
	}
	
	/**
	 * Specifies the color of the text field background.
	 */
	public var backgroundColor(get, set):Int;
	
	private function get_backgroundColor():Int
	{
		return _backgroundColor;
	}
	
	private function set_backgroundColor(Value:Int):Int
	{
		if (_backgroundColor != Value)
		{
			_backgroundColor = Value;
			
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
	public var shadow(get, set):Bool;
	
	private function get_shadow():Bool
	{
		return _shadow;
	}
	
	private function set_shadow(Value:Bool):Bool
	{
		if (_shadow != Value)
		{
			_shadow = Value;
			_outline = false;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	public var shadowColor(get, set):Int;
	
	private function get_shadowColor():Int
	{
		return _shadowColor;
	}
	
	private function set_shadowColor(Value:Int):Int 
	{
		if (_shadowColor != Value)
		{
			_shadowColor = Value;
			updateGlyphs(false, _shadow, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	/**
	 * Sets the padding of the text field. This is the distance between the text and the border of the background (if any).
	 */
	public var padding(get, set):Int;
	
	private function get_padding():Int
	{
		return _padding;
	}
	
	private function set_padding(Value:Int):Int 
	{
		if (_padding != Value)
		{
			_padding = Value;
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	override private function set_width(PxWidth:Float):Float
	{
		PxWidth = Std.int(PxWidth);
		
		if (PxWidth < 1) 
		{
			PxWidth = 1;
		}
		if (PxWidth != width)
		{
			_pendingTextChange = true;
		}
		
		return super.set_width(PxWidth);
	}
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	public var alignment(get, set):Int;
	
	private function get_alignment():Int
	{
		return _alignment;
	}
	
	private function set_alignment(PxAlignment:Int):Int 
	{
		if (_alignment != PxAlignment)
		{
			_alignment = PxAlignment;
			_pendingTextChange = true;
		}
		
		return PxAlignment;
	}
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine(get, set):Bool;
	
	private function get_multiLine():Bool
	{
		return _multiLine;
	}
	
	private function set_multiLine(PxMultiLine:Bool):Bool 
	{
		if (_multiLine != PxMultiLine)
		{
			_multiLine = PxMultiLine;
			_pendingTextChange = true;
		}
		
		return PxMultiLine;
	}
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	public var outline(get, set):Bool;
	
	private function get_outline():Bool
	{
		return _outline;
	}
	
	private function set_outline(Value:Bool):Bool 
	{
		if (_outline != Value)
		{
			_outline = Value;
			_shadow = false;
			updateGlyphs(false, false, true);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	/**
	 * Specifies whether color of the text outline.
	 */
	public var outlineColor(get, set):Int;
	
	private function get_outlineColor():Int
	{
		return _outlineColor;
	}
	
	private function set_outlineColor(Value:Int):Int 
	{
		if (_outlineColor != Value)
		{
			_outlineColor = Value;
			updateGlyphs(false, false, _outline);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	/**
	 * Sets which font to use for rendering.
	 */
	public var font(get, set):PxBitmapFont;
	
	private function get_font():PxBitmapFont
	{
		return _font;
	}
	
	private function set_font(PxFont:PxBitmapFont):PxBitmapFont 
	{
		if (_font != PxFont)
		{
			_font = PxFont;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
			
			#if !flash
			pixels = _font.pixels;
			#end
		}
		
		return PxFont;
	}
	
	/**
	 * Sets the distance between lines
	 */
	public var lineSpacing(get, set):Int;
	
	private function get_lineSpacing():Int
	{
		return _lineSpacing;
	}
	
	private function set_lineSpacing(PxSpacing:Int):Int
	{
		if (_lineSpacing != PxSpacing)
		{
			_lineSpacing = Std.int(Math.abs(PxSpacing));
			_pendingTextChange = true;
		}
		
		return PxSpacing;
	}
	
	/**
	 * Sets the "font size" of the text
	 */
	public var fontScale(get, set):Float;
	
	private function get_fontScale():Float
	{
		return _fontScale;
	}
	
	private function set_fontScale(PxScale:Float):Float
	{
		var tmp:Float = Math.abs(PxScale);
		
		if (tmp != _fontScale)
		{
			_fontScale = tmp;
			updateGlyphs(true, _shadow, _outline);
			_pendingTextChange = true;
		}
		
		return PxScale;
	}
	
	public var letterSpacing(get, set):Int;
	
	private function get_letterSpacing():Int
	{
		return _letterSpacing;
	}
	
	private function set_letterSpacing(PxSpacing:Int):Int
	{
		var tmp:Int = Std.int(Math.abs(PxSpacing));
		
		if (tmp != _letterSpacing)
		{
			_letterSpacing = tmp;
			_pendingTextChange = true;
		}
		
		return _letterSpacing;
	}
	
	public var autoUpperCase(get, set):Bool;
	
	private function get_autoUpperCase():Bool 
	{
		return _autoUpperCase;
	}
	
	private function set_autoUpperCase(Value:Bool):Bool 
	{
		if (_autoUpperCase != Value)
		{
			_autoUpperCase = Value;
			_pendingTextChange = true;
		}
		
		return _autoUpperCase;
	}
	
	public var wordWrap(get, set):Bool;
	
	private function get_wordWrap():Bool 
	{
		return _wordWrap;
	}
	
	private function set_wordWrap(Value:Bool):Bool 
	{
		if (_wordWrap != Value)
		{
			_wordWrap = Value;
			_pendingTextChange = true;
		}
		
		return _wordWrap;
	}
	
	public var fixedWidth(get, set):Bool;
	
	private function get_fixedWidth():Bool 
	{
		return _fixedWidth;
	}
	
	private function set_fixedWidth(Value:Bool):Bool 
	{
		if (_fixedWidth != Value)
		{
			_fixedWidth = Value;
			_pendingTextChange = true;
		}
		
		return _fixedWidth;
	}
	
	private function updateGlyphs(TextGlyphs:Bool = false, ShadowGlyphs:Bool = false, OutlineGlyphs:Bool = false):Void
	{
		#if flash
		if (TextGlyphs)
		{
			clearPreparedGlyphs(_preparedTextGlyphs);
			_preparedTextGlyphs = _font.getPreparedGlyphs(_fontScale, _textColor, _useTextColor);
		}
		
		if (ShadowGlyphs)
		{
			clearPreparedGlyphs(_preparedShadowGlyphs);
			_preparedShadowGlyphs = _font.getPreparedGlyphs(_fontScale, _shadowColor);
		}
		
		if (OutlineGlyphs)
		{
			clearPreparedGlyphs(_preparedOutlineGlyphs);
			_preparedOutlineGlyphs = _font.getPreparedGlyphs(_fontScale, _outlineColor);
		}
		#end
	}
	
	#if flash
	private function clearPreparedGlyphs(PxGlyphs:Array<BitmapData>):Void
	{
		if (PxGlyphs != null)
		{
			for (bmd in PxGlyphs)
			{
				if (bmd != null)
				{
					bmd.dispose();
				}
			}
			
			PxGlyphs = null;
		}
	}
	#end
}