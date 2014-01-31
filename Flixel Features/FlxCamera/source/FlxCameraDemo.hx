package ;
import flash.Lib;
import flixel.FlxGame;
import states.GameState;

/**
 * Demo for varisous flixel camera features:
 *
 * Styles
 * Zoom
 * Lerp
 * Lead
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 * @link https://github.com/ProG4mr
 */

class FlxCameraDemo extends FlxGame
{

	public function new() 
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		
		var ratioX:Float = stageWidth / 600;
		var ratioY:Float = stageHeight / 480;
		var ratio:Float = Math.min(ratioX, ratioY);
		
		#if TRUE_ZOOM_OUT
		ratio *= 0.5;
		#end
		
		#if (flash || desktop || neko)
		super(Math.floor(stageWidth / ratio) , Math.floor(stageHeight / ratio), GameState, ratio, 60, 60);
		#else
		super(Math.floor(stageWidth / ratio), Math.floor(stageHeight / ratio), GameState, ratio, 60, 30);
		#end
	}

}