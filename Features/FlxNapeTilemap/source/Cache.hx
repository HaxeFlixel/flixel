package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import gameobj.CustomNapeTilemap;

class Cache
{
    private static var levels = new Map<String, CustomNapeTilemap>();

    private static var tileGraphics:FlxGraphic;

    public static function init():Void
    {
        tileGraphics = FlxG.bitmap.add("assets/tiles.png");
    }

    public static function loadLevel(name: String, file: String):CustomNapeTilemap
    {
        if (levels.exists(name))
            return levels.get(name);
        var tilemap = new CustomNapeTilemap(file, tileGraphics, Constants.TILE_SIZE);
        levels.set(name, tilemap);
        return tilemap;
    }
}