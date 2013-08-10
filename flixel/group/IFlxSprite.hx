package flixel.group;
/**
 * The interface for properties of <code>FlxSprite</code>
 * It makes possible to add <code>FlxSpriteGroup</code> to <code>FlxSpriteGroup</code>
 **/
interface IFlxSprite extends IFlxBasic {
    public var x(default, set):Float;
    public var y(default, set):Float;
    public var alpha(default, set):Float;
}
