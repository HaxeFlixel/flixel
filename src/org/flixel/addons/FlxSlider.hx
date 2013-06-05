package org.flixel.addons;

#if !FLX_NO_MOUSE
import org.flixel.addons.FlxSpriteGroup;
import org.flixel.FlxG;
import org.flixel.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.FlxText;
import org.flixel.plugin.photonstorm.FlxExtendedSprite;
import org.flixel.plugin.photonstorm.FlxMouseControl;

/**
 * ...
 * @author Gama11
 */
class FlxSlider extends FlxSpriteGroup
{
	/**
	 * The dragable handle - loadGraphic() to change its graphic.
	 */
	public var handle:FlxExtendedSprite;
	/**
	 * The dragable area for the handle. Is configured automatically.
	 */
	private var bounds:FlxRect;
	/**
	 * The horizontal line in the background.
	 */
	public var line:FlxSprite;
	/**
	 * The left border sprite.
	 */
	public var leftBorder:FlxSprite;
	/**
	 * The right border sprite.
	 */
	public var rightBorder:FlxSprite;
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
	public var currentLabel:FlxText;

	/**
	 * The width of the slider.
	 */
	public var width:Int = 100;
	/**
	 * The height of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	public var height:Int = 8;
	/**
	 * The thickness of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	public var thickness:Int = 2;
	/**
	 * The color of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	public var color:Int = 0xFF000000;
	/**
	 * The color of the handle - make sure to call createSlider() if you
	 * want to change this.
	 */
	public var handleColor:Int = 0xFF828282;
	/**
	 * Current x pos.
	 */
	public var xCoord:Int = 0;
	/**
	 * Current y pos.
	 */
	public var yCoord:Int = 0;
	/**
	 * Stores a reference to parent object.
	 */
	private var obj:Dynamic;
	/**
	 * (Optional) Function to be called when slider was dragged / value changed.
	 * Two parameters are passed:
	 * The value the var is supossed to have (Number) and
	 * The currentLabel (FlxText) - needs to be updated manually in that case.
	 */
	public var callback:Float->FlxText->Void;
	/**
	 * Stores the variable the slider controls.
	 */
	public var varString:String;
	/**
	 * Stores the value of the variable - updated each frame.
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
	 * The handle's position relative to the slider's width.
	 */
	public var relHandlePos:Float;
	/**
	 * How many decimals the variable can have at max. Default is zero,
	 * or "only whole numbers".
	 */
	public var decimals:Int = 0;
	/**
	 * Whether this class should handle the changes to the specified var
	 * or if you wanna do that yourself / not at all. Automatically set to
	 * false if you specify a Callback function.
	 */
	public var overwriting:Bool = true;
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
	 * Creates a new <code>FlxSlider</code>.
	 *
	 * @param X X Position
	 * @param Y Y Position
	 * @param MinValue Mininum value the variable can be changed to.
	 * @param MaxValue Maximum value the variable can be changed to.
	 * @param Callback Function to be called when slider was dragged / value changed.
	 * @param VarString Variable that the slider controls - NEEDS TO BE PUBLIC! Not needed if Callback is used.
	 * @param Obj Reference to the object the variable belongs to. Not needed if Callback is used.
	 * @param Width Width of the slider.
	 */
	public function new(X:Int = 0, Y:Int = 0, MinValue:Float = 0, MaxValue:Float = 10, Callback:Float->FlxText->Void = null, VarString:String = null, Obj:Dynamic = null, Width:Int = 100)
	{
		super();
		// Assign all those constructor vars
		xCoord = X;
		yCoord = Y;
		minValue = MinValue;
		maxValue = MaxValue;
		varString = VarString;
		obj = Obj;
		width = Width;
		callback = Callback;
		
		if (Callback != null) 
			overwriting = false;
		
		var prop:Dynamic = Reflect.getProperty(Obj, VarString);
		
		if (Obj != null && VarString != null && prop != null && prop != Math.round(prop)) 
		{
			decimals = 2;
		}
		else
		{
			decimals = 0;
		}

		// Create the slider
		createSlider();
	}	

	/**
	 * Initially creates the slider with all its objects. Can also be
	 * called to redraw the thing if certain vars are changed manually later.
	 */
	public function createSlider():Void
	{
		// Need that to make use of the FlxPowerTools' dragable sprite feature
		if (FlxG.getPlugin(FlxMouseControl) == null) 
			FlxG.addPlugin(new FlxMouseControl());

		// Creating the "body" of the slider
		line = new FlxSprite(0, 0);
		line.makeGraphic(width + thickness * 3, thickness, color);

		var yPos:Int = Math.floor(0.5 * (thickness - height));
		leftBorder = new FlxSprite(0 - thickness, yPos);
		leftBorder.makeGraphic(thickness, height, color);
		rightBorder = new FlxSprite(width + thickness * 2, yPos);
		rightBorder.makeGraphic(thickness, height, color);

		// Creating the texts
		var textOffset:Int = 3;

		minLabel = new FlxText(2 - thickness * 2, (height / 2) + textOffset, 100, Std.string(minValue));
		minLabel.setFormat(null, 12, FlxG.BLACK, "left");
		maxLabel = new FlxText(width, (height / 2) + textOffset, 100, Std.string(maxValue));
		maxLabel.setFormat(null, 12, FlxG.BLACK, "left");

		nameLabel = new FlxText(0, - height * 3, width, varString);
		nameLabel.setFormat(null, 16, FlxG.BLACK, "center");

		currentLabel = new FlxText(0, (height / 2) + textOffset, width, "");
		currentLabel.setFormat(null, 12, handleColor, "center");
		
		if (obj != null && varString != null) 
		{
			value = Reflect.getProperty(obj, varString);
			currentLabel.text = Std.string(value);
		}
		else 
		{
			value = minValue;
			currentLabel.text = Std.string(minValue);
		}
		
		bounds = new FlxRect(xCoord, 0, width + thickness * 2, FlxG.height);

		handle = new FlxExtendedSprite(0, yPos);
		handle.makeGraphic(thickness * 2, height, handleColor);
		handle.enableMouseDrag(false, false, 255, bounds);
		handle.setDragLock(true, false);

		if (obj != null && varString != null) 
			handle.x = ((value - minValue) / (maxValue - minValue)) * width;
		
		// Add all the objects
		add(line);
		add(leftBorder);
		add(rightBorder);
		add(minLabel);
		add(maxLabel);
		add(nameLabel);
		add(currentLabel);
		add(handle);

		// Position the objects
		x = xCoord;
		y = yCoord;

		// Fire Callback just once so that a text for currentLabel can be set
		relHandlePos = (handle.x - xCoord) / width;
		if (callback != null) 
			callback(round(minValue + relHandlePos * (maxValue - minValue)), currentLabel);
	}

	override public function update():Void
	{
		// Update the var that stores the handle position relative to the slider's width
		relHandlePos = (handle.x - xCoord) / width;
		
		// Update the variable's value
		if (obj != null && varString != null && callback == null) 
		{
			currentLabel.text = Std.string(round(Reflect.getProperty(obj, varString)));
		}
		else
		{
			currentLabel.text = Std.string(round(minValue + relHandlePos * (maxValue - minValue)));
		}
		
		var tempValue:Float = minValue + relHandlePos * (maxValue - minValue);
		
		// ...and change the variable's value if the handle has been dragged
		if (value != tempValue) 
		{
			if (obj != null && varString != null && overwriting) 
				Reflect.setProperty(obj, varString, round(tempValue));
			
			if (callback != null) 
				callback(round(tempValue), currentLabel);

			value = tempValue;
		}

		// Make it possible to click anywhere on the slider

		var xM:Int = Math.floor(FlxG.mouse.x);
		var yM:Int = Math.floor(FlxG.mouse.y);

		if (xM >= xCoord && xM <= xCoord + width && yM >= (yCoord) && yM <= (yCoord + height * 2) && visible) 
		{
			if (FlxG.mouse.pressed()) 
			{
				handle.x = FlxG.mouse.x;
				if (!justClicked && clickSound != null) 
				{
					FlxG.play(clickSound);
					justClicked = true;
				}
			}
			else 
			{
				justClicked = false;
			}
			
			alpha = 0.5;
			if (!justHovered && hoverSound != null) 
				FlxG.play(hoverSound);
			
			justHovered = true;
		}
		else if (visible) 
		{
			alpha = 1;
			justHovered = false;
		}

		super.update();
	}

	/**
	 * Handy function for changing the textfields.
	 *
	 * @param Name Name of the slider - "" to hide
	 * @param Current Whether to show the current value or not
	 * @param Left Label for the left border text - "" to hide
	 * @param Right Label for the right border text - "" to hide
	 */
	public function setTexts(Name:String, Current:Bool = true, Left:String = null, Right:String = null):Void
	{
		if (Left == "") 
		{
			minLabel.visible = false;
		}
		else if (Left != null) 
		{
			minLabel.text = Left;
			minLabel.visible = true;
		}

		if (Right == "") 
		{
			maxLabel.visible = false;
		}
		else if (Right != null) 
		{
			maxLabel.text = Right;
			maxLabel.visible = true;
		}

		if (Name == "") 
		{
			nameLabel.visible = false;
		}
		else if (Name != null) 
		{
			nameLabel.text = Name;
			nameLabel.visible = true;
		}

		if (!Current) 
		{
			currentLabel.visible = false;
		}
		else 
		{
			currentLabel.visible = true;
		}
	}

	/**
	 * Handy function to round a number to set amount of decimals.
	 *
	 * @param n Number to round
	 */
	private function round(n:Float):Float
	{
		decimals = Std.int(Math.abs(decimals));
		return Std.int((n) * Math.pow(10, decimals)) / Math.pow(10, decimals);
	}

	/**
	 * Need that to make use of the FlxPowerTools' dragable sprite feature as well.
	 */
	override public function destroy():Void
	{
		// Important! Clear out the plugin otherwise resources will get messed right up after a while
		FlxMouseControl.clear();
		super.destroy();
	}
}
#end