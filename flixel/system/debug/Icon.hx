package flixel.system.debug;

private typedef IconBitmapData = openfl.display.BitmapData;

#if FLX_DEBUG @:bitmap("assets/images/debugger/cursorCross.png") #end
private class Cross extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/mover.png") #end
private class Mover extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/eraser.png") #end
private class Eraser extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/bitmapLog.png") #end
private class BitmapLog extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/transform.png") #end
private class Transform extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/cursors/transformScaleY.png") #end
private class ScaleY extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/cursors/transformScaleX.png") #end
private class ScaleX extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/cursors/transformScaleXY.png") #end
private class ScaleXY extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/cursors/transformRotate.png") #end
private class Rotate extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/flixel.png") #end
private class Flixel extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/drawDebug.png") #end
private class DrawDebug extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/log.png") #end
private class Log extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/stats.png") #end
private class Stats extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/watch.png") #end
private class Watch extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/console.png") #end
private class Console extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/arrowLeft.png") #end
private class ArrowLeft extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/arrowRight.png") #end
private class ArrowRight extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/close.png") #end
private class Close extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/interactive.png") #end
private class Interactive extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/windowHandle.png") #end
private class WindowHandle extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/minimize.png") #end
private class Minimize extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/maximize.png") #end
private class Maximize extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/open.png") #end
private class Open extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/pause.png") #end
private class Pause extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/record_off.png") #end
private class RecordOff extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/record_on.png") #end
private class RecordOn extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/restart.png") #end
private class Restart extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/step.png") #end
private class Step extends IconBitmapData {}

#if FLX_DEBUG @:bitmap("assets/images/debugger/buttons/stop.png") #end
private class Stop extends IconBitmapData {}

class Icon
{
	public static final flixel = new Flixel(11, 11);
	public static final cross = new Cross(11, 11);
	public static final mover = new Mover(11, 11);
	public static final eraser = new Eraser(11, 11);
	public static final bitmapLog = new BitmapLog(11, 11);
	public static final transform = new Transform(11, 11);
	public static final scaleX = new ScaleX(11, 11);
	public static final scaleY = new ScaleY(11, 11);
	public static final scaleXY = new ScaleXY(11, 11);
	public static final rotate = new Rotate(11, 11);
	public static final drawDebug = new DrawDebug(11, 11);
	public static final log = new Log(11, 11);
	public static final stats = new Stats(11, 11);
	public static final watch = new Watch(11, 11);
	public static final console = new Console(11, 11);
	public static final arrowLeft = new ArrowLeft(11, 11);
	public static final arrowRight = new ArrowRight(11, 11);
	public static final close = new Close(11, 11);
	public static final interactive = new Interactive(11, 11);
	public static final windowHandle = new WindowHandle(11, 11);
	public static final minimize = new Minimize(11, 11);
	public static final maximize = new Maximize(11, 11);
	public static final open = new Open(11, 11);
	public static final pause = new Pause(11, 11);
	public static final recordOff = new RecordOff(11, 11);
	public static final recordOn = new RecordOn(11, 11);
	public static final restart = new Restart(11, 11);
	public static final step = new Step(11, 11);
	public static final stop = new Stop(11, 11);
}
