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

enum Choice
{
	FIGHT;
	FLEE;
}

class CombatHUD extends FlxTypedGroup<FlxSprite>
{
	// These public variables will be used after combat has finished to help tell us what happened.
	public var enemy:Enemy; // we will pass the enemySprite that the playerSprite touched to initialize combat, and this will let us also know which enemySprite to kill, etc.
	public var playerHealth(default, null):Int; // when combat has finished, we will need to know how much remaining health the playerSprite has
	public var outcome(default, null):Outcome; // when combat has finished, we will need to know if the playerSprite killed the enemySprite or fled

	// These are the sprites that we will use to show the combat hud interface
	var background:FlxSprite; // this is the background sprite
	var playerSprite:Player; // this is a sprite of the playerSprite
	var enemySprite:Enemy; // this is a sprite of the enemySprite

	// These variables will be used to track the enemySprite's health
	var enemyHealth:Int;
	var enemyMaxHealth:Int;
	var enemyHealthBar:FlxBar; // This FlxBar will show us the enemySprite's current/max health

	var playerHealthCounter:FlxText; // this will show the playerSprite's current/max health

	var damages:Array<FlxText>; // This array will contain 2 FlxText objects which will appear to show damage dealt (or misses)

	var pointer:FlxSprite; // This will be the pointer to show which option (Fight or Flee) the user is pointing to.
	var selected:Choice; // this will track which option is selected
	var choices:Map<Choice, FlxText>; // this map will contain the FlxTexts for our 2 options: Fight and Flee

	var results:FlxText; // this text will show the outcome of the battle for the playerSprite.

	var alpha:Float = 0; // we will use this to fade in and out our combat hud
	var wait:Bool = true; // this flag will be set to true when don't want the playerSprite to be able to do anything (between turns)

	var fledSound:FlxSound;
	var hurtSound:FlxSound;
	var loseSound:FlxSound;
	var missSound:FlxSound;
	var selectSound:FlxSound;
	var winSound:FlxSound;
	var combatSound:FlxSound;

	var screen:FlxSprite;

	public function new()
	{
		super();

		screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 4, -1, 4);
		var waveSprite = new FlxEffectSprite(screen, [waveEffect]);
		add(waveSprite);

		// first, create our background. Make a black square, then draw borders onto it in white. Add it to our group.
		background = new FlxSprite().makeGraphic(120, 120, FlxColor.WHITE);
		background.drawRect(1, 1, 118, 44, FlxColor.BLACK);
		background.drawRect(1, 46, 118, 73, FlxColor.BLACK);
		background.screenCenter();
		add(background);

		// next, make a 'dummy' playerSprite that looks like our playerSprite (but can't move) and add it.
		playerSprite = new Player(background.x + 36, background.y + 16);
		playerSprite.animation.frameIndex = 3;
		playerSprite.active = false;
		playerSprite.facing = FlxObject.RIGHT;
		add(playerSprite);

		// do the same thing for an enemySprite. We'll just use enemySprite type REGULAR for now and change it later.
		enemySprite = new Enemy(background.x + 76, background.y + 16, REGULAR);
		enemySprite.animation.frameIndex = 3;
		enemySprite.active = false;
		enemySprite.facing = FlxObject.LEFT;
		add(enemySprite);

		// setup the playerSprite's health display and add it to the group.
		playerHealthCounter = new FlxText(0, playerSprite.y + playerSprite.height + 2, 0, "3 / 3", 8);
		playerHealthCounter.alignment = CENTER;
		playerHealthCounter.x = playerSprite.x + 4 - (playerHealthCounter.width / 2);
		add(playerHealthCounter);

		// create and add a FlxBar to show the enemySprite's health. We'll make it Red and Yellow.
		enemyHealthBar = new FlxBar(enemySprite.x - 6, playerHealthCounter.y, LEFT_TO_RIGHT, 20, 10);
		enemyHealthBar.createFilledBar(0xffdc143c, FlxColor.YELLOW, true, FlxColor.YELLOW);
		add(enemyHealthBar);

		// create our choices and add them to the group.
		choices = new Map();
		choices[FIGHT] = new FlxText(background.x + 30, background.y + 48, 85, "FIGHT", 22);
		choices[FLEE] = new FlxText(background.x + 30, choices[FIGHT].y + choices[FIGHT].height + 8, 85, "FLEE", 22);
		add(choices[FIGHT]);
		add(choices[FLEE]);

		pointer = new FlxSprite(background.x + 10, choices[FIGHT].y + (choices[FIGHT].height / 2) - 8, AssetPaths.pointer__png);
		pointer.visible = false;
		add(pointer);

		// create our damage texts. We'll make them be white text with a red shadow (so they stand out).
		damages = new Array<FlxText>();
		damages.push(new FlxText(0, 0, 40));
		damages.push(new FlxText(0, 0, 40));
		for (d in damages)
		{
			d.color = FlxColor.WHITE;
			d.setBorderStyle(SHADOW, FlxColor.RED);
			d.alignment = CENTER;
			d.visible = false;
			add(d);
		}

		// create our results text object. We'll position it, but make it hidden for now.
		results = new FlxText(background.x + 2, background.y + 9, 116, "", 18);
		results.alignment = CENTER;
		results.color = FlxColor.YELLOW;
		results.setBorderStyle(SHADOW, FlxColor.GRAY);
		results.visible = false;
		add(results);

		// like we did in our HUD class, we need to set the scrollFactor on each of our children objects to 0,0. We also set alpha to 0 (so we can fade this in)
		forEach(function(sprite:FlxSprite)
		{
			sprite.scrollFactor.set();
			sprite.alpha = 0;
		});

		// mark this object as not active and not visible so update and draw don't get called on it until we're ready to show it.
		active = false;
		visible = false;

		fledSound = FlxG.sound.load(AssetPaths.fled__wav);
		hurtSound = FlxG.sound.load(AssetPaths.hurt__wav);
		loseSound = FlxG.sound.load(AssetPaths.lose__wav);
		missSound = FlxG.sound.load(AssetPaths.miss__wav);
		selectSound = FlxG.sound.load(AssetPaths.select__wav);
		winSound = FlxG.sound.load(AssetPaths.win__wav);
		combatSound = FlxG.sound.load(AssetPaths.combat__wav);
	}

	/**
	 * This function will be called from PlayState when we want to start combat. It will setup the screen and make sure everything is ready.
	 * @param	playerHealth	The amount of health the playerSprite is starting with
	 * @param	enemy			This links back to the Enemy we are fighting with so we can get it's health and type (to change our sprite).
	 */
	public function initCombat(playerHealth:Int, enemy:Enemy)
	{
		screen.drawFrame();
		var screenPixels = screen.framePixels;

		if (FlxG.renderBlit)
			screenPixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		else
			screenPixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));

		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		screenPixels.applyFilter(screenPixels, screenPixels.rect, new Point(),
			new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));

		combatSound.play();
		this.playerHealth = playerHealth; // we set our playerHealth variable to the value that was passed to us
		this.enemy = enemy; // set our enemySprite object to the one passed to us

		updatePlayerHealth();

		// setup our enemySprite
		enemyMaxHealth = enemyHealth = if (enemy.type == REGULAR) 2 else 4; // each enemySprite will have health based on their type
		enemyHealthBar.value = 100; // the enemySprite's health bar starts at 100%
		enemySprite.changeType(enemy.type); // change our enemySprite's image to match their type.

		// make sure we initialize all of these before we start so nothing looks 'wrong' the second time we get
		wait = true;
		results.text = "";
		pointer.visible = false;
		results.visible = false;
		outcome = NONE;
		selected = FIGHT;
		movePointer();

		visible = true; // make our hud visible (so draw gets called on it) - note, it's not active, yet!

		// do a numeric tween to fade in our combat hud when the tween is finished, call finishFadeIn
		FlxTween.num(0, 1, .66, {ease: FlxEase.circOut, onComplete: finishFadeIn}, updateAlpha);
	}

	/**
	 * This function is called by our Tween to fade in/out all the items in our hud.
	 */
	function updateAlpha(alpha:Float)
	{
		this.alpha = alpha;
		forEach(function(sprite) sprite.alpha = alpha);
	}

	/**
	 * When we've finished fading in, we set our hud to active (so it gets updates), and allow the playerSprite to interact. We show our pointer, too.
	 */
	function finishFadeIn(_)
	{
		active = true;
		wait = false;
		pointer.visible = true;
		selectSound.play();
	}

	/**
	 * After we fade our hud out, we set it to not be active or visible (no update and no draw)
	 */
	function finishFadeOut(_)
	{
		active = false;
		visible = false;
	}

	/**
	 * This function is called to change the Player's health text on the screen.
	 */
	function updatePlayerHealth()
	{
		playerHealthCounter.text = playerHealth + " / 3";
		playerHealthCounter.x = playerSprite.x + 4 - (playerHealthCounter.width / 2);
	}

	override public function update(elapsed:Float)
	{
		if (!wait) // if we're waiting, don't do any of this.
		{
			updateKeyboardInput();
			updateTouchInput();
		}
		super.update(elapsed);
	}

	function updateKeyboardInput()
	{
		#if FLX_KEYBOARD
		// setup some simple flags to see which keys are pressed.
		var up:Bool = false;
		var down:Bool = false;
		var fire:Bool = false;

		// check to see any keys are pressed and set the cooresponding flags.
		if (FlxG.keys.anyJustReleased([SPACE, X, ENTER]))
		{
			fire = true;
		}
		else if (FlxG.keys.anyJustReleased([W, UP]))
		{
			up = true;
		}
		else if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			down = true;
		}

		// based on which flags are set, do the specified action
		if (fire)
		{
			selectSound.play();
			makeChoice(); // when the playerSprite chooses either option, we call this function to process their selection
		}
		else if (up || down)
		{
			// if the playerSprite presses up or down, we move the cursor up or down (with wrapping)
			selected = if (selected == FIGHT) FLEE else FIGHT;
			selectSound.play();
			movePointer();
		}
		#end
	}

	function updateTouchInput()
	{
		#if FLX_TOUCH
		for (touch in FlxG.touches.justReleased())
		{
			for (choice in choices.keys())
			{
				var text = choices[choice];
				if (touch.overlaps(text))
				{
					selectSound.play();
					selected = choice;
					movePointer();
					makeChoice();
					return;
				}
			}
		}
		#end
	}

	/**
	 * Call this function to place the pointer next to the currently selected choice
	 */
	function movePointer()
	{
		pointer.y = choices[selected].y + (choices[selected].height / 2) - 8;
	}

	/**
	 * This function will process the choice the playerSprite picked
	 */
	function makeChoice()
	{
		pointer.visible = false; // hide our pointer
		switch (selected) // check which item was selected when the playerSprite picked it
		{
			case FIGHT:
				// if FIGHT was picked...
				// ...the playerSprite attacks the enemySprite first
				// they have an 85% chance to hit the enemySprite
				if (FlxG.random.bool(85))
				{
					// if they hit, deal 1 damage to the enemySprite, and setup our damage indicator
					damages[1].text = "1";
					FlxTween.tween(enemySprite, {x: enemySprite.x + 4}, 0.1, {
						onComplete: function(_)
						{
							FlxTween.tween(enemySprite, {x: enemySprite.x - 4}, 0.1);
						}
					});
					hurtSound.play();
					enemyHealth--;
					enemyHealthBar.value = (enemyHealth / enemyMaxHealth) * 100; // change the enemySprite's health bar
				}
				else
				{
					// change our damage text to show that we missed!
					damages[1].text = "MISS!";
					missSound.play();
				}

				// position the damage text over the enemySprite, and set it's alpha to 0 but it's visible to true (so that it gets draw called on it)
				damages[1].x = enemySprite.x + 2 - (damages[1].width / 2);
				damages[1].y = enemySprite.y + 4 - (damages[1].height / 2);
				damages[1].alpha = 0;
				damages[1].visible = true;

				// if the enemySprite is still alive, it will swing back!
				if (enemyHealth > 0)
				{
					enemyAttack();
				}

				// setup 2 tweens to allow the damage indicators to fade in and float up from the sprites
				FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);

			case FLEE:
				// if the playerSprite chose to FLEE, we'll give them a 50/50 chance to escape
				if (FlxG.random.bool(50))
				{
					// if they succeed, we show the 'escaped' message and trigger it to fade in
					outcome = ESCAPE;
					results.text = "ESCAPED!";
					fledSound.play();
					results.visible = true;
					results.alpha = 0;
					FlxTween.tween(results, {alpha: 1}, .66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
				}
				else
				{
					// if they fail to escape, the enemySprite will get a free-swing
					enemyAttack();
					FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
					FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);
				}
		}

		// regardless of what happens, we need to set our 'wait' flag so that we can show what happened before moving on
		wait = true;
	}

	/**
	 * This function is called anytime we want the enemySprite to swing at the playerSprite
	 */
	function enemyAttack()
	{
		// first, lets see if the enemySprite hits or not. We'll give him a 30% chance to hit
		if (FlxG.random.bool(30))
		{
			// if we hit, flash the screen white, and deal one damage to the playerSprite - then update the playerSprite's health
			FlxG.camera.flash(FlxColor.WHITE, .2);
			FlxG.camera.shake(0.01, 0.2);
			hurtSound.play();
			damages[0].text = "1";
			playerHealth--;
			updatePlayerHealth();
		}
		else
		{
			// if the enemySprite misses, show it on the screen
			damages[0].text = "MISS!";
			missSound.play();
		}

		// setup the combat text to show up over the playerSprite and fade in/raise up
		damages[0].x = playerSprite.x + 2 - (damages[0].width / 2);
		damages[0].y = playerSprite.y + 4 - (damages[0].height / 2);
		damages[0].alpha = 0;
		damages[0].visible = true;
	}

	/**
	 * This function is called from our Tweens to move the damage displays up on the screen
	 */
	function updateDamageY(damageY:Float)
	{
		damages[0].y = damages[1].y = damageY;
	}

	/**
	 * This function is called from our Tweens to fade in/out the damage text
	 */
	function updateDamageAlpha(damageAlpha:Float)
	{
		damages[0].alpha = damages[1].alpha = damageAlpha;
	}

	/**
	 * This function is called when our damage texts have finished fading in - it will trigger them to start fading out again, after a short delay
	 */
	function doneDamageIn(_)
	{
		FlxTween.num(1, 0, .66, {ease: FlxEase.circInOut, startDelay: 1, onComplete: doneDamageOut}, updateDamageAlpha);
	}

	/**
	 * This function is triggered when our results text has finished fading in. If we're not defeated, we will fade out the entire hud after a short delay
	 */
	function doneResultsIn(_)
	{
		FlxTween.num(1, 0, .66, {ease: FlxEase.circOut, onComplete: finishFadeOut, startDelay: 1}, updateAlpha);
	}

	/**
	 * This function is triggered when the damage texts have finished fading out again. They will clear and reset them for next time.
	 * It will also check to see what we're supposed to do next - if the enemySprite is dead, we trigger victory, if the playerSprite is dead we trigger defeat, otherwise we reset for the next round.
	 */
	function doneDamageOut(_)
	{
		damages[0].visible = false;
		damages[1].visible = false;
		damages[0].text = "";
		damages[1].text = "";

		if (playerHealth <= 0)
		{
			// if the playerSprite's health is 0, we show the defeat message on the screen and fade it in
			outcome = DEFEAT;
			loseSound.play();
			results.text = "DEFEAT!";
			results.visible = true;
			results.alpha = 0;
			FlxTween.tween(results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else if (enemyHealth <= 0)
		{
			// if the enemySprite's health is 0, we show the victory message
			outcome = VICTORY;
			winSound.play();
			results.text = "VICTORY!";
			results.visible = true;
			results.alpha = 0;
			FlxTween.tween(results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else
		{
			// both are still alive, so we reset and have the playerSprite pick their next action
			wait = false;
			pointer.visible = true;
		}
	}
}
