package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class HUD extends FlxGroup
{
	public var width:Int = 200;
	public var height:Int = 180;
	public var background:FlxSprite;
	
	private var txtStyle:FlxText;
	private var txtLerp:FlxText;
	private var txtLead:FlxText;
	private var txtZoom:FlxText;
	
	public function new() 
	{
		super();
		
		var x:Int = 10000;
		
		background = new FlxSprite(x, 0);
		background.makeGraphic(width, height, FlxColor.BLACK);
		add(background);
		
		x += 6;
		var startY:Int = 10;
		
		add(new FlxText(x, startY, width, "[W,A,S,D] or arrows to control the orb.")); 
		
		add(new FlxText(x, startY + 20, 300, "[H] to change follow style."));
		addGreenText(txtStyle = new FlxText(x, startY + 33, width, "LOCKON"));
		
		add(new FlxText(x, startY + 55, width, "[U] or [J] to change lerp."));
		addGreenText(txtLerp = new FlxText(x, startY + 68, width, "Camera lerp: 1"));
		
		add(new FlxText(x, startY + 95, width, "[I] or [K] to change lead."));
		addGreenText(txtLead = new FlxText(x, startY + 108, width, "Camera lead: 0"));
		
		add(new FlxText(x, startY + 135, width, "[O] or [L] to change zoom."));
		addGreenText(txtZoom = new FlxText(x, startY + 148, width, "Camera zoom: 1"));
	}
	
	private function addGreenText(text:FlxText)
	{
		text.setFormat(null, 11, 0x55FF55);
		add(text);
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
		txtZoom.text = "Camera Zoom: " + Math.floor(zoom * 10) / 10;
	}
}