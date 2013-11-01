package flixel.ui;

#if !FLX_NO_MOUSE
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

/**
 * A slider GUI element for float and integer manipulation. 
 * @author Gama11
 */
class FlxSlider extends FlxSpriteGroup
{
	/**
	 * The horizontal line in the background.
	 */
	public var body:FlxSprite;
	/**
	 * The dragable handle - loadGraphic() to change its graphic.
	 */
	public var handle:FlxSprite;
	/**
	 * The text under the left border - equals minValue by default.
	 */
	public var minLabel:FlxText;
	/**
	 * The text under the right border - equals maxValue by default.
	 */
	public var maxLabel:FlxText;
	/**
	 * A text above the slider that displays its name.
	 */
	public var nameLabel:FlxText;
	/**
	 * A text under the slider that displays the current value.
	 */
	public var valueLabel:FlxText;
	/**
	 * Stores the current value of the variable - updated each frame.
	 */
	public var value:Float;
	/**
	 * Mininum value the variable can be changed to.
	 */
	public var minValue:Float;
	/**
	 * Maximum value the variable can be changed to.
	 */
	public var maxValue:Float;
	/**
	 * How many decimals the variable can have at max. Default is zero,
	 * or "only whole numbers".
	 */
	public var decimals:Int = 0;
	/**
	 * Sound that's played whenever the slider is clicked.
	 */
	public var clickSound:String;
	/**
	 * Sound that's played whenever the slider is hovered over.
	 */
	public var hoverSound:String;
	/**
	 * The alpha value the slider uses when it's hovered over. 1 to turn the effect off.
	 */
	public var hoverAlpha:Float = 0.5;
	/**
	 * A function to be called when the slider was used. 
	 * The current <code>relativePos</code> is passed as an argument.
	 */
	public var callback:Float->Void = null;

	/**
	 * The dragable area for the handle. Is configured automatically.
	 */
	private var _bounds:FlxRect;
	/**
	 * The width of the slider.
	 */
	private var _width:Int;
	/**
	 * The height of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var _height:Int;
	/**
	 * The thickness of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var _thickness:Int;
	/**
	 * The color of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var _color:Int;
	/**
	 * The color of the handle - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var _handleColor:Int;
	/**
	 * Stores a reference to parent object.
	 */
	private var _object:Dynamic;
	/**
	 * Helper var for callbacks.
	 */
	private var _lastPos:Float;
	/**
	 * Helper variable to avoid the clickSound playing every frame.
	 */
	private var _justClicked:Bool = false;
	/**
	 * Helper variable to avoid the hoverSound playing every frame.
	 */
	private var _justHovered:Bool = false;
	
	/**
	 * Creates a new <code>FlxSlider</code>.
	 *
	 * @param	Object 			Reference to the parent object of the variable
	 * @param	VarString 		Variable that the slider controls
	 * @param	X				x Position
	 * @param	Y 				y Position
	 * @param	MinValue 		Mininum value the variable can be changed to
	 * @param	MaxValue 		Maximum value the variable can be changed to
	 * @param	Width 			Width of the slider
	 * @param	Height 			Height of the slider
	 * @param	Thickness 		Thickness of the slider
	 * @param	Color 			Color of the slider background and all texts except for valueText showing the current value
	 * @param	HandleColor 	Color of the slider handle and the valueText showing the current value
	 */
	public function new(Object:Dynamic, VarString:String, X:Float = 0, Y:Float = 0, MinValue:Float = 0, MaxValue:Float = 10, Width:Int = 100, Height:Int = 15, Thickness:Int = 3, Color:Int = 0xFF000000, HandleColor:Int = 0xFF828282)
	{
		super();
		
		x = X; 
		y = Y;
		
		if (MinValue == MaxValue)
		{
			FlxG.log.error("FlxSlider: MinValue and MaxValue can't be the same (" + MinValue + ")");
		}
		
		// Determine the amount of decimals to show
		decimals = FlxMath.getDecimals(MinValue);
		
		if (FlxMath.getDecimals(MaxValue) > decimals)
		{
			decimals = FlxMath.getDecimals(MaxValue);
		}
		
		decimals ++;
		
		// Assign all those constructor vars
		minValue = MinValue;
		maxValue = MaxValue;
		_object = Object;
		varString = VarString;
		_width = Width;
		_height = Height;
		_thickness = Thickness;
		_color = Color;
		_handleColor = HandleColor;
		
		// Create the slider
		createSlider();
	}	

	/**
	 * Initially creates the slider with all its objects.
	 */
	private function createSlider():Void
	{
		_offset = new FlxPoint(7, 18); 
		_bounds = new FlxRect(x + _offset.x, y +_offset.y, _width, _height);
		
		// Creating the "body" of the slider
		body = new FlxSprite(_offset.x, _offset.y);
		body.makeGraphic(_width, _height, 0);
		body.scrollFactor.set();
		FlxSpriteUtil.drawLine(body, 0, _height / 2, _width, _height / 2, _color, _thickness); 
		
		handle = new FlxSprite(_offset.x, _offset.y);
		handle.makeGraphic(_thickness, _height, _handleColor);
		handle.scrollFactor.set();
		
		// Creating the texts
		nameLabel = new FlxText(_offset.x, 0, _width, varString);
		nameLabel.alignment = "center";
		nameLabel.color = _color;
		nameLabel.scrollFactor.set();
		
		var textOffset:Float = _height + _offset.y + 3;
		
		valueLabel = new FlxText(_offset.x, textOffset, _width);
		valueLabel.alignment = "center";
		valueLabel.color = _handleColor;
		valueLabel.scrollFactor.set();
		
		minLabel = new FlxText( -50 + _offset.x, textOffset, 100, Std.string(minValue));
		minLabel.alignment = "center";
		minLabel.color = _color;
		minLabel.scrollFactor.set();
		
		maxLabel = new FlxText(_width - 50 + _offset.x, textOffset, 100, Std.string(maxValue));
		maxLabel.alignment = "center";
		maxLabel.color = _color;
		maxLabel.scrollFactor.set();
		
		// Add all the objects
		add(body);
		add(handle);
		add(nameLabel);
		add(valueLabel);
		add(minLabel);
		add(maxLabel);
	}

	override public function update():Void
	{
		// Clicking and sound logic
		if (FlxMath.mouseInFlxRect(false, _bounds)) 
		{
			if (hoverAlpha != 1)
			{
				alpha = hoverAlpha;
			}
			
			if (hoverSound != null && !_justHovered)
			{
				FlxG.sound.play(hoverSound);
			}
			
			_justHovered = true;
			
			if (FlxG.mouse.pressed) 
			{
				handle.x = FlxG.mouse.screenX;
				updateValue();
				
				if (clickSound != null && !_justClicked) 
				{
					FlxG.sound.play(clickSound);
					_justClicked = true;
				}
			}
			if (!FlxG.mouse.pressed)
			{
				_justClicked = false;
			}
		}
		else 
		{
			if (hoverAlpha != 1)
			{
				alpha = 1;
			}
				
			_justHovered = false;
		}
		
		// Update the target value whenever the slider is being used
		if (FlxG.mouse.pressed && FlxMath.mouseInFlxRect(false, _bounds))
		{
			updateValue();
		}
			
		// Update the value variable
		if (varString != null && Reflect.getProperty(_object, varString) != null)
		{
			value = Reflect.getProperty(_object, varString);
		}
			
		// Changes to value from outside update the handle pos
		if (callback == null && handle.x != expectedPos) 
		{
			handle.x = expectedPos;
		}
			
		// Finally, update the valueLabel
		valueLabel.text = Std.string(FlxMath.roundDecimal(value, decimals));
		
		super.update();
	}
	
	/**
	 * Function that is called whenever the slider is used to either update the variable tracked or call the Callback function.
	 */
	private function updateValue():Void
	{
		if (callback == null) 
		{
			if (varString != null)
			{
				Reflect.setProperty(_object, varString, relativePos * (maxValue - minValue) + minValue);
			}
		}
		else if (_lastPos != relativePos) 
		{
			callback(relativePos);
			_lastPos = relativePos;
		}
	}
	
	/**
	 * Handy function for changing the textfields.
	 *
	 * @param 	Name 		Text of nameLabel - null to hide
	 * @param 	Value	 	Whether to show the valueText or not
	 * @param 	Min 		Text of minLabel - null to hide
	 * @param 	Max 		Text of maxLabel - null to hide
	 * @param 	Size 		Size to use for the texts
	 */
	public function setTexts(Name:String, Value:Bool = true, ?Min:String, ?Max:String, Size:Int = 8):Void
	{
		if (Name == null) 
		{
			nameLabel.visible = false;
		}
		else 
		{
			nameLabel.text = Name;
			nameLabel.visible = true;
		}
		
		if (Min == null) 
		{
			minLabel.visible = false;
		}
		else
		{
			minLabel.text = Min;
			minLabel.visible = true;
		}

		if (Max == null) 
		{
			maxLabel.visible = false;
		}
		else
		{
			maxLabel.text = Max;
			maxLabel.visible = true;
		}

		if (!Value) 
		{
			valueLabel.visible = false;
		}
		else 
		{
			valueLabel.visible = true;
		}
		
		nameLabel.size = Size;
		valueLabel.size = Size;
		minLabel.size = Size;
		maxLabel.size = Size;
	}
	
	/**
	 * Cleaning up memory.
	 */
	override public function destroy():Void
	{
		handle = null;
		body = null;
		minLabel = null;
		maxLabel = null;
		nameLabel = null;
		valueLabel = null;
		
		_bounds = null;
		_offset = null;
		
		super.destroy();
	}
	
	/**
	 * The expected position of the handle based on the current variable value.
	 */
	public var expectedPos(get, never):Float;
	
	private function get_expectedPos():Float 
	{ 
		var pos:Float = x + _offset.x + ((_width - handle.width) * ((value - minValue) / (maxValue - minValue)));
		
		// Make sure the pos stays within the bounds
		if (pos > x + _width + _offset.x)
		{
			pos = x + _width + _offset.x;
		}
		else if (pos < x + _offset.x)
		{
			pos = x + _offset.x; 
		}
		
		return pos; 
	}
	
	/**
	 * The position of the handle relative to the slider / max value.
	 */
	public var relativePos(get, never):Float;
	
	private function get_relativePos():Float 
	{ 
		var pos:Float = (handle.x - x - _offset.x) / (_width - handle.width); 
		
		// Relative position can't be bigger than 1
		if (pos > 1) 
		{
			pos = 1;
		}
		
		return pos;
	}
	
	/**
	 * Stores the variable the slider controls.
	 */
	public var varString(default, set):String;
	
	private function set_varString(Value:String):String
	{
		try 
		{
			var prop:Dynamic = Reflect.getProperty(_object, Value);
			varString = Value;
		}
		catch (e:Dynamic) 
		{
			FlxG.log.error("Could not create FlxSlider -", "'" + Value + "'" , "is not a valid field of", "'" + _object + "'");
			varString = null;
		}
		
		return Value;
	}
}
#end