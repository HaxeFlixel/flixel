package;

import flash.display.BitmapData;
import flixel.FlxSprite;

class PongSprite extends FlxSprite
{
	//public var color:Int;
	public var secondColor:Int;
	
	static public inline var SOLID:Int = 0;
	static public inline var GRADIENT:Int = 1;
	
	public function new( X:Int, Y:Int, Width:Int, Height:Int, Color:Int, Style:Int = SOLID, ?SecondColor:Int )
	{
		var Graphic:BitmapData = new BitmapData( Width, Height, false, Color );
		
		if ( Style == GRADIENT && SecondColor != null ) {
			secondColor = SecondColor;
			fillWithGradient( Graphic, color, secondColor );
		}
		
		super( X, Y, Graphic );
	}
	
	public function fillWithGradient( Bd:BitmapData, Color:Int, SecondColor:Int ):Void
	{
		color = Color;
		secondColor = SecondColor;
		
		var w:Int = Bd.width;
		var h:Int = Bd.height;
		var increment:Float = 1 / h;
		Bd = new BitmapData( w, h, false, Color );
		
		for ( yPos in 0...h ) {
			for ( xPos in 0...w ) {
				if ( xPos % increment == 0 ) {
					Bd.setPixel( xPos, yPos, secondColor );
				}
			}
		}
	}
}