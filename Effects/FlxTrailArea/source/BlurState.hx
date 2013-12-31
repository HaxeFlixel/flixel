package ;

import flixel.effects.FlxTrailArea;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxRandom;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.ui.FlxSlider;
import flixel.FlxSprite;
import flixel.text.FlxText;

//The state showing a remake of the FlxBlur demo
class BlurState extends FlxState {
	var emitter:FlxEmitter;
	var trailArea:FlxTrailArea;
	var sliderGroup:FlxGroup;
	
	override public function create():Void 
	{
		//The first thing to do is setting up the FlxTrailArea
		trailArea = new FlxTrailArea(0, 0, FlxG.width - 200, FlxG.height);
		
		//This just sets up an emitter at the bottom of the screen. After that 50 particles get added to the emitter.
		emitter = new FlxEmitter(0, FlxG.height + 20, 50);
		emitter.width = FlxG.width - 200;
		emitter.gravity = -40;
		emitter.setXSpeed( -20, 20);
		emitter.setYSpeed( -75, -25);
		
		var colors:Array<Int> = [FlxColor.BLUE, (FlxColor.BLUE | FlxColor.GREEN), FlxColor.GREEN, (FlxColor.GREEN | FlxColor.RED), FlxColor.RED];
		var particle:FlxParticle;
		var i:Int = 0;
		while (i < 50) {
			particle = new FlxParticle();
			particle.makeGraphic(32, 32, colors[Std.int(FlxRandom.float() * colors.length)]);
			particle.kill();
			
			//Second thing to do with the FlxTrailArea is adding all sprites that should have a trail to it
			trailArea.add(particle);
			emitter.add(particle);
			i++;
		}
		//Third thing is adding the FlxTrailArea to the state
		add(trailArea);
		add(emitter);
		emitter.start(false, 0, 0.1);
		
		//The part below just adds the white background and all the sliders and buttons on the right
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
	
	override public function destroy():Void 
	{
		super.destroy();
	}
	
	override public function update():Void 
	{
		super.update();
		
		//Goes to the other state
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT) {
			FlxG.switchState(new ParticleState());
		}
	}
	
	
}