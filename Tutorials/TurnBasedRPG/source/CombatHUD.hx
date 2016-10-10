package;

import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class CombatHUD extends FlxTypedGroup<FlxSprite>
{
	// ** These public variables will be used after combat has finished to help tell us what happened.
	public var e:Enemy;		// we will pass the enemy that the player touched to initialize combat, and this will let us also know which enemy to kill, etc.
	public var playerHealth(default, null):Int;	// when combat has finished, we will need to know how much remaining health the player has
	public var outcome(default, null):Outcome;	// when combat has finished, we will need to know if the player killed the enemy or fled
	
	// ** These are the sprites that we will use to show the combat hud interface
	private var _sprBack:FlxSprite;	// this is the background sprite
	private var _sprPlayer:Player;	// this is a sprite of the player
	private var _sprEnemy:Enemy;	// this is a sprite of the enemy
	
	// ** These variables will be used to track the enemy's health
	private var _enemyHealth:Int;
	private var _enemyMaxHealth:Int;
	private var _enemyHealthBar:FlxBar;	// This FlxBar will show us the enemy's current/max health
	
	private var _txtPlayerHealth:FlxText;	// this will show the player's current/max health
	
	private var _damages:Array<FlxText>;	// This array will contain 2 FlxText objects which will appear to show damage dealt (or misses)
	
	private var _pointer:FlxSprite;			// This will be the pointer to show which option (Fight or Flee) the user is pointing to.
	private var _selected:Int = 0;			// this will track which option is selected
	private var _choices:Array<FlxText>;	// this array will contain the FlxTexts for our 2 options: Fight and Flee
	
	private var _results:FlxText;	// this text will show the outcome of the battle for the player.
	
	private var _alpha:Float = 0;	// we will use this to fade in and out our combat hud
	private var _wait:Bool = true;	// this flag will be set to true when don't want the player to be able to do anything (between turns)
	
	private var _sndFled:FlxSound;
	private var _sndHurt:FlxSound;
	private var _sndLose:FlxSound;
	private var _sndMiss:FlxSound;
	private var _sndSelect:FlxSound;
	private var _sndWin:FlxSound;
	private var _sndCombat:FlxSound;
	
	private var _sprScreen:FlxSprite;
	
	public function new() 
	{
		super();
		
		_sprScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 4, -1, 4);
		var waveSprite = new FlxEffectSprite(_sprScreen, [waveEffect]);
		add(waveSprite);
		
		// first, create our background. Make a black square, then draw borders onto it in white. Add it to our group.
		_sprBack = new FlxSprite().makeGraphic(120, 120, FlxColor.WHITE);
		_sprBack.drawRect(1, 1, 118, 44, FlxColor.BLACK);
		_sprBack.drawRect(1, 46, 118, 73, FlxColor.BLACK);
		_sprBack.screenCenter();
		add(_sprBack);
		
		// next, make a 'dummy' player that looks like our player (but can't move) and add it.
		_sprPlayer = new Player(_sprBack.x + 36, _sprBack.y + 16);
		_sprPlayer.animation.frameIndex = 3;
		_sprPlayer.active = false;
		_sprPlayer.facing = FlxObject.RIGHT;
		add(_sprPlayer);
		
		// do the same thing for an enemy. We'll just use enemy type 0 for now and change it later.
		_sprEnemy = new Enemy(_sprBack.x + 76, _sprBack.y + 16, 0);
		_sprEnemy.animation.frameIndex = 3;
		_sprEnemy.active = false;
		_sprEnemy.facing = FlxObject.LEFT;
		add(_sprEnemy);
		
		// setup the player's health display and add it to the group.
		_txtPlayerHealth = new FlxText(0, _sprPlayer.y + _sprPlayer.height  + 2, 0, "3 / 3", 8);
		_txtPlayerHealth.alignment = CENTER;
		_txtPlayerHealth.x = _sprPlayer.x + 4 - (_txtPlayerHealth.width / 2);
		add(_txtPlayerHealth);
		
		// create and add a FlxBar to show the enemy's health. We'll make it Red and Yellow.
		_enemyHealthBar = new FlxBar(_sprEnemy.x - 6, _txtPlayerHealth.y, LEFT_TO_RIGHT, 20, 10);
		_enemyHealthBar.createFilledBar(0xffdc143c, FlxColor.YELLOW, true, FlxColor.YELLOW);
		add(_enemyHealthBar);
		
		// create our choices and add them to the group.
		_choices = new Array<FlxText>();
		_choices.push(new FlxText(_sprBack.x + 30, _sprBack.y + 48, 85, "FIGHT", 22));
		_choices.push(new FlxText(_sprBack.x + 30, _choices[0].y + _choices[0].height + 8, 85, "FLEE", 22));
		add(_choices[0]);
		add(_choices[1]);
		
		_pointer = new FlxSprite(_sprBack.x + 10, _choices[0].y + (_choices[0].height / 2) - 8, AssetPaths.pointer__png);
		_pointer.visible = false;
		add(_pointer);
		
		// create our damage texts. We'll make them be white text with a red shadow (so they stand out). 
		_damages = new Array<FlxText>();
		_damages.push(new FlxText(0, 0, 40));
		_damages.push(new FlxText(0, 0, 40));
		for (d in _damages)
		{
			d.color = FlxColor.WHITE;
			d.setBorderStyle(SHADOW, FlxColor.RED);
			d.alignment = CENTER;
			d.visible = false;
			add(d);
		}
		
		// create our results text object. We'll position it, but make it hidden for now.
		_results = new FlxText(_sprBack.x + 2, _sprBack.y + 9, 116, "", 18);
		_results.alignment = CENTER;
		_results.color = FlxColor.YELLOW;
		_results.setBorderStyle(SHADOW, FlxColor.GRAY);
		_results.visible = false;
		add(_results);
		
		// like we did in our HUD class, we need to set the scrollFactor on each of our children objects to 0,0. We also set alpha to 0 (so we can fade this in)
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set();
			spr.alpha = 0;
		});
		
		// mark this object as not active and not visible so update and draw don't get called on it until we're ready to show it.
		active = false;
		visible = false;
		
		_sndFled = FlxG.sound.load(AssetPaths.fled__wav);
		_sndHurt = FlxG.sound.load(AssetPaths.hurt__wav);
		_sndLose = FlxG.sound.load(AssetPaths.lose__wav);
		_sndMiss = FlxG.sound.load(AssetPaths.miss__wav);
		_sndSelect = FlxG.sound.load(AssetPaths.select__wav);
		_sndWin = FlxG.sound.load(AssetPaths.win__wav);
		_sndCombat = FlxG.sound.load(AssetPaths.combat__wav);
	}
	
	/**
	 * This function will be called from PlayState when we want to start combat. It will setup the screen and make sure everything is ready.
	 * @param	PlayerHealth	The amount of health the player is starting with
	 * @param	E				This links back to the Enemy we are fighting with so we can get it's health and type (to change our sprite).
	 */
	public function initCombat(PlayerHealth:Int, E:Enemy):Void
	{
		_sprScreen.drawFrame();
		var screenPixels = _sprScreen.framePixels;
		
		if (FlxG.renderBlit)
			screenPixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		else
			screenPixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));
		
		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		screenPixels.applyFilter(screenPixels, screenPixels.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
		
		_sndCombat.play();
		playerHealth = PlayerHealth;	// we set our playerHealth variable to the value that was passed to us
		e = E;	// set our enemy object to the one passed to us
		
		updatePlayerHealth();	// update the player health text
		
		// setup our enemy
		_enemyMaxHealth = _enemyHealth = (e.etype + 1) * 2; // each enemy will have health based on their type: Type 0 = 2 health, type 1 = 4 health
		_enemyHealthBar.value = 100;	// the enemy's health bar starts at 100%
		_sprEnemy.changeEnemy(e.etype);	// change our enemy's image to match their type.
		
		// make sure we initialize all of these before we start so nothing looks 'wrong' the second time we get 
		_wait = true;
		_results.text = "";
		_pointer.visible = false;
		_results.visible = false;
		outcome = NONE;
		_selected = 0;
		movePointer();
		
		visible = true;	// make our hud visible (so draw gets called on it) - note, it's not active, yet!
		
		// do a numeric tween to fade in our combat hud when the tween is finished, call finishFadeIn
		FlxTween.num(0, 1, .66, { ease: FlxEase.circOut, onComplete: finishFadeIn }, updateAlpha);
	}
	
	/**
	 * This function is called by our Tween to fade in/out all the items in our hud.
	 */
	private function updateAlpha(Value:Float):Void
	{
		_alpha = Value;
		forEach(function(spr:FlxSprite)
		{
			spr.alpha = _alpha;
		});
	}
	
	/**
	 * When we've finished fading in, we set our hud to active (so it gets updates), and allow the player to interact. We show our pointer, too.
	 */
	private function finishFadeIn(_):Void
	{
		active = true;
		_wait = false;
		_pointer.visible = true;
		_sndSelect.play();
	}
	
	/**
	 * After we fade our hud out, we set it to not be active or visible (no update and no draw)
	 */
	private function finishFadeOut(_):Void
	{
		active = false;
		visible = false;
	}
	
	/**
	 * This function is called to change the Player's health text on the screen.
	 */
	private function updatePlayerHealth():Void
	{
		_txtPlayerHealth.text = playerHealth + " / 3";
		_txtPlayerHealth.x = _sprPlayer.x + 4 - (_txtPlayerHealth.width / 2);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (!_wait)
		{
			// if we're waiting, don't do any of this.
			
			#if FLX_KEYBOARD
			// setup some simple flags to see which keys are pressed.
			var _up:Bool = false;
			var _down:Bool = false;
			var _fire:Bool = false;
			
			// check to see any keys are pressed and set the cooresponding flags.
			if (FlxG.keys.anyJustReleased([SPACE, X, ENTER]))
			{
				_fire = true;
			}
			else if (FlxG.keys.anyJustReleased([W, UP]))
			{
				_up = true;
			}
			else if (FlxG.keys.anyJustReleased([S, DOWN]))
			{
				_down = true;
			}
			
			// based on which flags are set, do the specified action
			if (_fire)
			{
				_sndSelect.play();
				makeChoice(); // when the player chooses either option, we call this function to process their selection
			}
			else if (_up)
			{
				// if the player presses up, we move the cursor up (with wrapping)
				if (_selected == 0)
					_selected = 1;
				else
					_selected--;
				_sndSelect.play();
				movePointer();
			}
			else if (_down)
			{
				// if the player presses down, we move the cursor down (with wrapping)
				if (_selected == 1)
					_selected = 0;
				else
					_selected++;
				_sndSelect.play();
				movePointer();
			}
			#end
			#if FLX_TOUCH
			var didSelect:Bool = false;
			for (touch in FlxG.touches.justReleased())
			{
				if (!didSelect)
				{
					if (touch.overlaps(_choices[0]))
					{
						didSelect = true;
						_sndSelect.play();
						_selected = 0;
						movePointer();
						makeChoice();
					}
					else if (touch.overlaps(_choices[1]))
					{
						didSelect = true;
						_sndSelect.play();
						_selected = 1;
						movePointer();
						makeChoice();
					}
				}
			}
			#end
		}
		super.update(elapsed);
	}
	
	/**
	 * Call this function to place the pointer next to the currently selected choice
	 */
	private function movePointer():Void
	{
		_pointer.y = _choices[_selected].y + (_choices[_selected].height / 2) - 8;
	}
	
	/**
	 * This function will process the choice the player picked
	 */
	private function makeChoice():Void
	{
		_pointer.visible = false;	// hide our pointer
		switch (_selected)	// check which item was selected when the player picked it
		{
			case 0:
				// if choice 0: FIGHT was picked...
				
				// ...the player attacks the enemy first
				// they have an 85% chance to hit the enemy
				if (FlxG.random.bool(85))
				{
					// if they hit, deal 1 damage to the enemy, and setup our damage indicator
					_damages[1].text = "1";
					FlxTween.tween(_sprEnemy, { x: _sprEnemy.x + 4 }, .1, { onComplete: function(_)
					{
						FlxTween.tween(_sprEnemy, { x: _sprEnemy.x - 4 }, .1);
					}});
					_sndHurt.play();
					_enemyHealth--;
					_enemyHealthBar.value = (_enemyHealth / _enemyMaxHealth) * 100; // change the enemy's health bar
				}
				else
				{
					// change our damage text to show that we missed!
					_damages[1].text = "MISS!";
					_sndMiss.play();
				}
				
				// position the damage text over the enemy, and set it's alpha to 0 but it's visible to true (so that it gets draw called on it)
				_damages[1].x = _sprEnemy.x + 2 - (_damages[1].width / 2);
				_damages[1].y = _sprEnemy.y + 4 - (_damages[1].height / 2);
				_damages[1].alpha = 0;
				_damages[1].visible = true;
				
				// if the enemy is still alive, it will swing back!
				if (_enemyHealth > 0)
				{
					enemyAttack();
				}
				
				// setup 2 tweens to allow the damage indicators to fade in and float up from the sprites
				FlxTween.num(_damages[0].y, _damages[0].y - 12, 1, { ease:FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, { ease: FlxEase.circInOut, onComplete: doneDamageIn }, updateDamageAlpha);
				
			case 1:
				
				// if the player chose to FLEE, we'll give them a 50/50 chance to escape
				if (FlxG.random.bool(50))
				{
					// if they succeed, we show the 'escaped' message and trigger it to fade in
					outcome = ESCAPE;
					_results.text = "ESCAPED!";
					_sndFled.play();
					_results.visible = true;
					_results.alpha = 0;
					FlxTween.tween(_results, { alpha:1 }, .66, { ease:FlxEase.circInOut, onComplete:doneResultsIn });
				}
				else
				{
					// if they fail to escape, the enemy will get a free-swing
					enemyAttack();
					FlxTween.num(_damages[0].y, _damages[0].y - 12, 1, { ease: FlxEase.circOut}, updateDamageY);
					FlxTween.num(0, 1, .2, { ease: FlxEase.circInOut, onComplete: doneDamageIn }, updateDamageAlpha);
				}
		}
		
		// regardless of what happens, we need to set our 'wait' flag so that we can show what happened before moving on
		_wait = true;
	}
	
	/**
	 * This function is called anytime we want the enemy to swing at the player
	 */
	private function enemyAttack():Void
	{
		// first, lets see if the enemy hits or not. We'll give him a 30% chance to hit
		if (FlxG.random.bool(30))
		{
			// if we hit, flash the screen white, and deal one damage to the player - then update the player's health
			FlxG.camera.flash(FlxColor.WHITE, .2);
			FlxG.camera.shake(0.01, 0.2);
			_sndHurt.play();
			_damages[0].text = "1";
			playerHealth--;
			updatePlayerHealth();
		}
		else
		{
			// if the enemy misses, show it on the screen
			_damages[0].text = "MISS!";
			_sndMiss.play();
		}
		
		// setup the combat text to show up over the player and fade in/raise up
		_damages[0].x = _sprPlayer.x + 2 - (_damages[0].width / 2);
		_damages[0].y = _sprPlayer.y + 4 - (_damages[0].height / 2);
		_damages[0].alpha = 0;
		_damages[0].visible = true;
	}
	
	/**
	 * This function is called from our Tweens to move the damage displays up on the screen
	 * @param	Value
	 */
	private function updateDamageY(Value:Float):Void
	{
		_damages[0].y = _damages[1].y = Value;
	}
	
	/**
	 * This function is called from our Tweens to fade in/out the damage text
	 */
	private function updateDamageAlpha(Value:Float):Void
	{
		_damages[0].alpha = _damages[1].alpha = Value;
	}
	
	/**
	 * This function is called when our damage texts have finished fading in - it will trigger them to start fading out again, after a short delay
	 */
	private function doneDamageIn(_):Void
	{
		FlxTween.num(1, 0, .66, { ease: FlxEase.circInOut, startDelay: 1, onComplete: doneDamageOut}, updateDamageAlpha);
	}
	
	/**
	 * This function is triggered when our results text has finished fading in. If we're not defeated, we will fade out the entire hud after a short delay
	 */
	private function doneResultsIn(_):Void
	{
		FlxTween.num(1, 0, .66, { ease: FlxEase.circOut, onComplete: finishFadeOut, startDelay: 1 }, updateAlpha);
	}
	
	/**
	 * This function is triggered when the damage texts have finished fading out again. They will clear and reset them for next time. 
	 * It will also check to see what we're supposed to do next - if the enemy is dead, we trigger victory, if the player is dead we trigger defeat, otherwise we reset for the next round.
	 */
	private function doneDamageOut(_):Void
	{
		_damages[0].visible = false;
		_damages[1].visible = false;
		_damages[0].text = "";
		_damages[1].text = "";
		
		if (playerHealth <= 0)
		{
			// if the player's health is 0, we show the defeat message on the screen and fade it in
			outcome = DEFEAT;
			_sndLose.play();
			_results.text = "DEFEAT!";
			_results.visible = true;
			_results.alpha = 0;
			FlxTween.tween(_results, { alpha: 1 }, .66, { ease: FlxEase.circInOut, onComplete: doneResultsIn });
		}
		else if (_enemyHealth <= 0)
		{
			// if the enemy's health is 0, we show the victory message
			outcome = VICTORY;
			_sndWin.play();
			_results.text = "VICTORY!";
			_results.visible = true;
			_results.alpha = 0;
			FlxTween.tween(_results, { alpha: 1 }, .66, { ease: FlxEase.circInOut, onComplete: doneResultsIn });
		}
		else
		{
			// both are still alive, so we reset and have the player pick their next action
			_wait = false;
			_pointer.visible = true;
		}
	}
}


/**
 * This enum is used to set the valid values for our outcome variable.
 * Outcome can only ever be one of these 4 values and we can check for these values easily once combat is concluded.
 */
enum Outcome
{
	NONE;
	ESCAPE;
	VICTORY;
	DEFEAT;
}
