package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.text.FlxText;
/**
 * ...
 * @author Noel Berry
 */
class TypeText extends FlxText
{
	private var message:String;
	private var callback:Void->Void;
	
	private var length:Float = 0;
	private var tab:Float = 0;
	private var timer:Float = 2;
	
	private var finishedText:Bool = false;
	
	private var sound:FlxSound = null;
	
	public function new(X:Float, Y:Float, Width:Int, Message:String, Callback:Void->Void = null, TypeSound:String = null)
	{
		super(X, Y, Width);
		color = 0xffeeeeee;
		
		// reset text, get message and callback
		message = Message;
		callback = Callback;
		
		if (TypeSound != null)
		{
			sound = FlxG.sound.load(TypeSound);
		}
	}
	
	override public function destroy():Void 
	{
		callback = null;
		message = null;
		
		super.destroy();
	}
	
	public function resetMessage(Message:String, Callback:Void->Void = null):Void
	{
		length = 0;
		tab = 0;
		timer = 2;
		message = Message;
		callback = Callback;
		finishedText = false;
	}
	
	override public function update():Void
	{
		// if action key was pressed, skip text
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justPressed.X)
		{
			timer = 0;
		}
		#end
		
		// calculate the new string
		var newText:String = ">> " + message.substr(0, Std.int(length));
		
		// if the timer hasn't gone off yet, increase text length
		if (timer > 0)
		{
			// increase display length, play sound
			if (length <= message.length)
			{
				var b:Int = Std.int(length);
				length += FlxG.elapsed * 10;
				
				if (b != Std.int(length) && sound != null)
				{
					sound.play();
				}
			}
			 
			// if we've reached the end, decrease timer
			if (length >= message.length)
			{
				tab += FlxG.elapsed * 20;
				
				if (tab > 5)
					newText += "|";
				if (tab > 10)
					tab = 0;
				 
				timer -= FlxG.elapsed;
			}
		}
		else if (!finishedText)
		{
			// decrease length, if nothing's left, callback
			length -= FlxG.elapsed * 40;
			newText += "|";
			
			if (length <= 0)
			{
				finishedText = true;
				if (callback != null)	callback();
			}
		}
		 
		// text changed? update it
		if (newText != text)
			text = newText;
		
		super.update();
	}
}