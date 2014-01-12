package flixel.system.resolution;
import flixel.util.FlxPoint;

interface IFlxResolutionPolicy 
{
	public function onMeasure(Width:Int, Height:Int):Void;
}