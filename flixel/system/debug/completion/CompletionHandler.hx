package flixel.system.debug.completion;

import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.ui.Keyboard;
using flixel.util.FlxArrayUtil;
using StringTools;

#if hscript
import flixel.system.debug.console.ConsoleUtil;
using flixel.util.FlxStringUtil;
#end

class CompletionHandler
{
	private var completionList:CompletionList;
	private var input:TextField;
	private var watchingSelection:Bool = false;
	
	public function new(completionList:CompletionList, input:TextField) 
	{
		this.completionList = completionList;
		this.input = input;
		
		completionList.completed = completed;
		completionList.selectionChanged = selectionChanged;
		completionList.closed = completionClosed;
		
		input.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	private function getTextUntilCaret():String
	{
		return input.text.substring(0, getCaretIndex());
	}

	private function getCaretIndex():Int
	{
		#if openfl_legacy
		// caretIndex is not a thing on legacy...
		return input.text.length;
		#else
		return input.caretIndex;
		#end
	}

	private function onKeyUp(e:KeyboardEvent)
	{
		var text = getTextUntilCaret();
		
		// close completion so that enter works
		if (text.endsWith(")") || text.endsWith("\"") || text.endsWith("'"))
		{
			completionList.close();
			return;
		}
		
		switch (e.keyCode)
		{
			case Keyboard.LEFT, Keyboard.RIGHT:
				completionList.close();
			
			case Keyboard.ENTER, Keyboard.ESCAPE, Keyboard.UP, Keyboard.DOWN:
				// handled by completion list, do nothing
			
			case _:
				invokeCompletion(getPathBeforeDot(text), e.keyCode == Keyboard.PERIOD);
				
				if (completionList.visible)
					completionList.filter = getWordAfterDot(text);
		}
	}
	
	private function invokeCompletion(path:String, isPeriod:Bool)
	{
		#if hscript
		var items:Array<String> = null;
		
		try
		{
			if (path.length != 0)
			{
				var output = ConsoleUtil.runCommand(path);
				items = ConsoleUtil.getFields(output);
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
		#end
	}
	
	private function getGlobals():Array<String>
	{
		#if hscript
		return ConsoleUtil.interp.getGlobals().sortAlphabetically();
		#else
		return [];
		#end
	}
	
	private function getCharXPosition():Float
	{
		var pos = 0.0;
		for (i in 0...getCaretIndex())
			pos += #if flash input.getCharBoundaries(i).width #else 6 #end;
		return pos;
	}
	
	private function getCompletedText(text:String, selectedItem:String):String
	{
		// replace the last occurence with the selected item
		return new EReg(getWordAfterDot(text) + "$", "g").replace(text, selectedItem);
	}
	
	private function completed(selectedItem:String)
	{
		var textUntilCaret = getTextUntilCaret();
		var insert = getCompletedText(textUntilCaret, selectedItem);
		input.text = insert + input.text.substr(getCaretIndex());
		input.setSelection(insert.length, insert.length);
	}
	
	private function selectionChanged(selectedItem:String)
	{
		#if hscript
		try
		{
			var lastWord = getLastWord(input.text);
			var command = getCompletedText(lastWord, selectedItem);
			var output = ConsoleUtil.runCommand(command);
			
			watchingSelection = true;
			FlxG.watch.addQuick("Selection", output);
		}
		catch (e:Dynamic) {}
		#end
	}
	
	private function completionClosed()
	{
		if (!watchingSelection)
			return;
		
		FlxG.watch.removeQuick("Selection");
		watchingSelection = false;
	}
	
	private function getPathBeforeDot(text:String):String
	{
		var lastWord = getLastWord(text);
		var dotIndex = lastWord.lastIndexOf(".");
		return lastWord.substr(0, dotIndex);
	}
	
	private function getWordAfterDot(text:String):String
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
	
	private function getLastWord(text:String):String
	{
		return ~/([^.a-zA-Z0-9_\[\]"']+)/g.split(text).last();
	}
}