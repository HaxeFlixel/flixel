package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.layer.DrawStackItem;
import flixel.text.pxText.PxBitmapFont;
import flixel.text.pxText.PxDefaultFontGenerator;
import flixel.text.pxText.PxTextAlign;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Extends FlxSprite to support rendering text.
 * Can tint, fade, rotate and scale just like a sprite.
 * Doesn't really animate though, as far as I know.
 * Also does nice pixel-perfect centering on pixel fonts
 * as long as they are only one liners.
 */
class FlxBitmapTextField extends FlxSprite
{
	public var numSpacesInTab(default, set):Int = 4;
	/**
	 * Sets the color of the text.
	 */
	public var textColor(default, set):FlxColor = FlxColor.TRANSPARENT;
	
	public var useTextColor(default, set):Bool = true;
	
	/**
	 * Text to display.
	 */
	public var text(default, set):String = "";
	
	/**
	 * Specifies whether the text field should have a filled background.
	 */
	public var background(default, set):Bool = false;
	
	/**
	 * Specifies the color of the text field background.
	 */
	public var backgroundColor(default, set):FlxColor = FlxColor.WHITE;
	
	/**
	 * Specifies whether the text should have a shadow.
	 */
	public var shadow(default, set):Bool = false;
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	public var shadowColor(default, set):FlxColor = FlxColor.TRANSPARENT;
	
	/**
	 * Sets the padding of the text field.
	 * This is the distance between the text and the border of the background (if any).
	 */
	public var padding(default, set):Int = 0;
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	public var alignment(default, set):Int = PxTextAlign.LEFT;
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	public var multiLine(default, set):Bool = false;
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	public var outline(default, set):Bool = false;
	
	/**
	 * Specifies whether color of the text outline.
	 */
	public var outlineColor(default, set):FlxColor = FlxColor.TRANSPARENT;
	
	/**
	 * Sets which font to use for rendering.
	 */
	public var font(default, set):PxBitmapFont;
	
	/**
	 * Sets the distance between lines
	 */
	public var lineSpacing(default, set):Int = 0;
	
	/**
	 * Sets the "font size" of the text
	 */
	public var fontScale(default, set):Float = 1;
	
	public var letterSpacing(default, set):Int = 0;
	
	public var autoUpperCase(default, set):Bool = false;
	
	public var wordWrap(default, set):Bool = true;
	
	public var fixedWidth(default, set):Bool = false;
	
	private var _tabSpaces:String = "    ";
	
	private var _pendingTextChange:Bool = false;
	
	#if FLX_RENDER_BLIT
	private var _preparedTextGlyphs:Array<BitmapData>;
	private var _preparedShadowGlyphs:Array<BitmapData>;
	private var _preparedOutlineGlyphs:Array<BitmapData>;
	#else
	private var _drawData:Array<Float> = [];
	private var _bgDrawData:Array<Float> = [];
	private var _point2 = FlxPoint.get();
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
			
			font = PxBitmapFont.fetch("default");
		}
		else
		{
			font = PxFont;
		}
		
		#if FLX_RENDER_BLIT
		updateGlyphs(true, shadow, outline);
		pixels = new BitmapData(1, 1, true);
		#else
		pixels = font.pixels;
		#end
		
		_pendingTextChange = true;
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function destroy():Void 
	{
		#if FLX_RENDER_BLIT
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
	
	#if FLX_RENDER_BLIT
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
		var textLength:Int = Std.int(_drawData.length / 6);
		
		for (camera in cameras)
		{
			if (background)
			{
				bgDrawItem = camera.getDrawStackItem(FlxG.bitmap.whitePixel, true, _blendInt, antialiasing);
				// TODO: make it work again
			}
			
			var drawItem = camera.getDrawStackItem(cachedGraphics, true, _blendInt, antialiasing);
			
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
			{
				continue;
			}
			
			_point.x = (x - (camera.scroll.x * scrollFactor.x) - (offset.x)) + origin.x;
			_point.y = (y - (camera.scroll.y * scrollFactor.y) - (offset.y)) + origin.y;
			
			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			var x1:Float = 0;
			var y1:Float = 0;
			
			if (!isSimpleRender(camera))
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
			
			if (background)
			{
				var currTileX = _bgDrawData[1] - x1;
				var currTileY = _bgDrawData[2] - y1;
				
				var relativeX = (currTileX * csx - currTileY * ssy);
				var relativeY = (currTileX * ssx + currTileY * csy);
				_point2.copyFrom(_point).add(relativeX, relativeY);
				
				drawItem.setDrawData(_point2, _bgDrawData[0],
					csx * width, ssx * width, -ssy * width, csy * width,
					true, FlxColor.fromRGBFloat(_bgDrawData[3], _bgDrawData[4], _bgDrawData[5]), alpha * camera.alpha);
			}
			
			var j:Int = 0;
			while (j < textLength)
			{
				var currPosInArr = j * 6;
				var currTileID = _drawData[currPosInArr];
				var currTileX = _drawData[currPosInArr + 1] - x1;
				var currTileY = _drawData[currPosInArr + 2] - y1;
				var currTileRed = _drawData[currPosInArr + 3];
				var currTileGreen = _drawData[currPosInArr + 4];
				var currTileBlue = _drawData[currPosInArr + 5];
				
				var relativeX = (currTileX * csx - currTileY * ssy);
				var relativeY = (currTileX * ssx + currTileY * csy);
				_point2.copyFrom(_point).add(relativeX, relativeY);
				
				drawItem.setDrawData(_point2, currTileID,
					csx * fontScale, ssx * fontScale, -ssy * fontScale, csy * fontScale,
					true, FlxColor.fromRGBFloat(currTileRed, currTileGreen, currTileBlue), alpha * camera.alpha);
				
				j++;
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
	
	override private function set_color(Color:FlxColor):Int
	{
		super.set_color(Color);
		_pendingTextChange = true;
		
		return color;
	}
	#end
	
	private function set_numSpacesInTab(Value:Int):Int 
	{
		if (numSpacesInTab != Value && Value > 0)
		{
			numSpacesInTab = Value;
			_tabSpaces = "";
			
			for (i in 0...Value)
			{
				_tabSpaces += " ";
			}
			
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	private function set_textColor(Value:FlxColor):FlxColor 
	{
		if (textColor != Value)
		{
			textColor = Value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	private function set_useTextColor(Value:Bool):Bool 
	{
		if (useTextColor != Value)
		{
			useTextColor = Value;
			updateGlyphs(true, false, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	override private function set_alpha(PxAlpha:Float):Float
	{
		#if FLX_RENDER_BLIT
		super.set_alpha(PxAlpha);
		#else
		alpha = PxAlpha;
		_pendingTextChange = true;
		#end
		
		return PxAlpha;
	}
	
	// TODO: override calcFrame (maybe)
	
	private function set_text(PxText:String):String 
	{
		if (PxText != text)
		{
			text = PxText;
			_pendingTextChange = true;
		}
		
		return text;
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
		
		if (font == null)
		{
			return;
		}
		
		var preparedText:String = autoUpperCase ? text.toUpperCase() : text;
		var calcFieldWidth:Int = 0; // Std.int(width);
		var rows:Array<String> = [];
		
		#if FLX_RENDER_BLIT
		var fontHeight:Int = Math.floor(font.getFontHeight() * fontScale);
		#else
		var fontHeight:Int = font.getFontHeight();
		#end
		
		var alignment:Int = alignment;
		
		// Cut text into pices
		var lineComplete:Bool;
		
		// Get words
		var lines:Array<String> = preparedText.split("\n");
		var i:Int = -1;
		var j:Int = -1;
		
		if (!multiLine)
		{
			lines = [lines[0]];
		}
		
		var wordLength:Int;
		var word:String;
		var tempStr:String;
		
		while (++i < lines.length) 
		{
			if (fixedWidth)
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
						
						if (wordWrap)
						{
							var prevWord:String = (wordPos > 0) ? words[wordPos - 1] : "";
							var nextWord:String = (wordPos < words.length) ? words[wordPos + 1] : "";
							if (prevWord != "\t") currentRow += " ";
							
							if (font.getTextWidth(currentRow, letterSpacing, fontScale) > width) 
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
								
								if (multiLine)
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
							if (font.getTextWidth(currentRow, letterSpacing, fontScale) > width) 
							{
								if (word != "")
								{
									j = 0;
									tempStr = "";
									wordLength = word.length;
									while (j < wordLength)
									{
										currentRow = txt + word.charAt(j);
										
										if (font.getTextWidth(currentRow, letterSpacing, fontScale) > width) 
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
								calcFieldWidth = Std.int(Math.max(calcFieldWidth, font.getTextWidth(txt, letterSpacing, fontScale)));
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
				calcFieldWidth = Std.int(Math.max(calcFieldWidth, font.getTextWidth(lineWithoutTabs, letterSpacing, fontScale)));
				rows.push(lineWithoutTabs);
			}
		}
		
		var finalWidth:Int = fixedWidth ? Std.int(width) : calcFieldWidth + padding * 2 + (outline ? 2 : 0);
		
		#if FLX_RENDER_BLIT
		var finalHeight:Int = Std.int(padding * 2 + Math.max(1, (rows.length * fontHeight + (shadow ? 1 : 0)) +
			(outline ? 2 : 0))) + ((rows.length >= 1) ? lineSpacing * (rows.length - 1) : 0);
		#else
		
		var finalHeight:Int = Std.int(padding * 2 + Math.max(1, (rows.length * fontHeight * fontScale +
			(shadow ? 1 : 0)) + (outline ? 2 : 0))) + ((rows.length >= 1) ? lineSpacing * (rows.length - 1) : 0);
		
		width = frameWidth = finalWidth;
		height = frameHeight = finalHeight;
		frames = 1;
		origin.x = width * 0.5;
		origin.y = height * 0.5;
		
		_halfWidth = origin.x;
		_halfHeight = origin.y;
		#end
		
		#if FLX_RENDER_BLIT
		if (pixels == null || (finalWidth != pixels.width || finalHeight != pixels.height)) 
		{
			pixels = new BitmapData(finalWidth, finalHeight, !background, backgroundColor);
		} 
		else 
		{
			pixels.fillRect(cachedGraphics.bitmap.rect, backgroundColor);
		}
		#else
		_drawData.splice(0, _drawData.length);
		_bgDrawData.splice(0, _bgDrawData.length);
		
		if (cachedGraphics == null)
		{
			return;
		}
		
		// Draw background
		if (background)
		{
			// Tile_ID
			_bgDrawData.push(font.bgTileID);		
			_bgDrawData.push( -_halfWidth);
			_bgDrawData.push( -_halfHeight);
			
			#if FLX_RENDER_TILE
			var colorMultiplier:Float = 1 / (255 * 255);
			
			var red:Float = (backgroundColor >> 16) * colorMultiplier;
			var green:Float = (backgroundColor >> 8 & 0xff) * colorMultiplier;
			var blue:Float = (backgroundColor & 0xff) * colorMultiplier;
			
			red *= (color >> 16);
			green *= (color >> 8 & 0xff);
			blue *= (color & 0xff);
			#end
			
			_bgDrawData.push(red);
			_bgDrawData.push(green);
			_bgDrawData.push(blue);
		}
		#end
		
		if (fontScale > 0)
		{
			#if FLX_RENDER_BLIT
			pixels.lock();
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
					if (fixedWidth)
					{
						ox = Std.int((width - font.getTextWidth(t, letterSpacing, fontScale)) / 2);
					}
					else
					{
						ox = Std.int((finalWidth - font.getTextWidth(t, letterSpacing, fontScale)) / 2);
					}
				}
				if (alignment == PxTextAlign.RIGHT) 
				{
					if (fixedWidth)
					{
						ox = Std.int(width) - Std.int(font.getTextWidth(t, letterSpacing, fontScale));
					}
					else
					{
						ox = finalWidth - Std.int(font.getTextWidth(t, letterSpacing, fontScale)) - 2 * padding;
					}
				}
				if (outline) 
				{
					for (py in 0...(2 + 1)) 
					{
						for (px in 0...(2 + 1)) 
						{
							#if FLX_RENDER_BLIT
							font.render(pixels, _preparedOutlineGlyphs, t, outlineColor, px + ox + padding, py + row * (fontHeight + lineSpacing) + padding, letterSpacing);
							#else
							font.render(_drawData, t, outlineColor, color, alpha, px + ox + padding - _halfWidth, py + row * (fontHeight * fontScale + lineSpacing) + padding - _halfHeight, letterSpacing, fontScale);
							#end
						}
					}
					ox += 1;
					oy += 1;
				}
				if (shadow) 
				{
					#if FLX_RENDER_BLIT
					font.render(pixels, _preparedShadowGlyphs, t, shadowColor, 1 + ox + padding, 1 + oy + row * (fontHeight + lineSpacing) + padding, letterSpacing);
					#else
					font.render(_drawData, t, shadowColor, color, alpha, 1 + ox + padding - _halfWidth, 1 + oy + row * (fontHeight * fontScale + lineSpacing) + padding - _halfHeight, letterSpacing, fontScale);
					#end
				}
				
				#if FLX_RENDER_BLIT
				font.render(pixels, _preparedTextGlyphs, t, textColor, ox + padding, oy + row * (fontHeight + lineSpacing) + padding, letterSpacing);
				#else
				font.render(_drawData, t, textColor, color, alpha, ox + padding - _halfWidth, oy + row * (fontHeight * fontScale + lineSpacing) + padding - _halfHeight, letterSpacing, fontScale, useTextColor);
				#end
				row++;
			}
			
			#if FLX_RENDER_BLIT
			pixels.unlock();
			resetFrameBitmapDatas();
			dirty = true;
			#end
		}
		
		_pendingTextChange = false;
	}
	
	private function set_background(Value:Bool):Bool 
	{
		if (background != Value)
		{
			background = Value;
			_pendingTextChange = true;
		}
		
		return background;
	}
	
	private function set_backgroundColor(Value:Int):Int
	{
		if (backgroundColor != Value)
		{
			backgroundColor = Value;
			
			if (background)
			{
				_pendingTextChange = true;
			}
		}
		return backgroundColor;
	}
	
	private function set_shadow(Value:Bool):Bool
	{
		if (shadow != Value)
		{
			shadow = Value;
			outline = false;
			updateGlyphs(false, shadow, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	private function set_shadowColor(Value:FlxColor):FlxColor 
	{
		if (shadowColor != Value)
		{
			shadowColor = Value;
			updateGlyphs(false, shadow, false);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	private function set_padding(Value:Int):Int 
	{
		if (padding != Value)
		{
			padding = Value;
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
	
	private function set_alignment(PxAlignment:Int):Int 
	{
		if (alignment != PxAlignment)
		{
			alignment = PxAlignment;
			_pendingTextChange = true;
		}
		
		return PxAlignment;
	}
	
	private function set_multiLine(PxMultiLine:Bool):Bool 
	{
		if (multiLine != PxMultiLine)
		{
			multiLine = PxMultiLine;
			_pendingTextChange = true;
		}
		
		return PxMultiLine;
	}
	
	private function set_outline(Value:Bool):Bool 
	{
		if (outline != Value)
		{
			outline = Value;
			shadow = false;
			updateGlyphs(false, false, true);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	private function set_outlineColor(Value:FlxColor):FlxColor 
	{
		if (outlineColor != Value)
		{
			outlineColor = Value;
			updateGlyphs(false, false, outline);
			_pendingTextChange = true;
		}
		
		return Value;
	}
	
	private function set_font(PxFont:PxBitmapFont):PxBitmapFont 
	{
		if (font != PxFont)
		{
			font = PxFont;
			updateGlyphs(true, shadow, outline);
			_pendingTextChange = true;
			
			#if FLX_RENDER_TILE
			pixels = font.pixels;
			#end
		}
		
		return PxFont;
	}
	
	private function set_lineSpacing(PxSpacing:Int):Int
	{
		if (lineSpacing != PxSpacing)
		{
			lineSpacing = Std.int(Math.abs(PxSpacing));
			_pendingTextChange = true;
		}
		
		return PxSpacing;
	}
	
	private function set_fontScale(PxScale:Float):Float
	{
		var tmp:Float = Math.abs(PxScale);
		
		if (tmp != fontScale)
		{
			fontScale = tmp;
			updateGlyphs(true, shadow, outline);
			_pendingTextChange = true;
		}
		
		return PxScale;
	}
	
	private function set_letterSpacing(PxSpacing:Int):Int
	{
		var tmp:Int = Std.int(Math.abs(PxSpacing));
		
		if (tmp != letterSpacing)
		{
			letterSpacing = tmp;
			_pendingTextChange = true;
		}
		
		return letterSpacing;
	}
	
	private function set_autoUpperCase(Value:Bool):Bool 
	{
		if (autoUpperCase != Value)
		{
			autoUpperCase = Value;
			_pendingTextChange = true;
		}
		
		return autoUpperCase;
	}
	
	private function set_wordWrap(Value:Bool):Bool 
	{
		if (wordWrap != Value)
		{
			wordWrap = Value;
			_pendingTextChange = true;
		}
		
		return wordWrap;
	}
	
	private function set_fixedWidth(Value:Bool):Bool 
	{
		if (fixedWidth != Value)
		{
			fixedWidth = Value;
			_pendingTextChange = true;
		}
		
		return fixedWidth;
	}
	
	private function updateGlyphs(TextGlyphs:Bool = false, ShadowGlyphs:Bool = false, OutlineGlyphs:Bool = false):Void
	{
		#if FLX_RENDER_BLIT
		if (TextGlyphs)
		{
			clearPreparedGlyphs(_preparedTextGlyphs);
			_preparedTextGlyphs = font.getPreparedGlyphs(fontScale, textColor, useTextColor);
		}
		
		if (ShadowGlyphs)
		{
			clearPreparedGlyphs(_preparedShadowGlyphs);
			_preparedShadowGlyphs = font.getPreparedGlyphs(fontScale, shadowColor);
		}
		
		if (OutlineGlyphs)
		{
			clearPreparedGlyphs(_preparedOutlineGlyphs);
			_preparedOutlineGlyphs = font.getPreparedGlyphs(fontScale, outlineColor);
		}
		#end
	}
	
	#if FLX_RENDER_BLIT
	private function clearPreparedGlyphs(PxGlyphs:Array<BitmapData>):Void
	{
		if (PxGlyphs != null)
		{
			for (bmd in PxGlyphs)
			{
				FlxDestroyUtil.dispose(bmd);
			}
			
			PxGlyphs = null;
		}
	}
	#end
}
