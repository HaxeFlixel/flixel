package;

import flash.ui.Mouse;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxObject;
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
	private var _resetButton:FlxButton;
	
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
	
	/**
	 * Just a simple flag to see if we should display the welcome message.
	 */
	private static var _firstLoad:Bool = true;
	
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
		
		_resetButton = new FlxButton(100, FlxG.height - 22, "Reset All", onResetRequest);
		add(_resetButton);
		
		// Provide some feedback on what the user has toggled
		
		topText = new FlxText(0, 2, FlxG.width, "");
		topText.alignment = CENTER;
		topText.size = 32;
		add(topText);
		
		if (_firstLoad)
		{
			updateText("Welcome to the particles demo!");
			_firstLoad = false;
		}
		else
		{
			updateText("Demo reset!");
		}
		
		// Let's setup some walls for our particles to collide against
		
		_collisionGroup = new FlxGroup();
		
		_floor = new FlxSprite(10, FlxG.height - 88);
		_floor.makeGraphic(FlxG.width - 20, 20, FlxColor.GRAY);
		
		// Kill the floor until we need it
		_floor.kill();
		
		// Lets make sure the pixels don't push our wall away! (though it does look funny)
		_floor.immovable = true;
		_floor.solid = true;
		_floor.elasticity = 0.8;
		
		// Add the floor to its group
		_collisionGroup.add(_floor);
		
		_wall = new FlxSprite(FlxG.width - 30, 10);
		_wall.makeGraphic(20, Std.int(_floor.y - 20), FlxColor.GRAY); 
		_wall.immovable = true;
		_wall.solid = true;
		_wall.elasticity = 0.8;
		_wall.kill();
		_collisionGroup.add(_wall);
		
		// Don't forget to add the group to the state
		add(_collisionGroup);
		
		// Now lets set our emitter free.
		// Params: Explode, Emit rate (in seconds), Quantity (if ignored, means launch continuously)
		
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
		
		// Tweening alpha like this is SUPER SLOW on HTML5, so it's disabled
		
		#if !js
		_alphaTween = FlxTween.tween(topText, { alpha: 0 }, 2);
		#end
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
		
		if (_emitter.launchMode == FlxEmitterMode.SQUARE)
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
				_emitter.velocity.set(200, -100, 200, 100);
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
				_emitter.velocity.set(200, -100, 200, 100);
			}
			
			updateText("Launching to the right");
		}
		else
		{
			_emitter.launchAngle.set(-180, 180);
			_emitter.velocity.set( -100, -100, 100, 100);
			
			updateText("Launching in all directions");
		}
	}
	
	private function onVelocityToggle():Void
	{
		_isVelocityOn = !_isVelocityOn;
		
		if (_isVelocityOn)
		{
			_emitter.velocity.set(50, 40, 60, 80, -400, -600, 400, 600);
		}
		else
		{
			_emitter.velocity.set( -100, -100, 100, 100);
		}
		
		updateText("Emitter velocity scaling", _isVelocityOn);
	}
	
	private function onAngularVelocityToggle():Void
	{
		_isAngularVelocityOn = !_isAngularVelocityOn;
		
		if (_isAngularVelocityOn)
		{
			_emitter.angularVelocity.set( -180, 180, -90, 90);
		}
		else
		{
			_emitter.angularVelocity.set(0);
		}
		
		updateText("Angular velocity", _isAngularVelocityOn);
	}
	
	private function onAngleToggle():Void
	{
		_isAngleOn = !_isAngleOn;
		
		if (_isAngleOn)
		{
			_emitter.angle.set( -90, 90);
		}
		else
		{
			_emitter.angle.set(0);
		}
		
		updateText("Random initial angle", _isAngleOn);
	}
	
	private function onLifespanToggle():Void
	{
		_isLifespanOn = !_isLifespanOn;
		
		if (_isLifespanOn)
		{
			_emitter.lifespan.set(0.1, 1);
		}
		else
		{
			_emitter.lifespan.set(3, 3);
		}
		
		updateText("Lifespan range is " + _emitter.lifespan.min + " - " + _emitter.lifespan.max);
	}
	
	private function onScaleToggle():Void
	{
		_isScaleOn = !_isScaleOn;
		
		if (_isScaleOn)
		{
			_emitter.scale.set(1, 1, 1, 1, 4, 4, 8, 8);
		}
		else
		{
			_emitter.scale.set(1);
		}
		
		updateText("Scaling", _isScaleOn);
	}
	
	private function onAlphaToggle():Void
	{
		_isAlphaOn = !_isAlphaOn;
		
		if (_isAlphaOn)
		{
			_emitter.alpha.set(1, 1, 0, 0);
		}
		else
		{
			_emitter.alpha.set(1);
		}
		
		updateText("Alpha", _isAlphaOn);
	}
	
	private function onColorToggle():Void
	{
		_isColorOn = !_isColorOn;
		
		if (_isColorOn)
		{
			_emitter.color.set(FlxColor.RED, FlxColor.PINK, FlxColor.BLUE, FlxColor.CYAN);
		}
		else
		{
			_emitter.color.set(FlxColor.WHITE);
		}
		
		updateText("Color", _isColorOn);
	}
	
	private function onDragToggle():Void
	{
		_isDragOn = !_isDragOn;
		
		if (_isDragOn)
		{
			_emitter.drag.set(200, 200, 600, 600);
		}
		else
		{
			_emitter.drag.set(0);
		}
		
		updateText("Drag", _isDragOn);
	}
	
	private function onAccelerationToggle():Void
	{
		_isAccelerationOn = !_isAccelerationOn;
		
		if (_isAccelerationOn)
		{
			_emitter.acceleration.set(0, 0, 0, 0, 200, 200, 400, 400);
		}
		else
		{
			_emitter.acceleration.set(0);
		}
		
		updateText("Acceleration", _isAccelerationOn);
	}
	
	private function onElasticityToggle():Void
	{
		_isElasticityOn = !_isElasticityOn;
		
		if (_isElasticityOn)
		{
			_emitter.elasticity.set(1, 1, 1, 1);
		}
		else
		{
			_emitter.elasticity.set(0);
		}
		
		updateText("Elasticity", _isElasticityOn);
	}
	
	private function onCollisionToggle():Void
	{
		_isCollisionOn = !_isCollisionOn;
		
		if (_isCollisionOn)
		{
			_wall.revive();
			_floor.revive();
			_emitter.solid = true;
		}
		else
		{
			_wall.kill();
			_floor.kill();
			_emitter.solid = false;
		}
		
		updateText("Collisions", _isCollisionOn);
	}
	
	private function onGravityToggle():Void
	{
		_isGravityOn = !_isGravityOn;
		
		if (_isGravityOn)
		{
			_emitter.acceleration.start.min.y = 800;
			_emitter.acceleration.start.max.y = 1000;
			_emitter.acceleration.end.min.y = 800;
			_emitter.acceleration.end.max.y = 1000;
		}
		else
		{
			_emitter.acceleration.set(0);
		}
		
		updateText("Gravity", _isGravityOn);
	}
	
	private function onResetRequest():Void
	{
		FlxG.resetGame();
	}
}