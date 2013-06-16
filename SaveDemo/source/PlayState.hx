package;

import flash.ui.Mouse;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.util.FlxPoint;
import org.flixel.FlxSave;
import org.flixel.FlxState;
import org.flixel.FlxSprite;
import org.flixel.FlxText;


class PlayState extends FlxState
{
	//Here's the FlxSave variable this is what we're going to be saving to.
	private var gameSave:FlxSave;
	
	//We're just going to drop a bunch of boxes into a group
	private var boxGroup:FlxGroup;
	private var numBoxes:Int;
	
	//We'll use these variables for the dragging
	private var dragOffset:FlxPoint;
	private var dragging:Bool;
	private var dragTarget:FlxObject;
	
	//Buttons for the demo
	private var demoSave:FlxButton;
	private var demoLoad:FlxButton;
	private var demoClear:FlxButton;
	private var demoQuit:FlxButton;
	
	//The top text that yells at you
	private var topText:FlxText;
	
	public function new()
	{
		numBoxes = 20;
		dragging = false;
		
		super();
	}
	
	override public function create():Void
	{
		FlxG.framerate = 60;
		FlxG.flashFramerate = 60;
		
		//So here's the core of this demo - the FlxSave you have to instantiate a new one before you can use it
		gameSave = new FlxSave();
		//And then you have to bind it to the save data, you can use different bind strings in different parts of your game
		//you MUST bind the save before it can be used.
		gameSave.bind("SaveDemo");
		
		//Since we need the text before the usual end of the demo we'll initialize it up here.
		topText = new FlxText(0, 2, FlxG.width, "Welcome!");
		topText.alignment = 'center';
		
		//This just makes some dim text with instructions
		var dragText:FlxText = new FlxText(5, FlxG.height / 2 -20, FlxG.width, "Click to Drag");
		dragText.color = 0x10101010;
		dragText.size = 50;
		add(dragText);
		
		//Set out offset to non-null here
		dragOffset = new FlxPoint(0, 0);
		
		//Make a group to place the boxes in
		boxGroup = new FlxGroup();
		//And let's make some boxes!
		for (i in 0...(numBoxes)) 
		{
			var box:FlxButton;
			//If we already have some save data to work with, then let's go ahead and put it to use
			if (gameSave.data.boxPositions != null)
			{
				box = new FlxButton(gameSave.data.boxPositions[i].x, gameSave.data.boxPositions[i].y, Std.string(i + 1));
				//I'm using a FlxButton in this instance because I can use if(button.state == FlxButton.PRESSED) 
				//to detect if the mouse is held down on a button
				topText.text = "Loaded positions";
			}
			//If not, oh well we'll just put them in the default locations
			else
			{
				box = new FlxButton((i * 35) + 9, 50, Std.string(i + 1));
				if (i * 35 > 360)
				{
					box.y = 85;
					box.x = (i * 35 -2) - 339;
				}
				topText.text = "No save found, using default positions";
			}
			box.makeGraphic(32, 32, 0xFFAAAAAA); //Make a graphic for our button, instead of the default
			boxGroup.add(box); //And add it to the group
		}
		add(boxGroup);//Add the group to the state
		
		//Get out buttons set up along the bottom of the screen
		demoSave = new FlxButton(2, FlxG.height -22, "Save Locations", onSave);
		add(demoSave);
		demoLoad = new FlxButton(82, FlxG.height -22, "Load Locations", onLoad);
		add(demoLoad);
		demoClear = new FlxButton(202, FlxG.height -22, "Clear Save", onClear);
		add(demoClear);
		demoQuit = new FlxButton(320, FlxG.height -22, "Quit", onQuit);
		add(demoQuit);
		
		//Let's not forget about our old text, which needs to be above everything else
		add(topText);
		
		//Let's re show the cursors
		FlxG.mouse.show();
		Mouse.hide();
	}
	
	override public function update():Void
	{
		//This is just to make the text at the top fade out
		if (topText.alpha > 0) 
		{
			topText.alpha -= .005;
		}
		
		super.update();
		//if you've clicked, lets see if you clicked on a button
		//Note something like this needs to be after super.update() that way the button's state has updated to reflect the mouse event
		if (FlxG.mouse.justPressed()) 
		{
			for (i in 0...(numBoxes)) 
			{
				var a:FlxButton = cast(boxGroup.members[i], FlxButton);
				if (a.status == FlxButton.PRESSED) 
				{
					dragOffset.x = a.x - FlxG.mouse.x; //The offset is used to make the box stick to the cursor and not snap to the corner
					dragOffset.y = a.y - FlxG.mouse.y;
					dragging = true;
					dragTarget = a;
				}
			}
		}
		//If you let go, then release that box!
		if (FlxG.mouse.justReleased()) 
		{
			dragTarget = null;
			dragging = false;
		}
		//And lets move the box around
		if (dragging) 
		{
			dragTarget.x = FlxG.mouse.x + dragOffset.x;
			dragTarget.y = FlxG.mouse.y + dragOffset.y;
		}
	}
	
	//Called when the user clicks the 'Save Locations' button
	private function onSave():Void 
	{
		//Do we already have a save? if not then we need to make one
		if (gameSave.data.boxPositions == null) 
		{
			//lets make a new array at the location data/
			//don't worry, if its not there - then flash will make a new variable there
			//You can also do something like gameSave.data.randomBool = true;
			//and if randomBool didn't exist before, then flash will create a boolean there.
			//though it's best to make a new type() before setting it, so you know the correct type is kept
			gameSave.data.boxPositions = new Array();
			for (i in 0...(numBoxes)) {
				var a:FlxButton = cast(boxGroup.members[i], FlxButton);
				//Cast the boxPositions as an array, you don't have to - but i like my FlashDevelop to highlight so i know im doing it right.
				//cast(gameSave.data.boxPositions, Array<Dynamic>).push(new FlxPoint(a.x, a.y));
				gameSave.data.boxPositions.push(new FlxPoint(a.x, a.y));
			}
			topText.text = "Created a new save, and saved positions";
			topText.alpha = 1;
		}
		else 
		{
			//So we already have some save data? lets overwrite the data WITHOUT ASKING! oooh so bad :P
			//Now we're not doing a real for-loop here, because i REALLY like for each, so we'll need our own index count
			var tempCount:Int = 0;
			//For each button in the group boxGroup - I'm sure you see why I like this already
			for (i in 0...numBoxes) 
			{
				var a:FlxButton = cast(boxGroup.members[i], FlxButton);
				gameSave.data.boxPositions[tempCount] = new FlxPoint(a.x, a.y);
				tempCount++;
			}
			topText.text = "Overwrote old positions";
			topText.alpha = 1;
		}
	}
	
	//Called when the user clicks the 'Load Locations' button
	private function onLoad():Void 
	{
		//Loading what? Theres no save data!
		if (gameSave.data.boxPositions == null)
		{
			topText.text = "Failed to load - There's no save";
			topText.alpha = 1;
		}
		else 
		{
			//Note that above I saved the positions as an array of FlxPoints, When the SWF is closed and re-opened the Types in the
			//array lose their type, and for some reason cannot be re-cast as a FlxPoint. They become regular Flash Objects with the correct
			//variables though, so you're safe to use them - just your IDE won't highlight recognize and highlight the variables
			var tempCount:Int = 0;
			for (i in 0...numBoxes) 
			{
				var a:FlxButton = cast(boxGroup.members[i], FlxButton);
				a.x = gameSave.data.boxPositions[tempCount].x;
				a.y = gameSave.data.boxPositions[tempCount].y;
				tempCount++;
			}
			topText.text = "Loaded positions";
			topText.alpha = 1;
		}
	}
	
	//Called when the user clicks the 'Clear Save' button
	private function onClear():Void 
	{
		//Lets just wipe the whole boxPositions array
		gameSave.data.boxPositions = null;
		topText.text = "Save erased";
		topText.alpha = 1;
	}
	//This just quits - state.destroy() is automatically called upon state changing
	private function onQuit():Void 
	{
		gameSave.close();
		FlxG.switchState(new MenuState());
	}
}