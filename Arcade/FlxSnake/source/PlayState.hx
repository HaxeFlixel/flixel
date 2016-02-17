package;

import flash.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

/**
* FlxSnake for Flixel 2.23 - 19th March 2010
* Ported to HaxeFlixel
* 
* Cursor keys to move. Red squares are _fruit. Snake can wrap around screen edges.
* @author Richard Davey, Photon Storm <rich@photonstorm.com>
* 
* Largely rewritten by @author Gama11
*/
class PlayState extends FlxState
{
	private static inline var MIN_INTERVALL:Float = 2;
	
	private var _scoreText:FlxText;
	private var _fruit:FlxSprite;
	private var _snakeHead:FlxSprite;
	private var _snakeBody:FlxSpriteGroup;
	
	private var _headPositions:Array<FlxPoint>;
	private var _movementIntervall:Float = 8;
	private var _score:Int = 0;
	private var _blockSize:Int = 8;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		// Get the head piece from the body For easy later reference, and also visually change the colour a little
		var screenMiddleX:Int = Math.floor(FlxG.width / 2);
		var screenMiddleY:Int = Math.floor(FlxG.height / 2);
		
		// Start by creating the head of the snake
		_snakeHead = new FlxSprite(screenMiddleX - _blockSize * 2, screenMiddleY);
		_snakeHead.makeGraphic(_blockSize - 2, _blockSize - 2, FlxColor.LIME);
		
		_snakeHead.facing = FlxObject.LEFT;
		offestSprite(_snakeHead);
		
		// This array stores the recent head positions to update the segment positions step by step
		_headPositions = [FlxPoint.get(_snakeHead.x, _snakeHead.y)];
		
		// The group holding the body segments
		_snakeBody = new FlxSpriteGroup();
		add(_snakeBody);
		
		// Add 3 body segments to start off
		for (i in 0...3)
		{
			addSegment();
			// Move the snake to attach the segment to the head
			moveSnake();
		}
		
		// Add the snake's head last so it's on top
		add(_snakeHead);
		
		// Something to eat. We only ever need one _fruit, we can just reposition it.
		_fruit = new FlxSprite();
		_fruit.makeGraphic(_blockSize - 2, _blockSize - 2, FlxColor.RED);
		randomizeFruitPosition();
		offestSprite(_fruit);
		add(_fruit);
		
		// Simple score
		_scoreText = new FlxText(0, 0, 200, "Score: " + _score);
		add(_scoreText);
		
		// Setup the movement timer
		resetTimer();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Just a little fading effect for the score text
		if (_scoreText.alpha < 1)
		{
			_scoreText.alpha += 0.1;
		}
		
		// Only continue if we're still alive
		if (!_snakeHead.alive)
		{
			if (FlxG.keys.anyJustReleased([SPACE, R]))
			{
				FlxG.resetState();
			}
			
			return;
		}
		
		// Did we eat the _fruit?
		FlxG.overlap(_snakeHead, _fruit, collectFruit);
		
		// Did we hit ourself? If so, game over! :(
		FlxG.overlap(_snakeHead, _snakeBody, gameOver);
		
		// WASD / arrow keys to control the snake
		// Also make sure you can't travel in the opposite direction,
		// because that causes quick and frustrating deaths!
		if (FlxG.keys.anyPressed([UP, W]) && _snakeHead.facing != FlxObject.DOWN)
		{
			_snakeHead.facing = FlxObject.UP;
		}
		else if (FlxG.keys.anyPressed([DOWN, S]) && _snakeHead.facing != FlxObject.UP)
		{
			_snakeHead.facing = FlxObject.DOWN;
		}
		else if (FlxG.keys.anyPressed([LEFT, A]) && _snakeHead.facing != FlxObject.RIGHT)
		{
			_snakeHead.facing = FlxObject.LEFT;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]) && _snakeHead.facing != FlxObject.LEFT)
		{
			_snakeHead.facing = FlxObject.RIGHT;
		}
	}
	
	/**
	 * To get a nice little 2px gap between the tiles
	 */
	private function offestSprite(Sprite:FlxSprite):Void
	{
		Sprite.offset.set(1, 1);
		Sprite.centerOffsets();
	}
	
	private function updateText(NewText:String):Void
	{
		_scoreText.text = NewText;
		_scoreText.alpha = 0;
	}
	
	private function collectFruit(Object1:FlxObject, Object2:FlxObject):Void
	{
		// Update the score
		_score += 10;
		updateText("Score: " + _score);
		
		randomizeFruitPosition();
		
		// Our reward - a new segment! :)
		addSegment();
		FlxG.sound.load(FlxAssets.getSound("flixel/sounds/beep")).play();
		
		// Become faster each pickup - set a max speed though!
		if (_movementIntervall >= MIN_INTERVALL)
		{
			_movementIntervall -= 0.25;
		}
	}
	
	private function randomizeFruitPosition(?Object1:FlxObject, ?Object2:FlxObject):Void
	{
		// Pick a random place to put the _fruit down
		_fruit.x = FlxG.random.int(0, Math.floor(FlxG.width / 8) - 1) * 8;
		_fruit.y = FlxG.random.int(0, Math.floor(FlxG.height / 8) - 1) * 8;
		
		// Check that the coordinates we picked aren't already covering the snake, if they are then run this function again
		FlxG.overlap(_fruit, _snakeBody, randomizeFruitPosition);
	}
	
	private function gameOver(Object1:FlxObject, Object2:FlxObject):Void
	{
		_snakeHead.alive = false;
		updateText("Game Over - Space to restart!");
		FlxG.sound.play("assets/flixel.wav");
	}
	
	private function addSegment():Void
	{
		// Spawn the new segment outside of the screen
		// It'll be attached to the snake end in the next moveSnake() call
		var segment:FlxSprite = new FlxSprite( -20, -20);
		segment.makeGraphic(_blockSize - 2, _blockSize - 2, FlxColor.GREEN); 
		_snakeBody.add(segment);
	}
	
	private function resetTimer(?Timer:FlxTimer):Void
	{
		// Stop the movement cycle if we're dead
		if (!_snakeHead.alive && Timer != null)
		{
			Timer.destroy();
			return;
		}
		
		new FlxTimer().start(_movementIntervall / FlxG.updateFramerate, resetTimer);
		moveSnake();
	}
	
	private function moveSnake():Void
	{	
		_headPositions.unshift(FlxPoint.get(_snakeHead.x, _snakeHead.y));
		
		if (_headPositions.length > _snakeBody.members.length)
		{
			_headPositions.pop();
		}
		
		// Update the position of the head
		switch (_snakeHead.facing)
		{
			case FlxObject.LEFT:
				_snakeHead.x -= _blockSize;
			case FlxObject.RIGHT:
				_snakeHead.x += _blockSize;
			case FlxObject.UP:
				_snakeHead.y -= _blockSize;
			case FlxObject.DOWN:
				_snakeHead.y += _blockSize;
		}
		
		FlxSpriteUtil.screenWrap(_snakeHead);
		
		for (i in 0..._headPositions.length)
		{
			_snakeBody.members[i].setPosition(_headPositions[i].x, _headPositions[i].y);
		}
	}
}
