package flixel.system;

#if !FLX_HAXE_BUILD
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.FlxBasePreloader;

@:bitmap("assets/images/preloader/light.png")
private class GraphicLogoLight extends BitmapData {}

@:bitmap("assets/images/preloader/corners.png")
private class GraphicLogoCorners extends BitmapData {}

/**
 * This is the Default HaxeFlixel Themed Preloader 
 * You can make your own style of Preloader by overriding FlxPreloaderBase and using this class as an example.
 * To use your Preloader, simply change Project.xml to say: <app preloader="class.path.MyPreloader" />
 */
class FlxPreloader extends FlxBasePreloader
{
	#if !js
	
	private static var BlendModeScreen = BlendMode.SCREEN;
	private static var BlendModeOverlay = BlendMode.OVERLAY;
	
	private var _buffer:Sprite;
	private var _bmpBar:Bitmap;
	private var _text:TextField;
	private var _logo:Sprite;
	private var _logoGlow:Sprite;
	
	/**
	 * Initialize your preloader here.
	 */
	override public function new(MinDisplayTime:Float = 0, ?AllowedURLs:Array<String>):Void
	{
		super(MinDisplayTime, AllowedURLs);
		
		// super(0, ["test.com", FlxPreloaderBase.LOCAL]); // example of site-locking
		
		// super(10); // example of long delay (10 seconds)
	}
	
	/**
	 * This class is called as soon as the FlxPreloaderBase has finished Initalizing.
	 * Override it to draw all your graphics and things - make sure you also override update
	 * Make sure you call super.create()
	 */
	override private function create():Void
	{
		_buffer = new Sprite();
		_buffer.scaleX = _buffer.scaleY = 2;
		addChild(_buffer);
		_width = Std.int(Lib.current.stage.stageWidth / _buffer.scaleX);
		_height = Std.int(Lib.current.stage.stageHeight / _buffer.scaleY);
		_buffer.addChild(new Bitmap(new BitmapData(_width, _height, false, 0x00345e)));
		var bitmap = new Bitmap(new GraphicLogoLight(0, 0));
		bitmap.smoothing = true;
		bitmap.width = bitmap.height = _height;
		bitmap.x = (_width - bitmap.width) / 2;
		_buffer.addChild(bitmap);
		_bmpBar = new Bitmap(new BitmapData(1, 7, false, 0x5f6aff));
		_bmpBar.x = 4;
		_bmpBar.y = _height - 11;
		_buffer.addChild(_bmpBar);
		
		_text = new TextField();
		_text.defaultTextFormat = new TextFormat("Nokia Cellphone FC Small", 8, 0x5f6aff);
		_text.embedFonts = true;
		_text.selectable = false;
		_text.multiline = false;
		_text.x = 2;
		_text.y = _bmpBar.y - 11;
		_text.width = 200;
		_buffer.addChild(_text);
		
		_logo = new Sprite();
		drawLogo(_logo.graphics);
		_logo.scaleX = _logo.scaleY = _height / 8 * 0.04;
		_logo.x = (_width - _logo.width) / 2;
		_logo.y = (_height - _logo.height) / 2;
		_buffer.addChild(_logo);
		_logoGlow = new Sprite();
		drawLogo(_logoGlow.graphics);
		_logoGlow.blendMode = BlendModeScreen;
		_logoGlow.scaleX = _logoGlow.scaleY = _height / 8 * 0.04;
		_logoGlow.x = (_width - _logoGlow.width) / 2;
		_logoGlow.y = (_height - _logoGlow.height) / 2;
		_buffer.addChild(_logoGlow);
		bitmap = new Bitmap(new GraphicLogoCorners(0, 0));
		bitmap.smoothing = true;
		bitmap.width = _width;
		bitmap.height = _height;
		_buffer.addChild(bitmap);
		bitmap = new Bitmap(new BitmapData(_width, _height, false, 0xffffff));
		var i:Int = 0;
		var j:Int = 0;
		while (i < _height)
		{
			j = 0;
			while (j < _width)
			{
				bitmap.bitmapData.setPixel(j++, i, 0);
			}
			i += 2;
		}
		bitmap.blendMode = BlendModeOverlay;
		bitmap.alpha = 0.25;
		_buffer.addChild(bitmap);
		
		super.create();
	}
	
	/**
	 * This function simply draws the HaxeFlixel logo.
	 * @param	graph
	 */
	private function drawLogo(graph:Graphics):Void
	{
		// draw green area
		graph.beginFill(0x00b922);
		graph.moveTo(50, 13);
		graph.lineTo(51, 13);
		graph.lineTo(87, 50);
		graph.lineTo(87, 51);
		graph.lineTo(51, 87);
		graph.lineTo(50, 87);
		graph.lineTo(13, 51);
		graph.lineTo(13, 50);
		graph.lineTo(50, 13);
		graph.endFill();
		
		// draw yellow area
		graph.beginFill(0xffc132);
		graph.moveTo(0, 0);
		graph.lineTo(25, 0);
		graph.lineTo(50, 13);
		graph.lineTo(13, 50);
		graph.lineTo(0, 25);
		graph.lineTo(0, 0);
		graph.endFill();
		
		// draw red area
		graph.beginFill(0xf5274e);
		graph.moveTo(100, 0);
		graph.lineTo(75, 0);
		graph.lineTo(51, 13);
		graph.lineTo(87, 50);
		graph.lineTo(100, 25);
		graph.lineTo(100, 0);
		graph.endFill();
		
		// draw blue area
		graph.beginFill(0x3641ff);
		graph.moveTo(0, 100);
		graph.lineTo(25, 100);
		graph.lineTo(50, 87);
		graph.lineTo(13, 51);
		graph.lineTo(0, 75);
		graph.lineTo(0, 100);
		graph.endFill();
		
		// draw light-blue area
		graph.beginFill(0x04cdfb);
		graph.moveTo(100, 100);
		graph.lineTo(75, 100);
		graph.lineTo(51, 87);
		graph.lineTo(87, 51);
		graph.lineTo(100, 75);
		graph.lineTo(100, 100);
		graph.endFill();
	}
	
	/**
	 * Cleanup your objects!
	 * Make sure you call super.destroy()!
	 */
	override private function destroy():Void
	{
		if (_buffer != null)	
		{
			removeChild(_buffer);
		}
		_buffer = null;
		_bmpBar = null;
		_text = null;
		_logo = null;
		_logoGlow = null;
		super.destroy();
	}
	
	/**
	 * Update is called every frame, passing the current percent loaded. Use this to change your loading bar or whatever.
	 * @param	Percent	The percentage that the project is loaded
	 */
	override public function update(Percent:Float):Void
	{
		_bmpBar.scaleX = Percent * (_width - 8);
		_text.text = Std.string(FlxG.VERSION) + " " + Std.int(Percent * 100) + "%";
		
		if (Percent < 0.1)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = 0;
		}
		else if (Percent < 0.15)
		{
			_logoGlow.alpha = Math.random();
			_logo.alpha = 0;
		}
		else if (Percent < 0.2)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = 0;
		}
		else if (Percent < 0.25)
		{
			_logoGlow.alpha = 0;
			_logo.alpha = Math.random();
		}
		else if (Percent < 0.7)
		{
			_logoGlow.alpha = (Percent - 0.45) / 0.45;
			_logo.alpha = 1;
		}
		else if ((Percent > 0.8) && (Percent < 0.9))
		{
			_logoGlow.alpha = 1 - (Percent - 0.8) / 0.1;
			_logo.alpha = 0;
		}
		else if (Percent > 0.9)
		{
			_buffer.alpha = 1 - (Percent - 0.9) / 0.1;
		}
	}
	#end
}
#end