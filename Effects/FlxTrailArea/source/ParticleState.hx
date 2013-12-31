package;

import flash.display.BlendMode;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSlider;
import flixel.util.FlxMath;
import flixel.effects.FlxTrailArea;
/**
 * A FlxState which can be used for the game's menu.
 */
class ParticleState extends FlxState
{
	var trailArea:FlxTrailArea;
	var emitter:FlxEmitter;
	var particleAmount:Int = 100;
	
	var sliderGroup:FlxGroup;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff000000; // 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		//Sets up the FlxTrail area on the top left of the screen with an area over the whole black part of the screen
		trailArea = new FlxTrailArea(0,0,FlxG.width - 200, FlxG.height);
		
		//Sets up the emitter for the particle explosion
		emitter = new FlxEmitter(200, 200, particleAmount);
		emitter.setColor(0xff0000, 0x00ff00);
		var particle:FlxParticle;
		var i:Int = 0;
		while (i < particleAmount) {
			particle = new FlxParticle();
			particle.makeGraphic(5,5);
			particle.kill();
			emitter.add(particle);
			
			//This adds all the particles to the FlxTrailArea so they get a trail effect
			trailArea.add(particle);
			i++;
		}
		//Finally, add the FlxTrailArea to the state
		add(trailArea);
		add(emitter);
		emitter.start(true, 1, 0, 0, 0.5);
		
		//This just adds the white background on the right and all the sliders/buttons
		var wall:FlxSprite = new FlxSprite(FlxG.width - 200, 0);
		wall.makeGraphic(200, FlxG.height);
		add(wall);
		
		sliderGroup = new FlxGroup();
		
		var slider:FlxSlider;
		slider = new FlxSlider(trailArea, "alphaMultiplier", FlxG.width - 180, 5, 0, 1, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "redMultiplier", FlxG.width - 180, 55, 0, 1, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "greenMultiplier", FlxG.width - 180, 105, 0, 1, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "blueMultiplier", FlxG.width - 180, 155, 0, 1, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "alphaOffset", FlxG.width - 180, 205, -25, 25, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "redOffset", FlxG.width - 180, 255, -25, 25, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "greenOffset", FlxG.width - 180, 305, -25, 25, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "blueOffset", FlxG.width - 180, 355, -25, 25, 150);
		sliderGroup.add(slider);
		
		slider = new FlxSlider(trailArea, "delay", FlxG.width - 180, 405, 0, 60, 150);
		sliderGroup.add(slider);
		
		add(sliderGroup);
		
		var button:FlxButton = new FlxButton(FlxG.width - 180, 460, "simpleRender", setSimpleRender);
		add(button);
		
		button = new FlxButton(FlxG.width - 100, 460, "Reset values", onResetClick);
		add(button);
		
		var text:FlxText = new FlxText((FlxG.width - 200) / 2, FlxG.height - 50, FlxG.width - 200, "Press right or left to cycle through the demos", 16);
		text.alignment = "center";
		text.x -= text.frameWidth / 2;
		add(text);
		
		text = new FlxText((FlxG.width - 200) / 2, 10, FlxG.width - 200, "Click in this area to create particles", 16);
		text.alignment = "center";
		text.x -= text.frameWidth / 2;
		add(text);
		
		super.create();
	}
	
	//switches simpleRender on and off
	function setSimpleRender() {
		if (trailArea.simpleRender == true) {
			trailArea.simpleRender = false;
		}
		else {
			trailArea.simpleRender = true;
		}
	}
	
	//Resets all the trailArea values
	function onResetClick() {
		trailArea.alphaMultiplier = 0.8;
		trailArea.redMultiplier = 1;
		trailArea.greenMultiplier = 1;
		trailArea.blueMultiplier = 1;
		trailArea.alphaOffset = 0;
		trailArea.redOffset = 0;
		trailArea.greenOffset = 0;
		trailArea.blueOffset = 0;
		trailArea.delay = 1;
		
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		//This starts the emitter where the user clicked
		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.x <= FlxG.width - 200) {
				emitter.x = FlxG.mouse.x;
				emitter.y = FlxG.mouse.y;
				emitter.start(true, 1, 0, 0, 0.5);
			}
		}
		
		//Goes to the other state
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT) {
			FlxG.switchState(new BlurState());
		}
		
	}	
}