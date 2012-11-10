package;

import flash.ui.Mouse;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState
{
	//This is for our messages
	private var topText:FlxText;
	
	//This is our elevator, for smashing the crates
	private var elevator:FlxSprite;
	
	//We'll reuse this when we make a bunch of crates
	private var crate:FlxSprite;
	
	//We'll make 100 per group crates to smash about
	private var numCrates:Int;
	
	//these are the groups that will hold all of our crates
	private var crateStormGroup:FlxGroup;
	private var crateStormGroup2:FlxGroup;
	private var crateStormMegaGroup:FlxGroup;
	
	//We'll make a sweet flixel logo to ride the elevator for option #2
	private var flixelRider:FlxSprite;
	
	//Here we have a few buttons for use in altering the demo
	private var crateStorm:FlxButton;
	private var crateStormG1:FlxButton;
	private var crateStormG2:FlxButton;
	private var quitButton:FlxButton;
	private var flxRiderButton:FlxButton;
	private var groupCollision:FlxButton;
	
	//Some toggle variables for use with the buttons
	private var isCrateStormOn:Bool;
	private var isFlxRiderOn:Bool;
	private var collideGroups:Bool;
	private var redGroup:Bool;
	private var blueGroup:Bool;
	private var rising:Bool;
	
	public function new()
	{
		numCrates = 200;
		isCrateStormOn = true;
		isFlxRiderOn = false;
		collideGroups = false;
		redGroup = true;
		blueGroup = true;
		rising = true;
		
		super();
	}
	
	override public function create():Void
	{
		//Kick the framerate back up
		FlxG.framerate = 30;
		FlxG.flashFramerate = 30;
		
		//Let's setup our elevator, for some wonderful crate bashing goodness
		elevator = new FlxSprite((FlxG.width / 2) - 100, 250, "assets/elevator.png");
		//Make it able to collide, and make sure it's not tossed around
		elevator.solid = elevator.immovable = true;
		//And add it to the state
		add(elevator);
		
		//Now lets get some crates to smash around, normally I would use an emitter for this
		//kind of scene, but for this demo I wanted to use regular sprites 
		//(See ParticlesDemo for an example of an emitter with colliding particles)
		//We'll need a group to place everything in - this helps a lot with collisions
		crateStormGroup = new FlxGroup();
		for (i in 0...numCrates) 
		{
			crate = new FlxSprite((FlxG.random() * 200) + 100, 20);
			crate.loadRotatedGraphic("assets/crate.png", 16, 0); //This loads in a graphic, and 'bakes' some rotations in so we don't waste resources computing real rotations later
			crate.angularVelocity = FlxG.random() * 50-150; //Make it spin a tad
			crate.acceleration.y = 300; //Gravity
			crate.acceleration.x = -50; //Some wind for good measure
			crate.maxVelocity.y = 500; //Don't fall at 235986mph
			crate.maxVelocity.x = 200; //"      fly  "  "
			crate.elasticity = FlxG.random(); //Let's make them all bounce a little bit differently
			crateStormGroup.add(crate);
		}
		add(crateStormGroup);
		//And another group, this time - Red crates
		crateStormGroup2 = new FlxGroup();
		for (i in 0...numCrates) {
			crate = new FlxSprite((FlxG.random() * 200) + 100, 20);
			crate.loadRotatedGraphic("assets/crate.png", 16, 1);
			crate.angularVelocity = FlxG.random() * 50-150;
			crate.acceleration.y = 300;
			crate.acceleration.x = 50;
			crate.maxVelocity.y = 500;
			crate.maxVelocity.x = 200;
			crate.elasticity = FlxG.random();
			crateStormGroup2.add(crate);
		}
		add(crateStormGroup2);
		
		//Now what we're going to do here is add both of those groups to a new containter group
		//This is useful if you had something like, coins, enemies, special tiles, etc.. that would all need
		//to check for overlaps with something like a player.
		crateStormMegaGroup = new FlxGroup();
		crateStormMegaGroup.add(crateStormGroup);
		crateStormMegaGroup.add(crateStormGroup2);
		
		//Cute little flixel logo that will ride the elevator
		flixelRider = new FlxSprite((FlxG.width / 2) - 13, 0, "assets/flixelLogo.png");
		flixelRider.solid = flixelRider.visible = flixelRider.exists = false; //But we don't want him on screen just yet...
		flixelRider.acceleration.y = 800;
		add(flixelRider);
		
		//This is for the text at the top of the screen
		topText = new FlxText(0, 2, FlxG.width, "Welcome");
		topText.alignment = "center";
		add(topText);
		
		//Lets make a bunch of buttons! YEAH!!!
		crateStorm = new FlxButton(2, FlxG.height - 22, "Crate Storm", onCrateStorm);
		add(crateStorm);
		flxRiderButton = new FlxButton(82, FlxG.height - 22, "Flixel Rider", onFlixelRider);
		add(flxRiderButton);
		crateStormG1 = new FlxButton(162, FlxG.height - 22, "Blue Group", onBlue);
		add(crateStormG1);
		crateStormG2 = new FlxButton(242, FlxG.height - 22, "Red Group", onRed);
		add(crateStormG2);
		groupCollision = new FlxButton(202, FlxG.height - 42, "Collide Groups", onCollideGroups);
		add(groupCollision);
		quitButton = new FlxButton(320, FlxG.height - 22, "Quit", onQuit);
		add(quitButton);
		
		//And lets get the flixel cursor visible again
		FlxG.mouse.show();
		Mouse.hide();
		
		FlxG.watch(elevator.velocity, "y", "vy");
	}
	
	override public function update():Void
	{
		//This is just to make the text at the top fade out
		if (topText.alpha > 0) 
		{
			topText.alpha -= .01;
		}
		
		//Here we'll make the elevator rise and fall - all of the constants chosen here are just after tinkering
		if (rising) 
		{
			elevator.velocity.y-= 10;
		}
		else 
		{
			elevator.velocity.y+= 10;
		}
		if (elevator.velocity.y == -300) 
		{
			rising = false;
		}
		else if (elevator.velocity.y == 300) 
		{
			rising = true;
		}
		
		//Run through the groups, and if a crate is off screen, get it back!
		for (i in 0...numCrates) 
		{
			var a = cast(crateStormGroup.members[i], FlxSprite);
			if (a.x < -10)
			{
				a.x = 400;
			}
			if (a.x > 400)
			{
				a.x = -10;
			}
			if (a.y > 300)
			{
				a.y = -10;
			}
		}
		for (i in 0...numCrates) 
		{
			var a = cast(crateStormGroup2.members[i], FlxSprite);
			if (a.x > 400)
			{
				a.x = -10;
			}
			if (a.x < -10)
			{
				a.x = 400;
			}
			if (a.y > 300)
			{
				a.y = -10;
			}
		}
		super.update();
		
		//Here we call our simple collide() function, what this does is checks to see if there is a collision
		//between the two objects specified, But if you pass in a group then it checks the group against the object,
		//or group against a group, You can even check a group of groups against an object - You can see the possibilities this presents.
		//To use it, simply call FlxG.collide(Group/Object1, Group/Object2, Notification(optional))
		//If you DO pass in a notification it will fire the function you created when two objects collide - allowing for even more functionality.
		if(collideGroups)
		{
			FlxG.collide(crateStormGroup, crateStormGroup2);
		}
		if(isCrateStormOn)
		{
			FlxG.collide(elevator, crateStormMegaGroup);
		}
		if (isFlxRiderOn) 
		{
			FlxG.collide(elevator, flixelRider);
		}
		//We don't specify a callback here, because we aren't doing anything super specific - just using the default collide method.
	}
	
	//This calls our friend the Flixel Rider into play
	private function onFlixelRider():Void {
		if (!isFlxRiderOn)
		{
			isFlxRiderOn = true; //Make the state aware that Flixel Rider is here
			isCrateStormOn = false; //Tell the state that the crates are off as of right now
			crateStormGroup.visible = crateStormGroup.exists = false; //Turn off the Blue crates
			crateStormGroup2.visible = crateStormGroup2.exists = false; //Turn off the Red crates
			flixelRider.solid = flixelRider.visible = flixelRider.exists = true; //Turn on the Flixel Rider
			flixelRider.y = flixelRider.velocity.y = 0; //Reset him at the top of the screen(Dont be like me and have him appear under the elevator :P)
			crateStormG1.visible = false; //Turn off the button for toggling the Blue group
			crateStormG2.visible = false; //Turn ooff the button for toggling the Red group
			groupCollision.visible = false; //Turn off the button for toggling group collision
			topText.text = "Flixel Elevator Rider!";
			topText.alpha = 1;
		}
	}
	
	//Enable the CRATE STOOOOOORM!
	private function onCrateStorm():Void {
		isCrateStormOn = true;
		isFlxRiderOn = false;
		if(blueGroup)
		{
			crateStormGroup.visible = crateStormGroup.exists = true;
		}
		if(redGroup)
		{
			crateStormGroup2.visible = crateStormGroup2.exists = true;
		}
		flixelRider.solid = flixelRider.visible = flixelRider.exists =false;
		crateStormG1.visible = true;
		crateStormG2.visible = true;
		if(blueGroup && redGroup)
		{
			groupCollision.visible = true;
		}
		topText.text = "CRATE STOOOOORM!";
		topText.alpha = 1;
	}
	
	//Toggle the Blue group
	private function onBlue():Void 
	{
		blueGroup = !blueGroup;
		crateStormGroup.visible = crateStormGroup.exists = !crateStormGroup.exists;
		for (i in 0...numCrates) 
		{
			var a = cast(crateStormGroup.members[i], FlxSprite);
			a.solid = !a.solid;//Run through and make them not collide - I'm not sure if this is neccesary
		}
		if (blueGroup && redGroup) 
		{
			groupCollision.visible = true;
		}
		else 
		{
			groupCollision.visible = false;
		}
		if (!blueGroup)
		{
			topText.text = "Blue Group: Disabled";
			topText.alpha = 1;
		}
		else 
		{
			topText.text = "Blue Group: Enabled";
			topText.alpha = 1;
		}
	}
	
	//Toggle the Red group
	private function onRed():Void {
		redGroup = !redGroup;
		crateStormGroup2.visible = crateStormGroup2.exists = !crateStormGroup2.exists;
		for (i in 0...numCrates) 
		{
			var a = cast(crateStormGroup2.members[i], FlxSprite);
			a.solid = !a.solid;
		}
		if (blueGroup && redGroup) 
		{
			groupCollision.visible = true;
		}
		else 
		{
			groupCollision.visible = false;
		}
		if (!redGroup)
		{
			topText.text = "Red Group: Disabled";
			topText.alpha = 1;
		}
		else 
		{
			topText.text = "Red Group: Enabled";
			topText.alpha = 1;
		}
	}
	
	//Toggle the group collision
	private function onCollideGroups():Void {
		collideGroups = !collideGroups;
		if (!collideGroups)
		{
			topText.text = "Group Collision: Disabled";
			topText.alpha = 1;
		}
		else 
		{
			topText.text = "Group Collision: Enabled";
			topText.alpha = 1;
		}
	}
	//This just quits - state.destroy() is automatically called upon state changing
	private function onQuit():Void {
		FlxG.switchState(new MenuState());
	}
}