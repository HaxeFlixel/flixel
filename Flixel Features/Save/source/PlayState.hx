package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSave;

class PlayState extends FlxState
{
	private static inline var NUM_BOXES:Int = 20;
	
	// Here's the FlxSave variable this is what we're going to be saving to.
	private var _gameSave:FlxSave;
	
	// We're just going to drop a bunch of boxes into a group
	private var _boxGroup:FlxTypedGroup<FlxButton>;
	
	// We'll use these variables for the dragging
	private var dragOffset:FlxPoint;
	private var _dragging:Bool = false;
	private var _dragTarget:FlxObject;
	
	// Buttons for the demo
	private var _saveButton:FlxButton;
	private var _loadButton:FlxButton;
	private var _clearButton:FlxButton;
	
	// The top text that yells at you
	private var _topText:FlxText;
	
	override public function create():Void
	{
		// So here's the core of this demo - the FlxSave you have to instantiate a new one before you can use it
		_gameSave = new FlxSave();
		// And then you have to bind it to the save data, you can use different bind strings in different parts of your game
		// you MUST bind the save before it can be used.
		_gameSave.bind("SaveDemo");
		
		//Since we need the text before the usual end of the demo we'll initialize it up here.
		_topText = new FlxText(0, 2, FlxG.width, "Welcome!");
		_topText.alignment = 'center';
		
		//This just makes some dim text with instructions
		var dragText:FlxText = new FlxText(5, FlxG.height / 2 - 20, FlxG.width, "Click to Drag");
		dragText.color = FlxColor.WHITE;
		dragText.alpha = 0.2;
		dragText.size = 50;
		add(dragText);
		
		//Set out offset to non-null here
		dragOffset = FlxPoint.get(0, 0);
		
		//Make a group to place the boxes in
		_boxGroup = new FlxTypedGroup<FlxButton>();
		
		//And let's make some boxes!
		for (i in 0...NUM_BOXES) 
		{
			var box:FlxButton;
			//If we already have some save data to work with, then let's go ahead and put it to use
			if (_gameSave.data.boxPositions != null)
			{
				box = new FlxButton(_gameSave.data.boxPositions[i].x, _gameSave.data.boxPositions[i].y, Std.string(i + 1));
				//I'm using a FlxButton in this instance because I can use if(button.state == FlxButton.PRESSED) 
				//to detect if the mouse is held down on a button
				_topText.text = "Loaded positions";
			}
			//If not, oh well we'll just put them in the default locations
			else
			{
				box = new FlxButton((i * 35) + 9, 50, Std.string(i + 1));
				
				if (i * 35 > 360)
				{
					box.setPosition((i * 35 -2) - 339, 85);
				}
				
				_topText.text = "No save found, using default positions";
			}
			
			// Make a graphic for our button, instead of using the default
			box.makeGraphic(32, 32, FlxColor.GRAY); 
			// And add it to the group
			_boxGroup.add(box); 
		}
		add(_boxGroup);//Add the group to the state
		
		// Get out buttons set up along the bottom of the screen
		var buttonY:Int = FlxG.height - 22;
		
		_saveButton = new FlxButton(2, buttonY, "Save Locations", onSave);
		add(_saveButton);
		_loadButton = new FlxButton(82, buttonY, "Load Locations", onLoad);
		add(_loadButton);
		_clearButton = new FlxButton(202, buttonY, "Clear Save", onClear);
		add(_clearButton);
		
		// Let's not forget about our old text, which needs to be above everything else
		add(_topText);
	}
	
	override public function update():Void
	{
		// This is just to make the text at the top fade out
		if (_topText.alpha > 0) 
		{
			_topText.alpha -= .005;
		}
		
		super.update();
		
		// If you've clicked, lets see if you clicked on a button
		// Note something like this needs to be after super.update() that way the button's state has updated to reflect the mouse event
		if (FlxG.mouse.justPressed) 
		{
			for (box in _boxGroup) 
			{
				if (box.status == FlxButton.PRESSED) 
				{
					// The offset is used to make the box stick to the cursor and not snap to the corner
					dragOffset.set(box.x - FlxG.mouse.x, box.y - FlxG.mouse.y);
					_dragging = true;
					_dragTarget = box;
				}
			}
		}
		
		// If you let go, then release that box!
		if (FlxG.mouse.justReleased) 
		{
			_dragTarget = null;
			_dragging = false;
		}
		
		// And lets move the box around
		if (_dragging) 
		{
			_dragTarget.setPosition(FlxG.mouse.x + dragOffset.x, FlxG.mouse.y + dragOffset.y);
		}
	}
	
	/**
	 * Called when the user clicks the 'Save Locations' button
	 */
	private function onSave():Void 
	{
		// Do we already have a save? if not then we need to make one
		if (_gameSave.data.boxPositions == null) 
		{
			// Let's make a new array at the location data/
			// don't worry, if its not there - then flash will make a new variable there
			// You can also do something like gameSave.data.randomBool = true;
			// and if randomBool didn't exist before, then flash will create a boolean there.
			// though it's best to make a new type() before setting it, so you know the correct type is kept
			_gameSave.data.boxPositions = new Array();
			
			for (box in _boxGroup) 
			{
				_gameSave.data.boxPositions.push(FlxPoint.get(box.x, box.y));
			}
			
			_topText.text = "Created a new save, and saved positions";
			_topText.alpha = 1;
		}
		else 
		{
			// So we already have some save data? lets overwrite the data WITHOUT ASKING! oooh so bad :P
			// Now we're not doing a real for-loop here, because i REALLY like for each, so we'll need our own index count
			var tempCount:Int = 0;
			
			// For each button in the group boxGroup - I'm sure you see why I like this already
			for (box in _boxGroup) 
			{
				_gameSave.data.boxPositions[tempCount] = FlxPoint.get(box.x, box.y);
				tempCount++;
			}
			
			_topText.text = "Overwrote old positions";
			_topText.alpha = 1;
		}
		_gameSave.flush();
	}
	
	/**
	 * Called when the user clicks the 'Load Locations' button 
	 */
	private function onLoad():Void 
	{
		// Loading what? Theres no save data!
		if (_gameSave.data.boxPositions == null)
		{
			_topText.text = "Failed to load - There's no save";
			_topText.alpha = 1;
		}
		else 
		{
			// Note that above I saved the positions as an array of FlxPoints, When the SWF is closed and re-opened the Types in the
			// array lose their type, and for some reason cannot be re-cast as a FlxPoint. They become regular Flash Objects with the correct
			// variables though, so you're safe to use them - just your IDE won't highlight recognize and highlight the variables
			var tempCount:Int = 0;
			
			for (box in _boxGroup) 
			{
				box.x = _gameSave.data.boxPositions[tempCount].x;
				box.y = _gameSave.data.boxPositions[tempCount].y;
				tempCount++;
			}
			
			_topText.text = "Loaded positions";
			_topText.alpha = 1;
		}
	}
	
	/**
	 * Called when the user clicks the 'Clear Save' button
	 */
	private function onClear():Void 
	{
		// Lets just wipe the whole boxPositions array
		_gameSave.data.boxPositions = null;
		_gameSave.flush();
		_topText.text = "Save erased";
		_topText.alpha = 1;
	}
}