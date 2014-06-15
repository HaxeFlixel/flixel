package;

import flash.ui.Mouse;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flash.display.BlendMode;

class PlayState extends FlxState
{
	/**
	 * Our example emitter.
	 */
	private var _emitter:FlxEmitter;
	
	/**
	 * Some buttons
	 */
	private var _blendButton:FlxButton;
	private var _launchModeButton:FlxButton;
	private var _directionButton:FlxButton;
	private var _velocityButton:FlxButton;
	private var _angularVelocityButton:FlxButton;
	private var _angleButton:FlxButton;
	private var _lifespanButton:FlxButton;
	private var _scaleButton:FlxButton;
	private var _alphaButton:FlxButton;
	private var _colorButton:FlxButton;
	private var _dragButton:FlxButton;
	private var _accelerationButton:FlxButton;
	private var _elasticityButton:FlxButton;
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
	private var _isBlendOn:Bool = false;
	private var _isLaunchOn:Bool = false;
	private var _isDirectionOn:Bool = false;
	private var _isVelocityOn:Bool = false;
	private var _isAngularVelocityOn:Bool = false;
	private var _isAngleOn:Bool = false;
	private var _isLifespanOn:Bool = false;
	private var _isScaleOn:Bool = false;
	private var _isAlphaOn:Bool = false;
	private var _isColorOn:Bool = false;
	private var _isDragOn:Bool = false;
	private var _isAccelerationOn:Bool = false;
	private var _isElasticityOn:Bool = false;
	private var _isCollisionOn:Bool = false;
	private var _isGravityOn:Bool = false;
	
	/**
	 * Just a useful flxText for notifications
	 */
	private var topText:FlxText;
	private var _alphaTween:VarTween;
	
	override public function create():Void
	{
		// Here we actually initialize out emitter
		// The parameters are X, Y and Size (Maximum number of particles the emitter can store)
		// This emitter will start right in the middle of the screen.
		
		_emitter = new FlxEmitter(FlxG.width / 2 , FlxG.height / 2, 200);
		
		// All we need to do to start using it is give it some particles. makeParticles() makes this easy!
		
		_emitter.makeParticles(2, 2, FlxColor.WHITE, 200);
		
		// Now let's add the emitter to the state.
		add(_emitter);
		
		// Now let's setup some buttons for messing with the emitter.
		
		_blendButton = new FlxButton(20, FlxG.height - 66, "Blend", onBlendToggle);
		add(_blendButton);
		
		_launchModeButton = new FlxButton(100, FlxG.height - 66, "LaunchMode", onLaunchModeToggle);
		add(_launchModeButton);
		
		_directionButton = new FlxButton(180, FlxG.height - 66, "Direction", onDirectionToggle);
		add(_directionButton);
		
		_velocityButton = new FlxButton(260, FlxG.height - 66, "Velocity", onVelocityToggle);
		add(_velocityButton);
		
		_angularVelocityButton = new FlxButton(340, FlxG.height - 66, "Angular Vel.", onAngularVelocityToggle);
		add(_angularVelocityButton);
		
		_angleButton = new FlxButton(420, FlxG.height - 66, "Angle", onAngleToggle);
		add(_angleButton);
		
		_lifespanButton = new FlxButton(500, FlxG.height - 66, "Lifespan", onLifespanToggle);
		add(_lifespanButton);
		
		_scaleButton = new FlxButton(20, FlxG.height - 44, "Scale", onScaleToggle);
		add(_scaleButton);
		
		_alphaButton = new FlxButton(100, FlxG.height - 44, "Alpha", onAlphaToggle);
		add(_alphaButton);
		
		_colorButton = new FlxButton(180, FlxG.height - 44, "Color", onColorToggle);
		add(_colorButton);
		
		_dragButton = new FlxButton(260, FlxG.height - 44, "Drag", onDragToggle);
		add(_dragButton);
		
		_accelerationButton = new FlxButton(340, FlxG.height - 44, "Acceleration", onAccelerationToggle);
		add(_accelerationButton);
		
		_elasticityButton = new FlxButton(420, FlxG.height - 44, "Elasticity", onElasticityToggle);
		add(_elasticityButton);
		
		_collisionButton = new FlxButton(500, FlxG.height - 44, "Collision", onCollisionToggle);
		add(_collisionButton);
		
		_gravityButton = new FlxButton(20, FlxG.height - 22, "Gravity", onGravityToggle);
		add(_gravityButton);
		
		// Provide some feedback on what the user has toggled
		
		topText = new FlxText(0, 2, FlxG.width, "");
		topText.alignment = CENTER;
		topText.size = 32;
		updateText("Welcome to the particles demo!");
		add(topText);
		
		// Let's setup some walls for our particles to collide against
		_collisionGroup = new FlxGroup();
		_wall = new FlxSprite(100, FlxG.height / 2 - 50);
		// Make it darker - easier on the eyes :)
		_wall.makeGraphic(10, 100, FlxColor.GRAY); 
		// Set both the visibility AND the solidity to false, in one go
		_wall.visible = _wall.solid = false;
		// Lets make sure the pixels don't push out wall away! (though it does look funny)
		_wall.immovable = true;
		_collisionGroup.add(_wall);
		
		// Duplicate our wall but this time it's a floor to catch gravity affected particles
		_floor = new FlxSprite(10, FlxG.height - 33);
		_floor.makeGraphic(FlxG.width - 20, 10, FlxColor.GRAY);
		_floor.visible = _floor.solid = false;
		_floor.immovable = true;
		_collisionGroup.add(_floor);
		
		// Please note that this demo makes the walls themselves not collide, for the sake of simplicity.
		// Normally you would make the particles have solid = true or false to make them collide or not on creation,
		// because in a normal environment your particles probably aren't going to change solidity at a mouse click.
		
		// Don't forget to add the group to the state
		add(_collisionGroup);
		
		// Now lets set our emitter free.
		// Params: Explode, Particle Lifespan, Emit rate (in seconds)
		_emitter.start(false, 0.01);
	}
	
	override public function update():Void
	{
		super.update();
		
		FlxG.collide(_emitter, _collisionGroup);
	}
	
	private function updateText(NewText:String, ?Status:Null<Bool>):Void
	{
		topText.text = NewText;
		
		if (Status != null)
		{
			topText.text += Status ? ": ON" : ": OFF";
		}
		
		topText.alpha = 1;
		
		if (_alphaTween != null)
		{
			_alphaTween.cancel();
		}
		
		_alphaTween = FlxTween.tween(topText, { alpha: 0 }, 2);
	}
	
	private function onBlendToggle():Void
	{
		_isBlendOn = !_isBlendOn;
		
		if (_isBlendOn)
		{
			_emitter.blend = BlendMode.INVERT;
		}
		else
		{
			_emitter.blend = null;
		}
		
		updateText("BlendMode", _isBlendOn);
	}
	
	private function onLaunchModeToggle():Void
	{
		_isLaunchOn = !_isLaunchOn;
		
		if (_isLaunchOn)
		{
			_emitter.launchMode = FlxEmitterMode.CIRCLE;
			
			if (_isDirectionOn)
			{
				_emitter.launchAngle.set(-45, 45);
			}
			
			updateText("LaunchMode: CIRCLE");
		}
		else
		{
			_emitter.launchMode = FlxEmitterMode.SQUARE;
			
			if (_isDirectionOn)
			{
				_emitter.velocity.setAll(200, -100, 200, 100);
			}
			
			updateText("LaunchMode: SQUARE");
		}
	}
	
	private function onDirectionToggle():Void
	{
		_isDirectionOn = !_isDirectionOn;
		
		if (_isDirectionOn)
		{
			if (_emitter.launchMode == FlxEmitterMode.CIRCLE)
			{
				_emitter.launchAngle.set(-45, 45);
			}
			else
			{
				_emitter.velocity.setAll(200, -100, 200, 100);
			}
			
			updateText("Launching to the right");
		}
		else
		{
			_emitter.launchAngle.set(-180, 180);
			_emitter.velocity.setAll( -100, -100, 100, 100);
			
			updateText("Launching in all directions");
		}
	}
	
	private function onVelocityToggle():Void
	{
		_isVelocityOn = !_isVelocityOn;
		
		if (_isVelocityOn)
		{
			_emitter.velocity.setAll(50, 40, 60, 80, -400, -600, 400, 600);
		}
		else
		{
			_emitter.velocity.setAll( -100, -100, 100, 100);
		}
		
		updateText("Emitter velocity scaling", _isVelocityOn);
	}
	
	private function onAngularVelocityToggle():Void
	{
		_isAngularVelocityOn = !_isAngularVelocityOn;
		
		if (_isAngularVelocityOn)
		{
			_emitter.angularVelocity.setAll( -180, 180, -90, 90);
		}
		else
		{
			_emitter.angularVelocity.setAll(0);
		}
		
		updateText("Angular velocity", _isAngularVelocityOn);
	}
	
	private function onAngleToggle():Void
	{
		_isAngleOn = !_isAngleOn;
	}
	
	private function onLifespanToggle():Void
	{
		_isLifespanOn = !_isLifespanOn;
	}
	
	private function onScaleToggle():Void
	{
		_isScaleOn = !_isScaleOn;
		
		if (_isScaleOn)
		{
			_emitter.scale.setAll(1, 1, 1, 1, 2, 2, 4, 4);
		}
		else
		{
			_emitter.scale.setAll(1);
		}
		
		updateText("Scaling", _isScaleOn);
	}
	
	private function onAlphaToggle():Void
	{
		_isAlphaOn = !_isAlphaOn;
	}
	
	private function onColorToggle():Void
	{
		_isColorOn = !_isColorOn;
		
		if (_isColorOn)
		{
			_emitter.color.setAll(FlxColor.RED, FlxColor.PINK, FlxColor.BLUE, FlxColor.NAVY_BLUE);
		}
		else
		{
			_emitter.color.setAll(FlxColor.WHITE);
		}
		
		updateText("Color", _isColorOn);
	}
	
	private function onDragToggle():Void
	{
		_isDragOn = !_isDragOn;
	}
	
	private function onAccelerationToggle():Void
	{
		_isAccelerationOn = !_isAccelerationOn;
	}
	
	private function onElasticityToggle():Void
	{
		_isElasticityOn = !_isElasticityOn;
	}
	
	private function onCollisionToggle():Void
	{
		_isCollisionOn = !_isCollisionOn;
	}
	
	private function onGravityToggle():Void
	{
		_isGravityOn = !_isGravityOn;
	}
}