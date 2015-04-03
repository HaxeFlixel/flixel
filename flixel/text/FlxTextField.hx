package flixel.text;

import flash.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * Extends FlxText for better support rendering text on cpp target.
 * Doesn't have multicamera support.
 * Displays over all other objects.
 */
class FlxTextField extends FlxText
{
	private var _camera:FlxCamera;
	private var _addedToDisplay:Bool = false;
	
	/**
	 * Creates a new FlxText object at the specified position.
	 * @param	X				The X position of the text.
	 * @param	Y				The Y position of the text.
	 * @param	Width			The width of the text object (height is determined automatically).
	 * @param	Text			The actual text you would like to display initially.
	 * @param	EmbeddedFont	Whether this text field uses embedded fonts or not
	 * @param	Camera			Camera to display. FlxG.camera is used by default (if you pass null)
	 */
	public function new(X:Float, Y:Float, Width:Int, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true, ?Camera:FlxCamera)
	{
		super(X, Y, Width, Text, Size, EmbeddedFont);
		
		height = (Text == null || Text.length <= 0) ? 1 : textField.textHeight + 4;
		
		textField.multiline = false;
		textField.wordWrap = false;
		
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		_camera = Camera;
		dirty = false;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if (textField.parent != null)
		{
			textField.parent.removeChild(textField);
		}
		
		_camera = null;
		super.destroy();
	}
	
	override public function stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void 
	{
		// This class doesn't support this operation
	}
	
	override public function pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
	{
		// This class doesn't support this operation
		return false;
	}
	
	override public function isSimpleRender(?camera:FlxCamera):Bool
	{
		// This class doesn't support this operation
		return true;
	}
	
	override private function get_pixels():BitmapData
	{
		calcFrame(true);
		return graphic.bitmap;
	}
	
	override private function set_pixels(Pixels:BitmapData):BitmapData
	{
		// This class doesn't support this operation
		return Pixels;
	}
	
	override private function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		textField.alpha = alpha;
		
		return Alpha;
	}
	
	override private function set_height(Height:Float):Float
	{
		Height = super.set_height(Height);
		if (textField != null)	textField.height = Height;
		return Height;
	}
	
	override private function set_visible(Value:Bool):Bool
	{
		textField.visible = Value;
		return super.set_visible(Value);
	}
	
	override public function kill():Void 
	{
		visible = false;
		super.kill();
	}
	
	override public function revive():Void 
	{
		visible = true;
		super.revive();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		if (_camera == null)	
		{
			return;
		}
		
		if (!_addedToDisplay)
		{
			#if FLX_RENDER_TILE
			_camera.canvas.addChild(textField);
			#else
			_camera.flashSprite.addChild(textField);
			#end
			
			_addedToDisplay = true;
			updateDefaultFormat();
		}
		
		if (!_camera.visible || !_camera.exists || !isOnScreen(_camera))
		{
			textField.visible = false;
		}
		else
		{
			textField.visible = true;
		}
		
		_point.x = x - (_camera.scroll.x * scrollFactor.x) - (offset.x);
		_point.y = y - (_camera.scroll.y * scrollFactor.y) - (offset.y);
		
		#if FLX_RENDER_TILE
		textField.x = _point.x;
		textField.y = _point.y;
		#else
		textField.x = (_point.x - 0.5 * _camera.width);
		textField.y = (_point.y - 0.5 * _camera.height);
		#end
		
		#if !FLX_NO_DEBUG
		FlxBasic.visibleCount++;
		#end
	}
	
	override private function get_camera():FlxCamera 
	{
		return _camera;
	}
	
	override private function set_camera(Value:FlxCamera):FlxCamera 
	{
		if (_camera != Value)
		{
			if (Value != null)
			{
				#if FLX_RENDER_TILE
				Value.canvas.addChild(textField);
				#else
				Value.flashSprite.addChild(textField);
				#end
				
				_addedToDisplay = true;
			}
			else
			{
				if (_camera != null)
				{
					textField.parent.removeChild(textField);
				}
				
				_addedToDisplay = false;
			}
			
			_camera = Value;
		}
		return Value;
	}
}