package flixel.text;

import flixel.input.FlxPointer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.frontEnds.InputTextFrontEnd;
import flixel.util.FlxColor;
import lime.system.Clipboard;
import openfl.utils.QName;

class FlxInputText extends FlxText implements IFlxInputText
{
	static inline var GUTTER:Int = 2;
	
	public var caretColor(default, set):FlxColor = FlxColor.WHITE;
	
	public var caretIndex(default, set):Int = -1;
	
	public var caretWidth(default, set):Int = 1;
	
	public var hasFocus(default, set):Bool = false;
	
	public var maxLength(default, set):Int = 0;
	
	public var multiline(get, set):Bool;
	
	public var passwordMode(get, set):Bool;
	
	public var selectionBeginIndex(get, never):Int;
	
	public var selectionEndIndex(get, never):Int;
	
	var caret:FlxSprite;
	
	var selectionIndex:Int = -1;
	
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true)
	{
		super(x, y, fieldWidth, text, size, embeddedFont);
		
		// If the text field's type isn't INPUT and there's a new line at the end
		// of the text, it won't be counted for in `numLines`
		textField.type = INPUT;
		
		caret = new FlxSprite();
		caret.moves = caret.active = caret.visible = false;
		regenCaret();
		updateCaretPosition();
		
		FlxG.inputText.registerInputText(this);
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		#if FLX_MOUSE
		if (visible)
		{
			updateInput();
		}
		#end
	}
	
	override function draw():Void
	{
		super.draw();
		
		drawSprite(caret);
	}
	
	override function destroy():Void
	{
		FlxG.inputText.unregisterInputText(this);
		
		super.destroy();
	}
	
	public function dispatchTypingAction(action:TypingAction):Void
	{
		switch (action)
		{
			case ADD_TEXT(text):
				replaceSelectedText(text);
			case MOVE_CURSOR(type, shiftKey):
				moveCursor(type, shiftKey);
			case COMMAND(cmd):
				runCommand(cmd);
		}
	}
	
	function drawSprite(sprite:FlxSprite):Void
	{
		if (sprite != null && sprite.visible)
		{
			sprite.scrollFactor.copyFrom(scrollFactor);
			sprite._cameras = _cameras;
			sprite.draw();
		}
	}
	
	function getCharIndexOnDifferentLine(charIndex:Int, lineIndex:Int):Int
	{
		if (charIndex < 0 || charIndex > text.length)
			return -1;
		if (lineIndex < 0 || lineIndex > textField.numLines - 1)
			return -1;
			
		var x = 0.0;
		var charBoundaries = textField.getCharBoundaries(charIndex - 1);
		if (charBoundaries != null)
		{
			x = charBoundaries.right;
		}
		else
		{
			x = GUTTER;
		}
		
		var y:Float = GUTTER;
		for (i in 0...lineIndex)
		{
			y += textField.getLineMetrics(i).height;
		}
		y += textField.getLineMetrics(lineIndex).height / 2;
		
		return getCharAtPosition(x, y);
	}
	
	function getCharAtPosition(x:Float, y:Float):Int
	{
		var lineY:Float = GUTTER;
		for (line in 0...textField.numLines)
		{
			var lineOffset = textField.getLineOffset(line);
			var lineHeight = textField.getLineMetrics(line).height;
			if (y >= lineY && y <= lineY + lineHeight)
			{
				// check for every character in the line
				var lineLength = textField.getLineLength(line);
				var lineEndIndex = lineOffset + lineLength;
				for (char in 0...lineLength)
				{
					var boundaries = textField.getCharBoundaries(lineOffset + char);
					// reached end of line, return this character
					if (boundaries == null)
						return lineOffset + char;
					if (x <= boundaries.right)
					{
						if (x <= boundaries.x + (boundaries.width / 2))
						{
							return lineOffset + char;
						}
						else
						{
							return (lineOffset + char < lineEndIndex) ? lineOffset + char + 1 : lineEndIndex;
						}
					}
				}
				
				// a character wasn't found, return the last character of the line
				return lineEndIndex;
			}
			
			lineY += lineHeight;
		}
		
		return -1;
	}
	
	function moveCursor(type:MoveCursorAction, shiftKey:Bool):Void
	{
		switch (type)
		{
			case LEFT:
				if (caretIndex > 0)
				{
					caretIndex--;
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case RIGHT:
				if (caretIndex < text.length)
				{
					caretIndex++;
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case UP:
				var lineIndex = textField.getLineIndexOfChar(caretIndex);
				if (lineIndex > 0)
				{
					caretIndex = getCharIndexOnDifferentLine(caretIndex, lineIndex - 1);
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case DOWN:
				var lineIndex = textField.getLineIndexOfChar(caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					caretIndex = getCharIndexOnDifferentLine(caretIndex, lineIndex + 1);
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case HOME:
				caretIndex = 0;
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case END:
				caretIndex = text.length;
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case LINE_BEGINNING:
				caretIndex = textField.getLineOffset(textField.getLineIndexOfChar(caretIndex));
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case LINE_END:
				var lineIndex = textField.getLineIndexOfChar(caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					caretIndex = textField.getLineOffset(lineIndex + 1) - 1;
				}
				else
				{
					caretIndex = text.length;
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case PREVIOUS_LINE:
				var lineIndex = textField.getLineIndexOfChar(caretIndex);
				if (lineIndex > 0)
				{
					var index = textField.getLineOffset(lineIndex);
					if (caretIndex == index)
					{
						caretIndex = textField.getLineOffset(lineIndex - 1);
					}
					else
					{
						caretIndex = index;
					}
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
			case NEXT_LINE:
				var lineIndex = textField.getLineIndexOfChar(caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					caretIndex = textField.getLineOffset(lineIndex + 1);
				}
				else
				{
					caretIndex = text.length;
				}
				
				if (!shiftKey)
				{
					selectionIndex = caretIndex;
				}
		}
	}
	
	function regenCaret():Void
	{
		caret.makeGraphic(caretWidth, Std.int(size + 2), caretColor);
	}
	
	function replaceSelectedText(newText:String):Void
	{
		if (newText == null)
			newText = "";
		if (newText == "" && selectionIndex == caretIndex)
			return;
			
		var beginIndex = selectionBeginIndex;
		var endIndex = selectionEndIndex;
		
		if (beginIndex == endIndex && maxLength > 0 && text.length == maxLength)
			return;
			
		if (beginIndex > text.length)
		{
			beginIndex = text.length;
		}
		if (endIndex > text.length)
		{
			endIndex = text.length;
		}
		if (endIndex < beginIndex)
		{
			var cache = endIndex;
			endIndex = beginIndex;
			beginIndex = cache;
		}
		if (beginIndex < 0)
		{
			beginIndex = 0;
		}
		
		replaceText(beginIndex, endIndex, newText);
	}
	
	function replaceText(beginIndex:Int, endIndex:Int, newText:String):Void
	{
		if (endIndex < beginIndex || beginIndex < 0 || endIndex > text.length || newText == null)
			return;
			
		if (maxLength > 0)
		{
			var removeLength = (endIndex - beginIndex);
			var newMaxLength = maxLength - text.length + removeLength;
			
			if (newMaxLength <= 0)
			{
				newText = "";
			}
			else if (newMaxLength < newText.length)
			{
				newText = newText.substr(0, newMaxLength);
			}
		}
		
		text = text.substring(0, beginIndex) + newText + text.substring(endIndex);
		
		selectionIndex = caretIndex = beginIndex + newText.length;
	}
	
	function runCommand(cmd:TypingCommand):Void
	{
		switch (cmd)
		{
			case NEW_LINE:
				if (multiline)
				{
					replaceSelectedText("\n");
				}
			case DELETE_LEFT:
				if (selectionIndex == caretIndex && caretIndex > 0)
				{
					selectionIndex = caretIndex - 1;
				}
				
				if (selectionIndex != caretIndex)
				{
					replaceSelectedText("");
					selectionIndex = caretIndex;
				}
			case DELETE_RIGHT:
				if (selectionIndex == caretIndex && caretIndex < text.length)
				{
					selectionIndex = caretIndex + 1;
				}
				
				if (selectionIndex != caretIndex)
				{
					replaceSelectedText("");
					selectionIndex = caretIndex;
				}
			case COPY:
				if (caretIndex != selectionIndex && !passwordMode)
				{
					Clipboard.text = text.substring(caretIndex, selectionIndex);
				}
			case CUT:
				if (caretIndex != selectionIndex && !passwordMode)
				{
					Clipboard.text = text.substring(caretIndex, selectionIndex);
					
					replaceSelectedText("");
				}
			case PASTE:
				if (Clipboard.text != null)
				{
					replaceSelectedText(Clipboard.text);
				}
			case SELECT_ALL:
				selectionIndex = 0;
				caretIndex = text.length;
		}
	}
	
	function updateCaretPosition():Void
	{
		if (textField == null)
			return;
			
		if (text.length == 0)
		{
			caret.setPosition(x + GUTTER, y + GUTTER);
		}
		else
		{
			var lineIndex = textField.getLineIndexOfChar(caretIndex);
			var boundaries = textField.getCharBoundaries(caretIndex - 1);
			if (boundaries != null)
			{
				caret.setPosition(x + boundaries.right, y + boundaries.y);
			}
			else // end of line
			{
				var lineY:Float = GUTTER;
				for (i in 0...lineIndex)
				{
					lineY += textField.getLineMetrics(i).height;
				}
				caret.setPosition(x + GUTTER, y + lineY);
			}
		}
	}
	
	#if FLX_MOUSE
	function updateInput()
	{
		if (FlxG.mouse.justPressed)
		{
			updatePointerInput(FlxG.mouse);
		}
	}
	
	function updatePointerInput(pointer:FlxPointer)
	{
		var overlap = false;
		var pointerPos = FlxPoint.get();
		for (camera in getCameras())
		{
			pointer.getWorldPosition(camera, pointerPos);
			if (overlapsPoint(pointerPos, true, camera))
			{
				hasFocus = true;
				
				getScreenPosition(_point, camera);
				caretIndex = getCharAtPosition(pointerPos.x - _point.x, pointerPos.y - _point.y);
				selectionIndex = caretIndex;
				
				overlap = true;
				break;
			}
		}
		
		if (!overlap)
		{
			hasFocus = false;
		}

		pointerPos.put();
	}
	#end
	
	override function set_color(value:FlxColor):FlxColor
	{
		if (color != value)
		{
			super.set_color(value);
			caretColor = value;
		}
		
		return value;
	}
	
	override function set_text(value:String):String
	{
		if (text != value)
		{
			super.set_text(value);
			
			if (hasFocus)
			{
				if (text.length < selectionIndex)
				{
					selectionIndex = text.length;
				}
				if (text.length < caretIndex)
				{
					caretIndex = text.length;
				}
			}
			else
			{
				selectionIndex = 0;
				caretIndex = 0;
			}
		}
		
		return value;
	}
	
	function set_caretColor(value:FlxColor):FlxColor
	{
		if (caretColor != value)
		{
			caretColor = value;
			regenCaret();
		}
		return value;
	}
	
	function set_caretIndex(value:Int):Int
	{
		if (caretIndex != value)
		{
			caretIndex = value;
			if (caretIndex < 0)
				caretIndex = 0;
			if (caretIndex > text.length)
				caretIndex = text.length;
			updateCaretPosition();
		}
		return value;
	}
	
	function set_caretWidth(value:Int):Int
	{
		if (caretWidth != value)
		{
			caretWidth = value;
			regenCaret();
		}
		return value;
	}
	
	function set_hasFocus(value:Bool):Bool
	{
		if (hasFocus != value)
		{
			hasFocus = value;
			if (hasFocus)
			{
				FlxG.inputText.focus = this;
				
				if (caretIndex < 0)
				{
					caretIndex = text.length;
					selectionIndex = caretIndex;
				}
				
				caret.visible = true;
			}
			else if (FlxG.inputText.focus == this)
			{
				FlxG.inputText.focus = null;
				
				if (selectionIndex != caretIndex)
				{
					selectionIndex = caretIndex;
				}
				
				caret.visible = false;
			}
		}
		return value;
	}
	
	function set_maxLength(value:Int):Int
	{
		if (maxLength != value)
		{
			maxLength = value;
			if (maxLength > 0 && text.length > maxLength)
			{
				text = text.substr(0, maxLength);
			}
		}
		
		return value;
	}
	
	function get_multiline():Bool
	{
		return textField.multiline;
	}
	
	function set_multiline(value:Bool):Bool
	{
		if (textField.multiline != value)
		{
			textField.multiline = value;
			// `wordWrap` will still add new lines even if `multiline` is false,
			// let's change it accordingly
			wordWrap = value;
			_regen = true;
		}
		return value;
	}
	
	function get_passwordMode():Bool
	{
		return textField.displayAsPassword;
	}
	
	function set_passwordMode(value:Bool):Bool
	{
		if (textField.displayAsPassword != value)
		{
			textField.displayAsPassword = value;
			_regen = true;
		}
		return value;
	}
	
	function get_selectionBeginIndex():Int
	{
		return FlxMath.minInt(caretIndex, selectionIndex);
	}
	
	function get_selectionEndIndex():Int
	{
		return FlxMath.maxInt(caretIndex, selectionIndex);
	}
}
