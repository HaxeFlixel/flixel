package;

import flash.ui.Mouse;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	/**
	 * Our emmiter
	 */
	private var _emitter:FlxEmitter;
	
	/**
	 * Our white pixel (This is to prevent creating 200 new pixels all to a new variable each loop)
	 */
	private var _whitePixel:FlxParticle;
	
	/**
	 * Some buttons
	 */
	private var _collisionButton:FlxButton;
	private var _gravityButton:FlxButton;
	
	/**
	 * Some walls stuff
	 */
	private var _collisionGroup:FlxGroup;
	private var _wall:FlxSprite;
	private var _floor:FlxSprite;
	
	/**
	 * We'll use these to track the current state of gravity and collision
	 */
	private var isGravityOn:Bool = false;
	private var isCollisionOn:Bool = false;
	
	/**
	 * Just a useful flxText for notifications
	 */
	private var topText:FlxText;
	
	override public function create():Void
	{
		FlxG.mouse.show();
		
		// Here we actually initialize out emitter
		// The parameters are X, Y and Size (Maximum number of particles the emitter can store)
		_emitter = new FlxEmitter(10, FlxG.height / 2, 200);
		
		// Now by default the emitter is going to have some properties set on it and can be used immediately
		// but we're going to change a few things.
		
		// First this emitter is on the side of the screen, and we want to show off the movement of the particles
		// so lets make them launch to the right.
		_emitter.setXSpeed(100, 200);
		
		// and lets funnel it a tad
		_emitter.setYSpeed( -50, 50);
		
		// Let's also make our pixels rebound off surfaces
		_emitter.bounce = 0.8;
		
		// Now let's add the emitter to the state.
		add(_emitter);
		
		// Now it's almost ready to use, but first we need to give it some pixels to spit out!
		// Lets fill the emitter with some white pixels
		for (i in 0...(Std.int(_emitter.maxSize / 2))) 
		{
			_whitePixel = new FlxParticle();
			_whitePixel.makeGraphic(2, 2, FlxColor.WHITE);
			// Make sure the particle doesn't show up at (0, 0)
			_whitePixel.visible = false; 
			_emitter.add(_whitePixel);
			_whitePixel = new FlxParticle();
			_whitePixel.makeGraphic(1, 1, FlxColor.WHITE);
			_whitePixel.visible = false;
			_emitter.add(_whitePixel);
		}
		
		// Now let's setup some buttons for messing with the emitter.
		_collisionButton = new FlxButton(2, FlxG.height - 22, "Collision", onCollisionToggle);
		add(_collisionButton);
		_gravityButton = new FlxButton(82, FlxG.height - 22, "Gravity", onGravityToggle);
		add(_gravityButton);
		
		// I'll just leave this here
		topText = new FlxText(0, 2, FlxG.width, "Welcome");
		topText.alignment = "center";
		add(topText);
		
		// Let's setup some walls for our pixels to collide against
		_collisionGroup = new FlxGroup();
		_wall = new FlxSprite(100, 100);
		// Make it darker - easier on the eyes :)
		_wall.makeGraphic(10, 100, FlxColor.GRAY); 
		// Set both the visibility AND the solidity to false, in one go
		_wall.visible = _wall.solid = false;
		// Lets make sure the pixels don't push out wall away! (though it does look funny)
		_wall.immovable = true;
		_collisionGroup.add(_wall);
		
		// Duplicate our wall but this time it's a floor to catch gravity affected particles
		_floor = new FlxSprite(10, 267);
		_floor.makeGraphic(FlxG.width - 20, 10, FlxColor.GRAY);
		_floor.visible = _floor.solid = false;
		_floor.immovable = true;
		_collisionGroup.add(_floor);
		
		// Please note that this demo makes the walls themselves not collide, for the sake of simplicity.
		// Normally you would make the particles have solid = true or false to make them collide or not on creation,
		// because in a normal environment your particles probably aren't going to change solidity at a mouse 
		// click. If they did, you would probably be better suited with emitter.setAll("solid", true)
		// I just don't feel that setAll is applicable here(Since I would still have to toggle the walls anyways)
		
		// Don't forget to add the group to the state (Like I did :P)
		add(_collisionGroup);
		
		// Now lets set our emitter free.
		// Params: Explode, Particle Lifespan, Emit rate (in seconds)
		_emitter.start(false, 3, .01);
	}
	
	override public function update():Void
	{
		// This is just to make the text at the top fade out
		if (topText.alpha > 0) 
		{
			topText.alpha -= 0.01;
		}
		
		super.update();
		
		FlxG.collide(_emitter, _collisionGroup);
	}
	
	/**
	 * This is run when you flip the collision
	 */
	private function onCollisionToggle():Void 
	{
		isCollisionOn = !isCollisionOn;
		
		if (isCollisionOn) 
		{
			if (isGravityOn) 
			{
				// Set the floor to the 'active' collision barrier
				_floor.solid = true;    
				_floor.visible = true;
				_wall.solid = false;
				_wall.visible = false;
			}
			else 
			{
				// Set the wall to the 'active' collision barrier
				_floor.solid = false;   
				_floor.visible = false;
				_wall.solid = true;
				_wall.visible = true;
			}
			
			topText.text = "Collision: ON";
		}
		else 
		{
			// Turn off the wall and floor, completely
			_wall.solid = _floor.solid = _wall.visible = _floor.visible = false;
			topText.text = "Collision: OFF";
		}
		
		topText.alpha = 1;
	}
	
	/**
	 * This is run when you flip the gravity
	 */
	private function onGravityToggle():Void 
	{
		isGravityOn = !isGravityOn;
		
		if (isGravityOn) 
		{
			_emitter.gravity = 200;
			
			if (isCollisionOn)
			{
				_floor.visible = true;
				_floor.solid = true;
				_wall.visible = false;
				_wall.solid = false;
			}
			
			//Just for the sake of completeness let's go ahead and make this change happen 
			//to all of the currently emitted particles as well.
			for (i in 0..._emitter.members.length) 
			{
				_emitter.members[i].acceleration.y = 200; 
			}
			
			topText.text = "Gravity: ON";
		}
		else 
		{
			_emitter.gravity = 0;
			
			if (isCollisionOn)
			{
				_wall.visible = true;
				_wall.solid = true;
				_floor.visible = false;
				_floor.solid = false;
			}
			
			for (i in 0..._emitter.members.length) 
			{
				_emitter.members[i].acceleration.y = 0;
			}
			
			topText.text = "Gravity: OFF";
		}
		
		topText.alpha = 1;
	}
}