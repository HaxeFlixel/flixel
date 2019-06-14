package;

import flixel.FlxG;
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
class EndState extends FlxState
{
	var _gameTitle:FlxText;
	var _startButton:FlxButton;

	override public function create():Void
	{
		// Fade in to the scene from black
		FlxG.cameras.flash(FlxColor.BLACK, 1);

		// Show our mouse!
		FlxG.mouse.visible = true;

		// Add some text to the stage as we did earlier
		_gameTitle = new FlxText(10, 90, 300, "And so the journey begins!!");
		_gameTitle.setFormat(null, 16, FlxColor.WHITE, CENTER);
		add(_gameTitle);

		// Add a button which will take us back to the main menu state
		_startButton = new FlxButton(137, 195, "", onStart);
		// Load sprites for different button states
		_startButton.loadGraphic("assets/ok0.png");
		_startButton.onOver.callback = onStartOver;
		_startButton.onOut.callback = onStartOut;
		add(_startButton);
	}

	function onStartOut():Void
	{
		_startButton.loadGraphic("assets/ok0.png");
	}

	function onStartOver():Void
	{
		_startButton.loadGraphic("assets/ok1.png");
	}

	function onStart():Void
	{
		FlxG.cameras.fade(FlxColor.BLACK, 1, false, onFade);
	}

	function onFade():Void
	{
		FlxG.switchState(new MenuState());
	}
}
