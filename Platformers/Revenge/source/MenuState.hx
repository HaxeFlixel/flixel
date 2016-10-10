package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * Copyright (c) 2010 Yadu Rajiv
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source
 * distribution.
 */
class MenuState extends FlxState
{
	private var _gameTitle:FlxText;
	private var _bg:FlxSprite;
	private var _bgEye:FlxSprite;
	private var _startButton:FlxButton;
	
	override public function create():Void 
	{
		// Fade in from black
		FlxG.cameras.flash(FlxColor.BLACK, 3);
		FlxG.mouse.visible = true;
		
		// Add the game text and set some formatting options along with a shadow; you can also
		// pass in your own font if you have one embedded or it uses Flixel's default one
		_gameTitle = new FlxText(10, 90, 300, "Revenge of the Eye from Outer Space!");
		_gameTitle.setFormat(null, 16, FlxColor.WHITE, CENTER);
		add(_gameTitle);
		
		// Adding the background image 320x240
		_bg = new FlxSprite(0, 0, "assets/bg.png");
		add(_bg);
		
		// Adding the alien eye image and adding constant angular velocity of 40 also limiting
		// the maxAngular to 40
		_bgEye = new FlxSprite(137, 100, "assets/bg_eye_float.png");
		_bgEye.angularVelocity = 40;
		_bgEye.maxAngular = 40;
		// Make it look a bit smoother
		_bgEye.antialiasing = true;
		add(_bgEye);
		
		// Adding a button with an anon call back function
		_startButton = new FlxButton(137, 195, "", onStart);
		// We add a couple of sprites to the button to act as normal and mouseover states
		_startButton.loadGraphic("assets/btnStart0.png");
		_startButton.onOver.callback = onStartOver;
		_startButton.onOut.callback = onStartOut;
		add(_startButton);
		
		// Some credit text
		add(new FlxText(280, 200, 40, "by Yadu Rajiv"));
	}
	
	private function onStart():Void
	{
		FlxG.cameras.fade(FlxColor.BLACK, 1, false, onFade);
	}
	
	private function onFade():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function onStartOver():Void
	{
		_startButton.loadGraphic("assets/btnStart1.png");
	}
	
	private function onStartOut():Void
	{
		_startButton.loadGraphic("assets/btnStart0.png");
	}
}