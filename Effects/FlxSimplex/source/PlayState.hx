package;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	// a FlxSprite to display the noise graphically
	var canvas:FlxSprite;
	// a helper class that holds the simplex noise info
	var helper:SimplexHelper;
	// a group to hold all UI stuff
	var hud:HUD;

	override public function create():Void
	{
		super.create();

		canvas = new FlxSprite(10, 10);
		canvas.makeGraphic(400, 400, 0x0, true);

		helper = new SimplexHelper(canvas);
		hud = new HUD();

		add(canvas);
		add(hud);

		updateAll();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// O/L, I/K, U/J, Y, H, and the arrow keys/WASD control the parameters of the noise
		// many key actions require the entire canvas to be redrawn with the new parameters, but some don't
		var regen = false;

		if (FlxG.keys.justPressed.O)
		{
			helper.scale *= 2;
			hud.updateScale(helper.scale);
			regen = true;
		}
		else if (FlxG.keys.justPressed.L)
		{
			helper.scale *= .5;
			hud.updateScale(helper.scale);
			regen = true;
		}

		if (helper.persistence < 1 && FlxG.keys.justPressed.I)
		{
			helper.persistence += .05;
			helper.persistence = FlxMath.roundDecimal(helper.persistence, 2);
			hud.updatePersistence(helper.persistence);
			regen = true;
		}
		else if (helper.persistence > .1 && FlxG.keys.justPressed.K)
		{
			helper.persistence -= .05;
			helper.persistence = FlxMath.roundDecimal(helper.persistence, 2);
			hud.updatePersistence(helper.persistence);
			regen = true;
		}

		if (FlxG.keys.justPressed.U)
		{
			helper.octaves++;
			hud.updateOctaves(helper.octaves);
			regen = true;
		}
		else if (helper.octaves > 1 && FlxG.keys.justPressed.J)
		{
			helper.octaves--;
			hud.updateOctaves(helper.octaves);
			regen = true;
		}

		if (FlxG.keys.justPressed.Y)
		{
			helper.tile = !helper.tile;
			hud.updateTiles(helper.tile);
			regen = true;
		}

		// Only used for `simplexTiles()`; simplexOctaves()` is implicitly seeded by the `x` and `y` parameters
		if (FlxG.keys.justPressed.H)
		{
			helper.seed = Std.random(1000000);
			hud.updateSeed(helper.seed);
			regen = true;
		}

		if (regen)
		{
			helper.regenSimplex();
		}
		else
		{
			// scroll the canvas around to explore the noise
			var dx = 0, dy = 0;

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.UP)
			{
				dy = 1;
			}
			else if (FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN)
			{
				dy = -1;
			}

			if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT)
			{
				dx = 1;
			}
			else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)
			{
				dx = -1;
			}

			if (dx != 0 || dy != 0)
			{
				helper.scrollSimplex(dx, dy);
				hud.updateX(helper.x);
				hud.updateY(helper.y);
			}
		}
	}

	/**
	 * Updates the HUD
	 */
	function updateAll():Void
	{
		hud.updateX(helper.x);
		hud.updateY(helper.y);
		hud.updateScale(helper.scale);
		hud.updatePersistence(helper.persistence);
		hud.updateOctaves(helper.octaves);
		hud.updateTiles(helper.tile);
		hud.updateSeed(helper.seed);
	}
}
