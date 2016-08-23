package states;

import flixel.addons.nape.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
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
    var firstRun:Bool = false;
    var currentLevel:Level = FIRST;

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

    override public function create():Void
    {
        FlxG.mouse.visible = false;
        FlxG.camera.bgColor = FlxColor.WHITE;

        initSpace();
        loadLevel(currentLevel);

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

        var instructions = new FlxText(0, 50, FlxG.width,
            "Space to switch levels, Up / W to double-jump", 16);
        instructions.color = FlxColor.BLACK;
        instructions.alignment = FlxTextAlign.CENTER;
        add(instructions);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE)
        {
            loadLevel(switch (currentLevel)
            {
                case FIRST: SECOND;
                case SECOND: FIRST;
            });
        }
    }

    function loadLevel(file:Level)
    {
        currentLevel = file;

        if (level != null)
        {
            level.body.space = null;
            remove(level);
        }
        
        level = new CustomNapeTilemap(file, "assets/tiles.png", Constants.TILE_SIZE);
        level.body.setShapeMaterials(Constants.platformMaterial);
        level.spawnPoints.sortRandomly();
        add(level);
    }
}

@:enum abstract Level(String) to String
{
    var FIRST = "assets/testmap.csv";
    var SECOND = "assets/testmap2.csv";
}