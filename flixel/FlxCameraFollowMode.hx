package flixel.system;

/**
 * Camera following modes.
 * 
 * Abstracted from an Int type for fast comparrison code:
 * http://nadako.tumblr.com/post/64707798715/cool-feature-of-upcoming-haxe-3-2-enum-abstracts
 */
 @:enum
 abstract FlxCameraFollowMode(Int)
 {
    /**
     * Camera has no deadzone, just tracks the focus object directly.
     */
     var STYLE_LOCKON           = 0;
    /**
     * Camera's deadzone is narrow but tall.
     */
     var STYLE_PLATFORMER       = 1;
        /**
     * Camera's deadzone is a medium-size square around the focus object.
     */
     var STYLE_TOPDOWN          = 2;
    /**
     * Camera's deadzone is a small square around the focus object.
     */
     var STYLE_TOPDOWN_TIGHT    = 3;
    /**
     * Camera will move screenwise.
     */
     var STYLE_SCREEN_BY_SCREEN = 4;
    /**
     * Camera has no deadzone, just tracks the focus object directly and centers it.
     */
     var STYLE_NO_DEAD_ZONE     = 5;

}
