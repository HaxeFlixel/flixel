package states;

import flixel.addons.nape.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import gameobj.CustomNapeTilemap;
import gameobj.Player;
import logic.PhysUtil;
import logic.PlayerController;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.PreListener;
using logic.MathUtil;

class PlayState extends FlxState
{
    var allPlayers = new FlxGroup();
    var level:CustomNapeTilemap;

    function initSpace():Void
    {
        FlxNapeSpace.init();
        FlxNapeSpace.space.gravity.setxy(0, 2000);
        Constants.oneWayType = new CbType();

        FlxNapeSpace.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
            Constants.oneWayType,
            CbType.ANY_BODY,
            PhysUtil.oneWayHandler,
            0, true
        ));
    }

    override public function create(): Void
    {
        Cache.init();
        initSpace();
        FlxG.camera.bgColor = FlxColor.WHITE;
        level = Cache.loadLevel("default", "assets/testmap.csv");
        level.body.setShapeMaterials(Constants.platformMaterial);
        level.spawnPoints.sortRandomly();
        add(level);

        var player = new Player(0, 0, FlxColor.BLUE);
        var playerCtrl = new PlayerController(player.body, level.body,
            new PlayerControls([LEFT], [RIGHT], [UP]));
        var point = level.spawnPoints[0];
        player.setPosition(point.x, point.y - player.height * 0.5);
        add(player);
        add(playerCtrl);

        player = new Player(0, 0, FlxColor.RED);
        playerCtrl = new PlayerController(player.body, level.body,
            new PlayerControls([A], [D], [W]));
        point = level.spawnPoints[1];
        player.setPosition(point.x, point.y - player.height * 0.5);
        add(player);
        add(playerCtrl);
    }
}
