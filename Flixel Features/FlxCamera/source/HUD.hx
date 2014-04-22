package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class HUD extends FlxGroup
{
	private var txtStyle:FlxText;
	private var txtLerp:FlxText;
	private var txtLead:FlxText;
	private var txtZoom:FlxText;
	public var background:FlxSprite;

	public function new() 
	{
		super();
		
		background = new FlxSprite(10000 - 50, -175, null);
		background.makeGraphic(300, 360, 0xFF000000);
		add(background);
		
		add(new FlxText(10010, 10, 200 - 10, "Use [W,A,S,D] to control the orb.\n\n[Y] or [H] to change camera style.\n\n\n\n[U] or [J] to change lerp.\n\n\n\n[I] or [K] to change lead.\n\n\n\n[O] or [L] to change zoom.")); 
		
		txtStyle = new FlxText(10010, 10 + 30 + 3, 190,  "STYLE_LOCKON");
		txtStyle.setFormat(null, 11, 0x55FF55, "left");
		add(txtStyle);
		
		txtLerp = new FlxText(10010, 50 + 30, 300,  "Camera lerp: 0");
		txtLerp.setFormat(null, 11, 0x55FF55, "left");
		add(txtLerp);
		
		txtLead = new FlxText(10010, 90 + 30, 300,  "Camera lead: 0");
		txtLead.setFormat(null, 11, 0x55FF55, "left");
		add(txtLead);

		txtZoom = new FlxText(10010, 130 + 30, 300,  "Camera zoom: 1");
		txtZoom.setFormat(null, 11, 0x55FF55, "left");
		add(txtZoom);
		
	}
	
	public function updateStyle(string:String) 
	{
		txtStyle.text = string;
	}
	
	public function updateCamLerp(lerp:Float) 
	{
		txtLerp.text = "Camera lerp: " + lerp;
	}
	
	public function updateCamLead(lead:Float) 
	{
		txtLead.text = "Camera lead: " + lead;
	}
	
	public function updateZoom(zoom:Float) 
	{
		//GameConsole.log("zoom  " + zoom);
		txtZoom.text = "Camera Zoom: " + Math.floor(zoom * 10) / 10;
	}
}