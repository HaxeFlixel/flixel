package;

import flash.ui.Mouse;
import org.flixel.FlxButton;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxParticle;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState
{
	//Our emmiter
	private var theEmitter:FlxEmitter;
	
	//Our white pixel (This is to prevent creating 200 new pixels all to a new variable each loop)
	private var whitePixel:FlxParticle;
	
	//Some buttons
	private var collisionButton:FlxButton;
	private var gravityButton:FlxButton;
	private var quitButton:FlxButton;
	
	//some walls stuff
	private var collisionGroup:FlxGroup;
	private var wall:FlxSprite;
	private var floor:FlxSprite;
	
	//We'll use these to track the current state of gravity and collision
	private var isGravityOn:Bool;
	private var isCollisionOn:Bool;
	
	//Just a useful flxText for notifications
	private var topText:FlxText;
	
	public function new()
	{
		isGravityOn   = false;
		isCollisionOn = false;
		
		super();
	}
	
	override public function create():Void
	{
		FlxG.framerate = 60;
		FlxG.flashFramerate = 60;
		
		//Here we actually initialize out emitter
		//The parameters are        X   Y                Size (Maximum number of particles the emitter can store)
		theEmitter = new FlxEmitter(10, FlxG.height / 2, 200);
		
		//Now by default the emitter is going to have some properties set on it and can be used immediately
		//but we're going to change a few things.
		
		//First this emitter is on the side of the screen, and we want to show off the movement of the particles
		//so lets make them launch to the right.
		theEmitter.setXSpeed(100, 200);
		
		//and lets funnel it a tad
		theEmitter.setYSpeed( -50, 50);
		
		//Let's also make our pixels rebound off surfaces
		theEmitter.bounce = .8;
		
		//Now let's add the emitter to the state.
		add(theEmitter);
		 
		//Now it's almost ready to use, but first we need to give it some pixels to spit out!
		//Lets fill the emitter with some white pixels
		var max:Int = Std.int(theEmitter.maxSize / 2);
		for (i in 0...max) {
			whitePixel = new FlxParticle();
			whitePixel.makeGraphic(2, 2, 0xFFFFFFFF);
			whitePixel.visible = false; //Make sure the particle doesn't show up at (0, 0)
			theEmitter.add(whitePixel);
			whitePixel = new FlxParticle();
			whitePixel.makeGraphic(1, 1, 0xFFFFFFFF);
			whitePixel.visible = false;
			theEmitter.add(whitePixel);
		}
		
		//Now let's setup some buttons for messing with the emitter.
		collisionButton = new FlxButton(2, FlxG.height - 22, "Collision", onCollision);
		add(collisionButton);
		gravityButton = new FlxButton(82, FlxG.height - 22, "Gravity", onGravity);
		add(gravityButton);
		quitButton = new FlxButton(320, FlxG.height - 22, "Quit", onQuit);
		add(quitButton);
		
		//I'll just leave this here
		topText = new FlxText(0, 2, FlxG.width, "Welcome");
		topText.alignment = "center";
		add(topText);
		
		//Lets setup some walls for our pixels to collide against
		collisionGroup = new FlxGroup();
		wall= new FlxSprite(100, 100);
		wall.makeGraphic(10, 100, 0x50FFFFFF);//Make it darker - easier on the eyes :)
		wall.visible = wall.solid = false;//Set both the visibility AND the solidity to false, in one go
		wall.immovable = true;//Lets make sure the pixels don't push out wall away! (though it does look funny)
		collisionGroup.add(wall);
		//Duplicate our wall but this time it's a floor to catch gravity affected particles
		floor = new FlxSprite(10, 267);
		floor.makeGraphic(FlxG.width - 20, 10, 0x50FFFFFF);
		floor.visible = floor.solid = false;
		floor.immovable = true;
		collisionGroup.add(floor);
		
		//Please note that this demo makes the walls themselves not collide, for the sake of simplicity.
		//Normally you would make the particles have solid = true or false to make them collide or not on creation,
		//because in a normal environment your particles probably aren't going to change solidity at a mouse 
		//click. If they did, you would probably be better suited with emitter.setAll("solid", true)
		//I just don't feel that setAll is applicable here(Since I would still have to toggle the walls anyways)
		
		//Don't forget to add the group to the state(Like I did :P)
		add(collisionGroup);
		
		//Now lets set our emitter free.
		//Params:        Explode, Particle Lifespan, Emit rate(in seconds)
		theEmitter.start(false, 3, .01);
		
		//Let's re show the cursors
		FlxG.mouse.show();
		Mouse.hide();
	}
	
	override public function update():Void
	{
		//This is just to make the text at the top fade out
		if (topText.alpha > 0) {
			topText.alpha -= .01;
		}
		super.update();
		FlxG.collide(theEmitter, collisionGroup);
	}
	
	//This is run when you flip the collision
	private function onCollision():Void {
		isCollisionOn = !isCollisionOn;
		if (isCollisionOn) {
			if (isGravityOn) {
				floor.solid = true;    //Set the floor to the 'active' collision barrier
				floor.visible = true;
				wall.solid = false;
				wall.visible = false;
			}else {
				floor.solid = false;   //Set the wall to the 'active' collision barrier
				floor.visible = false;
				wall.solid = true;
				wall.visible = true;
			}
			topText.text = "Collision: ON";
		}else {
			//Turn off the wall and floor, completely
			wall.solid = floor.solid = wall.visible = floor.visible = false;
			topText.text = "Collision: OFF";
		}
		topText.alpha = 1;
		FlxG.log("Toggle Collision");
	}
	
	//This is run when you flip the gravity
	private function onGravity():Void {
		isGravityOn = !isGravityOn;
		if (isGravityOn) {
			theEmitter.gravity = 200;
			if (isCollisionOn){
				floor.visible = true;
				floor.solid = true;
				wall.visible = false;
				wall.solid = false;
			}
			//Just for the sake of completeness let's go ahead and make this change happen 
			//to all of the currently emitted particles as well.
			for (i in 0...theEmitter.members.length) {
				cast(theEmitter.members[i], FlxParticle).acceleration.y = 200; //Cast the pixel from the emitter as a particle so we can use it
			}
			topText.text = "Gravity: ON";
		}else {
			theEmitter.gravity = 0;
			if (isCollisionOn){
				wall.visible = true;
				wall.solid = true;
				floor.visible = false;
				floor.solid = false;
			}
			for (i in 0...theEmitter.members.length) 
			{
				cast(theEmitter.members[i], FlxParticle).acceleration.y = 0;
			}
			topText.text = "Gravity: OFF";
		}
		topText.alpha = 1;
		FlxG.log("Toggle Gravity");
	}
	
	//This just quits - state.destroy() is automatically called upon state changing
	private function onQuit():Void 
	{
		FlxG.switchState(new MenuState());
	}
}