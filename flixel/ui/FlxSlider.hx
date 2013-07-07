package flixel.ui;

#if !FLX_NO_MOUSE
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.plugin.photonstorm.FlxExtendedSprite;
import flixel.plugin.photonstorm.FlxMouseControl;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

/**
 * A slider GUI element for floats and integers. 
 * 
 * @author Gama11
 */
class FlxSlider extends FlxSpriteGroup
{
	/**
	 * The dragable area for the handle. Is configured automatically.
	 */
	private var bounds:FlxRect;
	/**
	 * The horizontal line in the background.
	 */
	public var backGround:FlxSprite;
	/**
	 * The dragable handle - loadGraphic() to change its graphic.
	 */
	public var handle:FlxExtendedSprite;
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
	 * The width of the slider.
	 */
	private var width:Int;
	/**
	 * The height of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var height:Int;
	/**
	 * The thickness of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var thickness:Int;
	/**
	 * The color of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var color:Int;
	/**
	 * The color of the handle - make sure to call createSlider() if you
	 * want to change this.
	 */
	private var handleColor:Int;
	
	/**
	 * Stores a reference to parent object.
	 */
	private var object:Dynamic;
	/**
	 * Stores the variable the slider controls.
	 */
	public var varString(default, set_varString):String;
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
	 * Helper variable to avoid the clickSound playing every frame.
	 */
	private var justClicked:Bool = false;
	/**
	 * Helper variable to avoid the hoverSound playing every frame.
	 */
	private var justHovered:Bool = false;
	/**
	 * Whether you can also click on the slider to change the value or not.
	 */
	public var clickable:Bool = true;
	/**
	 * The offset of the slider from x and y.
	 */
	private var offset:FlxPoint;
	/**
	 * Stores the Callback function.
	 */
	private var callbackFunction:Float->Void;
	/**
	 * Helper var for callbacks.
	 */
	private var lastPos:Float;
	/**
	 * The alpha value the slider uses when it's hovered over. 1 to turn the effect off.
	 */
	public var hoverAlpha:Float = 0.5;
	
	/**
	 * Creates a new <code>FlxSlider</code>.
	 *
	 * @param 	X				x Position
	 * @param 	Y 				y Position
	 * @param 	MinValue 		Mininum value the variable can be changed to
	 * @param 	MaxValue 		Maximum value the variable can be changed to
	 * @param 	Obj 			Reference to the parent object of the variable
	 * @param 	VarString 		Variable that the slider controls
	 * @param 	Width 			Width of the slider
	 * @param 	Height 			Height of the slider
	 * @param 	Thickness 		Thickness of the slider
	 * @param 	Color 			Color of the slider background and all texts except for valueText showing the current value
	 * @param 	HandleColor 	Color of the slider handle and the valueText showing the current value
	 */
	public function new(X:Float = 0, Y:Float = 0, MinValue:Float = 0, MaxValue:Float = 10, Object:Dynamic = null, VarString:String = null, Width:Int = 100, Height:Int = 15, Thickness:Int = 3, Color:Int = 0xFF000000, HandleColor:Int = 0xFF828282)
	{
		super();
		
		// Assign all those constructor vars
		minValue = MinValue;
		maxValue = MaxValue;
		object = Object;
		varString = VarString;
		width = Width;
		height = Height;
		thickness = Thickness;
		color = Color;
		handleColor = HandleColor;
		
		// Need the mouse control plugin for dragable sprites
		if (FlxG.plugins.get(FlxMouseControl) == null) 
			FlxG.plugins.add(new FlxMouseControl());
		
		if (varString == null) 
		{
			kill();
		}
		else
		{
			// Attempt to create the slider
			createSlider(X, Y);
		}
	}	

	/**
	 * Initially creates the slider with all its objects.
	 */
	private function createSlider(X:Float, Y:Float):Void
	{
		offset = new FlxPoint(5, 10); 
		bounds = new FlxRect(X + offset.x, Y + offset.y, width, height);
		
		// Creating the "body" of the slider
		backGround = new FlxSprite(offset.x, offset.y);
		backGround.makeGraphic(width, height, 0);
		FlxSpriteUtil.drawLine(backGround, 0, height / 2, width, height / 2, color, thickness); 
		
		handle = new FlxExtendedSprite(offset.x, offset.y);
		handle.makeGraphic(thickness, height, handleColor);
		handle.enableMouseDrag(false, false, 255, bounds);
		
		// Creating the texts
		nameLabel = new FlxText(0, -4, width, varString);
		nameLabel.alignment = "center";
		nameLabel.color = color;
		
		var textOffset:Int = height + 10;
		
		valueLabel = new FlxText(offset.x, textOffset, width);
		valueLabel.alignment = "center";
		valueLabel.color = handleColor;
		
		minLabel = new FlxText( -50 + offset.x, textOffset, 100, Std.string(minValue));
		minLabel.alignment = "center";
		minLabel.color = color;
		
		maxLabel = new FlxText(width - 50 + offset.x, textOffset, 100, Std.string(maxValue));
		maxLabel.alignment = "center";
		maxLabel.color = color;
		
		// Add all the objects
		add(backGround);
		add(handle);
		add(nameLabel);
		add(valueLabel);
		add(minLabel);
		add(maxLabel);
		
		// Position the objects
		x = X;
		y = Y;
	}

	override public function update():Void
	{
		// Clicking and sound logic
		if (FlxMath.mouseInFlxRect(true, bounds)) 
		{
			if (hoverAlpha != 1)
				alpha = hoverAlpha;
				
			if (hoverSound != null && !justHovered)
				FlxG.sound.play(hoverSound);
			justHovered = true;
			
			if (clickable && FlxG.mouse.pressed()) {
				handle.x = FlxG.mouse.x;
				updateValue();
				
				if (clickSound != null && !justClicked) {
					FlxG.sound.play(clickSound);
					justClicked = true;
				}
			}
			if (!FlxG.mouse.pressed())
				justClicked = false;
		}
		else {
			if (hoverAlpha != 1)
				alpha = 1;
				
			justHovered = false;
		}
		
		// Update the target value whenever the slider is being used
		if (handle.isDragged)
			updateValue();
			
		// Update the value variable
		if (varString != null && Reflect.getProperty(object, varString) != null)
			value = Reflect.getProperty(object, varString);
			
		// Changes to value from outside update the handle pos
		if (callbackFunction == null && handle.x != expectedPos) 
			handle.x = expectedPos;
			
		// Finally, update the valueLabel
		valueLabel.text = Std.string(FlxMath.roundDecimal(value, decimals));
		
		super.update();
	}
	
	/**
	 * Function that is called whenever the slider is used to either update the variable tracked or call the Callback function.
	 */
	private function updateValue():Void
	{
		if (callbackFunction == null) {
			if (varString != null)
				Reflect.setProperty(object, varString, relativePos * (maxValue - minValue) + minValue);
		}
		else if (lastPos != relativePos) {
			Reflect.callMethod(null, callbackFunction, [relativePos]);
			lastPos = relativePos;
		}
	}
	
	/**
	 * The expected position of the handle based on the current variable value.
	 */
	public var expectedPos(get, never):Float;
	
	private function get_expectedPos():Float 
	{ 
		var pos:Float = x + offset.x + ((width - handle.width) * ((value - minValue) / (maxValue - minValue)));
		if (pos > x + width + offset.x)
			pos = x + width + offset.x;
		else if (pos < x + offset.x)
			pos = x + offset.x; 
		
		return pos; 
	}
	
	/**
	 * The position of the handle relative to the slider / max value.
	 */
	public var relativePos(get, never):Float;
	
	private function get_relativePos():Float 
	{ 
		var pos:Float = (handle.x - x - offset.x) / (width - handle.width); 
		if (pos > 1) 
			pos = 1;
			
		return pos;
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
	public function setTexts(Name:String, Value:Bool = true, Min:String = null, Max:String = null, Size:Int = 8):Void
	{
		if (Name == null) 
			nameLabel.visible = false;
		else 
		{
			nameLabel.text = Name;
			nameLabel.visible = true;
		}
		
		if (Min == null) 
			minLabel.visible = false;
		else
		{
			minLabel.text = Min;
			minLabel.visible = true;
		}

		if (Max == null) 
			maxLabel.visible = false;
		else
		{
			maxLabel.text = Max;
			maxLabel.visible = true;
		}

		if (!Value) 
			valueLabel.visible = false;
		else 
			valueLabel.visible = true;
		
		nameLabel.size = Size;
		valueLabel.size = Size;
		minLabel.size = Size;
		maxLabel.size = Size;
	}
	
	/**
	 * Sets a callback function to call whenever the handle position is changed. Disables the automatic adjustments of the tracked variable.
	 * 
	 * @param	Callback	Function to call. Must have one Float param to receive the relative handle position.
	 */
	public function setCallback(Callback:Float->Void):Void
	{
		callbackFunction = Callback;
	}
	
	/**
	 * Cleaning up memory.
	 */
	override public function destroy():Void
	{
		FlxMouseControl.clear();
		
		handle = null;
		bounds = null;
		backGround = null;
		minLabel = null;
		maxLabel = null;
		nameLabel = null;
		valueLabel = null;
		offset = null;
		
		super.destroy();
	}
	
	private function set_varString(value:String):String
	{
		try 
		{
			var prop:Dynamic = Reflect.getProperty(object, value);
			varString = value;
		}
		catch (e:Dynamic) 
		{
			FlxG.log.error("Could not create FlxSlider -", "'" + value + "'" , "is not a valid field of", "'" + object + "'");
			varString = null;
		}
		
		return value;
	}
}
#end