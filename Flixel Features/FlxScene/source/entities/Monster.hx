package entities;

import flixel.FlxSprite;
import flixel.FlxG;

class Monster extends FlxSprite
{
    public function new()
    {
        super();

        loadGraphic("assets/monster.png");
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // simple movement so we know it's alive :D
        angle += 100 * elapsed;
    }

    override public function destroy():Void
    {
        super.destroy();
    }
}