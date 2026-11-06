package flixel.system.debug.completion;

import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;

using StringTools;
using flixel.util.FlxArrayUtil;
using flixel.util.FlxStringUtil;

class CompletionHandler
{
	static inline var ENTRY_VALUE = "Entry Value";
	static inline var ENTRY_TYPE = "Entry Type";

	var completionList:CompletionList;
	var input:TextField;
	var watchingSelection:Bool = false;

	public function new(completionList:CompletionList, input:TextField)
	{
		this.completionList = completionList;
		this.input = input;
		
		completionList.completed = completed;
		completionList.selectionChanged = selectionChanged;
		completionList.closed = completionClosed;
		
		input.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	function getTextUntilCaret():String
	{
		return input.text.substring(0, getCaretIndex());
	}
	
	function getCaretIndex():Int
	{
		return input.caretIndex;
	}
	
	function onKeyUp(e:KeyboardEvent)
	{
		final text = getTextUntilCaret();
		
		// close completion so that enter works
		if (text.endsWith(")") || text.endsWith("\"") || text.endsWith("'") || text.endsWith(";"))
		{
			completionList.close();
			return;
		}
		
		switch (e.keyCode)
		{
			case Keyboard.LEFT, Keyboard.RIGHT:
				completionList.close();

			case Keyboard.ENTER, Keyboard.ESCAPE, Keyboard.UP, Keyboard.DOWN, Keyboard.TAB:
			// do nothing

			case _:
				invokeCompletion(getPathBeforeDot(text), e.keyCode == Keyboard.PERIOD);

				if (completionList.visible)
					completionList.filter = getWordAfterDot(text);
		}
	}
	
	function invokeCompletion(path:String, isPeriod:Bool)
	{
		var items:Array<String> = null;

		try
		{
			if (path.length != 0)
			{
				final output = FlxG.console.handler.evaluate(path);
				items = FlxG.console.handler.getFields(output);
			}
		}
		catch (e:Dynamic)
		{
			if (isPeriod) // special case for cases like 'flxg.'
			{
				completionList.close();
				return;
			}
		}
		
		if (items == null)
			items = getGlobals();
		
		if (items.length > 0)
			completionList.show(getCharXPosition(), items);
		else
			completionList.close();
	}
	
	function getGlobals():Array<String>
	{
		return FlxG.console.handler.getGlobals();
	}
	
	function getCharXPosition():Float
	{
		var pos = 0.0;
		for (i in 0...getCaretIndex())
			pos += #if flash input.getCharBoundaries(i).width #else 6 #end;
		return pos;
	}
	
	function getCompletedText(text:String, selectedItem:String):String
	{
		// replace the last occurrence with the selected item
		return new EReg(getWordAfterDot(text) + "$", "g").replace(text, selectedItem);
	}
	
	function completed(selectedItem:String)
	{
		var textUntilCaret = getTextUntilCaret();
		var insert = getCompletedText(textUntilCaret, selectedItem);
		input.text = insert + input.text.substr(getCaretIndex());
		input.setSelection(insert.length, insert.length);
	}
	
	function selectionChanged(selectedItem:String)
	{
		try
		{
			final lastWord = getLastWord(input.text);
			final command = getCompletedText(lastWord, selectedItem);
			final output = FlxG.console.handler.evaluate(command);
			
			watchingSelection = true;
			FlxG.watch.addQuick(ENTRY_VALUE, output);
			FlxG.watch.addQuick(ENTRY_TYPE, getReadableType(output));
		}
		catch (e) {}
	}
	
	function getReadableType(v:Dynamic):String
	{
		return switch (Type.typeof(v))
		{
			case TNull: null;
			case TInt: "Int";
			case TFloat: "Float";
			case TBool: "Bool";
			case TObject: "Object";
			case TFunction: "Function";
			case TClass(Array): 'Array[${v.length}]';
			case TClass(c): FlxStringUtil.getClassName(c, true);
			case TEnum(e): FlxStringUtil.getClassName(e, true);
			case TUnknown: "Unknown";
		}
	}
	
	function completionClosed()
	{
		if (!watchingSelection)
			return;
		
		FlxG.watch.removeQuick(ENTRY_VALUE);
		FlxG.watch.removeQuick(ENTRY_TYPE);
		watchingSelection = false;
	}
	
	function getPathBeforeDot(text:String):String
	{
		var lastWord = getLastWord(text);
		var dotIndex = lastWord.lastIndexOf(".");
		return lastWord.substr(0, dotIndex);
	}
	
	function getWordAfterDot(text:String):String
	{
		var lastWord = getLastWord(text);
		
		var index = lastWord.lastIndexOf(".");
		if (index < 0)
			index = 0;
		else
			index++;
		
		var word = lastWord.substr(index);
		return (word == null) ? "" : word;
	}
	
	function getLastWord(text:String):String
	{
		return ~/([^.a-zA-Z0-9_\[\]"']+)/g.split(text).last();
	}
}