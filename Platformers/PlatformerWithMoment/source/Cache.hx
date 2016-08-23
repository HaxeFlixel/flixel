package;

using logic.PhyUtil;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import gameobj.CustomNapeTilemap;
import nape.geom.Vec2;
import nape.phys.Material;

/**
 * Handy, pre-built Registry class that can be used to store
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Cache
{
    /**
     * Generic levels Array that can be used for cross-state stuff.
     * Example usage: Storing the levels of a platformer.
    */
    public static var tilegraphics: FlxGraphic;

    public static function init(): Void
    {
        tilegraphics = FlxG.bitmap.add("assets/tiles.png");
    }

    public static function loadLevel(name: String, file: String): CustomNapeTilemap
    {
        if (levels.exists(name))
            return levels.get(name);
        var tilemap = new CustomNapeTilemap(file, tilegraphics, Constants.TILESIZE);
        levels.set(name, tilemap);
        return tilemap;
    }

    public static var levels = new Map<String, CustomNapeTilemap>();
}