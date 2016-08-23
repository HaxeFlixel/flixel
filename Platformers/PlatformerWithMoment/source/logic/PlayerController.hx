package logic;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import nape.geom.Vec2;
import nape.phys.Body;
using logic.PhyUtil;

@: final
class PlayerController extends FlxBasic
{
    var playerbody: Body;
    var levelbody: Body;
    var onGround: Bool;
    var impg: Float;
    var impa: Float;
    var impj: Float;
    var remainJumps: Int;
    var maxJumps: Int;
    var keymap: PlayerControl;

    public function new(_playerbody: Body, _levelbody: Body,
                        control : PlayerControl = null,
                        impulse_ground : Float = 500, impulse_air : Float = 200,
                        impulse_jump : Float = 200)
    {
        super();
        playerbody = _playerbody;
        levelbody = _levelbody;
        impg = impulse_ground;
        impa = impulse_air;
        impj = impulse_jump;
        if (control == null) keymap = new PlayerControl([LEFT, A], [RIGHT, D], [UP, W]);
        else
            keymap = control;
        maxJumps = 2;
    }

    override public function update(dt: Float)
    {
        var impulse = new Vec2();
        onGround = playerbody.onTop();
#if debug
        FlxG.watch.addQuick("On Ground", onGround);
#end

        var _optimp: Float;
        if (onGround) _optimp = impg;
        else _optimp = impa;
        var totalx = 0.0;
        if (FlxG.keys.anyPressed(keymap.b_left))
            totalx = -_optimp;
        else if (FlxG.keys.anyPressed(keymap.b_right))
            totalx = _optimp;
        else
            totalx = 0;
        impulse.x = totalx * dt;
        if (onGround)
            remainJumps = maxJumps;
        if (FlxG.keys.anyJustPressed(keymap.b_jump) && remainJumps>0 )
        {
            impulse.y = -impj;
            remainJumps--;
        }
        playerbody.applyImpulse(impulse);
    }
}


class PlayerControl
{
    public var b_left: Array<FlxKey>;
    public var b_right: Array<FlxKey>;
    public var b_jump: Array<FlxKey>;

    public function new(btnleft: Array<FlxKey>, btnright: Array<FlxKey>,
                        btnjump: Array<FlxKey>)
    {
        b_left = btnleft;
        b_right = btnright;
        b_jump = btnjump;
    }
}