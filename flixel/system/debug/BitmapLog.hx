package flixel.system.debug;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormatAlign;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;

#if !FLX_NO_DEBUG
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.system.debug.FlxDebugger;

/**
 * An output window that lets you paste BitmapData in the debugger overlay.
 */
class BitmapLog extends Window
{
	public var zoom(default, set):Float = 1;
	
	private var _canvas:Bitmap;
	private var _bitmaps:Array<BitmapData> = [];
	private var _currIndex:Int = 0;
	private var _point:FlxPoint = FlxPoint.get();
	private var _lastMousePos:FlxPoint = FlxPoint.get();
	private var _curMouseOffset:FlxPoint = FlxPoint.get();
	private var _matrix:Matrix = new Matrix();
	private var _buttonLeft:FlxSystemButton;
	private var _buttonText:FlxSystemButton;
	private var _buttonRight:FlxSystemButton;
	private var _bitmapText:TextField;
	private var _ui:Sprite;
	private var _middleMouseDown:Bool = false;
	
	/**
	 * Creates a log window object.
	 */	
	public function new()
	{
		super("bitmapLog", new GraphicBitmapLog(0, 0));
		
		minSize.x = 165;
		
		_canvas = new Bitmap(new BitmapData(Std.int(width), Std.int(height - 15), true, FlxColor.TRANSPARENT));
		_canvas.x = 0;
		_canvas.y = 15;
		
		addChild(_canvas);
		
		createUI();
		setVisible(false);
		
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		#if (!FLX_NO_MOUSE && !FLX_NO_MOUSE_ADVANCED)
		addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleDown);
		addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleUp);
		#end
	}
	
	private function createUI():Void
	{
		_ui = new Sprite();
		_ui.y = 2;
		
		_buttonLeft = new FlxSystemButton(new GraphicArrowLeft(0, 0), previous);
		
		_bitmapText = DebuggerUtil.createTextField(20, -3);
		_bitmapText.text = "(0/0)";
		_bitmapText.defaultTextFormat.align = TextFormatAlign.CENTER;
		
		// allow clicking on the text to reset the current settings
		_buttonText = new FlxSystemButton(null, function() {
			resetSettings();
			refreshCanvas();
		});
		_buttonText.addChild(_bitmapText);
		
		_buttonRight = new FlxSystemButton(new GraphicArrowRight(0, 0), next);
		_buttonRight.x = 60;
		
		_ui.addChild(_buttonLeft);
		_ui.addChild(_buttonText);
		_ui.addChild(_buttonRight);
		
		addChild(_ui);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		super.destroy();
		
		clear();
		
		removeChild(_canvas);
		FlxDestroyUtil.dispose(_canvas.bitmapData);
		_canvas.bitmapData = null;
		_canvas = null;
		_bitmaps = null;
		
		removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		#if (!FLX_NO_MOUSE && !FLX_NO_MOUSE_ADVANCED)
		removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleDown);
		removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleUp);
		#end
	}
	
	override public function update():Void
	{
		if (_middleMouseDown)
		{
			var delta = FlxPoint.get(mouseX, mouseY);
			_curMouseOffset.addPoint(delta.subtractPoint(_lastMousePos));
			refreshCanvas();
			_lastMousePos.set(mouseX, mouseY);
		}
	}
	
	public override function resize(Width:Float, Height:Float):Void
	{
		super.resize(Width, Height);
		var bmp = _canvas.bitmapData;
		_canvas.bitmapData = null;
		FlxDestroyUtil.dispose(bmp);
		_canvas.bitmapData = new BitmapData(Std.int(_width - _canvas.x), Std.int(_height - _canvas.y), true, FlxColor.TRANSPARENT);
		refreshCanvas(_currIndex);
		_ui.x = _header.width - _ui.width + 43;
	}
	
	/**
	 * Show the next logged BitmapData in memory
	 */
	private inline function next():Void
	{
		resetSettings();
		refreshCanvas(_currIndex + 1);
	}
	
	/**
	 * Show the previous logged BitmapData in memory
	 */
	private inline function previous():Void 
	{
		resetSettings();
		refreshCanvas(_currIndex - 1);
	}
	
	private inline function resetSettings():Void
	{
		zoom = 1;
		_curMouseOffset.set();
	}
	
	/**
	 * Add a BitmapData to the log
	 */
	public function add(bmp:BitmapData):Bool
	{
		if (bmp == null)
		{
			return false;
		}
		setVisible(true);
		_bitmaps.push(bmp.clone());
		return refreshCanvas();
	}
	
	/**
	 * Clear one bitmap object from the log -- the last one, by default
	 * @param	Index
	 */
	public function clearAt(Index:Int = -1):Void
	{
		if (Index == -1)
		{
			Index = _bitmaps.length - 1;
		}
		FlxDestroyUtil.dispose(_bitmaps[Index]);
		_bitmaps[Index] = null;
		_bitmaps.splice(Index, 1);
		
		if (_currIndex > _bitmaps.length - 1) 
		{
			_currIndex = _bitmaps.length - 1;
		}
		
		refreshCanvas(_currIndex);
	}
	
	public function clear():Void
	{
		for (i in 0..._bitmaps.length) 
		{
			FlxDestroyUtil.dispose(_bitmaps[i]);
			_bitmaps[i] = null;
		}
		FlxArrayUtil.clearArray(_bitmaps);
		_canvas.bitmapData.fillRect(_canvas.bitmapData.rect, FlxColor.TRANSPARENT);
		_bitmapText.text = "(0/0)";
	}
	
	private function refreshCanvas(?Index:Null<Int>):Bool
	{
		if (_bitmaps == null || _bitmaps.length <= 0)
		{
			_currIndex = 0;
			return false;
		}
		
		if (Index == null)
		{
			Index = _currIndex;
		}
		
		_canvas.bitmapData.fillRect(_canvas.bitmapData.rect, FlxColor.TRANSPARENT);
		
		if (Index < 0)
		{
			Index = _bitmaps.length - 1;
		}
		else if (Index >= _bitmaps.length)
		{
			Index = 0;
		}
		
		var curBitmap:BitmapData = _bitmaps[Index];
		
		// find the window center
		_point.x = (_canvas.width / 2) - (curBitmap.width * zoom / 2);
		_point.y = (_canvas.height / 2) - (curBitmap.height * zoom / 2);
		
		_point.addPoint(_curMouseOffset);
		
		_matrix.identity();
		_matrix.scale(zoom, zoom);
		_matrix.translate(_point.x, _point.y);
		
		_canvas.bitmapData.draw(curBitmap, _matrix, null, null, _canvas.bitmapData.rect, false);
		_currIndex = Index;
		
		_bitmapText.text = '(${_currIndex + 1}/${_bitmaps.length})';
		return true;
	}
	
	private function onMouseWheel(e:MouseEvent):Void
	{
		zoom += FlxMath.signOf(e.delta) * 0.25;
		refreshCanvas();
	}
	
	private function onMiddleDown(e:MouseEvent):Void
	{
		_middleMouseDown = true;
		_lastMousePos.set(mouseX, mouseY);
	}
	
	private function onMiddleUp(e:MouseEvent):Void
	{
		_middleMouseDown = false;
	}
	
	private function set_zoom(Value:Float):Float
	{
		if (Value < 0)
		{
			Value = 0;
		}
		return zoom = Value;
	}
}
#end
