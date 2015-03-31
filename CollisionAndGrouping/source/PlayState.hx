package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.phys.nape.FlxNapeSpace;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxRandom;
import flixel.phys.IFlxBody;
import flixel.phys.IFlxSpace;
import flixel.phys.classic.FlxClassicSpace;

class PlayState extends FlxState
{
	// This is for our messages
	private var _topText:FlxText;
	
	// This is our elevator, for smashing the crates
	public static var _elevator:FlxSprite;
	
	// We'll reuse this when we make a bunch of crates
	private var _crate:FlxSprite;
	
	// We'll make 100 per group crates to smash about
	private var _numCrates:Int = 200;
	
	//these are the groups that will hold all of our crates
	private var _crateStormGroup:FlxTypedGroup<FlxSprite>;
	private var _crateStormGroup2:FlxTypedGroup<FlxSprite>;
	private var _crateStormMegaGroup:FlxGroup;
	
	// We'll make a sweet flixel logo to ride the elevator for option #2
	private var _flixelRider:FlxSprite;
	
	// Here we have a few buttons for use in altering the demo
	private var _crateStorm:FlxButton;
	private var _crateStormG1:FlxButton;
	private var _crateStormG2:FlxButton;
	private var _quitButton:FlxButton;
	private var _flxRiderButton:FlxButton;
	private var _groupCollision:FlxButton;
	
	// Some toggle variables for use with the buttons
	private var _isCrateStormOn:Bool = true;
	private var _isFlxRiderOn:Bool = false;
	private var _collideGroups:Bool = false;
	private var _redGroup:Bool = true;
	private var _blueGroup:Bool = true;
	private var _rising:Bool = true;
	
	override public function create():Void
	{
		super.create();
		
		
		////////////////////
		var space = new FlxClassicSpace();
		spaces.push(space);
		////////////////////
		
		
		// Let's setup our elevator, for some wonderful crate bashing goodness
		_elevator = new FlxSprite((FlxG.width / 2) - 100, 250, "assets/elevator.png");
		// Make it able to collide, and make sure it's not tossed around
		// And add it to the state
		add(_elevator);
		
		// Now lets get some crates to smash around, normally I would use an emitter for this
		// kind of scene, but for this demo I wanted to use regular sprites 
		// (See ParticlesDemo for an example of an emitter with colliding particles)
		// We'll need a group to place everything in - this helps a lot with collisions
		_crateStormGroup = new FlxTypedGroup<FlxSprite>();
		
		for (i in 0..._numCrates) 
		{
			_crate = new FlxSprite((FlxG.random.float() * 200) + 100, 20);
			// This loads in a graphic, and 'bakes' some rotations in so we don't waste resources computing real rotations later
			_crate.loadRotatedGraphic("assets/crate.png", 16, 0); 
			
			/////////////////////////////
			space.createBody(_crate);
			
			_crate.body.collisionGroup = 1;
			_crate.body.collisionMask = ~1;
			// Make it spin a tad
			_crate.body.angularVelocity = FlxG.random.float() * 50 - 150; 
			// Gravity
			_crate.body.acceleration.y = 300; 
			// Some wind for good measure
			_crate.body.acceleration.x = 50; 
			// Don't fall at 235986mph
			_crate.body.maxVelocity.y = 500; 
			// "      fly  "  "
			_crate.body.maxVelocity.x = 200; 
			// Let's make them all bounce a little bit differently
			_crate.body.elasticity = FlxG.random.float();
			/////////////////////////////
			
			_crateStormGroup.add(_crate);
		}
		
		add(_crateStormGroup);
		
		// And another group, this time - Red crates
		_crateStormGroup2 = new FlxTypedGroup<FlxSprite>();
		
		for (i in 0..._numCrates) 
		{
			_crate = new FlxSprite((FlxG.random.float() * 200) + 100, 20);
			_crate.loadRotatedGraphic("assets/crate.png", 16, 1);
			
			////////////////////////////////
			space.createBody(_crate);
			_crate.body.collisionGroup = 1;
			_crate.body.collisionMask = ~1;
			_crate.body.angularVelocity = FlxG.random.float() * 50-150;
			_crate.body.acceleration.y = 300;
			_crate.body.acceleration.x = -50;
			_crate.body.maxVelocity.y = 500;
			_crate.body.maxVelocity.x = 200;
			_crate.body.elasticity = FlxG.random.float();
			////////////////////////////////
			
			_crateStormGroup2.add(_crate);
		}
		/////////////////////////////////
		space.createBody(_elevator);
		_elevator.body.collisionGroup = 4;
		_elevator.body.collisionMask = ~0;
		_elevator.body.kinematic = true;
		/////////////////////////////////
		
		add(_crateStormGroup2);
		
		// Now what we're going to do here is add both of those groups to a new containter group
		// This is useful if you had something like, coins, enemies, special tiles, etc.. that would all need
		// to check for overlaps with something like a player.
		_crateStormMegaGroup = new FlxGroup();
		_crateStormMegaGroup.add(_crateStormGroup);
		_crateStormMegaGroup.add(_crateStormGroup2);
		_crateStormMegaGroup.add(_elevator);
		
		// Cute little flixel logo that will ride the elevator
		_flixelRider = new FlxSprite((FlxG.width / 2) - 13, 0, "assets/flixelLogo.png");
		// But we don't want him on screen just yet...
		//_flixelRider.body = new FlxNapeBody(_flixelRider, space);
		_flixelRider.exists = false;
		_flixelRider.acceleration.y = 800;
		_flixelRider.elasticity = 0;
		add(_flixelRider);
		
		// This is for the text at the top of the screen
		_topText = new FlxText(0, 2, FlxG.width, "Welcome");
		_topText.alignment = CENTER;
		add(_topText);
		
		// Lets make a bunch of buttons! YEAH!!!
		var buttonYPos:Int = FlxG.height - 20;
		
		FlxG.log.add("Hello");
		
		_crateStorm = new FlxButton(0, buttonYPos, "Crate Storm", onCrateStorm);
		add(_crateStorm);
		_flxRiderButton = new FlxButton(80, buttonYPos, "Flixel Rider", onFlixelRider);
		add(_flxRiderButton);
		_crateStormG1 = new FlxButton(160, buttonYPos, "Blue Group", onBlue);
		add(_crateStormG1);
		_crateStormG2 = new FlxButton(240, buttonYPos, "Red Group", onRed);
		add(_crateStormG2);
		_groupCollision = new FlxButton(320, buttonYPos, "Collide Groups", onCollideGroups);
		add(_groupCollision);
		
		FlxG.cameras.flash();
	}
	
	override public function update(elapsed:Float):Void
	{
		// This is just to make the text at the top fade out
		if (_topText.alpha > 0) 
		{
			_topText.alpha -= 0.01;
		}
		
		
		///////////////////////////////////
		
		// Here we'll make the elevator rise and fall - all of the constants chosen here are just after tinkering
		if (_rising) 
		{
			_elevator.body.velocity.y -= 10;
		}
		else 
		{
			_elevator.body.velocity.y += 10;
		}
		if (_elevator.body.velocity.y == - 300) 
		{
			_rising = false;
		}
		else if (_elevator.body.velocity.y == 300) 
		{
			_rising = true;
		}
		
		///////////////////////////////////
		
		// Run through the groups, and if a crate is off screen, get it back!
		for (crate in _crateStormGroup) 
		{
			if (crate.x < -10)
			{
				crate.x = 400;
			}
			if (crate.x > 400)
			{
				crate.x = -10;
			}
			if (crate.y > 300)
			{
				crate.y = -10;
			}
		}
		
		for (crate in _crateStormGroup2) 
		{
			if (crate.x > 400)
			{
				crate.x = -10;
			}
			if (crate.x < -10)
			{
				crate.x = 400;
			}
			if (crate.y > 300)
			{
				crate.y = -10;
			}
		}
		
		super.update(elapsed);
		
		// Here we call our simple collide() function, what this does is checks to see if there is a collision
		// between the two objects specified, But if you pass in a group then it checks the group against the object,
		// or group against a group, You can even check a group of groups against an object - You can see the possibilities this presents.
		// To use it, simply call FlxG.collide(Group/Object1, Group/Object2, Notification(optional))
		// If you DO pass in a notification it will fire the function you created when two objects collide - allowing for even more functionality.
		// We don't specify a callback here, because we aren't doing anything super specific - just using the default collide method.
	}
	
	/**
	 * This calls our friend the Flixel Rider into play
	 */ 
	private function onFlixelRider():Void 
	{
		if (!_isFlxRiderOn)
		{
			// Make the state aware that Flixel Rider is here
			_isFlxRiderOn = true; 
			// Tell the state that the crates are off as of right now
			_isCrateStormOn = false; 
			// Turn off the Blue crates
			_crateStormGroup.visible = _crateStormGroup.exists = false; 
			// Turn off the Red crates
			_crateStormGroup2.visible = _crateStormGroup2.exists = false; 
			// Turn on the Flixel Rider
			_flixelRider.visible = _flixelRider.exists = true; 
			// Reset him at the top of the screen(Dont be like me and have him appear under the elevator :P)
			_flixelRider.y = _flixelRider.velocity.y = 0; 
			// Turn off the button for toggling the Blue group
			_crateStormG1.visible = false; 
			// Turn ooff the button for toggling the Red group
			_crateStormG2.visible = false; 
			// Turn off the button for toggling group collision
			_groupCollision.visible = false;
			_topText.text = "Flixel Elevator Rider!";
			_topText.alpha = 1;
		}
	}
	
	/**
	 * Enable the CRATE STOOOOOORM!
	 */ 
	private function onCrateStorm():Void 
	{
		_isCrateStormOn = true;
		_isFlxRiderOn = false;
		
		if (_blueGroup)
		{
			_crateStormGroup.visible = _crateStormGroup.exists = true;
		}
		if (_redGroup)
		{
			_crateStormGroup2.visible = _crateStormGroup2.exists = true;
		}
		
		_flixelRider.visible = _flixelRider.exists = false;
		_crateStormG1.visible = true;
		_crateStormG2.visible = true;
		
		if (_blueGroup && _redGroup)
		{
			_groupCollision.visible = true;
		}
		
		_topText.text = "CRATE STOOOOORM!";
		_topText.alpha = 1;
	}
	
	/**
	 * Toggle the Blue group
	 */ 
	private function onBlue():Void 
	{
		_blueGroup = !_blueGroup;
		_crateStormGroup.visible = _crateStormGroup.exists = !_crateStormGroup.exists;
		
		for (crate in _crateStormGroup) 
		{
			// Run through and make them not collide - I'm not sure if this is neccesary
			//crate.solid = !crate.solid;
		}
		if (_blueGroup && _redGroup) 
		{
			_groupCollision.visible = true;
		}
		else 
		{
			_groupCollision.visible = false;
		}
		if (!_blueGroup)
		{
			_topText.text = "Blue Group: Disabled";
			_topText.alpha = 1;
		}
		else 
		{
			_topText.text = "Blue Group: Enabled";
			_topText.alpha = 1;
		}
	}
	
	/**
	 * Toggle the Red group
	 */
	private function onRed():Void 
	{
		_redGroup = !_redGroup;
		_crateStormGroup2.visible = _crateStormGroup2.exists = !_crateStormGroup2.exists;
		
		for (crate in _crateStormGroup2) 
		{
			//crate.solid = !crate.solid;
		}
		
		if (_blueGroup && _redGroup) 
		{
			_groupCollision.visible = true;
		}
		else 
		{
			_groupCollision.visible = false;
		}
		
		if (!_redGroup)
		{
			_topText.text = "Red Group: Disabled";
			_topText.alpha = 1;
		}
		else 
		{
			_topText.text = "Red Group: Enabled";
			_topText.alpha = 1;
		}
	}
	
	/////////////////////////////////////
	
	/**
	 * Toggle the group collision
	 */
	private function onCollideGroups():Void 
	{
		_collideGroups = !_collideGroups;
		
		if (!_collideGroups)
		{
			_topText.text = "Group Collision: Disabled";
			_topText.alpha = 1;
			
			_crateStormGroup2.forEach(function (sprite) { sprite.body.collisionGroup = 1; sprite.body.collisionMask = ~1; },true);
		}
		else 
		{
			_topText.text = "Group Collision: Enabled";
			_topText.alpha = 1;
			
			_crateStormGroup2.forEach(function (sprite) { sprite.body.collisionGroup = 2; sprite.body.collisionMask = ~2; },true);
		}
	}
	
	///////////////////////////////////
}