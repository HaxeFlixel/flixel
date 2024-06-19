package flixel.text;

import flixel.input.FlxPointer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.frontEnds.InputTextFrontEnd;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import lime.system.Clipboard;
import openfl.geom.Rectangle;
import openfl.text.TextFormat;
import openfl.utils.QName;

class FlxInputText extends FlxText implements IFlxInputText
{
	static inline var GUTTER:Int = 2;
	
	public var caretColor(default, set):FlxColor = FlxColor.WHITE;
	
	public var caretIndex(get, set):Int;
	
	public var caretWidth(default, set):Int = 1;
	
	public var hasFocus(default, set):Bool = false;
	
	public var maxLength(default, set):Int = 0;
	
	public var multiline(get, set):Bool;
	
	public var passwordMode(get, set):Bool;

	public var selectedTextColor(default, set):FlxColor = FlxColor.WHITE;
	
	public var selectionBeginIndex(get, never):Int;

	public var selectionColor(default, set):FlxColor = FlxColor.BLACK;
	
	public var selectionEndIndex(get, never):Int;
	
	var _caret:FlxSprite;
	var _caretIndex:Int = -1;
	var _selectionBoxes:Array<FlxSprite> = [];
	var _selectionFormat:TextFormat = new TextFormat();
	var _selectionIndex:Int = -1;
	
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, ?text:String, size:Int = 8, embeddedFont:Bool = true)
	{
		super(x, y, fieldWidth, text, size, embeddedFont);
		
		// If the text field's type isn't INPUT and there's a new line at the end
		// of the text, it won't be counted for in `numLines`
		textField.type = INPUT;
		
		_selectionFormat.color = selectedTextColor;
		
		_caret = new FlxSprite();
		_caret.visible = false;
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
		for (box in _selectionBoxes)
			drawSprite(box);

		super.draw();
		
		drawSprite(_caret);
	}
	
	override function destroy():Void
	{
		FlxG.inputText.unregisterInputText(this);

		_caret = FlxDestroyUtil.destroy(_caret);
		while (_selectionBoxes.length > 0)
			FlxDestroyUtil.destroy(_selectionBoxes.pop());
		_selectionBoxes = null;
		_selectionFormat = null;
		
		super.destroy();
	}

	override function applyFormats(formatAdjusted:TextFormat, useBorderColor:Bool = false):Void
	{
		super.applyFormats(formatAdjusted, useBorderColor);
		
		textField.setTextFormat(_selectionFormat, selectionBeginIndex, selectionEndIndex);
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

	public function setSelection(beginIndex:Int, endIndex:Int):Void
	{
		_selectionIndex = beginIndex;
		_caretIndex = endIndex;
		_regen = true; // regenerate so the selected text format is applied
		
		if (textField == null)
			return;
			
		_caret.alpha = (_selectionIndex == _caretIndex) ? 1 : 0;
		
		updateCaretPosition();
		regenSelectionBoxes();
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
				if (_caretIndex > 0)
				{
					_caretIndex--;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case RIGHT:
				if (_caretIndex < text.length)
				{
					_caretIndex++;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case UP:
				var lineIndex = textField.getLineIndexOfChar(_caretIndex);
				if (lineIndex > 0)
				{
					_caretIndex = getCharIndexOnDifferentLine(_caretIndex, lineIndex - 1);
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case DOWN:
				var lineIndex = textField.getLineIndexOfChar(_caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					_caretIndex = getCharIndexOnDifferentLine(_caretIndex, lineIndex + 1);
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case HOME:
				_caretIndex = 0;
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case END:
				_caretIndex = text.length;
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case LINE_BEGINNING:
				_caretIndex = textField.getLineOffset(textField.getLineIndexOfChar(_caretIndex));
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case LINE_END:
				var lineIndex = textField.getLineIndexOfChar(_caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					_caretIndex = textField.getLineOffset(lineIndex + 1) - 1;
				}
				else
				{
					_caretIndex = text.length;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case PREVIOUS_LINE:
				var lineIndex = textField.getLineIndexOfChar(_caretIndex);
				if (lineIndex > 0)
				{
					var index = textField.getLineOffset(lineIndex);
					if (_caretIndex == index)
					{
						_caretIndex = textField.getLineOffset(lineIndex - 1);
					}
					else
					{
						_caretIndex = index;
					}
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
			case NEXT_LINE:
				var lineIndex = textField.getLineIndexOfChar(_caretIndex);
				if (lineIndex < textField.numLines - 1)
				{
					_caretIndex = textField.getLineOffset(lineIndex + 1);
				}
				else
				{
					_caretIndex = text.length;
				}
				
				if (!shiftKey)
				{
					_selectionIndex = _caretIndex;
				}
				setSelection(_selectionIndex, _caretIndex);
		}
	}
	
	function regenCaret():Void
	{
		_caret.makeGraphic(caretWidth, Std.int(size + 2), caretColor);
	}
	
	function regenSelectionBoxes():Void
	{
		if (textField == null)
			return;
			
		while (_selectionBoxes.length > textField.numLines)
		{
			var box = _selectionBoxes.pop();
			if (box != null)
				box.destroy();
		}
		
		if (_caretIndex == _selectionIndex)
		{
			for (box in _selectionBoxes)
			{
				if (box != null)
					box.visible = false;
			}
			
			return;
		}
		
		var beginLine = textField.getLineIndexOfChar(selectionBeginIndex);
		var endLine = textField.getLineIndexOfChar(selectionEndIndex);
		
		for (line in 0...textField.numLines)
		{
			if (line >= beginLine && line <= endLine)
			{
				var lineStartIndex = textField.getLineOffset(line);
				var lineEndIndex = lineStartIndex + textField.getLineLength(line);
				
				var startIndex = FlxMath.maxInt(lineStartIndex, selectionBeginIndex);
				var endIndex = FlxMath.minInt(lineEndIndex, selectionEndIndex);
				
				var startBoundaries = textField.getCharBoundaries(startIndex);
				var endBoundaries = textField.getCharBoundaries(endIndex - 1);
				if (endBoundaries == null && endIndex > startIndex) // end of line, try getting the previous character
				{
					endBoundaries = textField.getCharBoundaries(endIndex - 2);
				}
				
				if (startBoundaries != null && endBoundaries != null)
				{
					if (_selectionBoxes[line] == null)
						_selectionBoxes[line] = new FlxSprite().makeGraphic(1, 1, selectionColor);
						
					_selectionBoxes[line].setPosition(x + startBoundaries.x, y + startBoundaries.y);
					_selectionBoxes[line].setGraphicSize(endBoundaries.right - startBoundaries.x, startBoundaries.height);
					_selectionBoxes[line].updateHitbox();
					_selectionBoxes[line].visible = true;
				}
				else if (_selectionBoxes[line] != null)
				{
					_selectionBoxes[line].visible = false;
				}
			}
			else if (_selectionBoxes[line] != null)
			{
				_selectionBoxes[line].visible = false;
			}
		}
	}
	
	function replaceSelectedText(newText:String):Void
	{
		if (newText == null)
			newText = "";
		if (newText == "" && _selectionIndex == _caretIndex)
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
		
		_selectionIndex = _caretIndex = beginIndex + newText.length;
		setSelection(_selectionIndex, _caretIndex);
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
				if (_selectionIndex == _caretIndex && _caretIndex > 0)
				{
					_selectionIndex = _caretIndex - 1;
				}
				
				if (_selectionIndex != _caretIndex)
				{
					replaceSelectedText("");
					_selectionIndex = _caretIndex;
				}
			case DELETE_RIGHT:
				if (_selectionIndex == _caretIndex && _caretIndex < text.length)
				{
					_selectionIndex = _caretIndex + 1;
				}
				
				if (_selectionIndex != _caretIndex)
				{
					replaceSelectedText("");
					_selectionIndex = _caretIndex;
				}
			case COPY:
				if (_caretIndex != _selectionIndex && !passwordMode)
				{
					Clipboard.text = text.substring(_caretIndex, _selectionIndex);
				}
			case CUT:
				if (_caretIndex != _selectionIndex && !passwordMode)
				{
					Clipboard.text = text.substring(_caretIndex, _selectionIndex);
					
					replaceSelectedText("");
				}
			case PASTE:
				if (Clipboard.text != null)
				{
					replaceSelectedText(Clipboard.text);
				}
			case SELECT_ALL:
				_selectionIndex = 0;
				_caretIndex = text.length;
				setSelection(_selectionIndex, _caretIndex);
		}
	}
	
	function updateCaretPosition():Void
	{
		if (textField == null)
			return;
			
		if (text.length == 0)
		{
			_caret.setPosition(x + GUTTER, y + GUTTER);
		}
		else
		{
			var boundaries = textField.getCharBoundaries(_caretIndex - 1);
			if (boundaries != null)
			{
				_caret.setPosition(x + boundaries.right, y + boundaries.y);
			}
			else // end of line
			{
				var lineY:Float = GUTTER;
				var lineIndex = textField.getLineIndexOfChar(_caretIndex);
				for (i in 0...lineIndex)
				{
					lineY += textField.getLineMetrics(i).height;
				}
				_caret.setPosition(x + GUTTER, y + lineY);
			}
		}
	}
	
	#if FLX_MOUSE
	function updateInput():Void
	{
		if (FlxG.mouse.justPressed)
		{
			updatePointerInput(FlxG.mouse);
		}
	}
	
	function updatePointerInput(pointer:FlxPointer):Void
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
				_caretIndex = getCharAtPosition(pointerPos.x - _point.x, pointerPos.y - _point.y);
				_selectionIndex = _caretIndex;
				setSelection(_selectionIndex, _caretIndex);
				
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
				if (text.length < _selectionIndex)
				{
					_selectionIndex = text.length;
				}
				if (text.length < _caretIndex)
				{
					_caretIndex = text.length;
				}
			}
			else
			{
				_selectionIndex = 0;
				_caretIndex = 0;
			}
			setSelection(_selectionIndex, _caretIndex);
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
	
	function get_caretIndex():Int
	{
		return _caretIndex;
	}
	function set_caretIndex(value:Int):Int
	{
		if (_caretIndex != value)
		{
			_caretIndex = value;
			if (_caretIndex < 0)
				_caretIndex = 0;
			if (_caretIndex > text.length)
				_caretIndex = text.length;
			setSelection(_caretIndex, _caretIndex);
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
				
				if (_caretIndex < 0)
				{
					_caretIndex = text.length;
					_selectionIndex = _caretIndex;
					setSelection(_selectionIndex, _caretIndex);
				}
				
				_caret.visible = true;
			}
			else if (FlxG.inputText.focus == this)
			{
				FlxG.inputText.focus = null;
				
				if (_selectionIndex != _caretIndex)
				{
					_selectionIndex = _caretIndex;
					setSelection(_selectionIndex, _caretIndex);
				}
				
				_caret.visible = false;
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
	
	function set_selectedTextColor(value:FlxColor):FlxColor
	{
		if (selectedTextColor != value)
		{
			selectedTextColor = value;
			_selectionFormat.color = selectedTextColor;
			_regen = true;
		}
		
		return value;
	}
	
	function get_selectionBeginIndex():Int
	{
		return FlxMath.minInt(_caretIndex, _selectionIndex);
	}
	
	function set_selectionColor(value:FlxColor):FlxColor
	{
		if (selectionColor != value)
		{
			selectionColor = value;
			for (box in _selectionBoxes)
			{
				if (box != null)
					box.makeGraphic(1, 1, selectionColor);
			}
		}
		
		return value;
	}
	
	function get_selectionEndIndex():Int
	{
		return FlxMath.maxInt(_caretIndex, _selectionIndex);
	}
}
