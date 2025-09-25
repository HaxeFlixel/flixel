package flixel.system.debug.log;

#if FLX_DEBUG
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.LineScaleMode;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.text.TextField;

using flixel.util.FlxBitmapDataUtil;

/**
 * An output window that lets you paste BitmapData in the debugger overlay.
 */
class BitmapLog extends Window
{
	public var zoom:Float = 1;
	
	final entries = new Array<BitmapLogEntry>();
	final canvas:Bitmap;
	final header:Header;
	final footer:Footer;
	final buttonRemove:FlxSystemButton;
	final canvasOffset = FlxPoint.get();
	
	var index:Int = -1;
	var state:State = IDLE;
	
	public function new()
	{
		super("BitmapLog", Icon.bitmapLog);
		
		minSize.x = 165;
		minSize.y = Window.HEADER_HEIGHT * 2 + 1;
		
		canvas = new Bitmap(new BitmapData(Std.int(width), Std.int(height - 15), true, FlxColor.TRANSPARENT));
		canvas.x = 0;
		canvas.y = 15;
		addChild(canvas);
		
		buttonRemove = new FlxSystemButton(Icon.close, removeCurrent);
		buttonRemove.x = width - buttonRemove.width - 3;
		buttonRemove.y = Window.HEADER_HEIGHT + 3;
		addChild(buttonRemove);
		
		header = new Header();
		header.y = 2;
		header.onPrev.add(()->setIndex(index - 1));
		header.onNext.add(()->setIndex(index + 1));
		header.onReset.add(resetSettings);
		addChild(header);
		
		footer = new Footer();
		addChild(footer);
		
		setVisible(false);
		
		#if FLX_MOUSE
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		#end
		
		FlxG.signals.preStateSwitch.add(clear);
		
		// place the handle on top
		removeChild(_handle);
		addChild(_handle);
		
		removeChild(_shadow);
	}
	
	/**
	 * Clean up memory.
	 */
	override function destroy():Void
	{
		super.destroy();
	
		clear();
	
		removeChild(canvas);
		canvas.bitmapData = FlxDestroyUtil.dispose(canvas.bitmapData);
		entries.resize(0);
	
		removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	
		FlxG.signals.preStateSwitch.remove(clear);
	}
	
	function onMouseWheel(e:MouseEvent):Void
	{
		zoom = Math.max(0.01, zoom + FlxMath.signOf(e.delta) * 0.25);
		drawCanvas();
	}
	
	override function onMouseDown(?e:MouseEvent)
	{
		super.onMouseDown(e);
		
		if (_overHeader == false && _overHandle == false)
			state = DRAG(e.stageX, e.stageY, canvasOffset.x, canvasOffset.y);
	}
	
	override function onMouseUp(?e:MouseEvent)
	{
		super.onMouseUp(e);
		state = IDLE;
	}
	
	override function onMouseMove(?e:MouseEvent)
	{
		super.onMouseMove(e);
		
		switch state
		{
			case IDLE:
			case DRAG(startX, startY, offsetStartX, offsetStartY):
				canvasOffset.x = e.stageX - startX + offsetStartX;
				canvasOffset.y = e.stageY - startY + offsetStartY;
				drawCanvas();
		}
	}
	
	override function updateSize():Void
	{
		super.updateSize();
		// account for the footer
		_background.scaleY = _height - _header.height * 2;
	}
	
	override function resize(width:Float, height:Float):Void
	{
		super.resize(width, height);
		
		canvas.bitmapData = FlxDestroyUtil.dispose(canvas.bitmapData);
		
		final canvasWidth = Std.int(_width - canvas.x);
		final canvasHeight = Std.int(_height - canvas.y - footer.getHeight());
		
		if (canvasWidth > 0 && canvasHeight > 0)
		{
			canvas.bitmapData = new BitmapData(canvasWidth, canvasHeight, true, FlxColor.TRANSPARENT);
			drawCanvas();
		}
		
		buttonRemove.x = _width - buttonRemove.width - 3;
		
		header.resize(_width - 5);
		footer.y = _height - footer.getHeight();
		footer.resize(_width);
	}
	
	inline function resetSettings()
	{
		zoom = 1;
		canvasOffset.set();
	}
	
	function indexOf(bitmap:BitmapData)
	{
		for (i => entry in entries)
		{
			if (entry.bitmap == bitmap)
				return i;
		}
		return -1;
	}
	
	function entryOf(bitmap:BitmapData):Null<BitmapLogEntry>
	{
		for (entry in entries)
		{
			if (entry.bitmap == bitmap)
				return entry;
		}
		return null;
	}
	
	public function has(bitmap:BitmapData)
	{
		for (i => entry in entries)
		{
			if (entry.bitmap == bitmap)
				return true;
		}
		return false;
	}
	
	/**
	 * Add a BitmapData to the log
	 */
	public function add(bitmap:BitmapData, name:String = ""):Bool
	{
		if (bitmap == null)
			return false;
		
		setVisible(true);
		
		final entry = entryOf(bitmap);
		if (entry != null && entry.name == name)
			return true;
		
		entries.push({bitmap: bitmap, name: name});
		setIndex(index < 0 ? 0 : index);
		return true;
	}
	
	public function remove(bitmap:BitmapData)
	{
		final index = indexOf(bitmap);
		if (index != -1)
			clearAt(index);
	}
	
	function removeCurrent()
	{
		clearAt(index);
	}
	
	/**
	 * Clear one bitmap object from the log -- the last one, by default
	 */
	public function clearAt(index = -1):Void
	{
		if (index == -1)
			index = entries.length - 1;
		
		entries.splice(index, 1);
	
		if (index > entries.length - 1)
			setIndex(entries.length - 1);
		else
			drawCanvas();
	}
	
	public function clear():Void
	{
		entries.resize(0);
		drawCanvas();
	}
	
	function drawCanvas()
	{
		if (canvas.bitmapData == null)
		{
			// If the window is too small there is no canvas bitmap
			return;
		}
		
		final canvasBmd = canvas.bitmapData;
		
		if (index < 0)
		{
			// wiping transparent doesn't work for some reason
			canvasBmd.fillRect(canvasBmd.rect, FlxColor.WHITE);
			canvasBmd.fillRect(canvasBmd.rect, FlxColor.TRANSPARENT);
			return;
		}
		
		final bitmap = entries[index].bitmap;
		// find the window center
		final point = FlxPoint.get();
		point.x = (canvasBmd.width / 2) - (bitmap.width * zoom / 2);
		point.y = (canvasBmd.height / 2) - (bitmap.height * zoom / 2);
		
		point.add(canvasOffset);
		
		final matrix = new Matrix();
		matrix.identity();
		matrix.scale(zoom, zoom);
		matrix.translate(point.x, point.y);
		point.put();
		
		canvasBmd.fillRect(canvasBmd.rect, FlxColor.TRANSPARENT);
		canvasBmd.draw(bitmap, matrix, null, null, canvasBmd.rect, false);
		
		drawBoundingBox(bitmap);
		canvasBmd.draw(FlxSpriteUtil.flashGfxSprite, matrix, null, null, canvasBmd.rect, false);
		
		header.setText(index + 1, entries.length, bitmap.width, bitmap.height);
		footer.setText(entries[index]);
	}
	
	function setIndex(index:Int):Bool
	{
		this.index = validIndex(index);
		
		if (this.index < 0)
			header.clear();
		
		resetSettings();
		drawCanvas();
		return true;
	}
	
	function validIndex(index:Int)
	{
		if (entries.length == 0)
			return -1;
		
		if (index < 0)
			return entries.length - 1;
		
		if (index >= entries.length)
			return 0;
		
		return index;
	}
	
	function drawBoundingBox(bitmap:BitmapData):Void
	{
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();
		gfx.lineStyle(1, FlxColor.RED, 0.75, false, LineScaleMode.NONE);
		var offset = 1 / zoom;
		gfx.drawRect(-offset, -offset, bitmap.width + offset, bitmap.height + offset);
	}
}

typedef BitmapLogEntry =
{
	bitmap:BitmapData,
	name:String
}

class Header extends Sprite
{
	public final onReset = new FlxSignal();
	public final onPrev = new FlxSignal();
	public final onNext = new FlxSignal();
	
	final prev:FlxSystemButton;
	final reset:FlxSystemButton;
	final next:FlxSystemButton;
	final dimensions:TextField;
	final counter:TextField;
	
	public function new ()
	{
		super();
		prev = new FlxSystemButton(Icon.arrowLeft, onPrev.dispatch);
		addChild(prev);
		
		// allow clicking on the text to reset the current settings
		reset = new FlxSystemButton(null, onReset.dispatch);
		addChild(reset);
		counter = DebuggerUtil.createTextField(0, -3);
		counter.text = "0/0";
		counter.x = -1;
		reset.addChild(counter);
		
		next = new FlxSystemButton(Icon.arrowRight, onNext.dispatch);
		next.x = 60;
		addChild(next);
		
		dimensions = DebuggerUtil.createTextField(0, -3);
		addChild(dimensions);
	}
	
	public function clear()
	{
		setText(0, 0, 0, 0);
		dimensions.text = "";
	}
	
	public function setText(index:Int, total:Int, width:Int, height:Int)
	{
		counter.text = '$index/$total';
		dimensions.text = '$width x $height';
	}
	
	public function resize(width:Float)
	{
		next.x = width - next.width - 3;
		reset.x = next.x - reset.width - 3;
		prev.x = reset.x - prev.width - 3;
		dimensions.x = (width - dimensions.textWidth) / 2;
		dimensions.visible = width > 200;
	}
	
	// Note: get_height doesn't work in flash
	public function getHeight() return Window.HEADER_HEIGHT;
}

class Footer extends Sprite
{
	final bg = new Shape();
	final text = new TextField();
	
	public function new ()
	{
		super();
		bg.graphics.beginFill(Window.HEADER_COLOR);
		bg.graphics.drawRect(0, 0, 1, Window.HEADER_HEIGHT);
		bg.alpha = Window.HEADER_ALPHA;
		addChild(bg);
		
		text = DebuggerUtil.createTextField(0, -1);
		addChild(text);
	}
	
	public function setText(entry:BitmapLogEntry)
	{
		text.text = (entry.name == "") ? "" : '"${entry.name}" | '
			+ FlxStringUtil.formatBytes(entry.bitmap.getMemorySize());
		text.x = (bg.width - text.width) / 2;
	}
	
	public function resize(width:Float)
	{
		bg.width = width;
	}
	
	// Note: get_height doesn't work in flash
	public function getHeight() return Window.HEADER_HEIGHT;
}

private enum State
{
	IDLE;
	DRAG(startX:Float, startY:Float, offsetStartX:Float, offsetStartY:Float);
}
#end