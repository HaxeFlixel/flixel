package;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.addons.text.FlxTypeText;
import haxe.macro.TypeTools;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _typeText:FlxTypeText;
	private var _status:FlxTypeText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		var square:FlxSprite = new FlxSprite( 10, 10 );
		square.makeGraphic( FlxG.width - 20, FlxG.height - 76, 0xff333333 );
		
		_typeText = new FlxTypeText( 10, 10, FlxG.width - 20, "Hello, and welcome to the FlxTypeText demo. You can press the buttons below and see the different ways to control this class. Enjoy! :)", 16, true );
		
		_typeText.delay = 0.1;
		_typeText.eraseDelay = 0.2;
		_typeText.showCursor = true;
		_typeText.cursorBlinkSpeed = 1.0;
		_typeText.prefix = "C:/HAXE/FLIXEL/";
		_typeText.autoErase = true;
		_typeText.waitTime = 2.0;
		_typeText.setTypingVariation( 0.75, true );
		_typeText.useDefaultSound = true;
		_typeText.color = 0x8811EE11;
		_typeText.setSkipKeys( [ "SPACE" ] );
		
		_status = new FlxTypeText( 10, FlxG.height - 92, FlxG.width - 20, "None", 16 );
		_status.color = 0x8800AA00;
		_status.prefix = "Status: ";
		
		var effect:FlxSprite = new FlxSprite( 10, 10 );
		var bitmapdata:BitmapData = new BitmapData( FlxG.width - 20, FlxG.height - 76, true, 0x88114411 );
		var scanline:BitmapData = new BitmapData( FlxG.width - 20, 1, true, 0x88001100 );
		
		for ( i in 0...bitmapdata.height )
		{
			if ( i % 2 == 0 )
			{
				bitmapdata.draw( scanline, new Matrix( 1, 0, 0, 1, 0, i ) );
			}
		}
		
		effect.loadGraphic( bitmapdata );
		
		var button1:FlxButton = new FlxButton( 20, FlxG.height - 60, "Start", startCallback );
		var button2:FlxButton = new FlxButton( 120, FlxG.height - 60, "Pause", pauseCallback );
		var button3:FlxButton = new FlxButton( 220, FlxG.height - 60, "Erase", eraseCallback );
		var button4:FlxButton = new FlxButton( 20, FlxG.height - 30, "Force Start", forceStartCallback );
		var button5:FlxButton = new FlxButton( 120, FlxG.height - 30, "Cursor", cursorCallback );
		var button6:FlxButton = new FlxButton( 220, FlxG.height - 30, "Force Erase", forceEraseCallback );
		
		add( square );
		add( _typeText );
		add( _status );
		add( effect );
		
		add( button1 );
		add( button2 );
		add( button3 );
		add( button4 );
		add( button5 );
		add( button6 );
		
		super.create();
	}
	
	private function startCallback():Void
	{
		_typeText.start( 0.02, false, false, null, null, onComplete, [ "Fully typed" ] );
	}
	
	private function pauseCallback():Void
	{
		_typeText.paused = !_typeText.paused;
	}
	
	private function eraseCallback():Void
	{
		_typeText.erase( 0.01, false, null, null, onComplete, [ "Fully erased" ] );
	}
	
	private function forceStartCallback():Void
	{
		_typeText.start( 0.03, true, true, null, null, onComplete, [ "Typed, erasing..." ] );
	}
	
	private function cursorCallback():Void
	{
		if ( _typeText.cursorCharacter == "|" )
		{
			_typeText.cursorCharacter = "#";
		}
		else
		{
			_typeText.cursorCharacter = "|";
		}
	}
	
	private function forceEraseCallback():Void
	{
		_typeText.erase( 0.02, true, null, null, onComplete, [ "Erased" ] );
	}
	
	private function onComplete( Text:String ):Void
	{
		_status.resetText( Text );
		_status.start( null, true );
	}
}