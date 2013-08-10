package flixel.group;

/**
 *  This class is for <code>FlxTypedGroup</code> to work with interface instead of <code>FlxBasic</code>, which is needed
 *  so that <code>FlxSpriteGroup</code> could extend <code>FlxTypedGroup</code> and be typed with <code>IFlxSprite</code>
 **/
interface IFlxBasic {
    public var exists:Bool;
    public var alive:Bool;
}
